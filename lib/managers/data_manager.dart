import 'package:flutter/material.dart';
import 'package:open_source_software/models/chat.dart';
import 'package:open_source_software/models/chatting.dart';
import 'package:open_source_software/models/match.dart';
import 'package:open_source_software/models/rental_item.dart';
import 'package:open_source_software/models/review.dart';
import 'package:open_source_software/models/user.dart';

enum CacheType { users, reviews, chattings, matches, rentalItems }

abstract class DataManager extends ChangeNotifier {
  Map<String, User> get users;
  Map<String, Review> get reviews;
  Map<String, Chatting> get chattings;
  Map<String, Match> get matches;
  Map<String, RentalItem> get rentalItems;

  // ── Lookups ───────────────────────────────────────────────────────────────

  User getUserById(String id);

  Review? getReviewById(String id) => reviews[id];

  Chatting? getChattingById(String id) => chattings[id];

  // 특정 아이템에서 해당 유저(요청자 또는 대여자)가 참여한 매치를 반환
  Match? findMatch(String rentalItemId, String userId);

  String? getMatchedLenderIdForItem(String rentalItemId);

  RentalStatus getStatusForUserOnItem(String rentalItemId, String userId);

  // ── Match 생성 ─────────────────────────────────────────────────────────────

  // 대여자가 새 매치 + 채팅방을 생성
  Match createMatchWithChatting(String rentalItemId, String lenderId);

  // ── Match 상태 변경 ────────────────────────────────────────────────────────

  // pending → matchConfirmed: 아이템 상태 및 isMatched/matchedID 업데이트
  void confirmMatch(String matchId);

  // 요청자가 취소: 아이템 상태를 cancelled로 변경
  void cancelAllMatchesForItem(String rentalItemId);

  // 대여자가 취소: 아이템 상태를 pending으로 되돌리고 매칭 정보 초기화
  void cancelLenderMatch(String matchId);

  void updateMatchStatus(String matchId, RentalStatus newStatus);

  // lenderReview = 대여자가 작성 → 요청자(borrower)에 대한 리뷰 → 요청자 score 재계산
  void updateMatchLenderReview(String matchId, Review newReview);

  // requesterReview = 요청자가 작성 → 대여자(lender)에 대한 리뷰 → 대여자 score 재계산
  void updateMatchRequesterReview(String matchId, Review newReview);

  // ── 채팅 ──────────────────────────────────────────────────────────────────

  void addChat(String chattingId, Chat chat);

  // ── 아이템 목록 ───────────────────────────────────────────────────────────

  void addRentalItem(RentalItem item);

  List<RentalItem> requestRentalItems(User user);

  // ── 서버 데이터 페치 ──────────────────────────────────────────────────────────

  // 앱 시작 or 전체 새로고침: 내 rentalItems·matches·reviews·상대방 users
  Future<void> fetchMyData(String userId);

  // 홈 화면 대여 가능한 rentalItem 목록 갱신
  Future<void> fetchAvailableRentalItems(String userId);

  // 특정 유저 프로필 + 받은 리뷰 갱신 (화면 진입 시 항상 호출)
  Future<void> fetchUserProfile(String userId);

  // 특정 채팅방 메시지 갱신 (채팅방 진입 시 항상 호출)
  Future<void> fetchChatMessages(String chattingId);

  // 해당 유저가 확정 대여자로 참여한 아이템 목록
  List<RentalItem> lentRentalItems(User user);

  // 아직 매칭되지 않고, 현재 유저가 요청자가 아닌 아이템
  List<RentalItem> notMatchedRentalItems(User user);

  void changeData() {
    notifyListeners();
  }
}
