import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/models/match.dart';
import '/models/rental_item.dart';
import '/models/user.dart';

class ReviewScreen extends StatefulWidget {
  final RentalItem rentalItem;
  final Match match;
  final User reviewee;

  const ReviewScreen({
    super.key,
    required this.rentalItem,
    required this.match,
    required this.reviewee,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text(
            '별점을 선택해주세요',
            style: TextStyle(color: context.onWarningColor),
          ),
          backgroundColor: context.warningColor,
        ),
      );
      return;
    }

    final reviewText = _commentController.text;
    if (reviewText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text(
            '리뷰 내용을 입력해주세요',
            style: TextStyle(color: context.onWarningColor),
          ),
          backgroundColor: context.warningColor,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 500),
        content: Text(
          '리뷰가 등록되었습니다',
          style: TextStyle(color: context.onGoodColor),
        ),
        backgroundColor: context.goodColor,
      ),
    );

    final DataManager dataManager = DataManager();
    await dataManager.postReview(
      score: _rating.toInt(),
      reviewText: reviewText,
      matchId: widget.match.matchID,
    );

    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('리뷰 작성'),
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    child: Text(
                      widget.reviewee.name[0],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.reviewee.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.rentalItem.product.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.onSurfaceVariantColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '별점',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: screenWidth * 0.1,
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: context.starColor,
                    ),
                  );
                }),
              ),
            ),
            if (_rating > 0)
              Center(
                child: Text(
                  _rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.starColor,
                  ),
                ),
              ),
            const SizedBox(height: 32),
            const Text(
              '리뷰',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 200,
              decoration: const InputDecoration(
                hintText: '거래 경험을 공유해주세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitReview,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  '리뷰 등록하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
