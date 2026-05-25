import 'package:flutter/material.dart';
import '/models/rental_status.dart';

extension RentalStatusExtension on RentalStatus {
  Color get color {
    switch (this) {
      case RentalStatus.pending:
        return Colors.grey;
      case RentalStatus.matchConfirmed:
        return Colors.blue;
      case RentalStatus.inProgress:
        return Colors.orange;
      case RentalStatus.returned:
        return Colors.green;
      case RentalStatus.cancelled:
        return Colors.red;
      case RentalStatus.otherUserMatched:
        return Colors.grey;
    }
  }

  String get text {
    switch (this) {
      case RentalStatus.pending:
        return '대기 중';
      case RentalStatus.matchConfirmed:
        return '매칭 확정';
      case RentalStatus.inProgress:
        return '대여 중';
      case RentalStatus.returned:
        return '반납 완료';
      case RentalStatus.cancelled:
        return '취소됨';
      case RentalStatus.otherUserMatched:
        return '다른 사용자 매칭';
    }
  }

  String get nextButtonText {
    switch (this) {
      case RentalStatus.pending:
        return '매칭 확정';
      case RentalStatus.matchConfirmed:
        return '대여 시작';
      case RentalStatus.inProgress:
        return '반납 완료';
      case RentalStatus.returned:
        return '리뷰 작성';
      case RentalStatus.cancelled:
        return '취소됨';
      case RentalStatus.otherUserMatched:
        return '다른 사용자 매칭';
    }
  }
}
