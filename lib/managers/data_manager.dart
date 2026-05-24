import 'package:flutter/material.dart';
import 'package:open_source_software/api/mock_server_interceptor.dart';
import 'package:open_source_software/models/building.dart';
import 'package:open_source_software/models/chat.dart';
import 'package:open_source_software/models/chatting.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/models/place.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';

enum CacheType { users, reviews, chattings, matches, rentalItems }

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  DataManager._internal() {
    _refreshAllSync();
  }

  // ── 건물 목록 (고정값) ────────────────────────────────────────────────────────
  // GeoJSON의 [경도, 위도] 순서를 LatLng(위도, 경도)로 변환
  static final List<Place> places = [
    Building(
      id: '정보문화관',
      name: '정보문화관',
      area: GeofencePolygonRegion(
        id: '정보문화관',
        polygon: [
          LatLng(37.5603386, 126.9983113),
          LatLng(37.5601445, 126.9988615),
          LatLng(37.5599687, 126.998703),
          LatLng(37.5595234, 126.9988384),
          LatLng(37.5592791, 126.9986541),
          LatLng(37.5592837, 126.9985072),
          LatLng(37.559528, 126.9984496),
          LatLng(37.5595234, 126.9982364),
          LatLng(37.5597769, 126.9982508),
          LatLng(37.5597655, 126.9980377),
          LatLng(37.5599185, 126.998029),
          LatLng(37.5599299, 126.9982019),
          LatLng(37.5600418, 126.9981529),
        ],
      ),
      neighbor: ["학림관", "원흥관", "만해광장"],
    ),
    Building(
      id: '원흥관',
      name: '원흥관',
      area: GeofencePolygonRegion(
        id: '원흥관',
        polygon: [
          LatLng(37.5595334, 126.9984459),
          LatLng(37.5595182, 126.9981949),
          LatLng(37.5591035, 126.9982619),
          LatLng(37.558783, 126.9986969),
          LatLng(37.5585005, 126.9985819),
          LatLng(37.5583668, 126.999082),
          LatLng(37.5588392, 126.999287),
          LatLng(37.5590397, 126.9992334),
          LatLng(37.5591111, 126.9992602),
          LatLng(37.5595334, 126.9988387),
          LatLng(37.5592843, 126.9986509),
          LatLng(37.5592888, 126.998511),
        ],
      ),
      neighbor: ["정보문화관", "만해광장", "신공학관", "본관"],
    ),
    Building(
      id: '만해광장',
      name: '만해광장',
      area: GeofencePolygonRegion(
        id: '만해광장',
        polygon: [
          LatLng(37.5601505, 126.9988541),
          LatLng(37.5603146, 126.9990057),
          LatLng(37.5600396, 127.000067),
          LatLng(37.5592283, 126.99993),
          LatLng(37.5591821, 126.9998863),
          LatLng(37.5591113, 126.9992544),
          LatLng(37.5595294, 126.9988374),
          LatLng(37.5599713, 126.9986982),
        ],
      ),
      neighbor: ["학림관", "원흥관", "정보문화관", "금강관", "본관"],
    ),
    Building(
      id: '학림관',
      name: '학림관',
      area: GeofencePolygonRegion(
        id: '학림관',
        polygon: [
          LatLng(37.5601473, 126.9988492),
          LatLng(37.5602331, 126.9986064),
          LatLng(37.5605813, 126.998911),
          LatLng(37.5606548, 126.9992333),
          LatLng(37.5604448, 127.0000941),
          LatLng(37.5604728, 127.0005179),
          LatLng(37.5600354, 127.0003634),
          LatLng(37.5600844, 127.0000897),
          LatLng(37.5600406, 127.0000632),
          LatLng(37.5603118, 126.9990081),
        ],
      ),
      neighbor: ["정보문화관", "만해광장", "금강관"],
    ),
    Building(
      id: '금강관',
      name: '금강관',
      area: GeofencePolygonRegion(
        id: '금강관',
        polygon: [
          LatLng(37.5591842, 126.9998723),
          LatLng(37.5592194, 127.0003131),
          LatLng(37.5599118, 127.0005678),
          LatLng(37.5598669, 127.0007862),
          LatLng(37.5602751, 127.0008359),
          LatLng(37.5604948, 127.0007476),
          LatLng(37.5604743, 127.000515),
          LatLng(37.5600389, 127.000362),
          LatLng(37.5600884, 127.0000863),
          LatLng(37.560044, 127.0000622),
          LatLng(37.5592298, 126.9999292),
        ],
      ),
      neighbor: ["학림관", "만해광장", "본관"],
    ),
    Building(
      id: '본관',
      name: '본관',
      area: GeofencePolygonRegion(
        id: '본관',
        polygon: [
          LatLng(37.5583752, 126.9990737),
          LatLng(37.5582283, 126.9991064),
          LatLng(37.5580658, 126.9996516),
          LatLng(37.55893, 127.0000478),
          LatLng(37.5591467, 126.9999751),
          LatLng(37.559197, 126.9999899),
          LatLng(37.5591148, 126.9992562),
          LatLng(37.5590409, 126.9992297),
          LatLng(37.5588412, 126.9992848),
        ],
      ),
      neighbor: ["금강관", "만해광장", "신공학관", "원흥관", "중앙도서관", "팔정도", "명진관"],
    ),
    Building(
      id: '팔정도',
      name: '팔정도',
      area: GeofencePolygonRegion(
        id: '팔정도',
        polygon: [
          LatLng(37.5589256, 127.0000472),
          LatLng(37.5588318, 127.0004159),
          LatLng(37.5587963, 127.000407),
          LatLng(37.558683, 127.0007131),
          LatLng(37.5584988, 127.0009007),
          LatLng(37.5583429, 127.0007376),
          LatLng(37.5577974, 127.0005164),
          LatLng(37.55804, 126.9996406),
        ],
      ),
      neighbor: ["본관", "중앙도서관", "명진관", "법학관"],
    ),
    Building(
      id: '신공학관',
      name: '신공학관',
      area: GeofencePolygonRegion(
        id: '신공학관',
        polygon: [
          LatLng(37.5585044, 126.9985812),
          LatLng(37.5585682, 126.9983396),
          LatLng(37.5586278, 126.9983396),
          LatLng(37.5587101, 126.9980533),
          LatLng(37.5586874, 126.9980211),
          LatLng(37.5587101, 126.9979245),
          LatLng(37.5584916, 126.9975541),
          LatLng(37.5583441, 126.9975165),
          LatLng(37.5579753, 126.9978762),
          LatLng(37.5578037, 126.9983772),
          LatLng(37.557859, 126.9986456),
          LatLng(37.5583725, 126.999075),
        ],
      ),
      neighbor: ["원흥관", "중앙도서관", "본관"],
    ),
    Building(
      id: '중앙도서관',
      name: '중앙도서관',
      area: GeofencePolygonRegion(
        id: '중앙도서관',
        polygon: [
          LatLng(37.5578629, 126.9986408),
          LatLng(37.5575158, 126.9987731),
          LatLng(37.5574061, 126.9991865),
          LatLng(37.5575917, 126.999325),
          LatLng(37.5580114, 126.9994879),
          LatLng(37.5580411, 126.9996407),
          LatLng(37.5580677, 126.9996538),
          LatLng(37.5582292, 126.9991061),
          LatLng(37.5583729, 126.9990755),
        ],
      ),
      neighbor: ["신공학관", "본관", "팔정도", "명진관", "과학관"],
    ),
    Building(
      id: '명진관',
      name: '명진관',
      area: GeofencePolygonRegion(
        id: '명진관',
        polygon: [
          LatLng(37.558042, 126.9996354),
          LatLng(37.5577979, 127.0005173),
          LatLng(37.5577179, 127.0006053),
          LatLng(37.5572921, 127.0004934),
          LatLng(37.5575907, 126.9993191),
          LatLng(37.558014, 126.9994853),
        ],
      ),
      neighbor: ["중앙도서관", "팔정도", "법학관", "과학관", "본관"],
    ),
    Building(
      id: '과학관',
      name: '과학관',
      area: GeofencePolygonRegion(
        id: '과학관',
        polygon: [
          LatLng(37.5575932, 126.9993204),
          LatLng(37.5574076, 126.999184),
          LatLng(37.5574134, 126.9991066),
          LatLng(37.5572702, 126.9991619),
          LatLng(37.5571153, 126.9991121),
          LatLng(37.5570349, 126.9991066),
          LatLng(37.5569107, 126.9991951),
          LatLng(37.5568537, 126.9992024),
          LatLng(37.5567397, 126.9995509),
          LatLng(37.5567291, 126.9998532),
          LatLng(37.556957, 127.0000744),
          LatLng(37.5568986, 127.0004026),
          LatLng(37.5572961, 127.000491),
        ],
      ),
      neighbor: ["중앙도서관", "명진관", "법학관", "대운동장"],
    ),
    Building(
      id: '대운동장',
      name: '대운동장',
      area: GeofencePolygonRegion(
        id: '대운동장',
        polygon: [
          LatLng(37.5567378, 126.9998478),
          LatLng(37.5562053, 126.9996299),
          LatLng(37.5558367, 127.0012879),
          LatLng(37.5567218, 127.0014811),
          LatLng(37.5569604, 127.0000702),
        ],
      ),
      neighbor: ["법학관", "과학관", "혜화관", "조소관"],
    ),
    Building(
      id: '조소관',
      name: '조소관',
      area: GeofencePolygonRegion(
        id: '조소관',
        polygon: [
          LatLng(37.5567246, 127.0014714),
          LatLng(37.5565439, 127.0027059),
          LatLng(37.5563582, 127.0026755),
          LatLng(37.5561582, 127.0024262),
          LatLng(37.5558761, 127.0022863),
          LatLng(37.5558352, 127.0012859),
        ],
      ),
      neighbor: ["대운동장", "혜화관", "사회과학관"],
    ),
    Building(
      id: '법학관',
      name: '법학관',
      area: GeofencePolygonRegion(
        id: '법학관',
        polygon: [
          LatLng(37.5585057, 127.0008898),
          LatLng(37.55843, 127.0011539),
          LatLng(37.5582805, 127.0012272),
          LatLng(37.5581626, 127.0015956),
          LatLng(37.5567717, 127.0011682),
          LatLng(37.5569042, 127.0003915),
          LatLng(37.5577168, 127.0005992),
          LatLng(37.5577991, 127.0005089),
          LatLng(37.5583575, 127.0007437),
        ],
      ),
      neighbor: ["팔정도", "명진관", "과학관", "대운동장", "혜화관"],
    ),
    Building(
      id: '혜화관',
      name: '혜화관',
      area: GeofencePolygonRegion(
        id: '혜화관',
        polygon: [
          LatLng(37.558169, 127.0015795),
          LatLng(37.5581994, 127.0019373),
          LatLng(37.5580238, 127.0024272),
          LatLng(37.5566425, 127.0020694),
          LatLng(37.5567743, 127.0011705),
        ],
      ),
      neighbor: ["법학관", "대운동장", "조소관", "사회과학관"],
    ),
    Building(
      id: '사회과학관',
      name: '사회과학관',
      area: GeofencePolygonRegion(
        id: '사회과학관',
        polygon: [
          LatLng(37.5565526, 127.0027028),
          LatLng(37.5572651, 127.0035141),
          LatLng(37.5574455, 127.0027028),
          LatLng(37.5585097, 127.0029654),
          LatLng(37.558283, 127.0026211),
          LatLng(37.5583801, 127.0023818),
          LatLng(37.5581488, 127.0021017),
          LatLng(37.5580239, 127.002411),
          LatLng(37.5566451, 127.0020608),
        ],
      ),
      neighbor: ["문화관", "조소관", "혜화관"],
    ),
    Building(
      id: '문화관',
      name: '문화관',
      area: GeofencePolygonRegion(
        id: '문화관',
        polygon: [
          LatLng(37.5585169, 127.0029414),
          LatLng(37.5588315, 127.0033208),
          LatLng(37.5588222, 127.0035659),
          LatLng(37.5581837, 127.0038869),
          LatLng(37.5572584, 127.0035134),
          LatLng(37.5574435, 127.0026905),
        ],
      ),
      neighbor: ["사회과학관"],
    ),
  ];

  static Place? placeById(String id) {
    for (final p in places) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ── 캐시 TTL 상수 ──────────────────────────────────────────────────────────
  static const _ttlUsers = Duration(minutes: 10);
  static const _ttlReviews = Duration(minutes: 5);
  static const _ttlChattings = Duration(seconds: 30);
  static const _ttlMatches = Duration(minutes: 1);
  static const _ttlRentalItems = Duration(minutes: 1);

  // ── 캐시 데이터 ──────────────────────────────────────────────────────────────
  Map<String, User> _users = {};
  Map<String, Review> _reviews = {};
  Map<String, Chatting> _chattings = {};
  Map<String, Match> _matches = {};
  Map<String, RentalItem> _rentalItems = {};

  // ── 캐시 타임스탬프 ──────────────────────────────────────────────────────────
  DateTime? _usersLastFetchedAt;
  DateTime? _reviewsLastFetchedAt;
  DateTime? _chattingsLastFetchedAt;
  DateTime? _matchesLastFetchedAt;
  DateTime? _rentalItemsLastFetchedAt;

  // ── 게터 (TTL 만료 시 lazy refresh) ──────────────────────────────────────────
  Map<String, User> get users {
    if (_isCacheStale(_usersLastFetchedAt, _ttlUsers)) {
      refreshCache(CacheType.users);
      _scheduleChangeData();
    }
    return _users;
  }

  Map<String, Review> get reviews {
    if (_isCacheStale(_reviewsLastFetchedAt, _ttlReviews)) {
      refreshCache(CacheType.reviews);
      _scheduleChangeData();
    }
    return _reviews;
  }

  Map<String, Chatting> get chattings {
    if (_isCacheStale(_chattingsLastFetchedAt, _ttlChattings)) {
      refreshCache(CacheType.chattings);
      _scheduleChangeData();
    }
    return _chattings;
  }

  Map<String, Match> get matches {
    if (_isCacheStale(_matchesLastFetchedAt, _ttlMatches)) {
      refreshCache(CacheType.matches);
      _scheduleChangeData();
    }
    return _matches;
  }

  Map<String, RentalItem> get rentalItems {
    if (_isCacheStale(_rentalItemsLastFetchedAt, _ttlRentalItems)) {
      refreshCache(CacheType.rentalItems);
      _scheduleChangeData();
    }
    return _rentalItems;
  }

  // ── 캐시 유틸리티 ──────────────────────────────────────────────────────────
  bool _isCacheStale(DateTime? lastFetch, Duration ttl) {
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > ttl;
  }

  bool _pendingChangeData = false;
  void _scheduleChangeData() {
    if (_pendingChangeData) return;
    _pendingChangeData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingChangeData = false;
      changeData();
    });
  }

  void invalidateCache(CacheType type) {
    switch (type) {
      case CacheType.users:
        _usersLastFetchedAt = null;
      case CacheType.reviews:
        _reviewsLastFetchedAt = null;
      case CacheType.chattings:
        _chattingsLastFetchedAt = null;
      case CacheType.matches:
        _matchesLastFetchedAt = null;
      case CacheType.rentalItems:
        _rentalItemsLastFetchedAt = null;
    }
  }

  void refreshCache(CacheType type) {
    final server = MockServerInterceptor();
    switch (type) {
      case CacheType.users:
        _users = server.usersSnapshot;
        _usersLastFetchedAt = DateTime.now();
      case CacheType.reviews:
        _reviews = server.reviewsSnapshot;
        _reviewsLastFetchedAt = DateTime.now();
      case CacheType.chattings:
        _chattings = server.chattingsSnapshot;
        _chattingsLastFetchedAt = DateTime.now();
      case CacheType.matches:
        _matches = server.matchesSnapshot;
        _matchesLastFetchedAt = DateTime.now();
      case CacheType.rentalItems:
        _rentalItems = server.rentalItemsSnapshot;
        _rentalItemsLastFetchedAt = DateTime.now();
    }
  }

  void refreshIfStale(CacheType type) {
    final bool stale;
    switch (type) {
      case CacheType.users:
        stale = _isCacheStale(_usersLastFetchedAt, _ttlUsers);
      case CacheType.reviews:
        stale = _isCacheStale(_reviewsLastFetchedAt, _ttlReviews);
      case CacheType.chattings:
        stale = _isCacheStale(_chattingsLastFetchedAt, _ttlChattings);
      case CacheType.matches:
        stale = _isCacheStale(_matchesLastFetchedAt, _ttlMatches);
      case CacheType.rentalItems:
        stale = _isCacheStale(_rentalItemsLastFetchedAt, _ttlRentalItems);
    }
    if (stale) refreshCache(type);
  }

  void initCache() {
    _refreshAllSync();
    changeData();
  }

  void _refreshAllSync() {
    final server = MockServerInterceptor();
    final now = DateTime.now();
    _users = server.usersSnapshot;
    _usersLastFetchedAt = now;
    _reviews = server.reviewsSnapshot;
    _reviewsLastFetchedAt = now;
    _chattings = server.chattingsSnapshot;
    _chattingsLastFetchedAt = now;
    _matches = server.matchesSnapshot;
    _matchesLastFetchedAt = now;
    _rentalItems = server.rentalItemsSnapshot;
    _rentalItemsLastFetchedAt = now;
  }

  // ── Lookups ───────────────────────────────────────────────────────────────

  User getUserById(String id) {
    if (!_users.containsKey(id)) {
      refreshCache(CacheType.users);
      _scheduleChangeData();
    }
    return _users[id] ?? User(id: id, name: '알 수 없음', email: '');
  }

  Review? getReviewById(String id) {
    if (!_reviews.containsKey(id)) {
      refreshCache(CacheType.reviews);
      _scheduleChangeData();
    }
    return _reviews[id];
  }

  Chatting? getChattingById(String id) {
    if (!_chattings.containsKey(id)) {
      refreshCache(CacheType.chattings);
      _scheduleChangeData();
    }
    return _chattings[id];
  }

  Match? findMatch(String rentalItemId, String userId) {
    final item = rentalItems[rentalItemId];
    if (item == null) return null;
    final isRequester = item.requesterID == userId;
    return matches.values.where((m) {
      if (m.rentalItemID != rentalItemId) return false;
      return isRequester ? m.requesterID == userId : m.lenderID == userId;
    }).firstOrNull;
  }

  String? getMatchedLenderIdForItem(String rentalItemId) {
    final item = rentalItems[rentalItemId];
    if (item?.matchedID == null) return null;
    return matches[item!.matchedID]?.lenderID;
  }

  RentalStatus getStatusForUserOnItem(String rentalItemId, String userId) {
    final item = rentalItems[rentalItemId];
    if (item == null) return RentalStatus.pending;
    if (item.requesterID == userId) return item.rentalStatus;
    if (item.rentalStatus == RentalStatus.cancelled) return RentalStatus.cancelled;
    if (item.matchedID != null) {
      final confirmedMatch = matches[item.matchedID!];
      if (confirmedMatch?.lenderID == userId) return item.rentalStatus;
      return RentalStatus.otherUserMatched;
    }
    return RentalStatus.pending;
  }

  // ── Match 생성 ─────────────────────────────────────────────────────────────

  Match createMatchWithChatting(String rentalItemId, String lenderId) {
    final newMatch = MockServerInterceptor().serverCreateMatchWithChatting(
      rentalItemId,
      lenderId,
    );
    refreshCache(CacheType.matches);
    refreshCache(CacheType.chattings);
    refreshCache(CacheType.rentalItems);
    changeData();
    return newMatch;
  }

  // ── Match 상태 변경 ────────────────────────────────────────────────────────

  void confirmMatch(String matchId) {
    MockServerInterceptor().serverConfirmMatch(matchId);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    changeData();
  }

  void cancelAllMatchesForItem(String rentalItemId) {
    MockServerInterceptor().serverCancelAllMatchesForItem(rentalItemId);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    changeData();
  }

  void cancelLenderMatch(String matchId) {
    MockServerInterceptor().serverCancelLenderMatch(matchId);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    changeData();
  }

  void updateMatchStatus(String matchId, RentalStatus newStatus) {
    MockServerInterceptor().serverUpdateMatchStatus(matchId, newStatus);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    if (newStatus == RentalStatus.returned) refreshCache(CacheType.users);
    changeData();
  }

  void updateMatchLenderReview(String matchId, Review newReview) {
    MockServerInterceptor().serverUpdateMatchLenderReview(matchId, newReview);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.matches);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.users);
    changeData();
  }

  void updateMatchRequesterReview(String matchId, Review newReview) {
    MockServerInterceptor().serverUpdateMatchRequesterReview(matchId, newReview);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.matches);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.users);
    changeData();
  }

  // ── 채팅 ──────────────────────────────────────────────────────────────────

  void addChat(String chattingId, Chat chat) {
    MockServerInterceptor().serverAddChat(chattingId, chat);
    refreshCache(CacheType.chattings);
    changeData();
  }

  // ── 아이템 목록 ───────────────────────────────────────────────────────────

  void addRentalItem(RentalItem item) {
    MockServerInterceptor().serverAddRentalItem(item);
    refreshCache(CacheType.rentalItems);
    changeData();
  }

  List<RentalItem> requestRentalItems(User user) {
    return rentalItems.values
        .where((item) => item.requesterID == user.id)
        .toList();
  }

  List<RentalItem> lentRentalItems(User user) {
    return rentalItems.values.where((item) {
      if (!item.isMatched || item.matchedID == null) return false;
      return matches[item.matchedID]?.lenderID == user.id;
    }).toList();
  }

  List<RentalItem> notMatchedRentalItems(User user) {
    return rentalItems.values
        .where((item) => !item.isMatched && item.requesterID != user.id)
        .toList();
  }

  // ── 서버 데이터 페치 ──────────────────────────────────────────────────────────

  Future<void> fetchMyData(String userId) async {
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.users);
    changeData();
  }

  Future<void> fetchAvailableRentalItems(String userId) async {
    refreshCache(CacheType.rentalItems);
    changeData();
  }

  Future<void> fetchUserProfile(String userId) async {
    refreshCache(CacheType.users);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.matches);
    changeData();
  }

  Future<void> fetchChatMessages(String chattingId) async {
    refreshCache(CacheType.chattings);
    changeData();
  }

  void changeData() => notifyListeners();
}
