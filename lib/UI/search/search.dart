import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pizza_management/data/api/api_constant.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/pizza_repository.dart';

import '../pizza_screen/pizza_detail.dart';

class SearchScreen extends StatefulWidget {
  final Future<void> Function()? refreshRecommend;

  const SearchScreen({
    super.key,
    this.refreshRecommend
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final _searchRepository = PizzaRepository();
  List<Pizza> pizzas = [];
  Timer ? debounce;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
    debounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          "Search Pizza",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search pizza...",
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
                onChanged: (value) {
                  if (debounce?.isActive ?? false) debounce!.cancel();
                  debounce = Timer(
                    const Duration(milliseconds: 400),
                        () async {
                      if (value.trim().isEmpty) {
                        setState(() => pizzas.clear());
                        return;
                      }
                      final result = await _searchRepository.searchPizza(value);
                      if (!mounted) return;

                      setState(() {
                        pizzas = result;
                      });
                    },
                  );
                },
              ),
            ),
          ),

          if (searchController.text.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Popular Searches",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip("The Classics"),
                _chip("Ocean's Delight"),
                _chip("Green Garden"),
                _chip("Best Seller"),
                _chip("Meat Feast"),
                _chip("BBQ"),
                _chip("Mushroom"),
              ],
            ),

            const SizedBox(height: 30),

            Icon(
              Icons.local_pizza,
              size: 140,
              color: Colors.orange.shade200,
            ),

            const SizedBox(height: 20),

            Text(
              "Find your favorite pizza 🍕",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 18,
              ),
            ),
          ] else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: pizzas.length,
                itemBuilder: (context, index) {
                  final item = pizzas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          ApiConstant.pizzaImage(item.image),
                          width: 65,
                          height: 65,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.soup_kitchen,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(item.sauce),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                Icons.monetization_on,
                                color: Colors.amber,
                                size: 15,
                              ),
                              Text(
                                "\$${item.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PizzaDetailScreen(
                              pizza: item,
                            ),
                          ),
                        );
                        if (result == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static Widget _chip(String text) {
    return Chip(
      backgroundColor: Colors.white,
      label: Text(text),
      avatar: const Icon(
        Icons.local_pizza_rounded,
        size: 18,
        color: Colors.red,
      ),
    );
  }
}