import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:open_source_software/models/campus_building.dart';
import 'package:open_source_software/api/api_client.dart';

/// 캠퍼스 건물 단위 위치를 관리하는 매니저 (싱글톤 + ChangeNotifier).
///
/// 하는 일:
///  1. 앱 시작 시 assets 의 GeoJSON 을 읽어 17개 건물 폴리곤을 로드
///  2. geolocator 위치 스트림을 구독해 GPS 변화를 추적
///  3. 좌표가 들어올 때마다 어느 건물에 속하는지 판별
///  4. Dwell Time(5초) 동안 연속 체류한 건물만 "현재 건물"로 확정
///  5. 건물이 바뀐 순간에만 notifyListeners() 호출 + onBuildingChanged 콜백
///  6. 건물 전환 시 서버에 위치를 전송 (현재는 연결 지점만 마련, 8단계 갈래1)
///
/// 기존 TestDataManager 와 동일하게 싱글톤 + ChangeNotifier 패턴을 따른다.

class BuildingNameTransfer {
  static const Map<String, String> _koreanToCode = {
    '정보문화관': 'INFO_CULTURE',
    '원흥관': 'WONHEUNG',
    '만해광장': 'MANHAE_PLAZA',
    '학림관': 'HAKRIM',
    '금강관': 'GEUMGANG',
    '본관': 'MAIN_BUILDING',
    '팔정도': 'PALJEONGDO',
    '신공학관': 'SHINGONG',
    '중앙도서관': 'CENTRAL_LIBRARY',
    '명진관': 'MYUNGJIN',
    '과학관': 'SCIENCE',
    '대운동장': 'MAIN_STADIUM',
    '조소관': 'SCULPTURE',
    '법학관': 'LAW_SCHOOL',
    '혜화관': 'HYEHWA',
    '사회과학관': 'SOCIAL_SCIENCE',
    '문화관': 'CULTURE',
  };

  /// 한글 건물명 → 영어 코드 (예: '정보문화관' → 'INFO_CULTURE').
  /// 매핑에 없는 값은 원본 문자열을 그대로 반환.
  static String toCode(String korean) => _koreanToCode[korean] ?? korean;
}

class LocationManager extends ChangeNotifier {
  // ── 싱글톤 ──────────────────────────────────────────────
  static final LocationManager _instance = LocationManager._internal();
  factory LocationManager() => _instance;
  LocationManager._internal();

  // ── 상수 ───────────────────────────────────────────────

  /// GeoJSON asset 경로 (pubspec.yaml 에 등록된 경로와 일치해야 함)
  static const String _geoJsonAssetPath = 'assets/dongguk_campus.geojson';

  /// Dwell Time — 새 건물에 이 시간 이상 연속 체류해야 건물 전환을 확정한다.
  /// 경계에서 GPS 가 미세하게 튕기는 바운싱(핑퐁) 현상을 걸러낸다.
  static const Duration _dwellTime = Duration(seconds: 5);

  // ── 상태 ───────────────────────────────────────────────

  /// 로드된 17개 캠퍼스 건물
  final List<CampusBuilding> _buildings = [];

  /// 현재 확정된 건물. 건물 밖이면 null.
  CampusBuilding? _currentBuilding;

  /// Dwell Time 판정 대기 중인 후보 건물.
  CampusBuilding? _candidateBuilding;

  /// 후보 건물이 처음 감지된 시각.
  DateTime? _candidateSince;

  /// geolocator 위치 스트림 구독 핸들.
  StreamSubscription<Position>? _positionSub;

  bool _isInitialized = false;

  // ── 외부 공개 ───────────────────────────────────────────

  /// 현재 확정된 건물명. 건물 밖이거나 아직 미확정이면 null.
  String? get currentBuildingName => _currentBuilding?.name;

  /// 현재 확정된 건물 객체.
  CampusBuilding? get currentBuilding => _currentBuilding;

  /// 초기화 완료 여부.
  bool get isInitialized => _isInitialized;

  /// 로드된 모든 건물 이름 목록. initialize() 완료 전이면 빈 리스트.
  List<String> get buildingNames => _buildings.map((b) => b.name).toList();

  /// 건물이 바뀐 순간 호출되는 콜백.
  ///
  /// 화면 등 외부에서 추가 동작이 필요할 때 등록한다.
  /// 인자는 새 건물명이며, 건물 밖으로 나간 경우 null 이 전달된다.
  void Function(String? newBuildingName)? onBuildingChanged;

  // ── 초기화 ──────────────────────────────────────────────

  /// 앱 시작 시 1회 호출.
  ///
  /// GeoJSON 로드 → 위치 권한 확인 → 위치 스트림 구독 순으로 진행한다.
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[Location] 이미 초기화됨 — 중복 호출 무시');
      return;
    }

    await _loadBuildings();

    final bool permitted = await _ensurePermission();
    if (!permitted) {
      debugPrint('[Location] 위치 권한 없음 — 스트림 구독 생략');
      // 권한이 없어도 초기화 자체는 완료 처리한다.
      // 이후 사용자가 권한을 허용하면 startTracking() 으로 재시도 가능.
      _isInitialized = true;
      return;
    }

    _startTracking();
    _isInitialized = true;
    debugPrint('[Location] 초기화 완료 — 건물 ${_buildings.length}개 로드');
  }

  /// GeoJSON asset 을 읽어 _buildings 에 17개 건물을 채운다. (4단계)
  Future<void> _loadBuildings() async {
    try {
      final String raw = await rootBundle.loadString(_geoJsonAssetPath);
      final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
      final List<dynamic> features = json['features'] as List<dynamic>;

      _buildings.clear();
      for (final feature in features) {
        _buildings.add(
          CampusBuilding.fromGeoJsonFeature(feature as Map<String, dynamic>),
        );
      }
      debugPrint('[Location] GeoJSON 로드 성공 — ${_buildings.length}개 건물');
    } catch (e) {
      debugPrint('[Location] GeoJSON 로드 실패: $e');
    }
  }

  /// 위치 서비스 활성화 및 권한을 확인한다. (geolocator 표준 절차)
  Future<bool> _ensurePermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  // ── 위치 추적 ───────────────────────────────────────────

  /// 위치 스트림 구독을 시작한다.
  void _startTracking() {
    // distanceFilter: 5m 이상 이동했을 때만 콜백 — 불필요한 갱신을 줄인다.
    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onPositionUpdate);
  }

  /// 권한 허용 후 외부에서 추적을 재시도할 때 사용.
  Future<void> startTracking() async {
    if (_positionSub != null) return; // 이미 추적 중
    final bool permitted = await _ensurePermission();
    if (permitted) _startTracking();
  }

  /// 새 GPS 좌표가 들어올 때마다 호출된다.
  void _onPositionUpdate(Position position) {
    final LatLng point = LatLng(position.latitude, position.longitude);
    final CampusBuilding? detected = _detectBuilding(point);
    _applyDwellTime(detected);
  }

  /// 좌표가 어느 건물에 속하는지 판별한다. (5단계)
  ///
  /// 17개 폴리곤을 순회해 첫 번째로 포함되는 건물을 반환한다.
  /// 폴리곤이 겹치는 경우 리스트 순서상 먼저 나온 건물이 우선한다.
  /// 어느 건물에도 속하지 않으면 null(건물 밖)을 반환한다.
  CampusBuilding? _detectBuilding(LatLng point) {
    for (final building in _buildings) {
      if (building.contains(point)) return building;
    }
    return null;
  }

  /// Dwell Time 로직으로 건물 전환을 확정한다. (5단계 - 바운싱 방지)
  ///
  /// 감지된 건물이 현재 건물과 같으면 후보를 초기화하고 끝낸다.
  /// 다르면 후보로 잡아두고, 같은 후보가 5초 이상 유지될 때만 확정한다.
  void _applyDwellTime(CampusBuilding? detected) {
    // 감지 결과가 이미 확정된 현재 건물과 같음 → 후보 취소, 변화 없음
    if (detected?.name == _currentBuilding?.name) {
      _candidateBuilding = null;
      _candidateSince = null;
      return;
    }

    // 새로운 후보가 등장했거나, 후보가 바뀜 → 타이머 리셋
    if (detected?.name != _candidateBuilding?.name) {
      _candidateBuilding = detected;
      _candidateSince = DateTime.now();
      return;
    }

    // 같은 후보가 계속 유지되는 중 → 체류 시간이 Dwell Time 을 넘었는지 확인
    final since = _candidateSince;
    if (since == null) return;
    if (DateTime.now().difference(since) >= _dwellTime) {
      _confirmBuildingChange(detected);
    }
  }

  /// 건물 전환을 확정하고 외부에 알린다.
  void _confirmBuildingChange(CampusBuilding? newBuilding) {
    _currentBuilding = newBuilding;
    _candidateBuilding = null;
    _candidateSince = null;

    debugPrint('[Location] 건물 전환 확정 → ${newBuilding?.name ?? "건물 밖"}');

    // UI 자동 갱신 (ListenableBuilder 등이 반응)
    notifyListeners();

    // 서버에 위치 전송 (8단계)
    _sendLocationToServer(newBuilding?.name);

    // 외부 콜백 (화면 등에서 추가 동작이 필요할 때)
    onBuildingChanged?.call(newBuilding?.name);
  }

  // ── 서버 전송 (8단계 - 갈래 1) ───────────────────────────

  /// 건물 전환 시 서버에 현재 위치를 전송한다.
  ///
  /// 백엔드 위치 API 가 아직 확정되지 않아, 현재는 로그만 남긴다.
  /// 백엔드 연결 시 아래 주석 처리된 코드를 살리면 된다.
  ///
  /// API 명세: PATCH /users/location, body: { "currentBuilding": "원흥관" }
  Future<void> _sendLocationToServer(String? buildingName) async {
    if (buildingName == null) {
      debugPrint('[Location] 건물 밖 — 서버 전송 생략');
      return;
    }

    debugPrint('[Location] (예정) 서버로 위치 전송 → $buildingName');

    // ── 백엔드 연결 시 아래 주석을 해제하세요 ──────────────────
    //
    try {
      await ApiClient().dio.patch(
        '/api/v1/users/location',
        data: {'currentBuilding': BuildingNameTransfer.toCode(buildingName)},
      );
      debugPrint('[Location] 서버 위치 갱신 성공 → $buildingName');
    } catch (e) {
      debugPrint('[Location] 서버 위치 갱신 실패: $e');
    }

    // ─────────────────────────────────────────────────────
  }

  // ── 정리 ───────────────────────────────────────────────

  /// 위치 추적을 멈춘다. (로그아웃 등 필요 시 호출)
  void stopTracking() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
