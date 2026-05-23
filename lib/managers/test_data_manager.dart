import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/models/chat.dart';
import 'package:open_source_software/models/chatting.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/models/product.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';

class TestDataManager extends DataManager {
  static final TestDataManager _instance = TestDataManager._internal();

  factory TestDataManager() => _instance;

  TestDataManager._internal();

  @override
  final Map<String, User> users = {
    'guest': User(id: 'guest', name: 'Guest', email: ''),
    '0': User(
      id: '0',
      name: 'Kim sample',
      email: 'test@email.com',
      score: 10.0,
    ),
    '1': User(
      id: '1',
      name: '김철수',
      email: 'kim@example.com',
      score: 85,
      rentalHistory: ['deal1', 'deal2', 'deal3'],
    ),
    '2': User(
      id: '2',
      name: '이영희',
      email: 'lee@example.com',
      score: 92,
      rentalHistory: ['deal4', 'deal5'],
    ),
    '3': User(
      id: '3',
      name: '박민수',
      email: 'park@example.com',
      score: 78,
      rentalHistory: ['deal6'],
    ),
    'l1': User(id: 'l1', name: '김대여', email: 'lender@example.com', score: 90),
    'l2': User(id: 'l2', name: '이빌려', email: 'lender2@example.com', score: 85),
    'r1': User(id: 'r1', name: '박여행', email: 'renter@example.com', score: 82),
    'reviewer1': User(
      id: 'reviewer1',
      name: '김리뷰',
      email: 'reviewer1@example.com',
      score: 85,
    ),
    'reviewer2': User(
      id: 'reviewer2',
      name: '이후기',
      email: 'reviewer2@example.com',
      score: 90,
    ),
    'reviewer3': User(
      id: 'reviewer3',
      name: '박평가',
      email: 'reviewer3@example.com',
      score: 75,
    ),
  };

  @override
  final Map<String, Review> reviews = {
    'b1': Review(
      id: 'b1',
      score: 5,
      reviewText: "잘 썼습니다. ",
      writer: User(
        id: '0',
        name: 'Kim sample',
        email: "test@email.com",
        score: 10.0,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    '1': Review(
      id: '1',
      score: 5,
      reviewText: '매우 친절하시고 물건 상태도 좋았습니다. 감사합니다!',
      writer: User(
        id: 'reviewer1',
        name: '김리뷰',
        email: 'reviewer1@example.com',
        score: 85,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    '2': Review(
      id: '2',
      score: 4,
      reviewText: '약속 시간도 잘 지키시고 좋았어요.',
      writer: User(
        id: 'reviewer2',
        name: '이후기',
        email: 'reviewer2@example.com',
        score: 90,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    '3': Review(
      id: '3',
      score: 4,
      reviewText: '대여 과정이 원활했습니다.',
      writer: User(
        id: 'reviewer3',
        name: '박평가',
        email: 'reviewer3@example.com',
        score: 75,
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  };

  @override
  final Map<String, Chatting> chattings = {
    'chat_m_b1': Chatting(id: 'chat_m_b1'),
    'chat_m_b2': Chatting(id: 'chat_m_b2'),
    'chat_m_b3': Chatting(id: 'chat_m_b3'),
    'chat_m_l1': Chatting(id: 'chat_m_l1'),
    'chat_m_ri1': Chatting(id: 'chat_m_ri1'),
    'chat_m_ri2': Chatting(id: 'chat_m_ri2'),
    'chat_m_ri3': Chatting(id: 'chat_m_ri3'),
    'c_test': Chatting(id: 'c_test'),
    'c_test2': Chatting(id: 'c_test2'),
  };

  @override
  final Map<String, Match> matches = {
    'm_b1': const Match(
      matchID: 'm_b1',
      rentalItemID: 'b1',
      requesterID: '0',
      lenderID: '1',
      chattingID: 'chat_m_b1',
      requesterReviewID: 'b1',
    ),
    'm_b2': const Match(
      matchID: 'm_b2',
      rentalItemID: 'b2',
      requesterID: '0',
      lenderID: 'l1',
      chattingID: 'chat_m_b2',
    ),
    'm_b3': const Match(
      matchID: 'm_b3',
      rentalItemID: 'b3',
      requesterID: '0',
      lenderID: 'l2',
      chattingID: 'chat_m_b3',
    ),
    'm_l1': const Match(
      matchID: 'm_l1',
      rentalItemID: 'l1',
      requesterID: 'r1',
      lenderID: '0',
      chattingID: 'chat_m_l1',
    ),
    'm_ri1': const Match(
      matchID: 'm_ri1',
      rentalItemID: 'ri1',
      requesterID: '1',
      lenderID: 'reviewer1',
      chattingID: 'chat_m_ri1',
      lenderReviewID: '1',
    ),
    'm_ri2': const Match(
      matchID: 'm_ri2',
      rentalItemID: 'ri2',
      requesterID: '1',
      lenderID: 'reviewer2',
      chattingID: 'chat_m_ri2',
      lenderReviewID: '2',
    ),
    'm_ri3': const Match(
      matchID: 'm_ri3',
      rentalItemID: 'ri3',
      requesterID: '1',
      lenderID: 'reviewer3',
      chattingID: 'chat_m_ri3',
      lenderReviewID: '3',
    ),
    "m_test": const Match(
      matchID: "m_test",
      rentalItemID: "ri_test",
      requesterID: "1",
      lenderID: '0',
      chattingID: "c_test",
    ),
    "m_test2": const Match(
      matchID: "m_test2",
      rentalItemID: "ri_test",
      requesterID: "1",
      lenderID: '2',
      chattingID: "c_test2",
    ),
  };

  @override
  final Map<String, RentalItem> rentalItems = {
    '1': RentalItem(
      id: '1',
      title: '급하게 드릴 필요해요',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      preferences: '오늘 저녁까지 필요합니다',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    'qwer': RentalItem(
      id: 'qwer',
      title: '급하게 드릴 필요해요',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용으로 오늘 저녁까지 필요합니다',
      preferences: '오늘 저녁까지 필요합니다',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    '2': RentalItem(
      id: '2',
      title: '캠핑용 텐트 빌려주실 분',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      location: '서울시 마포구',
      price: 30000,
      description: '이번 주말 캠핑 가는데 텐트가 필요합니다',
      preferences: '금요일 오후에 수령 가능합니다',
      requesterID: '2',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    '3': RentalItem(
      id: '3',
      title: '빔프로젝터 급구',
      product: Product(name: '빔프로젝트', category: '전자기기'),
      location: '서울시 송파구',
      price: 20000,
      description: '회사 프레젠테이션용으로 필요합니다',
      preferences: '내일 오전까지 필요',
      requesterID: '3',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    'b1': RentalItem(
      id: 'b1',
      title: '드릴 대여',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용',
      preferences: '',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      matchIDs: ['m_b1'],
      isMatched: true,
      matchedID: 'm_b1',
      rentalStatus: RentalStatus.reviewed,
    ),
    'b2': RentalItem(
      id: 'b2',
      title: '드릴 대여',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '서울시 강남구',
      price: 10000,
      description: '가구 조립용',
      preferences: '',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      matchIDs: ['m_b2'],
      isMatched: true,
      matchedID: 'm_b2',
      rentalStatus: RentalStatus.inProgress,
    ),
    'b3': RentalItem(
      id: 'b3',
      title: '캠핑 텐트',
      product: Product(name: '4인용 텐트', category: '캠핑 용품'),
      location: '서울시 마포구',
      price: 30000,
      description: '캠핑용',
      preferences: '',
      requesterID: '0',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      matchIDs: ['m_b3'],
      isMatched: true,
      matchedID: 'm_b3',
      rentalStatus: RentalStatus.returned,
    ),
    'l1': RentalItem(
      id: 'l1',
      title: '카메라 대여',
      product: Product(name: '미러리스 카메라', category: '전자기기'),
      location: '서울시 송파구',
      price: 25000,
      description: '여행용',
      preferences: '',
      requesterID: 'r1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      matchIDs: ['m_l1'],
      isMatched: true,
      matchedID: 'm_l1',
      rentalStatus: RentalStatus.matchConfirmed,
    ),
    'ri1': RentalItem(
      id: 'ri1',
      title: '',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '',
      price: 0,
      description: '',
      preferences: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri1'],
      isMatched: true,
      matchedID: 'm_ri1',
      rentalStatus: RentalStatus.reviewed,
    ),
    'ri2': RentalItem(
      id: 'ri2',
      title: '',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '',
      price: 0,
      description: '',
      preferences: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri2'],
      isMatched: true,
      matchedID: 'm_ri2',
      rentalStatus: RentalStatus.reviewed,
    ),
    'ri3': RentalItem(
      id: 'ri3',
      title: '',
      product: Product(name: '전동 드릴', category: '공구'),
      location: '',
      price: 0,
      description: '',
      preferences: '',
      requesterID: '1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      matchIDs: ['m_ri3'],
      isMatched: true,
      matchedID: 'm_ri3',
      rentalStatus: RentalStatus.reviewed,
    ),
    'ri_test': RentalItem(
      id: "ri_test",
      title: "ri_test",
      product: Product(name: '휴지', category: "생필품"),
      location: "신공학관",
      price: 1000,
      description: "test",
      preferences: "test",
      requesterID: '1',
      createdAt: DateTime.now(),
      matchIDs: ["m_test", "m_test2"],
      isMatched: true,
      matchedID: "m_test2",
      rentalStatus: RentalStatus.matchConfirmed,
    ),
  };

  // ── Lookups ───────────────────────────────────────────────────────────────

  @override
  User getUserById(String id) {
    return users[id] ?? User(id: id, name: '알 수 없음', email: '');
  }

  @override
  Review? getReviewById(String id) => reviews[id];

  @override
  Chatting? getChattingById(String id) => chattings[id];

  // 특정 아이템에서 해당 유저(요청자 또는 대여자)가 참여한 매치를 반환
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

    // 요청자는 아이템 실제 상태
    if (item.requesterID == userId) return item.rentalStatus;

    // 취소된 경우 모든 참여자에게 취소 표시
    if (item.rentalStatus == RentalStatus.cancelled) {
      return RentalStatus.cancelled;
    }

    // 매칭이 확정된 경우
    if (item.matchedID != null) {
      final confirmedMatch = matches[item.matchedID!];
      if (confirmedMatch?.lenderID == userId) return item.rentalStatus;
      // 확정되지 않은 다른 대여자
      return RentalStatus.otherUserMatched;
    }

    // 매칭 미확정: 대기 중
    return RentalStatus.pending;
  }

  // ── Match 생성 ─────────────────────────────────────────────────────────────

  // 대여자가 새 매치 + 채팅방을 생성
  @override
  Match createMatchWithChatting(String rentalItemId, String lenderId) {
    final item = rentalItems[rentalItemId]!;
    final matchId = 'match_${rentalItemId}_$lenderId';
    final chattingId = 'chat_$matchId';
    chattings[chattingId] = Chatting(id: chattingId);
    final newMatch = Match(
      matchID: matchId,
      rentalItemID: rentalItemId,
      requesterID: item.requesterID,
      lenderID: lenderId,
      chattingID: chattingId,
    );
    matches[matchId] = newMatch;
    rentalItems[rentalItemId] = item.copyWith(
      matchIDs: [...item.matchIDs, matchId],
    );
    changeData();
    return newMatch;
  }

  // ── Match 상태 변경 ────────────────────────────────────────────────────────

  // pending → matchConfirmed: 아이템 상태 및 isMatched/matchedID 업데이트
  @override
  void confirmMatch(String matchId) {
    final match = matches[matchId];
    if (match == null) return;
    final item = rentalItems[match.rentalItemID];
    if (item != null) {
      rentalItems[match.rentalItemID] = item.copyWith(
        isMatched: true,
        matchedID: matchId,
        rentalStatus: RentalStatus.matchConfirmed,
      );
    }
    changeData();
  }

  // 요청자가 취소: 아이템 상태를 cancelled로 변경
  @override
  void cancelAllMatchesForItem(String rentalItemId) {
    final item = rentalItems[rentalItemId];
    if (item != null) {
      rentalItems[rentalItemId] = item.copyWith(
        isMatched: false,
        clearMatchedID: true,
        rentalStatus: RentalStatus.cancelled,
      );
    }
    changeData();
  }

  // 대여자가 취소: 아이템 상태를 pending으로 되돌리고 매칭 정보 초기화
  @override
  void cancelLenderMatch(String matchId) {
    final match = matches[matchId];
    if (match == null) return;
    final item = rentalItems[match.rentalItemID];
    if (item != null) {
      rentalItems[match.rentalItemID] = item.copyWith(
        isMatched: false,
        clearMatchedID: true,
        rentalStatus: RentalStatus.pending,
      );
    }
    changeData();
  }

  @override
  void updateMatchStatus(String matchId, RentalStatus newStatus) {
    final match = matches[matchId];
    if (match == null) return;
    final item = rentalItems[match.rentalItemID];
    if (item != null) {
      rentalItems[match.rentalItemID] = item.copyWith(rentalStatus: newStatus);
    }
    if (newStatus == RentalStatus.returned) {
      final itemId = match.rentalItemID;
      final lender = users[match.lenderID];
      if (lender != null && !lender.rentalHistory.contains(itemId)) {
        users[match.lenderID] = lender.copyWith(
          rentalHistory: [...lender.rentalHistory, itemId],
        );
      }
      final requester = users[match.requesterID];
      if (requester != null && !requester.rentalHistory.contains(itemId)) {
        users[match.requesterID] = requester.copyWith(
          rentalHistory: [...requester.rentalHistory, itemId],
        );
      }
    }
    changeData();
  }

  // lenderReview = 대여자가 작성 → 요청자(borrower)에 대한 리뷰 → 요청자 score 재계산
  @override
  void updateMatchLenderReview(String matchId, Review newReview) {
    final match = matches[matchId];
    if (match == null) return;
    reviews[newReview.id] = newReview;
    matches[matchId] = match.copyWith(lenderReviewID: newReview.id);
    final item = rentalItems[match.rentalItemID];
    if (item != null) {
      rentalItems[match.rentalItemID] = item.copyWith(
        rentalStatus: RentalStatus.reviewed,
      );
    }
    final newScore = _recalculateScore(match.requesterID);
    final requester = users[match.requesterID];
    if (requester != null) {
      users[match.requesterID] = requester.copyWith(score: newScore);
    }
    changeData();
  }

  // requesterReview = 요청자가 작성 → 대여자(lender)에 대한 리뷰 → 대여자 score 재계산
  @override
  void updateMatchRequesterReview(String matchId, Review newReview) {
    final match = matches[matchId];
    if (match == null) return;
    reviews[newReview.id] = newReview;
    matches[matchId] = match.copyWith(requesterReviewID: newReview.id);
    final item = rentalItems[match.rentalItemID];
    if (item != null) {
      rentalItems[match.rentalItemID] = item.copyWith(
        rentalStatus: RentalStatus.reviewed,
      );
    }
    final newScore = _recalculateScore(match.lenderID);
    final lender = users[match.lenderID];
    if (lender != null) {
      users[match.lenderID] = lender.copyWith(score: newScore);
    }
    changeData();
  }

  double _recalculateScore(String userId) {
    final scores = <int>[];
    for (final match in matches.values) {
      // 이 유저가 requester일 때 → 대여자가 작성한 lenderReview가 이 유저에 대한 리뷰
      if (match.requesterID == userId && match.lenderReviewID != null) {
        final review = reviews[match.lenderReviewID!];
        if (review != null) scores.add(review.score);
      }
      // 이 유저가 lender일 때 → 요청자가 작성한 requesterReview가 이 유저에 대한 리뷰
      if (match.lenderID == userId && match.requesterReviewID != null) {
        final review = reviews[match.requesterReviewID!];
        if (review != null) scores.add(review.score);
      }
    }
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  // ── 채팅 ──────────────────────────────────────────────────────────────────

  @override
  void addChat(String chattingId, Chat chat) {
    final chatting = chattings[chattingId];
    if (chatting != null) {
      chatting.addChat(chat);
      changeData();
    }
  }

  // ── 아이템 목록 ───────────────────────────────────────────────────────────

  @override
  void addRentalItem(RentalItem item) {
    rentalItems[item.id] = item;
    changeData();
  }

  @override
  List<RentalItem> requestRentalItems(User user) {
    return rentalItems.values
        .where((item) => item.requesterID == user.id)
        .toList();
  }

  // 해당 유저가 확정 대여자로 참여한 아이템 목록
  @override
  List<RentalItem> lentRentalItems(User user) {
    return rentalItems.values.where((item) {
      if (!item.isMatched || item.matchedID == null) return false;
      return matches[item.matchedID]?.lenderID == user.id;
    }).toList();
  }

  // 아직 매칭되지 않고, 현재 유저가 요청자가 아닌 아이템
  @override
  List<RentalItem> notMatchedRentalItems(User user) {
    return rentalItems.values
        .where((item) => !item.isMatched && item.requesterID != user.id)
        .toList();
  }
}
