import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/UI/pizza_screen/pizza_detail.dart';
import 'package:pizza_management/data/repository/ai_repository.dart';
import '../../data/api/api_constant.dart';
import '../../data/model/pizza.dart';

class AIRecommendScreen extends StatefulWidget {
  final String token;

  const AIRecommendScreen({
    super.key,
    required this.token,
  });

  @override
  State<AIRecommendScreen> createState() => AIRecommendState();
}

class AIRecommendState extends State<AIRecommendScreen> {
  final logger = Logger();
  final List<dynamic> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    logger.i("AI screen init ${identityHashCode(this)}");
    loadAIData();
  }

  Future<void> loadAIData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await AIRepository().getRecommend(widget.token);
      if (mounted) {
        setState(() {
          _data.clear();
          _data.addAll(result);
          _isLoading = false;
        });
      }
      logger.i(result);
      logger.i(widget.token);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      logger.e("Error loading AI data: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "✨ Recommendations For You",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Based on your recent activities",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? _buildLoading()
              : _data.isEmpty
              ? _buildEmptyState()
              : _buildList(),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        return _buildAICard(_data[index]);
      },
    );
  }

  Widget _buildAICard(dynamic item) {
    final Pizza pizza = Pizza(
      id: item['id'] ?? 0,
      name: item['name'] ?? "",
      price: (item['price'] as num?)?.toDouble() ?? 0,
      image: item['image'] ?? "",
      toppingsName: const [],
      mainIngredient: null,
      isGlutenFree: false,
      sauce: "",
      categoryName: "",
    );
    final double score = (item['score'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PizzaDetailScreen(
                    pizza: pizza,
                    refreshRecommend: loadAIData,
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Hero(
                tag: pizza.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    ApiConstant.pizzaImage(pizza.image),
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stacktrace) {
                      return Container(
                        width: 110,
                        height: 110,
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.local_pizza,
                          size: 45,
                          color: Colors.orange,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: SizedBox(
                  height: 110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pizza.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                              Colors.green.shade50,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${(score * 10).toStringAsFixed(0)}%",
                              style: TextStyle(
                                color:
                                Colors.green.shade700,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.orange,
                            size: 18,
                          ),

                          const SizedBox(width: 5),
                          Text(
                            "AI Recommended",
                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            "\$${pizza.price.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.deepOrange,
                              fontWeight:
                              FontWeight.bold,
                              fontSize: 21,
                            ),
                          ),

                          const Spacer(),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.orange,
          ),
          SizedBox(height: 20),
          Text(
            "AI is finding pizzas you'll love 🍕",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_alt,
            color: Colors.white38,
            size: 90,
          ),
          SizedBox(height: 20),
          Text(
            "No recommendations yet",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 10),
          Text(
            "Explore more pizzas",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}