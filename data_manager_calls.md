# DataManager 서버 호출 위치 목록

DataManager의 서버 호출 함수가 외부(화면/위젯)에서 호출되는 위치를 정리한 표입니다.  
`data_manager.dart` 내부 자기호출은 제외합니다.

---

## 호출 위치 전체 표

| 함수 | 호출 파일 | 줄 | 호출 컨텍스트 |
|------|----------|----|--------------|
| `fetchAvailableRentalItems` | `screens/item_detail_screen.dart` | 23 | `RefreshIndicator.onRefresh` — `Future.wait`로 `fetchUserProfile`과 병렬 |
| `fetchAvailableRentalItems` | `screens/rental_list_screen.dart` | 39 | `RefreshIndicator.onRefresh` |
| `fetchUserProfile` | `screens/item_detail_screen.dart` | 26 | `RefreshIndicator.onRefresh` — `Future.wait`로 `fetchAvailableRentalItems`과 병렬 |
| `fetchUserProfile` | `screens/other_user_profile_screen.dart` | 25 | `initState` — 화면 진입 시 1회 |
| `fetchUserProfile` | `screens/other_user_profile_screen.dart` | 59 | `RefreshIndicator.onRefresh` |
| `fetchChatMessages` | `screens/chat_screen.dart` | 64 | `initState` — 화면 진입 시 최신 메시지 갱신 |
| `fetchChatMessages` | `screens/chat_screen.dart` | 87 | `_refreshMessages()` — pull-to-refresh 후 전체 메시지 재동기화 |
| `createMatchWithChatting` | `screens/item_detail_screen.dart` | 366 | `_onChatPressed()` — 대여자가 처음 채팅 버튼 클릭 시 매치+채팅방 동시 생성 |
| `confirmMatch` | `screens/chat_screen.dart` | 179 | `_updateRentalStatus()` — `pending → matchConfirmed` 상태 전환 버튼 |
| `cancelMatch` | `screens/item_detail_screen.dart` | 409 | `_onCancelPressed()` — 취소 다이얼로그 확인 버튼 |
| `updateMatchStatus` | `screens/chat_screen.dart` | 183 | `_updateRentalStatus()` — `matchConfirmed → inProgress` 상태 전환 버튼 |
| `updateMatchStatus` | `screens/chat_screen.dart` | 187 | `_updateRentalStatus()` — `inProgress → returned` 상태 전환 버튼 |
| `updateMatchLenderReview` | `screens/review_screen.dart` | 92 | `_submitReview()` — 대여자(lender)가 리뷰 등록 버튼 클릭 |
| `updateMatchRequesterReview` | `screens/review_screen.dart` | 90 | `_submitReview()` — 요청자(requester)가 리뷰 등록 버튼 클릭 |
| `addChat` | `screens/chat_screen.dart` | 156 | `_receiveMessage()` — 상대방 메시지 수신 시뮬레이션 (테스트용) |
| `addChat` | `screens/chat_screen.dart` | 170 | `_sendMessage()` — 사용자가 전송 버튼 클릭 |
| `addRentalItem` | `screens/rental_request_screen.dart` | 55 | `_submitRequest()` — 대여 요청 폼 제출 버튼 |
| `fetchMyData` | `screens/chatting_list.dart` | 40 | `RefreshIndicator.onRefresh` |
| `fetchMyData` | `screens/user_profile_screen.dart` | 40 | `_refreshMyData()` — `RefreshIndicator.onRefresh` |

---

## 호출 컨텍스트별 분류

| 컨텍스트 | 함수 |
|---------|------|
| **`initState` (화면 진입 시 1회)** | `fetchUserProfile`, `fetchChatMessages` |
| **`RefreshIndicator.onRefresh` (pull-to-refresh)** | `fetchAvailableRentalItems` (×2), `fetchUserProfile` (×2), `fetchMyData` (×2) |
| **상태 전환 버튼 (`_updateRentalStatus`)** | `confirmMatch`, `updateMatchStatus` (×2) |
| **채팅 메시지 송수신** | `addChat` (×2), `fetchChatMessages` |
| **매치 생성/취소** | `createMatchWithChatting`, `cancelMatch` |
| **리뷰 제출** | `updateMatchLenderReview`, `updateMatchRequesterReview` |
| **아이템 등록** | `addRentalItem` |

---

## 참고: 내부 전용 함수 (외부 직접 호출 없음)

| 함수 | 설명 |
|------|------|
| `refreshCache` | `data_manager.dart` 내부에서만 호출. 각 public 함수가 API 호출 후 직접 invoke |
| `initCache` | 싱글턴 생성자의 `_initAsync()`에서 자동 실행. 외부에서 별도 호출 불필요 |
