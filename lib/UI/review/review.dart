import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/data/model/review.dart';
import 'package:pizza_management/data/repository/review_repository.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _reviewRepository = ReviewRepository();
  final logger = Logger();
  final TextEditingController commentController = TextEditingController();
  List<Review> reviews = [];
  bool isLoading = true;
  int rating = 5;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> loadReviews() async {
    try {
      final data = await _reviewRepository.getReview();
      if (!mounted) return;
      setState(() {
        reviews = data;
        isLoading = false;
      });
    } catch (e) {
      logger.e(e);
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  double averageRating() {
    if (reviews.isEmpty) return 0;
    double total = 0;
    for (final item in reviews) {
      total += item.rating;
    }

    return total / reviews.length;
  }

  Widget _buildReviewCard(Review item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.orange.shade100,
                  child: const Icon(
                    Icons.person,
                    color: Colors.deepOrange,
                  ),
                ),

                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.user?.fullName ?? "Anonymous",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 5),
                      Text(
                        item.createdAt.toString().substring(0, 10),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(
                    5,
                        (index) =>
                        Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: index < item.rating
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                  ),
                )
              ]
          ),

          const SizedBox(height: 18),
          Text(
            item.comment,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.thumb_up_alt_outlined,
                size: 20,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 6),
              Text(
                "Helpful",
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const Spacer(),
              Icon(
                Icons.favorite_border,
                size: 20,
                color: Colors.red.shade300,
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        title: const Text(
          "Customer Reviews",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadReviews,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    averageRating().toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) =>
                          Icon(
                            Icons.star_rounded,
                            size: 28,
                            color: index < averageRating().round()
                                ? Colors.amber
                                : Colors.grey.shade300,
                          ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "${reviews.length} Reviews",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Write your review",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                          icon: Icon(
                            Icons.star_rounded,
                            size: 36,
                            color: index < rating
                                ? Colors.amber
                                : Colors.grey.shade300,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Share your experience...",
                      filled: true,
                      fillColor: const Color(0xffF6F7FB),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Submit Review",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Recent Reviews",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            ...reviews.map((item) {
              return _buildReviewCard(item);
            }),
          ],
        ),
      ),
    );
  }
}