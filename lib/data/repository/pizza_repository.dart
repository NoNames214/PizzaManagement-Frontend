import 'package:logger/logger.dart';
import 'package:pizza_management/data/service/pizza_service.dart';
import '../model/pizza.dart';

class PizzaRepository {
  final PizzaService _pizzaService = PizzaService();
  final logger = Logger();

  Future<List<Pizza>> getPizza(int categoryId) async {
    try {
      return await _pizzaService.getPizza(categoryId);
    }
    catch (e) {
      logger.e("Get Pizza Failed: $e");
      return [];
    }
  }

  Future<bool> createPizza(Map<String, dynamic> data, String filePath) async {
    try {
      return await _pizzaService.createPizza(data, filePath);
    }
    catch (e) {
      logger.e("Create Pizza Failed: $e");
      return false;
    }
  }

  Future<List<Pizza>> searchPizza(String keyword) async {
    try {
      return await _pizzaService.searchPizza(keyword);
    }
    catch (e) {
      logger.e("Search Pizza Failed: $e");
      return [];
    }
  }

}