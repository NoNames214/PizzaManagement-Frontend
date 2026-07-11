import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pizza_management/UI/AI/ai_discovery.dart';
import 'package:pizza_management/UI/cart/cart.dart';
import 'package:pizza_management/UI/profile/profile.dart';
import 'package:pizza_management/UI/review/review.dart';
import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/repository/category_repository.dart';
import 'package:pizza_management/data/repository/pizza_repository.dart';
import '../../data/api/api_constant.dart';
import '../../data/model/category.dart';
import '../pizza_screen/pizza_screen.dart';
import '../search/search.dart';

class Home extends StatefulWidget {
  final String token;

  const Home({
    super.key,
    required this.token,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Category>> _categories;
  int _currentIndex = 0;
  bool isLoading = true;
  late final AIRecommendScreen aiScreen;
  final _pizzaRepository = PizzaRepository();
  final logger = Logger();
  List<Pizza> pizzas = [];
  final GlobalKey<AIRecommendState> aiKey = GlobalKey<AIRecommendState>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _categories = CategoryRepository().getCategories();
    aiScreen = AIRecommendScreen(key: aiKey, token: widget.token);
  }

  Future<void> loadSearch(String keyword) async {
    try {
      final data = await _pizzaRepository.searchPizza(keyword);
      if (!mounted) return;
      setState(() {
        pizzas = data;
        isLoading = false;
      });
    }
    catch(e) {
      logger.e('Load search Failed: $e');
      setState(() {
        pizzas = [];
        isLoading = false;
      });
    }
  }

  Future<void> refreshRecommend() async {
    aiKey.currentState?.loadAIData();
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildHomeContent(),
        const CartScreen(),
        aiScreen,
        const ReviewScreen(),
        const Profile(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _buildColorBackground(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildBody(),
            ),
          ),
          _buildBottomNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      bottom: 18,
      left: 15,
      right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(100),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withAlpha(60)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_filled, "Home", 0),
                _buildNavItem(Icons.shopping_cart, "Cart", 1),
                _buildNavItem(Icons.auto_awesome, "AI", 2),
                _buildNavItem(Icons.reviews_outlined, "Review", 3),
                _buildNavItem(Icons.person, "Profile", 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 8,
          vertical: 8,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFE57351),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withAlpha(70),
              size: 24,
            ),
            if (isSelected) const SizedBox(width: 4),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 25),
          if (searchController.text.isNotEmpty)
            _buildSearchResult(),
          const SizedBox(height: 30),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildTheUsualBanner(),
          const SizedBox(height: 30),
          _buildQuickFilters(),
          const SizedBox(height: 30),
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuGrid(),
          const SizedBox(height: 140),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(70),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withAlpha(70)),
          ),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              if (value.trim().isEmpty) {
                setState(() {
                  pizzas.clear();
                });
              }
              else {
                loadSearch(value);
              }
            },
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search delicious pizza...',
              hintStyle: TextStyle(color: Colors.white60),
              prefixIcon: Icon(Icons.search, color: Colors.white),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorBackground() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Color(0xFFE57351), Color(0xFFFFCC80)],
      ),
    ),
  );

  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bonjour,', style: TextStyle(color: Colors.white70)),
          Text(
            'Hungry for Pizza?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.notifications_none, color: Colors.white),
      ),
    ],
  );

  Widget _buildQuickFilters() => SizedBox(
    height: 80,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children:
          [
                Icons.local_pizza,
                Icons.local_drink,
                Icons.icecream,
                Icons.lunch_dining,
                Icons.fastfood,
              ]
              .map(
                (icon) => Container(
                  margin: const EdgeInsets.only(right: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(90),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
              )
              .toList(),
    ),
  );

  Widget _buildTheUsualBanner() => Container(
    height: 140,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFE57351), Color(0xFFFFCC80)],
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Stack(
      children: [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Summer Deal\nFree Drink!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset('assets/images/category_pizza.png', height: 140),
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchResult() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (pizzas.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No pizza found',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pizzas.length,
      itemBuilder: (context, index) {
        final item = pizzas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                ApiConstant.pizzaImage(item.image),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(item.name),
            subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                )
              );
            },
          ),
        );
      }
    );
  }

  Widget _buildMenuGrid() => FutureBuilder<List<Category>>(
    future: _categories,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text("Error: ${snapshot.error}"));
      }
      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text("No data"));
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.9,
        ),
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final cat = snapshot.data![index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PizzaScreen(
                    categoryId: cat.id,
                    categoryName: cat.name,
                    refreshRecommend: refreshRecommend,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(ApiConstant.categoryImage(cat.imageUrl)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    cat.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
