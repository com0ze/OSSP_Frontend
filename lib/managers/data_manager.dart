import 'package:flutter/material.dart';
import 'dart:developer';
import '/api/api_client.dart';
import '/managers/login_manager.dart';
import '/models/building.dart';
import '/models/chat.dart';
import '/models/chatting.dart';
import '/models/match.dart';
import '/models/place.dart';
import '/models/rental_item.dart';
import '/models/review.dart';
import '/models/user.dart';
import '/models/main_user.dart';
import '/models/product.dart';

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  // 앱 시작 시 캐시는 비어 있음
  DataManager._internal();

  late final Future<void> _readyFuture;

  // 초기 데이터 로딩이 완료될 때까지 대기하는 Future.
  // 이미 완료된 경우 await 시 즉시 반환됩니다.
  Future<void> get ready => _readyFuture;

  LoginManager loginManager = LoginManager();

  // ── 정적 데이터 (고정값, 서버 조회 불필요) ────────────────────────────────
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

  // ── 원소 캐시 (ID → 데이터) ───────────────────────────────────────────────
  final Map<String, User> _users = {};
  final Map<String, Review> _reviews = {};
  final Map<String, Chatting> _chattings = {};
  final Map<String, Match> _matches = {};
  final Map<String, RentalItem> _rentalItems = {};

  Map<String, User> get users => _users;
  Map<String, Review> get reviews => _reviews;
  Map<String, Chatting> get chattings => _chattings;
  Map<String, Match> get matches => _matches;
  Map<String, RentalItem> get rentalItems => _rentalItems;

  // 다른 화면에 진입 시 그 전에 저장했던 임시 정보 파기
  void clearCache() {
    _users.clear();
    _reviews.clear();
    _chattings.clear();
    _matches.clear();
    _rentalItems.clear();
  }

  // 메인 유저 최신화
  Future<void> updateMainUser() async {
    String myId = loginManager.currentUser.id;
    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/users/me
      final resUser = await ApiClient().dio.get('/api/v1/users/me');
      final newMe = MainUser.fromJson(
        ApiClient.extractData(resUser.data) as Map<String, dynamic>,
      );

      // 더 자세한 정보로 업데이트
      _users[myId] = newMe;
      loginManager.updateUser(newMe);

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // --- 각 화면 별로 필요 정보 요청 --------------------------------------------

  // chat_screen(채팅 리스트 화면에서 넘어감)
  // 기본 정보로 채팅 클래스 보유
  // room id, match id, 상대 유저의 아이디, 상대의 이름
  // 마지막 메시지, 마지막 메시지 시간
  Future<void> chatScreenInitCache({
    required String chattingId,
    required String matchId,
    required String itemId,
  }) async {
    Chatting? chatting = _chattings[chattingId];
    if (chatting == null) return;

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/chats/{roomId}/messages
      final resChats = await ApiClient().dio.get(
        '/api/v1/chats/$chattingId/messages',
      );

      // chat클래스 리스트를 생성하고 채팅 클래스 생성
      final List<dynamic> rawChatList =
          ApiClient.extractData(resChats.data) as List<dynamic>;
      final List<Chat> chatList = rawChatList
          .map((json) => Chat.fromJson(json as Map<String, dynamic>))
          .toList();

      // 새로운 채팅을 캐쉬에 삽입
      chatting = chatting.copyWith(chats: chatList);
      _chattings[chatting.id] = chatting;

      // 상대 유저 캐쉬에 삽입
      final resOtherUser = await ApiClient().dio.get(
        '/api/v1/users/${chatting.opponentId}',
      );

      final opponent = User.fromJson(
        ApiClient.extractData(resOtherUser.data) as Map<String, dynamic>,
      );
      _users[opponent.id] = opponent;

      // GET /api/v1/requests/{requestId}
      final resItem = await ApiClient().dio.get('/api/v1/requests/$itemId');
      final newItem = RentalItem.fromJson(
        ApiClient.extractData(resItem.data) as Map<String, dynamic>,
      );

      // 더 자세한 정보로 업데이트
      _rentalItems[itemId] = newItem;

      // 매치 추가
      _matches[matchId] = Match(
        matchID: matchId,
        rentalItemID: itemId,
        requesterID: newItem.requesterID,
        chattingID: chattingId,
        lenderID: newItem.requesterID == opponent.id
            ? loginManager.currentUser.id
            : opponent.id,
      );

      // GET /api/v1/reviews/my — hasReviewed 체크를 위해 내가 쓴 리뷰 로드
      final resMyReviews = await ApiClient().dio.get('/api/v1/reviews/my');
      final List<dynamic> rawMyReviews =
          resMyReviews.data['data'] as List<dynamic>;
      final List<Review> myReviews = rawMyReviews
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
          .toList();
      _reviews.addEntries(myReviews.map((r) => MapEntry(r.id, r)));

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // chatting_list
  // 기본 정보 X
  Future<void> chattingListScreenInitCache() async {
    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/chats
      final resChattings = await ApiClient().dio.get('/api/v1/chats');

      // chatint클래스 리스트를 생성하고 데이터 삽입
      final List<dynamic> rawChattingList =
          ApiClient.extractData(resChattings.data) as List<dynamic>;
      final List<Chatting> chatttingList = rawChattingList
          .map((json) => Chatting.fromJson(json as Map<String, dynamic>))
          .toList();

      _chattings.addEntries(
        chatttingList.map((chatting) => MapEntry(chatting.id, chatting)),
      );

      // 매칭 스테이터스 표시 및 채팅방으로 넘어가기 위해서 리스트 호출
      // GET /api/v1/requests/me
      final resRentals = await ApiClient().dio.get('/api/v1/requests/me');

      // rental item 리스트를 생성 및 저장
      final List<dynamic> rawRentalList =
          ApiClient.extractData(resRentals.data) as List<dynamic>;
      final List<RentalItem> rentalList = rawRentalList
          .map((json) => RentalItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _rentalItems.addEntries(
        rentalList.map((item) => MapEntry(item.id, item)),
      );

      final String myId = loginManager.currentUser.id;
      for (final chatting in chatttingList) {
        if (chatting.matchId.isEmpty) continue;
        final item = _rentalItems[chatting.requestId];
        if (item == null) continue;
        final isRequester = item.requesterID == myId;
        _matches[chatting.matchId] = Match(
          matchID: chatting.matchId,
          rentalItemID: chatting.requestId,
          requesterID: item.requesterID,
          lenderID: isRequester ? chatting.opponentId : myId,
          chattingID: chatting.id,
        );
      }

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // item_detail_screen(채팅 화면, 대여 목록 화면에서 넘어감)
  // 기본 정보로 rentalItem 클래스 보유
  // 아이디만 알아도 동작하게 만듦
  Future<void> itemDetailScreenInitCache(String itemId) async {
    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/requests/{requestId}
      final resItem = await ApiClient().dio.get('/api/v1/requests/$itemId');
      Map<String, dynamic> resItemData =
          ApiClient.extractData(resItem.data) as Map<String, dynamic>;
      final newItem = RentalItem.fromJson(resItemData);

      // 더 자세한 정보로 업데이트
      _rentalItems[itemId] = newItem;

      // 요청 유저 캐쉬에 삽입
      final resRequester = await ApiClient().dio.get(
        '/api/v1/users/${newItem.requesterID}',
      );

      final requester = User.fromJson(
        ApiClient.extractData(resRequester.data) as Map<String, dynamic>,
      );
      _users[requester.id] = requester;

      if (newItem.isMatched) {
        final existingMatch = _matches[newItem.matchedID!];
        _matches[newItem.matchedID!] = Match(
          matchID: newItem.matchedID!,
          rentalItemID: newItem.id,
          requesterID: newItem.requesterID,
          lenderID: resItemData["providerId"],
          chattingID: existingMatch?.chattingID,
        );
      }

      // TODO: 리뷰 단건 조회 가능하면 거래의 리뷰 추가하기
      // 요청자 리뷰, 대여자 리뷰

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // other_user_profile_screen
  // 기본 정보로 rentalItem 클래스 보유(물건 상세 정보 페이지에서 넘어감)
  // 아이디만 알아도 동작하게 만듦
  Future<void> otherUserProfileScreenInitCache(String userId) async {
    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/users/{userId}
      final resUser = await ApiClient().dio.get('/api/v1/users/$userId');
      final newUser = User.fromJson(
        ApiClient.extractData(resUser.data) as Map<String, dynamic>,
      );

      // 더 자세한 정보로 업데이트
      _users[userId] = newUser;

      // GET /api/v1/users/me/reviews
      final resReview = await ApiClient().dio.get(
        '/api/v1/users/$userId/reviews',
        queryParameters: {'page': 0, 'size': 100}, // 일단 많이 가지고 오기
      );

      // 1. 최상위 중괄호 {} 전체를 Map<String, dynamic>으로 확실하게 인식시킵니다.
      final Map<String, dynamic> rootResponse =
          resReview.data as Map<String, dynamic>;

      // 리뷰 리스트를 생성 및 저장
      //// 2. rootResponse['data']를 거쳐서 그 안의 진짜 'content' 배열을 꺼내야 합니다!
      final List<dynamic> rawReviewList =
          rootResponse['data']['content'] as List<dynamic>;

      final List<Review> reviewList = rawReviewList
          .map(
            (json) =>
                Review.fromJson(json as Map<String, dynamic>)
                  ..revieweeId = userId,
          )
          .toList();

      _reviews.addEntries(reviewList.map((item) => MapEntry(item.id, item)));

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // user_profile_screen
  // 기존에 알아야하는 정보 없음
  // 굳이 캐쉬 클리어로 새로고침 할 필요 없음
  Future<void> userProfileScreenInitCache() async {
    // 메인 유저 최신화
    await updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/requests/me
      final resRentals = await ApiClient().dio.get('/api/v1/requests/me');

      // rental item 리스트를 생성 및 저장
      final List<dynamic> rawRentalList =
          ApiClient.extractData(resRentals.data) as List<dynamic>;
      final List<RentalItem> rentalList = rawRentalList
          .map((json) => RentalItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _rentalItems.addEntries(
        rentalList.map((item) => MapEntry(item.id, item)),
      );

      // GET /api/v1/users/me/reviews
      final resReview = await ApiClient().dio.get(
        '/api/v1/users/me/reviews',
        queryParameters: {'page': 0, 'size': 100}, // 일단 많이 가지고 오기
      );

      // 1. 최상위 중괄호 {} 전체를 Map<String, dynamic>으로 확실하게 인식시킵니다.
      final Map<String, dynamic> rootResponse =
          resReview.data as Map<String, dynamic>;

      // 리뷰 리스트를 생성 및 저장
      //// 2. rootResponse['data']를 거쳐서 그 안의 진짜 'content' 배열을 꺼내야 합니다!
      final List<dynamic> rawReviewList =
          rootResponse['data']['content'] as List<dynamic>;

      final String userId = loginManager.currentUser.id;
      final List<Review> reviewList = rawReviewList
          .map(
            (json) =>
                Review.fromJson(json as Map<String, dynamic>)
                  ..revieweeId = userId,
          )
          .toList();

      _reviews.addEntries(reviewList.map((item) => MapEntry(item.id, item)));

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // rental list screen
  // 기존에 알아야하는 정보 없음
  Future<void> rentalListScreenInitCache() async {
    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/requests/nearby
      final resRentals = await ApiClient().dio.get('/api/v1/requests/nearby');

      // rental item 리스트를 생성 및 저장
      final List<dynamic> rawRentalList =
          ApiClient.extractData(resRentals.data) as List<dynamic>;
      final List<RentalItem> rentalList = rawRentalList
          .map((json) => RentalItem.fromJson(json as Map<String, dynamic>))
          .toList();

      _rentalItems.addEntries(
        rentalList.map((item) => MapEntry(item.id, item)),
      );

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // rental item을 서버에 요청해서 업데이트 후 반환
  Future<RentalItem?> getRentalItem(String itemId) async {
    await itemDetailScreenInitCache(itemId);
    return _rentalItems[itemId];
  }

  // 서버에 rental item 추가 요청을 날림
  Future<void> addRentalItem({
    required Product product,
    required String placeId,
    required int price,
    required int duration,
    required String description,
  }) async {
    try {
      // 정보를 서버에 전송
      // POST /api/v1/requests

      // 1. 명세서에 명시된 키(Key)와 데이터 타입에 맞게 Map을 구성합니다.
      final Map<String, dynamic> requestData = {
        "itemName": product.name,
        "buildingName": placeId,
        "rewardAmt": price, // int 타입
        "duration": duration, // int 타입
        "memo": description,
      };
      final res = await ApiClient().dio.post(
        '/api/v1/requests',
        data: requestData,
      );

      if (res.statusCode == 400) return;

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  Match? getMatch(String? matchId) {
    if (matchId == null) return null;
    return _matches[matchId];
  }

  User? getUser(String? userId) {
    if (userId == null) return null;
    return _users[userId];
  }

  Future<Match?> createMatchWithChatting(String itemId) async {
    try {
      // 정보를 서버에 전송

      // POST /api/v1/requests/{requestId}/accept
      final Map<String, dynamic> requestDataMatch = {
        "providerId": loginManager.currentUser.id,
      };
      final resMatch = await ApiClient().dio.post(
        '/api/v1/requests/$itemId/accept',
        data: requestDataMatch,
      );
      Map<String, dynamic> resMatchData =
          ApiClient.extractData(resMatch.data) as Map<String, dynamic>;

      if (resMatch.statusCode == 404) throw Error();
      if (resMatch.statusCode == 409) throw Error();

      // POST /api/v1/chats
      final Map<String, dynamic> requestDataChatting = {
        "matchId": resMatchData["matchId"],
      };
      final resChatting = await ApiClient().dio.post(
        '/api/v1/chats',
        data: requestDataChatting,
      );
      Map<String, dynamic> resChattingData =
          ApiClient.extractData(resChatting.data) as Map<String, dynamic>;

      Chatting chatting = Chatting.fromJson(
        resChattingData,
      ).copyWith(requestId: itemId);
      Match match = Match.fromJson(resMatchData);

      _chattings[chatting.id] = chatting;
      _matches[match.matchID] = match;

      changeData();

      return match;
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return null;
    }
  }

  // 요청 취소 요청
  Future<void> cancelMatch(String itemId) async {
    try {
      // 정보를 서버에 전송
      // PATCH /api/v1/requests/{requestId}/cancel
      final res = await ApiClient().dio.patch(
        '/api/v1/requests/$itemId/cancel',
      );

      if (res.statusCode == 404) return;
      if (res.statusCode == 409) return;

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  Chatting? getChatting(String? chattingId) {
    if (chattingId == null) return null;
    return _chattings[chattingId];
  }

  RentalStatus getStatusForUserOnItem(String itemId, String userId) {
    final item = _rentalItems[itemId];
    if (item == null) return RentalStatus.pending;
    if (item.isMatched && item.matchedID != null) {
      final confirmedMatch = _matches[item.matchedID!];
      if (confirmedMatch != null) {
        final isParticipant =
            confirmedMatch.lenderID == userId ||
            confirmedMatch.requesterID == userId;
        if (!isParticipant) return RentalStatus.otherUserMatched;
      }
    }
    return item.rentalStatus;
  }

  Future<void> updateMatchStatus(String matchId, RentalStatus newStatus) async {
    final rentalItemId = _matches[matchId]?.rentalItemID;
    if (rentalItemId == null) return;
    final action = newStatus == RentalStatus.inProgress
        ? 'handover'
        : 'complete';
    await ApiClient().dio.patch('/api/v1/requests/$rentalItemId/$action');

    changeData();
  }

  Future<void> postReview({
    required int score,
    required String reviewText,
    required String matchId,
  }) async {
    try {
      // 정보를 서버에 전송
      // POST /api/v1/reviews
      final Map<String, dynamic> requestDataMatch = {
        "matchId": matchId,
        "score": score,
        "comments": reviewText,
      };
      final res = await ApiClient().dio.post(
        '/api/v1/reviews',
        data: requestDataMatch,
      );

      if (res.statusCode == 404) return;
      if (res.statusCode == 409) return;

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  List<Review> getUserReceivedReview(String userId) =>
      _reviews.values.where((r) => r.revieweeId == userId).toList();

  List<Review> getUserWriteReview(String userId) =>
      _reviews.values.where((r) => r.writerId == userId).toList();

  void changeData() => notifyListeners();
}
