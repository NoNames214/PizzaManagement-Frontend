import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pizza_management/UI/pizza_screen/pizza_detail.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/repository/ai_repository.dart';
import 'package:pizza_management/data/repository/auth_repository.dart';
import '../../data/ai_recommend/interaction_type.dart';
import '../../data/model/pizza.dart';
import '../../data/service/pizza_service.dart';


class PizzaScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final Future<void> Function() refreshRecommend;

  const PizzaScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.refreshRecommend,
  });

  @override
  State<PizzaScreen> createState() => _PizzaScreenState();
}

class _PizzaScreenState extends State<PizzaScreen> {
  late Future<List<Pizza>> _pizzas;



  @override
  void initState() {
    super.initState();
    _pizzas = PizzaService().getPizza(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7A082),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Pizza>>(
        future: _pizzas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Connect Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No data",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final data = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final pizza = data[index];
              final randomRating = (3.5 + Random().nextDouble() * 1.5).toStringAsFixed(1);
              return GestureDetector(
                onTap: () async {
                  final token = await AuthRepository().getToken();
                  final int pizzaId = pizza.id;
                  final String eventType = InteractionType.click;
                  if (token != null) {
                    await AIRepository().trackUserAction(pizzaId, eventType, token);
                    await widget.refreshRecommend();
                  }
                  else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token is null')),
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PizzaDetailScreen(
                                  pizza: pizza,
                                  refreshRecommend: widget.refreshRecommend,
                              ),
                      ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 45,
                        child: Stack(
                          children: [
                            Hero(
                              tag: pizza.id,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                child: Image.network(
                                  ApiConstant.pizzaImage(pizza.image),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      randomRating,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 55,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pizza.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  if (pizza.mainIngredient?.hasCheese == true)
                                    _buildTag(Icons.circle, "Cheese"),
                                  if (pizza.mainIngredient?.hasSeafood == true)
                                    _buildTag(Icons.set_meal, "Seafood"),
                                  if (pizza.mainIngredient?.hasPineapple == true)
                                    _buildTag(Icons.eco, "Pineapple"),
                                  if ((pizza.mainIngredient?.priceRange ?? 0) >= 0)
                                    _buildTag(Icons.local_fire_department_rounded, "Spicy")
                                ],
                              ),

                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      "\$${pizza.price.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
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
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: Colors.orange),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
