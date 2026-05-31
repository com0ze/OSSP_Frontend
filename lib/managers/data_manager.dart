import 'package:flutter/material.dart';
import 'dart:developer';
import '/api/api_client.dart';
import '/managers/login_manager.dart';
import '/models/chat.dart';
import '/models/chatting.dart';
import '/models/match.dart';
import '/models/rental_item.dart';
import '/models/review.dart';
import '/models/user.dart';
import '/managers/location_manager.dart';
import '/models/main_user.dart';
import '/models/product.dart';

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  // 앱 시작 시 캐시는 비어 있음
  DataManager._internal() {
    LocationManager().addListener(changeData);
  }

  LoginManager loginManager = LoginManager();

  // ── 원소 캐시 (ID → 데이터) ───────────────────────────────────────────────
  final Map<String, User> _users = {};
  final Map<String, Review> _reviews = {};
  final Map<String, Chatting> _chattings = {};
  final Map<String, Match> _matches = {};
  final Map<String, RentalItem> _rentalItems = {};

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
    try {
      // GET /api/v1/chats/{roomId}/messages
      final resChats = await ApiClient().dio.get(
        '/api/v1/chats/$chattingId/messages',
      );
      final chatList = (ApiClient.extractData(resChats.data) as List<dynamic>)
          .map((json) => Chat.fromJson(json as Map<String, dynamic>))
          .toList();

      // 캐시에 없으면 빈 Chatting 생성 후 메시지 교체
      final chatting = _chattings[chattingId] ?? Chatting(id: chattingId);
      chatting.replaceChats(chatList);
      _chattings[chattingId] = chatting;

      // GET /api/v1/requests/{requestId}
      final resItem = await ApiClient().dio.get('/api/v1/requests/$itemId');
      final itemData =
          ApiClient.extractData(resItem.data) as Map<String, dynamic>;
      final newItem = RentalItem.fromJson(itemData);
      _rentalItems[itemId] = newItem;

      // 상대방 ID 도출: 아이템 응답에서 직접 파싱 (_chattings 의존 제거)
      final myId = loginManager.currentUser.id;
      final opponentId = newItem.requesterID == myId
          ? (itemData['providerId'] as String? ?? chatting.opponentId)
          : newItem.requesterID;

      // 상대 유저 캐시에 삽입
      if (opponentId.isNotEmpty) {
        final resOtherUser = await ApiClient().dio.get(
          '/api/v1/users/$opponentId',
        );
        final opponent = User.fromJson(
          ApiClient.extractData(resOtherUser.data) as Map<String, dynamic>,
        );
        _users[opponent.id] = opponent;
      }

      // 매치 갱신
      final lenderID = newItem.requesterID == myId
          ? (itemData['providerId'] as String? ?? '')
          : myId;
      _matches[matchId] = Match(
        matchID: matchId,
        rentalItemID: itemId,
        requesterID: newItem.requesterID,
        lenderID: lenderID,
        chattingID: chattingId,
      );

      // GET /api/v1/reviews/my — hasReviewed 체크를 위해 내가 쓴 리뷰 로드
      final resMyReviews = await ApiClient().dio.get('/api/v1/reviews/my');
      final rawMyReviews =
          ApiClient.extractData(resMyReviews.data) as List<dynamic>;
      _reviews.addEntries(
        rawMyReviews
            .map(
              (json) =>
                  Review.fromJson(json as Map<String, dynamic>)
                    ..writerId = myId,
            )
            .map((r) => MapEntry(r.id, r)),
      );

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
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
          chattingID:
              existingMatch?.chattingID ?? resItemData["roomId"] as String?,
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
      );

      final List<dynamic> rawReviewList =
          ApiClient.extractData(resReview.data) as List<dynamic>;

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
    // 메인 유저 최신화 + 채팅/매치/대여아이템 데이터 병렬 로드
    // chattingListScreenInitCache 내부에서 /api/v1/requests/me 호출 포함
    await Future.wait([updateMainUser(), chattingListScreenInitCache()]);

    try {
      // GET /api/v1/users/me/reviews
      final resReview = await ApiClient().dio.get('/api/v1/users/me/reviews');

      final String userId = loginManager.currentUser.id;

      final List<dynamic> rawReceivedReviews =
          ApiClient.extractData(resReview.data) as List<dynamic>;
      final receivedReviews = rawReceivedReviews
          .map(
            (json) =>
                Review.fromJson(json as Map<String, dynamic>)
                  ..revieweeId = userId,
          )
          .toList();
      _reviews.addEntries(receivedReviews.map((r) => MapEntry(r.id, r)));

      // GET /api/v1/reviews/my — 내가 작성한 리뷰
      final resMyReviews = await ApiClient().dio.get('/api/v1/reviews/my');
      final List<dynamic> rawWrittenReviews =
          ApiClient.extractData(resMyReviews.data) as List<dynamic>;
      final writtenReviews = rawWrittenReviews
          .map(
            (json) =>
                Review.fromJson(json as Map<String, dynamic>)
                  ..writerId = userId,
          )
          .toList();
      _reviews.addEntries(writtenReviews.map((r) => MapEntry(r.id, r)));

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
        "buildingName": BuildingNameTransfer.toEnglish(placeId),
        "rewardAmt": price, // int 타입
        "duration": duration, // int 타입
        "memo": description,
      };
      await ApiClient().dio.post('/api/v1/requests', data: requestData);

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

  RentalItem? getCachedRentalItem(String? id) {
    if (id == null) return null;
    return _rentalItems[id];
  }

  List<Chatting> getAllChattings() => _chattings.values.toList();

  List<RentalItem> getAvailableRentalItems(String currentUserId) {
    final currentBuilding = LocationManager().currentBuildingName;
    return _rentalItems.values.where((i) {
      if (i.isMatched || i.requesterID == currentUserId) return false;
      if (currentBuilding == null) return false;
      return i.buildingName == currentBuilding ||
          i.buildingName == BuildingNameTransfer.toEnglish(currentBuilding) ||
          i.buildingName == BuildingNameTransfer.toKorean(currentBuilding);
    }).toList();
  }

  List<RentalItem> getBorrowedItems(String userId) =>
      _rentalItems.values.where((i) => i.requesterID == userId).toList();

  List<RentalItem> getLentItems(String userId) {
    final lentItemIds = _matches.values
        .where((m) => m.lenderID == userId)
        .map((m) => m.rentalItemID)
        .toSet();
    return _rentalItems.values
        .where((i) => lentItemIds.contains(i.id))
        .toList();
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

      // POST /api/v1/chats
      final Map<String, dynamic> requestDataChatting = {
        "matchId": resMatchData["matchId"],
      };
      final resChatting = await ApiClient().dio.post(
        '/api/v1/chats',
        data: requestDataChatting,
      );
      final Map<String, dynamic> resChattingData =
          ApiClient.extractData(resChatting.data) as Map<String, dynamic>;
      resChattingData['requestId'] = itemId;

      Chatting chatting = Chatting.fromJson(resChattingData);
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
  Future<bool> cancelMatch(String itemId) async {
    try {
      // 정보를 서버에 전송
      // PATCH /api/v1/requests/{requestId}/cancel
      await ApiClient().dio.patch('/api/v1/requests/$itemId/cancel');

      // 로컬 캐시도 즉시 취소 상태로 갱신
      final item = _rentalItems[itemId];
      if (item != null) {
        _rentalItems[itemId] = item.copyWith(
          isMatched: false,
          clearMatchedID: true,
          rentalStatus: RentalStatus.cancelled,
        );
      }

      changeData();
      return true;
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return false;
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
    try {
      await ApiClient().dio.patch('/api/v1/requests/$rentalItemId/$action');

      // 로컬 캐시도 즉시 갱신
      final item = _rentalItems[rentalItemId];
      if (item != null) {
        _rentalItems[rentalItemId] = item.copyWith(rentalStatus: newStatus);
      }

      changeData();
    } catch (e) {
      log('❌ 상태 업데이트 실패: $e');
    }
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
      await ApiClient().dio.post('/api/v1/reviews', data: requestDataMatch);

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
