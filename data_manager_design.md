# DataManager 재설계 문서

## 1. 설계 원칙

| 원칙 | 설명 |
|------|------|
| Lazy init | 앱 시작 시 캐시는 비어 있음. 사용자 상호작용이 발생할 때 on-demand로 로드. |
| Per-element TTL | 개별 원소마다 독립적인 타임스탬프. 만료된 원소만 단건 재조회. |
| 2-tier cache | **목록 tier**(어떤 ID가 속하는지) + **원소 tier**(원소 상세 데이터)로 분리. |
| Fire-and-forget | getter는 동기적으로 현재 캐시를 반환하고, 만료 감지 시 async 재조회를 트리거. |
| Partial update | Write 성공 후 전체 재조회 없이 해당 원소만 `copyWith`로 부분 갱신. |
| Optimistic delete | 삭제 시 캐시에서 먼저 제거한 뒤 서버에 전송. 실패 시 다음 목록 재조회 시 자연 복구. |

---

## 2. 캐시 2-tier 구조

```
[목록 tier]             [원소 tier]
_nearbyItemIds    →  _rentalItems[id]  +  _rentalItemsCachedTime[id]
_myActiveItemIds  →  _rentalItems[id]  +  _rentalItemsCachedTime[id]
_myHistoryItemIds →  _rentalItems[id]  +  _rentalItemsCachedTime[id]
_myChattingIds    →  _chattings[id]    +  _chattingsCachedTime[id]
(on-demand)       →  _users[id]        +  _usersCachedTime[id]
(write-only)      →  _reviews[id]      +  _reviewsCachedTime[id]
(derived)         →  _matches[id]         (rentalItem 조회 시 함께 파싱)
```

**목록 tier** (`_ttlIdList = 1분`):  
서버에서 "어떤 ID들이 이 카테고리에 속하는지"만 조회.  
만료 시 ID 목록만 재조회하고, 각 원소는 원소 TTL로 개별 판단.

**원소 tier** (각자의 TTL):  
ID별 상세 데이터와 개별 타임스탬프. 만료된 원소만 단건 재조회.

---

## 3. TTL 상수

| 대상 | 상수 | 값 | 이유 |
|------|------|----|------|
| User 상세 | `_ttlUser` | 10분 | 점수/정보 변동 드묾 |
| RentalItem 상세 | `_ttlRentalItem` | 5분 | 상태 변경 중간 빈도 |
| Chatting 메시지 | `_ttlChatting` | 30초 | 실시간성 중요 |
| 목록 ID 집합 | `_ttlIdList` | 1분 | 새 아이템 감지 주기 |

---

## 4. 시나리오별 동작 흐름

### 시나리오 1: 앱 시작

```
DataManager() 생성
└─ 생성자에서 _initAsync() 호출하지 않음
└─ 모든 캐시 Map, Set, DateTime? 이 비어 있음
└─ UI 최초 렌더링 시 getter 접근 → 시나리오 2로 진입
```

### 시나리오 2: 데이터 요청 — 캐시 없음 / 원하는 원소 없음

예시: `nearbyRentalItems` getter 접근 (최초)

```
nearbyRentalItems getter 호출
├─ _isListStale(null) == true
│   └─ _refreshNearbyItemIds().then((_) => changeData())  ← fire-and-forget
│       ├─ GET /api/v1/requests/nearby → [{id, ...}, ...]
│       ├─ _nearbyItemIds = {응답의 id들}
│       ├─ _nearbyItemIdsFetchedAt = now
│       └─ for id in 응답:
│           ├─ _isElementStale(id, _rentalItemsCachedTime, _ttlRentalItem) == true (없으므로)
│           └─ _fetchRentalItem(id).catchError((_) {})  ← fire-and-forget
│               ├─ GET /api/v1/requests/{id}  ← 단건 API 필요 (현재 없음 → 아래 주의사항 참고)
│               ├─ _rentalItems[id] = RentalItem.fromJson(res.data)
│               ├─ _touchElement(_rentalItemsCachedTime, id)
│               └─ changeData()  ← UI 재빌드
└─ 현재 _nearbyItemIds ∩ _rentalItems.keys 반환 (초기엔 빈 목록)
   → 조회 완료 후 changeData()로 UI 다시 렌더링
```

> **주의**: RentalItem 단건 조회 API(`GET /api/v1/requests/{id}`)가 없으면,  
> `_refreshNearbyItemIds()`에서 목록 응답에 원소 상세도 함께 파싱해 원소 캐시에 바로 등록한다.  
> 이 경우 `_fetchRentalItem`은 no-op.

### 시나리오 3: 데이터 요청 — 캐시에 있지만 원소 TTL 만료

예시: `getUserById('42')` 호출 (10분 경과)

```
getUserById('42') 호출
├─ _isElementStale('42', _usersCachedTime, _ttlUser) == true
│   └─ _fetchUser('42').catchError((_) {})  ← fire-and-forget
│       ├─ GET /api/v1/users/42
│       ├─ existing = _users['42']
│       ├─ existing != null
│       │   → _users['42'] = existing.copyWith(name: ..., score: ...)  ← 부분 갱신
│       └─ existing == null
│           → _users['42'] = User.fromJson(res.data)  ← 신규 등록
│       ├─ _touchElement(_usersCachedTime, '42')
│       └─ changeData()
└─ 현재 캐시 값 _users['42'] (만료 전 데이터) 즉시 반환
   → 재조회 완료 후 changeData()로 UI 재빌드
```

### 시나리오 4-A: Write — 생성 (create)

예시: `addRentalItem(item)` 호출

```
addRentalItem(item) 호출
├─ POST /api/v1/requests  {item.toJson()}
├─ 서버 응답에서 생성된 RentalItem 파싱 (서버 부여 id 포함)
│   newItem = RentalItem.fromJson(res.data)
├─ _rentalItems[newItem.id] = newItem
├─ _myActiveItemIds.add(newItem.id)
├─ _touchElement(_rentalItemsCachedTime, newItem.id)
└─ changeData()
```

예시: `createMatchWithChatting(rentalItemId, lenderId)` 호출

```
createMatchWithChatting(rentalItemId, lenderId) 호출
├─ POST /api/v1/requests/{rentalItemId}/accept  {providerId: lenderId}
│   → {matchId, requestId, requesterId, providerId}
├─ POST /api/v1/chats  {matchId}
│   → {roomId}
├─ _matches[matchId] = Match(matchId, rentalItemId, requesterId, lenderId, roomId)
├─ _chattings[roomId] = Chatting(id: roomId, chats: [])
├─ _myChattingIds.add(roomId)
├─ _rentalItems[rentalItemId] = existing.copyWith(
│     isMatched: true, matchedID: matchId,
│     rentalStatus: RentalStatus.matchConfirmed)
├─ _touchElement(_rentalItemsCachedTime, rentalItemId)
├─ _touchElement(_chattingsCachedTime, roomId)
└─ changeData()
```

### 시나리오 4-B: Write — 갱신 (update)

예시: `updateMatchStatus(matchId, RentalStatus.inProgress)` 호출

```
updateMatchStatus(matchId, newStatus) 호출
├─ rentalItemId = _matches[matchId]?.rentalItemID
├─ PATCH /api/v1/requests/{rentalItemId}/handover  (inProgress)
│  PATCH /api/v1/requests/{rentalItemId}/complete  (returned)
├─ _rentalItems[rentalItemId] =
│     _rentalItems[rentalItemId]!.copyWith(rentalStatus: newStatus)
├─ _touchElement(_rentalItemsCachedTime, rentalItemId)
├─ (returned인 경우) 관련 유저 점수 만료
│   _evictTimestamp(_usersCachedTime, match.lenderID)
│   _evictTimestamp(_usersCachedTime, match.requesterID)
│   → 다음 getUserById 호출 시 서버에서 갱신된 점수 재조회
└─ changeData()
```

예시: `updateMatchLenderReview(matchId, review)` 호출

```
updateMatchLenderReview(matchId, review) 호출
├─ match = _matches[matchId]
├─ POST /api/v1/reviews  {reviewerId: lenderID, revieweeId: requesterID, score, comments}
├─ _reviews[review.id] = review                      ← 리뷰 로컬 등록
├─ _touchElement(_reviewsCachedTime, review.id)
├─ _rentalItems[rentalItemId] =
│     _rentalItems[rentalItemId]!.copyWith(rentalStatus: RentalStatus.reviewed)
├─ _touchElement(_rentalItemsCachedTime, rentalItemId)
├─ _evictTimestamp(_usersCachedTime, match.requesterID)  ← 피리뷰어 점수 만료
└─ changeData()
```

### 시나리오 5: Write — 삭제 (낙관적 갱신)

예시: `cancelMatch(rentalItemId)` 호출

```
cancelMatch(rentalItemId) 호출
├─ 1. 캐시에서 먼저 제거 (낙관적 갱신 — UI 즉시 반영)
│   ├─ _rentalItems.remove(rentalItemId)
│   ├─ _evictTimestamp(_rentalItemsCachedTime, rentalItemId)
│   ├─ _nearbyItemIds.remove(rentalItemId)
│   ├─ _myActiveItemIds.remove(rentalItemId)
│   └─ changeData()
├─ 2. 서버에 전송
│   PATCH /api/v1/requests/{rentalItemId}/cancel
└─ 3. 실패 시: 다음 _refreshNearbyItemIds / _refreshMyActiveItemIds 때 자연 복구
```

---

## 5. 개별 함수 로직 명세

### `_isElementStale(id, timestamps, ttl)`
```
t = timestamps[id]
if t == null: return true   ← 캐시에 없음
return DateTime.now() - t > ttl
```

### `_isListStale(fetchedAt)`
```
if fetchedAt == null: return true   ← 한 번도 조회 안 함
return DateTime.now() - fetchedAt > _ttlIdList
```

### `_touchElement(timestamps, id)`
```
timestamps[id] = DateTime.now()
```

### `_evictTimestamp(timestamps, id)`
```
timestamps.remove(id)
// 데이터 Map에서의 제거는 호출부에서 명시적으로 수행
```

### `_fetchUser(id)`
```
res = await GET /api/v1/users/{id}
existing = _users[id]
_users[id] = existing?.copyWith(
  name: res.data['name'],
  email: res.data['email'],
  score: res.data['score'],
) ?? User.fromJson(res.data)
_touchElement(_usersCachedTime, id)
changeData()
```

### `_fetchRentalItem(id)`
```
// 단건 API가 있을 때:
res = await GET /api/v1/requests/{id}
existing = _rentalItems[id]
_rentalItems[id] = existing?.copyWith(...) ?? RentalItem.fromJson(res.data)
_touchElement(_rentalItemsCachedTime, id)
changeData()

// 단건 API가 없을 때 (현재):
// no-op — 목록 재조회(_refreshNearbyItemIds 등) 시 원소도 함께 갱신됨
```

### `_fetchChatMessages(id)`
```
res = await GET /api/v1/chats/{id}/messages
messages = (res.data as List).map(Chat.fromJson).toList()
_chattings[id] = Chatting(id: id, chats: messages)
_touchElement(_chattingsCachedTime, id)
changeData()
```

### `_refreshNearbyItemIds()`
```
res = await GET /api/v1/requests/nearby
newIds = Set<String>()
now = DateTime.now()

for json in res.data:
  item = RentalItem.fromJson(json)    ← 목록 응답에 상세 포함 시
  newIds.add(item.id)
  _rentalItems[item.id] = item
  _touchElement(_rentalItemsCachedTime, item.id)
  // Match 포함 시 함께 파싱
  if json['matchId'] != null:
    match = Match.fromJson(json)
    _matches[match.matchID] = match

_nearbyItemIds = newIds
_nearbyItemIdsFetchedAt = now
```

### `_refreshMyChattingIds()`
```
userId = LoginManager().currentUser?.id ?? ''
res = await GET /api/v1/chats?userId={userId}
newIds = Set<String>()
now = DateTime.now()

for json in res.data:
  ch = Chatting.fromJson(json)    ← messages 포함됨
  newIds.add(ch.id)
  _chattings[ch.id] = ch
  _touchElement(_chattingsCachedTime, ch.id)

_myChattingIds = newIds
_myChattingIdsFetchedAt = now
```

### `nearbyRentalItems` (getter)
```
if _isListStale(_nearbyItemIdsFetchedAt):
  _refreshNearbyItemIds().then((_) => changeData())   ← fire-and-forget

// 현재 캐시에 있는 원소만 반환 (목록 재조회 후 changeData로 UI 재빌드)
return _nearbyItemIds
    .map((id) => _rentalItems[id])
    .whereType<RentalItem>()
    .toList()
```

### `getUserById(id)` (getter)
```
if _isElementStale(id, _usersCachedTime, _ttlUser):
  _fetchUser(id).catchError((_) {})   ← fire-and-forget

return _users[id] ?? User(id: id, name: '알 수 없음', email: '')
```

### `getChattingById(id)` (getter)
```
if _isElementStale(id, _chattingsCachedTime, _ttlChatting):
  _fetchChatMessages(id).catchError((_) {})   ← fire-and-forget

return _chattings[id]
```

### `addChat(chattingId, chat)`
```
await POST /api/v1/chats/{chattingId}/messages  {chat.toJson()}
// 낙관적 갱신: 서버 응답 기다리지 않고 로컬에 바로 추가
existing = _chattings[chattingId]
if existing != null:
  _chattings[chattingId] = existing.copyWith(
    chats: [...existing.chats, chat])
_touchElement(_chattingsCachedTime, chattingId)
changeData()
// 또는: _evictTimestamp 후 다음 getChattingById 호출 시 서버에서 전체 재조회
```

---

## 6. 현재 구현과의 주요 차이점

| 항목 | 현재 `data_manager.dart` | 새 설계 |
|------|--------------------------|---------|
| 앱 시작 | `_initAsync()`로 전체 사전 조회 | 캐시 비어 있음, on-demand |
| 만료 감지 단위 | 컬렉션 전체 (`_isCollectionStale`) | 원소 단위 (`_isElementStale`) |
| 만료 시 조회 범위 | 전체 bulk refresh | 해당 원소만 단건 조회 |
| Write 후 처리 | `refreshCache(전체)` | `copyWith` 부분 갱신 |
| 목록 관리 | 없음 (bulk로 전체 덮어씀) | ID 집합 별도 관리 |
| 삭제 순서 | 서버 → 캐시 | 캐시 → 서버 (낙관적 갱신) |
| `_matches` 갱신 | bulk refresh 시 전체 재파싱 | 목록 재조회 시 함께 파싱 / write 시 직접 등록 |

---

## 7. 제약 및 주의사항

1. **RentalItem 단건 API 없음**  
   현재 API에 `GET /api/v1/requests/{id}` 엔드포인트가 없으므로, `_fetchRentalItem`은 no-op.  
   원소 갱신은 목록 재조회(`_refreshNearbyItemIds` 등) 시 함께 이루어짐.  
   → 향후 단건 API 추가 시 진정한 per-element 갱신 가능.

2. **목록 TTL과 원소 TTL의 관계**  
   `_ttlIdList(1분) < _ttlRentalItem(5분)`이면, 목록이 원소보다 먼저 만료되어 목록 재조회 시 원소 타임스탬프도 함께 갱신됨.  
   실질적으로 원소 단건 재조회가 일어나는 경우는 `_ttlIdList`보다 `_ttlRentalItem`이 짧을 때임.

3. **낙관적 갱신 실패 처리**  
   서버 전송 실패 시 로컬 캐시가 서버 상태와 불일치할 수 있음.  
   다음 목록 재조회 시 서버 상태로 자연 복구됨.  
   사용자 경험상 즉각적인 롤백이 필요하다면 실패 핸들러에서 캐시를 명시적으로 복구해야 함.
