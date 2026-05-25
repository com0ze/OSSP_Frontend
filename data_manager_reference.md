# DataManager 함수 동작 상세 설명

`lib/managers/data_manager.dart`의 서버 호출 함수별 동작을 상세히 설명합니다.

---

## 캐시 구조 요약

DataManager는 싱글턴이며, 모든 데이터를 메모리 캐시로 관리합니다.

| 캐시 맵 | TTL | 비고 |
|--------|-----|------|
| `_users` | 10분 | 원소별 TTL (`_usersCachedTime[id]`) |
| `_reviews` | 없음 | 리뷰 작성 후 로컬에서만 추가, 서버 bulk 조회 없음 |
| `_chattings` | 30초 | 원소별 TTL (`_chattingsCachedTime[id]`) |
| `_matches` | 1분 | `_rentalItems`와 타임스탬프 공유 — rentalItems 조회 시 함께 파싱 |
| `_rentalItems` | 1분 | 원소별 TTL (`_rentalItemsCachedTime[id]`) |

---

## 데이터 조회 함수

### `fetchAvailableRentalItems(String userId)`

**API:** `GET /api/v1/requests/nearby`, `GET /api/v1/requests/me?type=active`, `GET /api/v1/requests/me?type=history` (3개 병렬)

**동작:**
1. `refreshCache(CacheType.rentalItems)`를 호출해 3개 엔드포인트를 병렬로 fetch
2. 응답을 병합해 `_rentalItems`, `_matches`를 전부 교체
3. `changeData()` → `notifyListeners()` 로 UI 갱신

**주의:** `userId` 파라미터는 현재 사용되지 않음. 서버 인증 토큰 기반으로 동작.

---

### `fetchUserProfile(String userId)`

**API:** `GET /api/v1/users/{userId}`

**동작:**
1. `_usersCachedTime[userId]`를 제거해 해당 유저 캐시를 강제 만료
2. `getUserById(userId)` 호출 → 만료 감지 후 단건 재조회 트리거
3. `refreshCache(CacheType.rentalItems)` 추가 호출로 아이템 목록도 갱신
4. `changeData()` → UI 갱신

**비고:** `getUserById`는 fire-and-forget 비동기이므로, 실제 유저 데이터는 콜백이 완료된 후 두 번째 `changeData()`에서 반영됨.

---

### `fetchChatMessages(String chattingId)`

**API:** `GET /api/v1/chats/{chattingId}/messages`

**동작:**
1. 해당 채팅방의 메시지 목록을 서버에서 받아옴
2. `_chattings[chattingId]`를 새 `Chatting` 객체로 교체 (기존 메시지 전부 대체)
3. `_chattingsCachedTime[chattingId]` 갱신
4. `changeData()` → `ChatScreen`의 `_onDataChanged` → `_syncFromChatting()` 실행

---

### `fetchMyData(String userId)`

**API:** rentalItems 3개 + chattings 1개 (병렬)

**동작:**
1. `refreshCache(CacheType.rentalItems)`와 `refreshCache(CacheType.chattings)`를 `Future.wait`로 병렬 실행
2. `_rentalItems`, `_matches`, `_chattings` 전체 갱신
3. `changeData()` → UI 갱신

---

## Lookup 함수 (캐시 조회 + 필요 시 자동 갱신)

### `getUserById(String id)`

**동작:**
- `_usersCachedTime[id]`로 TTL(10분) 확인
- 만료됐으면 `GET /api/v1/users/{id}`를 fire-and-forget으로 호출 → 완료 후 캐시 업데이트 + `changeData()`
- 즉시 `_users[id]`를 반환 (없으면 `User(name: '알 수 없음')` 플레이스홀더 반환)

**패턴:** 첫 호출 시 플레이스홀더가 반환되고, 서버 응답 후 UI가 자동으로 재빌드됨.

---

### `getChattingById(String id)`

**동작:**
- `_chattingsCachedTime[id]`로 TTL(30초) 확인
- 만료됐으면 `fetchChatMessages(id)` 비동기 트리거 (fire-and-forget)
- 즉시 `_chattings[id]` 반환 (`null` 가능)

---

### `getReviewById(String id)`

**동작:** `_reviews[id]` 직접 반환. 서버 단건 조회 없음.  
리뷰는 `updateMatchLenderReview` / `updateMatchRequesterReview` 에서만 로컬 캐시에 추가됨.

---

### `getStatusForUserOnItem(String rentalItemId, String userId)`

**동작:**
- 아이템의 `rentalStatus`와 `matchedID`를 기반으로 현재 사용자의 상태를 반환
- 요청자(`requesterID == userId`)면 아이템의 `rentalStatus` 그대로 반환
- 대여자면 확정 매치의 `lenderID`와 비교:
  - 일치 → `rentalStatus` 반환
  - 불일치 → `RentalStatus.otherUserMatched` 반환 (다른 사람과 매칭된 상태)
- 취소된 경우는 요청자/대여자 구분 없이 `cancelled` 반환

---

### `findMatch(String rentalItemId, String userId)`

**동작:**
- `matches` 중 `rentalItemID`가 일치하는 것 검색
- userId가 requester인지 여부에 따라 `requesterID` 또는 `lenderID`로 매칭
- 없으면 `null` 반환

---

## 매치 생성 / 상태 변경 함수

### `createMatchWithChatting(String rentalItemId, String lenderId)`

**API 순서 (직렬):**
1. `POST /api/v1/requests/{rentalItemId}/accept` — 매치 생성, `matchId` 수령
2. `POST /api/v1/chats` — 채팅방 생성, `roomId` 수령
3. `refreshCache(rentalItems)` + `refreshCache(chattings)` 병렬 갱신
4. `changeData()`

**반환:** 새로 생성된 `Match` 객체 (캐시에 없으면 직접 조립해서 반환)

---

### `confirmMatch(String matchId)`

**API:** `POST /api/v1/requests/{rentalItemId}/accept`

**동작:**
- 실질적으로는 이미 accept 시 ACCEPTED 상태로 생성되므로 no-op에 가까움
- `_rentalItemsCachedTime[rentalItemId]` 만료 → `refreshCache(rentalItems)` → `changeData()`

---

### `cancelMatch(String rentalItemId)`

**API:** `PATCH /api/v1/requests/{rentalItemId}/cancel`

**동작:**
1. 취소 요청 전송
2. `_rentalItemsCachedTime[rentalItemId]` 만료
3. `refreshCache(rentalItems)` → `changeData()`

---

### `updateMatchStatus(String matchId, RentalStatus newStatus)`

**API:**
- `newStatus == inProgress` → `PATCH /api/v1/requests/{rentalItemId}/handover`
- `newStatus == returned` → `PATCH /api/v1/requests/{rentalItemId}/complete`

**동작:**
1. 상태에 따라 다른 엔드포인트 호출
2. `_rentalItemsCachedTime[rentalItemId]` 만료
3. `returned` 상태로 전환 시 lender/requester의 유저 캐시도 함께 만료 (`_usersCachedTime`)
4. `refreshCache(rentalItems)` → `changeData()`

---

## 리뷰 함수

### `updateMatchLenderReview(String matchId, Review newReview)`

**API:** `POST /api/v1/reviews`  
**요청 바디:** `{ matchId, score, comments }`

**대상:** 대여자(lender)가 리뷰를 작성할 때 호출.  
서버는 인증 토큰으로 reviewer를 판단하며, `_matches[matchId].lenderReviewID`에 새 리뷰 ID가 설정됨.

**동작:**
1. POST 요청 전송
2. `_reviews[newReview.id]` 로컬 캐시에 즉시 추가 (서버 재조회 없이 낙관적 반영)
3. `_rentalItemsCachedTime[rentalItemId]` 만료 — 서버의 match 응답에 `lenderReviewID`가 포함되도록 강제 갱신 유발
4. `_usersCachedTime[requesterID]` 만료 — 피리뷰어(requester)의 매너 점수 갱신을 위해
5. `refreshCache(rentalItems)` → `changeData()`

---

### `updateMatchRequesterReview(String matchId, Review newReview)`

**API:** `POST /api/v1/reviews`  
**요청 바디:** `{ matchId, score, comments }`

**대상:** 요청자(requester)가 리뷰를 작성할 때 호출.

**동작:** `updateMatchLenderReview`와 동일 구조.  
차이점: `_usersCachedTime[lenderID]` 만료 (피리뷰어가 lender이므로).

---

## 채팅 함수

### `addChat(String chattingId, Chat chat)`

**API:** `POST /api/v1/chats/{chattingId}/messages`

**동작:**
1. 메시지 전송
2. `fetchChatMessages(chattingId)` 호출로 서버 메시지 목록 재동기화
3. `ChatScreen._onDataChanged` → `_syncFromChatting()` → 새 메시지만 `_messages`에 추가

**비고:** 낙관적 UI 업데이트 없이 서버 응답 후 반영됨.

---

## 아이템 등록 함수

### `addRentalItem(RentalItem item)`

**API:** `POST /api/v1/requests`  
**요청 바디:** `{ itemName, buildingName, rewardAmt, duration, memo, requesterId }`

**동작:**
1. 등록 요청 전송
2. `refreshCache(rentalItems)` — 새 아이템이 목록에 포함되도록 전체 갱신
3. `changeData()` → UI 갱신

---

## 내부 유틸리티 함수

### `refreshCache(CacheType type)`

외부에서 직접 호출하지 않고, 각 public 함수가 내부적으로 사용.

| CacheType | 동작 |
|-----------|------|
| `rentalItems` | 3개 엔드포인트 병렬 fetch → `_rentalItems`, `_matches` 전체 교체 |
| `chattings` | `GET /api/v1/chats?userId=` → `_chattings` 전체 교체 |
| `users` | bulk 엔드포인트 없음 — no-op (on-demand 단건 조회만 사용) |
| `reviews` | bulk 엔드포인트 없음 — no-op (로컬 캐시만 사용) |
| `matches` | `refreshCache(rentalItems)` 위임 — matches는 rentalItems 응답에 포함 |

### `changeData()`

`notifyListeners()`의 alias. `ListenableBuilder`로 구독 중인 모든 위젯을 재빌드 트리거.

### `invalidateCache(CacheType type)` / `_invalidateElement(...)`

각 타임스탬프 맵에서 항목을 제거해 다음 접근 시 stale 판정을 받게 만드는 내부 헬퍼.
