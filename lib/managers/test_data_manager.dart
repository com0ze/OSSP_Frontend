import 'package:flutter/widgets.dart';
import 'package:open_source_software/api/mock_server_interceptor.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/models/chat.dart';
import 'package:open_source_software/models/chatting.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';

class TestDataManager extends DataManager {
  static final TestDataManager _instance = TestDataManager._internal();
  factory TestDataManager() => _instance;

  TestDataManager._internal() {
    _refreshAllSync();
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

  // ── DataManager 게터 (TTL 만료 시 lazy refresh) ────────────────────────────
  @override
  Map<String, User> get users {
    if (_isCacheStale(_usersLastFetchedAt, _ttlUsers)) {
      refreshCache(CacheType.users);
      _scheduleChangeData();
    }
    return _users;
  }

  @override
  Map<String, Review> get reviews {
    if (_isCacheStale(_reviewsLastFetchedAt, _ttlReviews)) {
      refreshCache(CacheType.reviews);
      _scheduleChangeData();
    }
    return _reviews;
  }

  @override
  Map<String, Chatting> get chattings {
    if (_isCacheStale(_chattingsLastFetchedAt, _ttlChattings)) {
      refreshCache(CacheType.chattings);
      _scheduleChangeData();
    }
    return _chattings;
  }

  @override
  Map<String, Match> get matches {
    if (_isCacheStale(_matchesLastFetchedAt, _ttlMatches)) {
      refreshCache(CacheType.matches);
      _scheduleChangeData();
    }
    return _matches;
  }

  @override
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

  // 한 프레임 안에서 여러 번 호출돼도 changeData()는 프레임당 한 번만 실행
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

  // 캐시 미스 시 즉시 서버(Mock) 에서 전체 재로드하고 다음 프레임에 UI 갱신
  @override
  User getUserById(String id) {
    if (!_users.containsKey(id)) {
      refreshCache(CacheType.users);
      _scheduleChangeData();
    }
    return _users[id] ?? User(id: id, name: '알 수 없음', email: '');
  }

  @override
  Review? getReviewById(String id) {
    if (!_reviews.containsKey(id)) {
      refreshCache(CacheType.reviews);
      _scheduleChangeData();
    }
    return _reviews[id];
  }

  @override
  Chatting? getChattingById(String id) {
    if (!_chattings.containsKey(id)) {
      refreshCache(CacheType.chattings);
      _scheduleChangeData();
    }
    return _chattings[id];
  }

  // B5: public getter 사용 → TTL 만료 자동 처리 + 캐시 미스 처리 포함
  @override
  Match? findMatch(String rentalItemId, String userId) {
    final item = rentalItems[rentalItemId];
    if (item == null) return null;
    final isRequester = item.requesterID == userId;
    return matches.values.where((m) {
      if (m.rentalItemID != rentalItemId) return false;
      return isRequester ? m.requesterID == userId : m.lenderID == userId;
    }).firstOrNull;
  }

  @override
  String? getMatchedLenderIdForItem(String rentalItemId) {
    final item = rentalItems[rentalItemId];
    if (item?.matchedID == null) return null;
    return matches[item!.matchedID]?.lenderID;
  }

  @override
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

  @override
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

  // B4: 상태 변경 시 matches 캐시도 함께 갱신 → 화면 간 데이터 일관성 보장

  @override
  void confirmMatch(String matchId) {
    MockServerInterceptor().serverConfirmMatch(matchId);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    changeData();
  }

  @override
  void cancelAllMatchesForItem(String rentalItemId) {
    MockServerInterceptor().serverCancelAllMatchesForItem(rentalItemId);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    changeData();
  }

  @override
  void cancelLenderMatch(String matchId) {
    MockServerInterceptor().serverCancelLenderMatch(matchId);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    changeData();
  }

  @override
  void updateMatchStatus(String matchId, RentalStatus newStatus) {
    MockServerInterceptor().serverUpdateMatchStatus(matchId, newStatus);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    if (newStatus == RentalStatus.returned) refreshCache(CacheType.users);
    changeData();
  }

  @override
  void updateMatchLenderReview(String matchId, Review newReview) {
    MockServerInterceptor().serverUpdateMatchLenderReview(matchId, newReview);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.matches);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.users);
    changeData();
  }

  @override
  void updateMatchRequesterReview(String matchId, Review newReview) {
    MockServerInterceptor().serverUpdateMatchRequesterReview(matchId, newReview);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.matches);
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.users);
    changeData();
  }

  // ── 채팅 ──────────────────────────────────────────────────────────────────

  @override
  void addChat(String chattingId, Chat chat) {
    MockServerInterceptor().serverAddChat(chattingId, chat);
    refreshCache(CacheType.chattings);
    changeData();
  }

  // ── 아이템 목록 ───────────────────────────────────────────────────────────

  @override
  void addRentalItem(RentalItem item) {
    MockServerInterceptor().serverAddRentalItem(item);
    refreshCache(CacheType.rentalItems);
    changeData();
  }

  // B5: public getter 사용 → TTL 만료·캐시 미스 자동 처리

  @override
  List<RentalItem> requestRentalItems(User user) {
    return rentalItems.values
        .where((item) => item.requesterID == user.id)
        .toList();
  }

  @override
  List<RentalItem> lentRentalItems(User user) {
    return rentalItems.values.where((item) {
      if (!item.isMatched || item.matchedID == null) return false;
      return matches[item.matchedID]?.lenderID == user.id;
    }).toList();
  }

  @override
  List<RentalItem> notMatchedRentalItems(User user) {
    return rentalItems.values
        .where((item) => !item.isMatched && item.requesterID != user.id)
        .toList();
  }

  // ── 서버 데이터 페치 ──────────────────────────────────────────────────────────
  // [MOCK] 실제 서버에서는 각 메서드가 HTTP 요청을 통해 필요한 데이터만 부분 로드.
  // Mock에서는 MockServerInterceptor 스냅샷 전체를 갱신하여 동일한 효과를 시뮬레이션.

  @override
  Future<void> fetchMyData(String userId) async {
    refreshCache(CacheType.rentalItems);
    refreshCache(CacheType.matches);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.users);
    changeData();
  }

  @override
  Future<void> fetchAvailableRentalItems(String userId) async {
    refreshCache(CacheType.rentalItems);
    changeData();
  }

  @override
  Future<void> fetchUserProfile(String userId) async {
    refreshCache(CacheType.users);
    refreshCache(CacheType.reviews);
    refreshCache(CacheType.matches);
    changeData();
  }

  @override
  Future<void> fetchChatMessages(String chattingId) async {
    refreshCache(CacheType.chattings);
    changeData();
  }
}
