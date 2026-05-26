import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/models/review.dart';
import '/widgets/widget_factory.dart';

class ReviewWidgetFactory extends WidgetFactory {
  final Review review;

  ReviewWidgetFactory({required this.review});

  @override
  Widget makeWidget(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  review.reviewerNickname ?? DataManager().getUser(review.writerId)?.name ?? review.writerId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < review.score ? Icons.star : Icons.star_border,
                    color: context.starColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${review.score}점',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  _formatDate(review.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.reviewText,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
