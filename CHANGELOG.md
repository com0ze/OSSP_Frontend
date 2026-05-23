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
