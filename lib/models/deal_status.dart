enum DealStatus {
  pending,
  matchConfirmed,
  inProgress,
  returned,
  reviewed,
}

extension DealStatusExtension on DealStatus {
  String get displayName {
    switch (this) {
      case DealStatus.pending:
        return '대기중';
      case DealStatus.matchConfirmed:
        return '매칭 확정';
      case DealStatus.inProgress:
        return '진행중';
      case DealStatus.returned:
        return '반납 완료';
      case DealStatus.reviewed:
        return '후기 작성 완료';
    }
  }
}
