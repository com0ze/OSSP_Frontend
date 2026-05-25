// ignore_for_file: unused_import, unused_field, unused_element
import 'package:flutter/material.dart';
import 'package:open_source_software/screens/other_user_profile_screen.dart';
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

class DataManager extends ChangeNotifier {
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;

  // 앱 시작 시 캐시는 비어 있음 — _initAsync() 제거
  DataManager._internal();

  LoginManager loginManager = LoginManager();

  // ── 정적 데이터 (고정값, 서버 조회 불필요) ────────────────────────────────
  static final List<Place> places = []; // 건물 목록 — data_manager.dart에서 복사
  static Place? placeById(String id) => throw UnimplementedError();

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
      final newMe = MainUser.fromJson(resUser.data as Map<String, dynamic>);

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
  Future<void> chatScreenInitCache(
    String chattingId,
    String matchId,
    String itemId,
  ) async {
    Chatting? chatting = _chattings[chattingId];
    if (chatting == null) return;

    // 원하는 정보를 얻었으니 캐쉬 초기화
    clearCache();

    // 메인 유저 최신화
    updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/chats/{roomId}/messages
      final resChats = await ApiClient().dio.get(
        '/api/v1/chats/$chattingId/messages',
      );

      // chat클래스 리스트를 생성하고 채팅 클래스 생성
      final List<dynamic> rawChatList = resChats.data as List<dynamic>;
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

      final opponent = User.fromJson(resOtherUser.data as Map<String, dynamic>);
      _users[opponent.id] = opponent;

      // GET /api/v1/requests/{requestId}
      final resItem = await ApiClient().dio.get('/api/v1/requests/$itemId');
      final newItem = RentalItem.fromJson(resItem.data as Map<String, dynamic>);

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

      changeData();
    } catch (e) {
      log('❌ 메시지 로드 및 파싱 실패: $e');
      return; // 에러 발생
    }
  }

  // chatting_list
  // 기본 정보 X
  Future<void> chattingListScreenInitCache() async {
    // 기존에 알아야하는 정보 없음
    clearCache();

    // 메인 유저 최신화
    updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/chats
      final resChattings = await ApiClient().dio.get('/api/v1/chats');

      // chatint클래스 리스트를 생성하고 데이터 삽입
      final List<dynamic> rawChattingList = resChattings.data as List<dynamic>;
      final List<Chatting> chatttingList = rawChattingList
          .map((json) => Chatting.fromJson(json as Map<String, dynamic>))
          .toList();

      _chattings.addEntries(
        chatttingList.map((chatting) => MapEntry(chatting.id, chatting)),
      );

      // TODO: match_status는 백에게 부탁해야함
      // TODO: 상대 유저는 이름만 나오게 수정해야함

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
    // 기존에 알아야하는 정보 없음
    clearCache();

    // 메인 유저 최신화
    updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/requests/{requestId}
      final resItem = await ApiClient().dio.get('/api/v1/requests/$itemId');
      final newItem = RentalItem.fromJson(resItem.data as Map<String, dynamic>);

      // 더 자세한 정보로 업데이트
      _rentalItems[itemId] = newItem;

      // 요청 유저 캐쉬에 삽입
      final resRequester = await ApiClient().dio.get(
        '/api/v1/users/${newItem.requesterID}',
      );

      final requester = User.fromJson(
        resRequester.data as Map<String, dynamic>,
      );
      _users[requester.id] = requester;

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
    // 기존에 알아야하는 정보 없음
    clearCache();

    // 메인 유저 최신화
    updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/users/{userId}
      final resUser = await ApiClient().dio.get('/api/v1/users/$userId');
      final newUser = User.fromJson(resUser.data as Map<String, dynamic>);

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
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
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
    updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/requests/me
      final resRentals = await ApiClient().dio.get('/api/v1/requests/me');

      // rental item 리스트를 생성 및 저장
      final List<dynamic> rawRentalList = resRentals.data as List<dynamic>;
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

      final List<Review> reviewList = rawReviewList
          .map((json) => Review.fromJson(json as Map<String, dynamic>))
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
    // 기존에 알아야하는 정보 없음
    clearCache();

    // 메인 유저 최신화
    updateMainUser();

    try {
      // 정보를 서버로 부터 요청
      // GET /api/v1/requests/nearby
      final resRentals = await ApiClient().dio.get('/api/v1/requests/nearby');

      // rental item 리스트를 생성 및 저장
      final List<dynamic> rawRentalList = resRentals.data as List<dynamic>;
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

  void changeData() => notifyListeners();
}
