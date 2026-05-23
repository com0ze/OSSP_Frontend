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

- # feature/data_widget_refactoring
    - ## version: 1.1.0
        - ### UI개선 및 구조 리팩토링
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

        - ### 취소 기능 및 상태 관리 구조 개선
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

        - ### DataManager 추상화 및 의존성 역전 적용
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