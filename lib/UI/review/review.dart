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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (reviews.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.reviews_outlined,
                size: 90,
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              Text(
                "No reviews yet",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black38,
      appBar: AppBar(
        title: const Text("Customer Reviews"),
        centerTitle: true,
        backgroundColor: Colors.red,
        foregroundColor: Colors.grey,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: loadReviews,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Text(
                    "Average Rating",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    averageRating().toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                          (index) => Icon(
                        Icons.star,
                        color: index < averageRating().round()
                            ? Colors.amber
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "${reviews.length} Reviews",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Write your review",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                        icon: Icon(
                          Icons.star,
                          size: 35,
                          color: index < rating
                              ? Colors.amber
                              : Colors.grey.shade300,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 15),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Share your experience...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {

                      },
                      child: const Text(
                        "Submit Review",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Recent Reviews",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            ...reviews.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    item.user?.fullName ?? "Anonymous",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(
                            Icons.star,
                            size: 18,
                            color: i < item.rating
                                ? Colors.amber
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      Text(item.comment),
                      const SizedBox(height: 8),
                      Text(
                        item.createdAt.toString().substring(0, 10),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}