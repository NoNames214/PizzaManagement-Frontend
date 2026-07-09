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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            'Recommend for you',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        _isLoading ? _buildLoading() : _data.isEmpty
            ? _buildEmptyState() : _buildList(),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: _data.length,
      itemBuilder: (context, index) {
        final item = _data[index];
        return _buildAICard(item);
      },
    );
  }

  Widget _buildAICard(dynamic item) {
    final Pizza pizza = Pizza(
      id: item['id'] ?? 0,
      name: item['name'] ?? "",
      price: (item['price'] as num?)?.toDouble() ?? 0.0,
      image: item['image'] ?? "",
      toppingsName: [],
      mainIngredient: null,
      isGlutenFree: false,
      sauce: '',
      categoryName: '',
    );
    debugPrint("UI render: ${pizza.name}");
    final double score = (item['score'] as num?)?.toDouble() ?? 0.0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PizzaDetailScreen(
              pizza: pizza,
              refreshRecommend: loadAIData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.cyanAccent.withAlpha(50),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 110,
                  height: 110,
                  color: Colors.black26,
                  child: Image.network(
                    ApiConstant.pizzaImage(pizza.image),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_pizza,
                        color: Colors.orange,
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 15, 15, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pizza.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "${(score * 10).toStringAsFixed(0)}% Match",
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      "\$${pizza.price.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 20),
            Text(
              'Analyzing your taste...',
              style: TextStyle(color: Colors.cyanAccent.withAlpha(150)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 50),
        child: Text(
          "No recommendations yet.\nTry to explore more pizzas!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}