import 'category.dart';

class GroceryItem {
  GroceryItem({
    required this.id, 
    required this.name, 
    required this.quantity, 
    required this.category});

  String id;
  String name;
  String quantity;
  Category category;
}
