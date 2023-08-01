import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocerieslist_app/data/catagories.dart';
import 'package:grocerieslist_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:grocerieslist_app/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'grocery-app-e1634-default-rtdb.firebaseio.com', 'grocery-list.json');
  try{

    final response = await http.get(url);
    if(response.statusCode >=400){
      setState(() {
        
       _error = 'Failed to fetch Data. Please try again later.';
      });
    }
    if(response.body == 'null'){
      setState(() {
        _isLoading = false;
      });
      return ;
    }
    final Map<String, dynamic> listData =
        await json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries.firstWhere((catItem) => catItem.value.title == item.value['category']).value;
      loadedItems.add(GroceryItem(
          id: item.key, 
          name: item.value['name'], 
          quantity: item.value['quantity'], 
          category: category
          ));
    }
       setState(() {
       _groceryItems = loadedItems;
       _isLoading = false;
       });
     }catch (err){
     setState(() {
      _error = 'Something Went wrong. Please try again later.';
     });
  }
        }

  void _additem() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));
        if(newItem == null){
          return;
        }
        setState(() {
        _groceryItems.add(newItem);
        });
          
  }

  void _removeItem(GroceryItem item)async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('grocery-app-e1634-default-rtdb.firebaseio.com', 'grocery-list/${item.id}.json',);
     final response = await http.delete(url);

      if(response.statusCode >=400){
        setState(() {
          _groceryItems.insert(index,item);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Something Went Wrong'))
          );
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('No Items in Grocery List. Try Adding Some!'),
    );
    if(_isLoading){
      content=const Center(child: CircularProgressIndicator());
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color),
            title: Text(_groceryItems[index].name),
            trailing: Text(_groceryItems[index].quantity),
          ),
        ),
      );
    }
    if(_error !=null){
        content = Center(
          child: Text(_error!),
        );
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Groceries List'), actions: [
          IconButton(
              icon: const Icon(
                Icons.add,
                size: 20,
                color: Colors.white,
              ),
              onPressed: _additem)
        ]),
        body: content);
  }
}
