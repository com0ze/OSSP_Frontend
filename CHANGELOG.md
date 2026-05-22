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