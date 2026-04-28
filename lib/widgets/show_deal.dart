import 'package:flutter/material.dart';
import '../models/deal.dart';
import '../models/deal_status.dart';
import 'show_widget.dart';

class ShowDeal extends ShowWidget {
  final Deal deal;
  final VoidCallback? onTap;

  ShowDeal({
    required this.deal,
    this.onTap,
  });

  @override
  Widget makeWidget() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deal.product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(deal.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                deal.product.category,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                deal.note,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        deal.seller.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '₩${_formatPrice(deal.price)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(deal.duration.startTime)} ~ ${_formatDate(deal.duration.endTime)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(DealStatus status) {
    Color color;
    switch (status) {
      case DealStatus.pending:
        color = Colors.orange;
        break;
      case DealStatus.matchConfirmed:
        color = Colors.blue;
        break;
      case DealStatus.inProgress:
        color = Colors.green;
        break;
      case DealStatus.returned:
        color = Colors.purple;
        break;
      case DealStatus.reviewed:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
