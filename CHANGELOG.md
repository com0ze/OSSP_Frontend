- # feature/update
    - ## version: 1.0.0
        - ### commit: 채팅 기능 업데이트
            - #### author: Seo JeongHun
            - #### date: 2026-05-02
            - feature: 
                - 채팅 창에서 상대방 채팅도 만들어서 시뮬레이션 할 수 있게 구현 (화면에 있는 버튼이 아니라 키보드 엔터누르면 상대방이 작성한 것 처럼 작동)
                - 채팅 메시지 버블 함수로 분리
                - 채팅 메시지 추가시 동작 구현
                    - 스크롤이 제일 아래로 내려와있는 경우는 그 메시지가 바로 아래에 추가되고 기존은 위로 밀리도록 구현
                    - 스크롤이 아래가 아닌 위로 올라와있어 과거 메시지를 확인하는 경우
                        - 상대방 메시지 도착 시, 이를 버퍼 리스트에 저장하고 아래로 스크롤하거나 플로팅 버튼을 누르면 추가되게 함
                            - 이를 통해서 과거 메시지를 보는 동안에는 새로운 메시지가 와도 스크롤이 움직이지 않음
                            - 플로팅 버튼을 누르면 아래로 자동으로 스크롤될 수 있도록 구현함
                        - 위의 메시지를 보면서, 사용자가 메시지를 보내는 경우 자동으로 아래로 스크롤되며 버퍼 리스트에 쌓인 메시지 버블을 생성함

                - 테마 모드 설정 버튼이 배경색을 가지도록 구현, 이를 통해 현재 설정값 확인할 수 있게 함
                - 테마 모드 설정 버튼을 함수로 분리

                - 리뷰 화면 별점 크기 동적으로 바뀌도록 수정

                - 업데이트 기록을 남기기 위해서 커밋 별로 수정 사항 작성하는 CHANGELOG.md추가

        - ### commit: 물건 상세정보 페이지 수정
            - #### author: Seo JeongHun
            - #### date: 2026-05-02
            - feature: 
                - 물건 상세정보 페이지의 채팅하기 버튼 색 변경

        - ### commit: 앱 이름 반영
            - #### author: Seo JeongHun
            - #### date: 2026-05-03
            - feature: 
                - 물건 상세정보 페이지의 채팅하기 버튼 색 변경 로직 통일
                - 물건 대여 요청 버튼 색 변경
                - 로그인 창에 앱 이름 반영
                - 홈 네비게이션 바 아이콘 버그 수정
                
        - ### commit: CHANGELOG.md 수정
            - #### author: Seo JeongHun
            - #### date: 2026-05-03
            - feature:
                - changelog.md의 계층 구조 변경
                - days -> date로 변경
                
    - ## version: 1.1.0
        - ### commit: 브랜치 통합
            - #### author: Seo JeongHun, Lee JaeWon
            - #### date: 2026-05-24
            - feature: 
                - 브랜치 통합
                
- # feature/notification
    - ## version: 1.0.1
        - ### commit: notification manager 생성
            - #### author: Lee JaeWon
            - #### date: 2026-05-02
            - feature: 
                - notification_manager.dart 생성

    - ## version: 1.1.0
        - ### commit: 알림 기능 구현
            - #### author: Lee JaeWon
            - #### date: 2026-05-23
            - feature: 
                - 안드로이드 알림 기능 구현
                    - 포어그라운드 기반
                    - 채팅 기능 구현 시 사용할 예정
                    - 현재 화면이 채팅방이 아닌 경우 알림 발생,  채팅방이어도 다른 채팅방이면 알림 발생
    
    - ## version: 1.1.0
        - ### commit: 웹 디버그용 mock제작
            - #### author: Seo JeongHun
            - #### date: 2026-05-24
            - feature: 
                - 아이폰 알림 코드 수정
                    - 아이폰은 앱 켜져있을 시 알림 X -> 소리와 앱 아이콘 만 표시
                - 웹 또는 윈도우에서 테스트 가능하도록 notification_manager 종류를 여러개로 나눔
                    - 웹 또는 윈도우인 경우 알림 대신 로그 출력
                         
- # feature/data_widget_refactoring
    - ## version: 1.1.0
        - ### comiit: UI개선 및 구조 리팩토링
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - 데이터 모델 리팩토링
                    - 기존 Deal, DealStatus, Duration 모델 삭제
                    - Match, Chatting 모델로 대체하여 대여 흐름 명확화
                    - RentalStatus enum을 별도 파일(models/rental_status.dart)로 분리
                    - RentalStatus에 cancelled, otherUserMatched 상태 추가
                    - Match.chattingID를 non-nullable(필수값)로 변경

                - TestDataManager 싱글톤 도입
                    - ChangeNotifier 기반 중앙화된 데이터 저장소 구현
                    - ListenableBuilder를 활용한 반응형 UI 상태 관리 전환
                    - 매칭 생성/확정/상태변경/취소 등 비즈니스 로직 일원화

                - 위젯 팩토리 패턴 도입
                    - WidgetFactory 추상 클래스 기반 팩토리 패턴 적용
                    - 기존 show_*.dart 위젯들을 *_widget_factory.dart로 전면 교체
                    - ChatWidgetFactory, ChattingRoomWidgetFactory, RentalItemWidgetFactory, ReviewWidgetFactory 구현

                - 채팅 기능 개선
                    - 내가 참여한 매치 목록을 보여주는 채팅 목록(ChattingList) 화면 추가
                    - 채팅방 카드에 상대방 이름, 물건명, 마지막 메시지, 시간, 진행 상태 표시
                    - 채팅창 상단 우측에 물건 상세정보 이동 버튼 추가
                    - 채팅창에서 대여 상태(pending → matchConfirmed → inProgress → returned → reviewed) 단계별 진행 구현

                - 대여 흐름 완성
                    - 매칭 확정 시 동일 아이템의 나머지 매치를 otherUserMatched로 자동 전환
                    - 반납 완료 시 요청자·대여자 양측 rentalHistory에 아이템 자동 추가
                    - 리뷰 작성 시 상대방 score를 수신한 전체 리뷰 평균으로 자동 재계산
                    - 요청자 취소: 해당 아이템의 모든 매치를 cancelled로 처리
                    - 대여자 취소: 본인 매치 cancelled, 나머지 매치를 pending으로 복원, 아이템 상태 초기화

                - 물건 상세정보 페이지 개선
                    - 현재 사용자 역할(요청자/대여자)에 따라 버튼 조건부 표시
                    - 요청자: 매칭 확정 전에는 채팅하기 버튼 숨김
                    - 대여 전 상태(pending, matchConfirmed)에만 취소하기 버튼 노출
                    - 취소 전 확인 다이얼로그 표시

                - 마이페이지 개선
                    - 빌린 물건 / 빌려준 물건 / 받은 리뷰 탭으로 구성
                    - 빌린 물건 탭에서 매칭 확정 전에는 상대방 정보 대신 '매칭 대기 중' 표시
                    - 받은 리뷰 탭에서 본인이 아닌 타인이 작성한 리뷰만 표시

                - 홈 네비게이션 개선
                    - 채팅 탭 추가
                    - BottomNavigationBarType.fixed 적용으로 4개 탭 색상 유지

        - ### commit: 취소 기능 및 상태 관리 구조 개선
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - 상태 관리 구조 변경 (Match → RentalItem)
                    - Match.rentalStatus 제거, RentalItem.rentalStatus로 이전
                    - 아이템 단위로 대여 상태를 일원 관리하여 일관성 향상
                    - getStatusForUserOnItem 로직 재구현
                        - 요청자: 아이템 실제 상태 표시
                        - 확정된 대여자: 아이템 실제 상태 표시
                        - 미확정 대여자: otherUserMatched 또는 pending으로 계산
                        - 취소된 아이템: 모든 참여자에게 cancelled 표시

                - 취소 기능 구현
                    - 물건 상세정보 페이지에 역할별 취소하기 버튼 추가
                    - 요청자 취소: 아이템 자체를 cancelled 상태로 변경
                    - 대여자 취소(확정 후): 아이템을 pending으로 되돌려 다른 대여자가 매칭 가능하게 복원
                    - 취소 전 확인 다이얼로그 표시
                    - 취소 완료 후 취소하기 버튼 자동 소멸
                    - 요청자는 매칭 전(대기 중)에도 취소하기 버튼 표시

        - ### commit: DataManager 추상화 및 의존성 역전 적용
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - DataManager 추상 클래스 도입 (managers/data_manager.dart 신규 생성)
                    - ChangeNotifier를 상속하는 DataManager 추상 클래스 정의
                    - 데이터 접근(users, reviews, chattings, matches, rentalItems)을 추상 getter로 선언
                    - 모든 비즈니스 로직 메서드(getUserById, findMatch, confirmMatch 등)를 추상 인터페이스로 정의
                    - changeData() 메서드를 추상 클래스로 이전하여 중복 제거

                - TestDataManager 리팩토링
                    - ChangeNotifier 직접 상속에서 DataManager 상속으로 변경
                    - private 필드(_users, _reviews 등)를 DataManager 규약에 맞게 공개 필드로 변경
                    - @override 어노테이션 추가로 인터페이스 구현 명시

                - 화면 및 위젯에서 의존성 역전 적용
                    - 모든 화면(chatting_list, lender_profile, other_user_profile, rental_list, rental_request, review, user_profile)에서 TestDataManager 타입 대신 DataManager 타입으로 변수 선언
                    - rental_item_widget_factory도 동일하게 DataManager 타입 참조로 전환
                    - 구체 구현(TestDataManager)이 아닌 추상 인터페이스(DataManager)에 의존하도록 구조 개선

- # feature/login
    - ## version: 1.1.0
        - ### commit: ID, PW 검증 로직 추가
            - #### author: Seo JeongHun
            - #### date: 2026-05-02
            - feature
                - ID 검증 로직 추가
                    1. 빈 값 검증
                    2. 이메일 형식 확인
                    3. 이메일 도메인 확인
                - PW 검증 로직 추가
                    1. 빈 값 확인
                    2. 길이 확인
                    3. 허용 불가 특수문자 확인
                    4. 필수 포함 요소 검사

        - ### commit: JWT 기반 서버 통신 및 자동 로그인 구현
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - 의존성 추가
                    - dio: HTTP 클라이언트 라이브러리
                    - flutter_secure_storage: 토큰 보안 저장소

                - api/ 폴더 신설 및 서버 통신 구조 구축
                    - ApiClient: Dio 싱글톤 생성 및 인터셉터 등록 관리
                    - AuthInterceptor: 모든 요청에 액세스 토큰 자동 주입, 401 응답 시 리프레시 토큰으로 자동 갱신 후 원래 요청 재시도, 갱신 실패 시 자동 로그아웃
                    - MockServerInterceptor: 실제 서버 없이 테스트 가능한 가짜 서버 구현 (login, register, refresh, logout, me 엔드포인트 지원, 실제 서버 연결 시 삭제 예정)
                    - TokenStorageManager: FlutterSecureStorage 기반 액세스/리프레시/FCM 토큰 관리 싱글톤

                - LoginManager 서버 통신 적용
                    - login(): ApiClient를 통한 /login API 호출로 교체, 응답에서 토큰 추출 후 저장
                    - register(): ApiClient를 통한 /register API 호출로 교체
                    - initAutoLogin(): /me API로 저장된 토큰 유효성 검증 후 유저 정보 복원, 갱신도 실패하면 토큰 파기
                    - logout(): 서버에 /logout 요청 후 로컬 토큰 파기 (서버 실패 시에도 로컬은 반드시 초기화)
                    - 중복 토큰 관리 제거: LoginManager 내 FlutterSecureStorage 직접 사용을 TokenStorageManager 위임으로 통일

                - 자동 로그인 구현
                    - 앱 시작 시 initAutoLogin() 호출 후 runApp 실행
                    - 로그인 상태에 따라 초기 화면 분기 (로그인 성공 → HomeNavigation, 미로그인 → LoginScreen)

                - 회원가입 화면 추가 (signin_screen.dart 신규 생성)
                    - 이름, 이메일, 비밀번호, 비밀번호 확인 입력 필드 구성
                    - 이메일·비밀번호 검증은 LoginManager 기존 로직 재사용
                    - 비밀번호 확인 불일치 시 에러 표시
                    - 회원가입 성공 시 로그인 화면 스택 제거 후 HomeNavigation 진입
                    - 로그인 화면 회원가입 버튼 → SigninScreen 연결
                    
        - ### commit: import 경로 절대 경로로 수정
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature: import 경로 절대 경로로 수정

- # feature/api
    - ## version: 1.1.0
        - ### commit: 서버 통신 및 캐시 구조 개선
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - TestDataManager 전면 개편
                    - TTL(Time-To-Live) 기반 캐시 만료 관리 도입 (users 10분, reviews 5분, chattings 30초, matches·rentalItems 1분)
                    - 공개 getter에서 TTL 만료 감지 시 자동 캐시 갱신 트리거
                    - `_scheduleChangeData()` 디바운싱 추가: 같은 프레임 내 여러 getter가 동시에 만료되어도 `changeData()`는 프레임당 한 번만 실행
                    - 캐시 미스(`getUserById`, `getReviewById`, `getChattingById`) 시 서버에서 즉시 재조회 후 다음 프레임에 UI 갱신
                    - `confirmMatch`, `cancelAllMatchesForItem`, `cancelLenderMatch`, `updateMatchStatus` 상태 변경 시 `matches` 캐시도 함께 갱신하여 화면 간 데이터 일관성 보장
                    - `requestRentalItems`, `lentRentalItems`, `notMatchedRentalItems`, `findMatch` 등 계산 메서드에서 private 필드 대신 TTL이 적용된 public getter 사용

                - DataManager 추상 인터페이스에 fetch 메서드 추가
                    - `fetchMyData`, `fetchAvailableRentalItems`, `fetchUserProfile`, `fetchChatMessages` 추상 메서드 선언

                - 물건 상세정보 페이지 새로고침 로직 수정
                    - `onRefresh` 시 `fetchAvailableRentalItems`와 `fetchUserProfile`을 `Future.wait`로 병렬 실행

        - ### commit: 인증 및 로그인 개선
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - `LoginManager.forceLogout` 메서드 추가
                    - 동시에 여러 곳에서 호출되어도 한 번만 실행되도록 `_isLoggingOut` 플래그로 보호
                    - 로그아웃 후 등록된 핸들러(`_forceLogoutHandler`)를 호출하여 화면 전환 처리

                - 설정 화면에 로그아웃 버튼 추가
                    - `setting_screen.dart` 상단에 로그아웃 ListTile 추가
                    - 탭 시 `LoginManager().forceLogout('로그아웃되었습니다.')` 호출

                - 전역 키 기반 네비게이션 구현 (`app_keys.dart` 신규 생성)
                    - `navigatorKey`, `scaffoldMessengerKey` GlobalKey 선언
                    - `MaterialApp`에 등록하여 BuildContext 없이 화면 전환 및 스낵바 표시 가능

                - `main.dart`에 로그아웃 핸들러 등록
                    - 로그아웃 또는 토큰 만료 시 LoginScreen으로 이동하고 스낵바로 메시지 표시

                - `AuthInterceptor` 동시 401 경쟁 조건 수정
                    - `static Future<String>? _refreshFuture` 도입으로 동시 다발 401 응답 시 토큰 갱신 요청이 한 번만 전송되도록 보장
                    - `_doRefresh()` 헬퍼 메서드 분리
                    - `finally` 블록에서 Future 초기화하여 다음 401에서 새로 시도 가능

        - ### commit: 사용자 프로필 화면 개선
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - 사용자 정보 영역에서만 새로고침 기능 제공
                    - `Column` 레이아웃으로 사용자 정보 헤더·탭 바를 상단에 고정
                    - `RefreshIndicator`를 사용자 정보 헤더 영역에만 적용 (탭·콘텐츠에는 새로고침 없음)
                    - 새로고침 시 `fetchMyData` 호출하여 사용자 정보 및 3개 탭의 데이터 일괄 갱신

        - ### commit: 버그 수정
            - #### author: Seo JeongHun
            - #### date: 2026-05-23
            - feature:
                - `chat_screen.dart` 리소스 누수 및 리스너 관리 수정
                    - `_scrollController.dispose()` 누락 수정
                    - `ListenableBuilder.builder` 내부에서 `addPostFrameCallback(() => _syncFromChatting())`을 매 리빌드마다 등록하던 버그 제거 (콜백 누적 문제)
                    - `initState`에서 `dataManager.addListener(_onDataChanged)` 등록, `dispose`에서 제거하여 올바른 리스너 수명 주기 관리

                - 모델 직렬화 보완
                    - `rental_item.dart`: `fromJson`/`toJson`에 `rentalStatus` 필드 추가 (누락 시 서버 왕복 후 상태 초기화되는 버그)
                    - `match.dart`: `fromJson`, `toJson` 메서드 신규 추가
                    - `main_user.dart`: `copyWith`에서 `id: this.id`로 하드코딩되어 `id` 파라미터가 무시되던 버그 수정 → `id: id ?? this.id`
                    - `user.dart`: `addRentalHistory` 메서드명 오타 수정(`addrentalHistory` → `addRentalHistory`), 생성자에서 `List<String>.from(...)` 사용으로 항상 가변 리스트 생성 보장

                - 리뷰 ID 충돌로 인한 데이터 소실 수정 (`review_screen.dart`)
                    - 리뷰 ID를 `matchID`로 고정하면 대여자·요청자 리뷰가 동일한 키에 저장되어 먼저 제출한 리뷰가 덮어써지는 버그 수정
                    - `'${matchID}_${reviewee.id}'` 형태로 변경하여 리뷰 ID 충돌 방지

                - `ChatWidgetFactory` 파라미터 버그 수정
                    - 내부에서 `currentUserId` 파라미터를 무시하고 `LoginManager().currentUser`를 직접 조회하던 문제 수정 → 전달받은 `currentUserId` 사용
                    - `chat_screen.dart` 호출부에서 `message.sendUser.id` (발신자 ID)를 잘못 전달하던 문제 수정 → `loginManager.currentUserOrGuest.id` 전달

                - `UserInfoHeader`의 불필요한 `ListenableBuilder` 제거 (`lender_profile_screen.dart`)
                    - 헤더가 `user` 파라미터만 표시하면서도 모든 캐시 변경 시마다 리빌드되던 문제 수정
                    - 부모 화면의 `ListenableBuilder`에서 이미 최신 `User`를 받아 넘기므로 중복 구독 불필요

                - `other_user_profile_screen.dart` `initState` 에러 처리 추가
                    - `fetchUserProfile` 호출 결과에 `.ignore()` 추가하여 미처리 Future 경고 제거

                - `item_detail_screen.dart` 중복 `DataManager` 지역 변수 제거
                    - `_onChatPressed`, `_onCancelPressed` 내부의 `DataManager dataManager = TestDataManager()` 중복 선언 제거

        - ### commit: api 관리자 통합
            - #### author: Seo JeongHun
            - #### date: 2026-05-24
            - feature:
                - 브랜치 통합으로 인한 api관리자 중복 제거

        - ### commit: api 통신 방식 변경
            - #### author: Seo JeongHun
            - #### date: 2026-05-24
            - feature:
                - import 주소 단순화
                - 각 클래스 별 TTL 도입
                - mock서버에서 클론뜨는 게 아니라 실제로 통신하는 것 처럼 구현

        - ### commit: 데이터 매니저 교체
            - #### author: Seo JeongHun
            - #### date: 2026-05-25
            - feature:
                - **STOMP 실시간 채팅 클라이언트 구현** (`lib/chat/stomp_client.dart` 신규)
                    - WebSocket + STOMP 프로토콜 기반 `ChatStompClient` 클래스 추가
                    - STOMP 프레임 수동 파싱 (CONNECT / SUBSCRIBE / SEND / DISCONNECT)
                    - 채널 구독·해제 및 메시지 발행 기능 구현
                    - `chat_screen.dart`에 연동하여 실시간 메시지 송수신 적용

                - **DataManager 완전 교체 및 API 정합성 확보** (`data_manager.dart`)
                    - `getUserReceivedReview(userId)` 메서드 추가: `revieweeId` 기반으로 받은 리뷰 필터링
                    - `getUserWriteReview(userId)` 메서드 추가: `writerId` 기반으로 작성한 리뷰 필터링
                    - `getStatusForUserOnItem(itemId, userId)` 시그니처 변경: async 제거 → 동기 2-인자 메서드로 단순화
                    - 취소 API 메서드 수정: `dio.post` → `dio.patch` (`/api/v1/requests/{id}/cancel`)
                    - `userProfileScreenInitCache` / `otherUserProfileScreenInitCache`: 리뷰 로드 시 `..revieweeId = userId` cascade 설정 추가
                    - `data_manager_new.dart`, `temp_data_manager.dart` 임시 파일 삭제 후 단일 `DataManager`로 통합

                - **모델 구조 변경**
                    - `review.dart`: `User writer` → `String writerId` 교체, `String? revieweeId` 필드 추가 (직렬화 시 cascade로 설정)
                    - `user.dart`: `email` 필드 제거 (`MainUser`에만 유지), `rentalHistory: List<String>` → `rentalCount: int` 로 교체
                    - `chatting.dart`: `matchId`, `requestId`, `opponentId`, `opponentName`, `lastMessage`, `updatedAt` 필드 추가
                    - `match.dart`: 백엔드 미지원으로 `requesterReviewID`, `lenderReviewID` 필드 제거
                    - `chat.dart`, `rental_item.dart`, `main_user.dart`: API 스펙에 맞게 `fromJson` 키 매핑 정비

                - **LoginManager 리팩토링** (`login_manager.dart`)
                    - 내부 `_Session` 클래스 도입으로 user + accessToken 원자적 관리
                    - `currentUser` / `accessToken` 접근자를 null 대신 `StateError` 발생 방식으로 명확화
                    - 불필요한 메서드 제거 및 코드 간소화

                - **화면 및 위젯 DataManager 연동**
                    - `chat_screen.dart`: `getStatusForUserOnItem`으로 상태 구독, `getUserWriteReview`로 리뷰 작성 여부 확인, STOMP 클라이언트 연동
                    - `user_profile_screen.dart`: `userProfileScreenInitCache` / `getUserReceivedReview` 사용하도록 재작성
                    - `review_widget_factory.dart`: `review.writer.name` → `DataManager().getUser(review.writerId)?.name`으로 교체
                    - `chatting_room_widget_factory.dart`, `rental_item_widget_factory.dart`, `chat_widget_factory.dart`: DataManager 기반 데이터 조회로 전환
                    - `chatting_list.dart`, `item_detail_screen.dart`, `rental_request_screen.dart`, `review_screen.dart`, `lender_profile_screen.dart`: API 변경 사항 반영
                    - `setting_screen.dart` 신규 추가

                - **Mock 서버 재구성** (`mock_server_interceptor.dart`)
                    - 취소 엔드포인트: `POST` → `PATCH` 수정
                    - 리뷰 목록 응답에 `{'data': ...}` 래핑 추가 (Spring Page 형식 정합)
                    - `_recalculateScore`, `_receivedReviewsFor` 함수를 `revieweeId` 필드 기반으로 재작성
                    - `requesterReviewID`, `lenderReviewID` 관련 코드 전면 제거
                    - 테스트 데이터 전면 재구성: 산발적 ID 체계(`'0'`, `'b1'`, `'reviewer1'` 등) → 일관된 `u0`~`u4` / `i_b1`~`i_n3` 체계로 교체
                        - u0(김샘플) 기준 빌린 물건 5건(pending·matchConfirmed·inProgress·returned×2), 빌려준 물건 2건, 주변 아이템 3건
                        - 각 매치에 실제 대화 흐름이 있는 채팅 메시지 포함
                        - 완료된 거래(i_b4, i_l2)에 한해 양방향 리뷰 데이터 포함, i_b5는 리뷰 미작성 상태로 유지

                - **임시 문서 정리**
                    - `data update.md`, `data_manager_calls.md`, `data_manager_design.md`, `data_manager_reference.md` 삭제

        - ### commit: 버그 수정 및 모델 보완
            - #### author: Seo JeongHun
            - #### date: 2026-05-26
            - fix:
                - **`LoginManager.updateUser()` 무한 루프 수정** (`login_manager.dart`)
                    - `updateUser()` 내부에서 `DataManager().updateMainUser()`를 다시 호출하는 구조로 인해 `GET /api/v1/users/me`가 무한 반복 호출되던 문제 수정
                    - `updateUser()`는 세션 내 유저 객체 교체만 담당하도록 `DataManager().updateMainUser()` 호출 제거

                - **Mock 서버 타입 에러 수정** (`mock_server_interceptor.dart`)
                    - `queryParameters` 값이 `int`로 전달될 때 `int.tryParse()`에 `String`이 아닌 `int`가 전달되어 `TypeError`로 앱이 종료되던 문제 수정
                        - `options.queryParameters['page'] ?? '0'` → `options.queryParameters['page']?.toString() ?? '0'` (702, 703, 1045, 1046번 줄)
                    - `as String?` 강제 캐스팅으로 인한 `_CastError` 가능성 수정
                        - `options.queryParameters['status'] as String?` → `?.toString()` (730, 764, 765번 줄)

            - feature:
                - **`RentalItem` 모델 `requesterName` 필드 추가** (`rental_item.dart`)
                    - `requesterName` 필드 추가 (기본값 `''`)
                    - `fromJson`에서 `requesterNickname` / `requesterName` 키로 파싱
                    - `copyWith`에 전파 추가

        - ### commit: 채팅 화면 버그 수정 및 기능 보완
            - #### author: Seo JeongHun
            - #### date: 2026-05-26
            - fix:
                - **채팅 목록에서 Match 재구성** (`data_manager.dart`)
                    - `chattingListScreenInitCache` 완료 후 `Chatting` + `RentalItem` 데이터를 조합하여 `_matches` 캐시를 채우도록 추가
                    - `lenderID`는 `RentalItem.requesterID`와 현재 사용자 비교로 도출

                - **채팅 진입 시 기존 메시지 미표시 버그 수정** (`chat_screen.dart`)
                    - `_refreshMessages` 완료 후 DataManager에서 새 `Chatting` 객체를 재취득하지 않아 `chatting.chats`가 항상 빈 상태였던 문제 수정
                    - `setState` 내에서 `dataManager.getChatting(...)` 재호출로 갱신

                - **`activeStompClient` 임포트 누락 복구** (`chat_screen.dart`)
                    - `stomp_client.dart` 직접 임포트로 회귀된 것을 `active_stomp_client.dart`로 복원
                    - `ChatStompClient()` 직접 참조 4곳을 `activeStompClient`로 교체

                - **상태 진행 버튼 되돌림 버그 수정** (`chat_screen.dart`)
                    - `updateMatchStatus` 호출이 `await` 없이 실행되어 `_onDataChanged`가 캐시 구 상태를 읽어 `_currentStatus`를 되돌리는 문제 수정
                    - `matchConfirmed → inProgress`, `inProgress → returned` 전환 시 `await updateMatchStatus` 후 `_refreshMessages` 호출 추가

                - **다른 채팅방에서 리뷰 작성이 막히는 버그 수정** (`chat_screen.dart`)
                    - `hasReviewed` 체크가 `revieweeId` 기반으로 동작해 같은 상대(김철수)와의 다른 거래에서도 리뷰가 차단되던 문제 수정
                    - `r.revieweeId == _otherUser.id` → `r.matchId == widget.match.matchID` 로 거래 단위 체크로 변경

                - **ⓘ 버튼 후 재진입 시 NullException 수정** (`data_manager.dart`)
                    - `itemDetailScreenInitCache`에서 Match를 갱신할 때 `chattingID`를 누락하여 재진입 시 `widget.match.chattingID!`가 null이 되던 문제 수정
                    - 기존 `_matches[matchID]?.chattingID` 값을 보존하도록 수정

                - **채팅창 빠른 진입 시 상대방 이름 "알 수 없음" 표시 버그 수정** (`chat_screen.dart`)
                    - `initState`에서 동기적으로 `_otherUser`를 설정하므로 캐시 미적재 시 fallback 표시되던 문제 수정
                    - `addPostFrameCallback`과 `_refreshMessages` 모두에서 `chatScreenInitCache` 완료 후 `_otherUser`를 DataManager 캐시에서 재취득하도록 수정

        - ### commit: API 스펙 정합성 수정 및 리뷰 모델 보완
            - #### author: Seo JeongHun
            - #### date: 2026-05-26
            - fix:
                - **Mock 서버 응답 포맷 api_spec.md 정합** (`mock_server_interceptor.dart`)
                    - `_receivedReviewsFor` (5.3/5.4): 스펙에 없는 `reviewerId` 필드 제거
                    - `GET /api/v1/reviews/my` (5.2): `matchId` 필드 추가, `{"status":"OK","statusCode":200,"message":"...","data":[...]}` 래퍼 적용
                    - `POST /api/v1/reviews` (5.1): 빈 `{}` 반환에서 `{"status":"OK","statusCode":200,"message":"...","data":null}` 형식으로 수정
                    - 기존 리뷰 데이터(`rev_b4_*`, `rev_l2_*`)에 `matchId` cascade 설정 추가
                    - `serverCreateReview`에서 생성 리뷰에 `matchId` cascade 설정 추가

                - **`Review` 모델 필드 및 파싱 보완** (`review.dart`)
                    - `matchId` 필드 추가 및 `fromJson`에서 파싱
                    - `revieweeId` 필드를 `fromJson`에서 JSON 파싱으로 처리 (5.2 응답의 `revieweeId` 직접 활용)
                    - `reviewerNickname` 필드 추가 및 `fromJson`에서 파싱

                - **리뷰 위젯 작성자 이름 미표시 버그 수정** (`review_widget_factory.dart`)
                    - 5.3/5.4 응답에 `reviewerId` 미포함으로 `writerId`가 빈 문자열이 되어 이름이 표시되지 않던 문제 수정
                    - `reviewerNickname → 캐시 유저명 → writerId` 순서로 fallback 적용

            - feature:
                - **`chatScreenInitCache`에 내가 쓴 리뷰 로드 추가** (`data_manager.dart`)
                    - `GET /api/v1/reviews/my` 호출을 추가하여 `_reviews` 캐시에 내가 작성한 리뷰 적재
                    - `hasReviewed` 체크(`matchId` 기반)가 실제로 동작하기 위한 데이터 공급

        - ### commit: 실서버 응답 wrapper 파싱 전면 적용
            - #### author: Seo JeongHun
            - #### date: 2026-05-26
            - fix:
                - **`ApiClient.extractData()` 헬퍼 추가** (`api_client.dart`)
                    - 실서버 응답 `{"status":int,"message":"...","data":{...}}` wrapper를 자동으로 벗겨냄
                    - `status` 또는 `message` 키가 있고 `data` 키가 존재할 때만 unwrap, 그 외(mock 서버 직접 응답 등)는 그대로 반환

                - **전체 API 파싱 지점에 `extractData` 적용** (`login_manager.dart`, `data_manager.dart`)
                    - `initAutoLogin`: `/api/v1/users/me` 응답 → `MainUser.fromJson` 파싱 시 적용
                    - `login`: `/api/v1/auth/login` 응답 → `accessToken` / `refreshToken` 추출 시 적용
                    - `updateMainUser`: `/api/v1/users/me` 응답 → `MainUser.fromJson` 파싱 시 적용
                    - `chatScreenInitCache`: 채팅 메시지 목록, 상대방 유저, 아이템 3개 파싱 지점 적용
                    - `chattingListScreenInitCache`: 채팅 목록, 대여 아이템 목록 파싱 지점 적용
                    - `itemDetailScreenInitCache`: 아이템, 요청자 유저 파싱 지점 적용
                    - `otherUserProfileScreenInitCache`: 유저 파싱 지점 적용
                    - `userProfileScreenInitCache`: 대여 아이템 목록 파싱 지점 적용
                    - `rentalListScreenInitCache`: 주변 아이템 목록 파싱 지점 적용
                    - `createMatchWithChatting`: 매치, 채팅방 파싱 지점 2곳 적용
                    - 리뷰 페이지네이션(`['data']['content']`) 및 `reviews/my`(`['data']`) 경로는 이미 양쪽 서버 모두 정상 동작하므로 변경 없음

                - **물건 상세 화면 채팅하기 버튼 `pending` 비활성화 조건 제거** (`item_detail_screen.dart`)
                    - 대여자(lender) 입장에서 WAITING(pending) 상태 아이템의 채팅하기 버튼이 실서버에서 비활성화되던 문제 수정
                    - 요청자는 `confirmed != null`일 때만 버튼이 표시되므로 pending 비활성화 조건이 불필요
                    - `cancelled` 상태일 때만 비활성화하도록 변경

- # feature/buildng
    - ## version: 1.1.0
        - ### commit: rental_item이 place사용하도록 구조 변경
            - #### author: Seo JeongHun
            - #### date: 2026-05-24
            - feature:
                - geofencing_api 패키지 설치
                - LentalItem location -> placeID
                - place.dart 수정
                    - 필요없는 부분들 삭제
                - building.dart 수정
                    - 구조적으로 잘못된 부분 수정
                    - 이웃 장소 불러오기 수정
                - rental_request_screen.dart 수정
                    - 장소를 드롭다운 형식으로 선택할 수 있게함
                - test_data_manager에 건물 이름과 테두리 좌표 추가

- # feature/design
    - ## version: 1.1.0
        - ### commit: 디자인 요소 변경
            - #### author: Seo JeongHun
            - #### date: 2026-05-24
            - feature:
                - main.dart 스낵바 속도 조절
                - 상단바에 색 넣음

- # feature/data_structure
    - ## version: 1.1.0
        - ### commit: 데이터 매니저 통합
            - #### author: Seo JeongHun
            - #### date: 2026-05-24
            - feature:
                - test_data_manager 삭제