import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import this for kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker for web
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dish.dart'; // Import your model

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DishAdapter()); // Register the adapter
  await Hive.openBox<Dish>('dishes'); // Open a box for dishes
  runApp(FilipinoFoodOrderingApp());
}

class FilipinoFoodOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FoodMenuScreen(),
    );
  }
}

class FoodMenuScreen extends StatefulWidget {
  @override
  _FoodMenuScreenState createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  final Box<Dish> dishBox = Hive.box<Dish>('dishes');

  // Restored dish data
  final List<Dish> initialDishes = [
    Dish(name: 'Itlog', price: 15, image: 'assets/images/itlog.jpg', category: 'Breakfast'),
    Dish(name: 'Rice', price: 10, image: 'assets/images/rice.jpg', category: 'Breakfast'),
    Dish(name: 'Hotdog', price: 15, image: 'assets/images/hotdog.jpg', category: 'Breakfast'),
    Dish(name: 'Tocino', price: 20, image: 'assets/images/tocino.jpg', category: 'Breakfast'),
    Dish(name: 'Lugaw', price: 25, image: 'assets/images/lugaw.jpg', category: 'Breakfast'),
    Dish(name: 'Kapi', price: 30, image: 'assets/images/kapi.jpg', category: 'Breakfast'),
    Dish(name: 'Sinigang', price: 90, image: 'assets/images/sinigang.jpg', category: 'Pork'),
    Dish(name: 'Bistek', price: 80, image: 'assets/images/bistek.jpg', category: 'Pork'),
    Dish(name: 'Humba', price: 80, image: 'assets/images/humba.jpg', category: 'Pork'),
    Dish(name: 'Menudo', price: 70, image: 'assets/images/menudo.jpg', category: 'Pork'),
    Dish(name: 'Tokwa Baboy', price: 100, image: 'assets/images/tokwa_baboy.jpg', category: 'Pork'),
    Dish(name: 'Caldereta', price: 80, image: 'assets/images/caldereta.jpg', category: 'Pork'),
    Dish(name: 'Adobo', price: 70, image: 'assets/images/adobo.jpg', category: 'Chicken'),
    Dish(name: 'Tinolang Manok', price: 90, image: 'assets/images/tinolang_manok.jpg', category: 'Chicken'),
    Dish(name: 'Halang-halang', price: 60, image: 'assets/images/halang_halang.jpg', category: 'Chicken'),
    Dish(name: 'Fried Chicken', price: 50, image: 'assets/images/fried_chicken.jpg', category: 'Chicken'),
    Dish(name: 'Pinakbet', price: 40, image: 'assets/images/pinakbet.jpg', category: 'Gulay'),
    Dish(name: 'Chopsuey', price: 30, image: 'assets/images/chopsuey.jpg', category: 'Gulay'),
    Dish(name: 'Sitaw', price: 30, image: 'assets/images/sitaw.jpg', category: 'Gulay'),
    Dish(name: 'Tortang Talong', price: 25, image: 'assets/images/tortang_talong.jpg', category: 'Gulay'),
    Dish(name: 'Ginataan', price: 30, image: 'assets/images/ginataan.jpg', category: 'Gulay'),
    Dish(name: 'Monggo', price: 30, image: 'assets/images/monggo.jpg', category: 'Gulay'),
    Dish(name: 'Halo-Halo', price: 100, image: 'assets/images/halo_halo.jpg', category: 'Dessert'),
    Dish(name: 'Mango Float', price: 100, image: 'assets/images/mango_float.jpg', category: 'Dessert'),
    Dish(name: 'C2', price: 20, image: 'assets/images/c2.jpg', category: 'Drinks'),
    Dish(name: 'Mineral', price: 20, image: 'assets/images/mineral.jpg', category: 'Drinks'),
    Dish(name: 'Coke mismo', price: 20, image: 'assets/images/coke.jpg', category: 'Drinks'),
    Dish(name: 'Coke 1L', price: 50, image: 'assets/images/coke1.jpg', category: 'Drinks'),
    Dish(name: 'Sprite 1L', price: 50, image: 'assets/images/sprite1.jpg', category: 'Drinks'),
  ];

  String selectedCategory = 'Breakfast';
  double totalAmount = 0;
  double dailyIncome = 0;
  double weeklyIncome = 0;
  double monthlyIncome = 0;

  Map<String, int> dishCounts = {};
  Map<String, int> dishSalesCount = {}; // Track sales count for each dish
  TextEditingController moneyGivenController = TextEditingController();
  double change = 0;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  // Variable to store selected date range
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Load initial dishes into Hive if the box is empty
    if (dishBox.isEmpty) {
      for (var dish in initialDishes) {
        dishBox.add(dish);
      }
    }
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        // For web, use file_picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
        if (result != null) {
          setState(() {
            _imageFile = File(result.files.single.path!);
          });
        }
      } else {
        // For mobile, use image_picker
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void addNewDish() {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    String selectedCategory = 'Breakfast'; // Default category

    // List of categories
    final List<String> categories = ['Breakfast', 'Pork', 'Chicken', 'Gulay', 'Drinks', 'Dessert'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Dish'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Dish Name'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
              SizedBox(height: 10),
              // Dropdown for category selection
              DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              // Button to pick an image
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
              // Display the selected image
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  final newDish = Dish(
                    name: nameController.text,
                    price: double.tryParse(priceController.text) ?? 0,
                    category: selectedCategory, // Use the selected category
                    image: _imageFile != null
                        ? _imageFile!.path // Save the file path if an image is uploaded
                        : 'assets/images/default.jpg', // Fallback to default image
                  );
                  dishBox.add(newDish); // Add the new dish to Hive
                  _imageFile = null; // Reset the image file after adding
                });
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void addToTotal(double price, String dishName) {
    setState(() {
      totalAmount += price;
      dailyIncome += price;
      weeklyIncome += price;
      monthlyIncome += price;

      // Update the dish count for the order
      if (dishCounts.containsKey(dishName)) {
        dishCounts[dishName] = dishCounts[dishName]! + 1;
      } else {
        dishCounts[dishName] = 1;
      }

      // Update the sales count for the dish
      if (dishSalesCount.containsKey(dishName)) {
        dishSalesCount[dishName] = dishSalesCount[dishName]! + 1;
      } else {
        dishSalesCount[dishName] = 1;
      }
    });
  }

  void clearOrder() {
    setState(() {
      totalAmount = 0;
      dishCounts.clear();
      change = 0;
      moneyGivenController.clear();
    });
  }

  void clearAllSalesData() {
    setState(() {
      dishSalesCount.clear(); // Clear all sales data
      dailyIncome = 0;
      weeklyIncome = 0;
      monthlyIncome = 0;
    });
  }

  void calculateChange() {
    double moneyGiven = double.tryParse(moneyGivenController.text) ?? 0;
    if (moneyGiven >= totalAmount) {
      setState(() {
        change = moneyGiven - totalAmount;
      });
    } else {
      setState(() {
        change = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kulang imong kwarta!')),
      );
    }
  }

  void viewOrder(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Your Order"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List of dishes in the order
                ...dishCounts.entries.map((entry) {
                  String dishName = entry.key;
                  int count = entry.value;
                  double price = dishBox.values.firstWhere((dish) => dish.name == dishName).price;
                  double totalPrice = price * count;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$dishName x$count - ₱${totalPrice.toStringAsFixed(2)}'),
                      Row(
                        children: [
                          // Minus button
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              removeFromOrder(dishName);
                              Navigator.of(context).pop(); // Close the dialog
                              viewOrder(context); // Reopen the dialog to show updated order
                            },
                          ),
                          // Plus button
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () {
                              addToTotal(price, dishName); // Add the dish to the total
                              Navigator.of(context).pop(); // Close the dialog
                              viewOrder(context); // Reopen the dialog to show updated order
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
                // Display total amount
                SizedBox(height: 20),
                Text(
                  'Total Amount: ₱$totalAmount',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void removeFromOrder(String dishName) {
    setState(() {
      if (dishCounts.containsKey(dishName)) {
        if (dishCounts[dishName]! > 1) {
          dishCounts[dishName] = dishCounts[dishName]! - 1; // Decrease count
        } else {
          dishCounts.remove(dishName); // Remove the dish from the order
        }
        double price = dishBox.values.firstWhere((dish) => dish.name == dishName).price;
        totalAmount -= price; // Decrease total amount
        dailyIncome -= price; // Decrease daily income
        weeklyIncome -= price; // Decrease weekly income
        monthlyIncome -= price; // Decrease monthly income
      }
    });
  }

  void editMenu(String dishName) {
    Dish dish = dishBox.values.firstWhere((dish) => dish.name == dishName);
    TextEditingController priceController = TextEditingController(text: dish.price.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Price for $dishName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Create a new Dish instance with the updated price
                  Dish updatedDish = Dish(
                    name: dish.name,
                    price: double.tryParse(priceController.text) ?? dish.price,
                    category: dish.category,
                    image: dish.image,
                  );
                  // Update the dish in Hive
                  dishBox.putAt(dishBox.values.toList().indexOf(dish), updatedDish);
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                // Delete the dish
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Delete Dish'),
                      content: Text('Are you sure you want to delete $dishName?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              // Remove the dish from Hive
                              dishBox.deleteAt(dishBox.values.toList().indexOf(dish));
                            });
                            Navigator.of(context).pop(); // Close the delete confirmation dialog
                            Navigator.of(context).pop(); // Close the edit dialog
                          },
                          child: Text('Delete'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the delete confirmation dialog
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked; // Store the selected date range
        dailyIncome = 0;
        weeklyIncome = 0;
        monthlyIncome = 0;

        // Calculate income based on the selected date range
        // For demonstration, we will just set some dummy values
        // You can replace this with your actual income calculation logic
        dailyIncome = 100; // Replace with actual calculation
        weeklyIncome = 500; // Replace with actual calculation
        monthlyIncome = 2000; // Replace with actual calculation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve all dishes from Hive
    List<Dish> allDishes = dishBox.values.toList();

    // Filter dishes based on the selected category
    List<Dish> filteredDishes =
        allDishes.where((dish) => dish.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Papa Tams Eatery'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: addNewDish,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 255, 255, 255)),
              child: Text(
                'Kalindirya',
                style: TextStyle(color: const Color.fromARGB(255, 221, 0, 0), fontSize: 20),
              ),
            ),
            
            ListTile(
              title: Text('Income'), // New item
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => IncomeSummaryScreen(
                      dishBox: dishBox,
                      dishSalesCount: dishSalesCount, // Pass the sales count map
                    ),
                  ),
                );
              },
            ),
           
            if (selectedDateRange != null) // Display selected date range
              ListTile(
                title: Text('Selected Date Range: ${selectedDateRange!.start.toLocal()} - ${selectedDateRange!.end.toLocal()}'),
              ),
            Divider(),
            ListTile(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Breakfast', 'Pork', 'Chicken', 'Gulay', 'Drinks', 'Dessert'].map((category) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Text(category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedCategory == category ? Colors.blue : Colors.grey,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredDishes.length,
              itemBuilder: (context, index) {
                final dish = filteredDishes[index];
                return GestureDetector(
                  onTap: () => addToTotal(dish.price, dish.name),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: dish.image.startsWith('assets/') // NEW: Check if the image is from assets
                              ? Image.asset(
                                  dish.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // NEW: Display a placeholder if the asset image fails to load
                                    return Center(
                                      child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(dish.image), // NEW: Load image from file path
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // NEW: Display a placeholder if the file image fails to load
                                    return Center(
                                      child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                                    );
                                  },
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                dish.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text('₱${dish.price}',
                                  style: TextStyle(fontSize: 14)),
                              Text('x${dishCounts[dish.name] ?? 0}'),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  editMenu(dish.name);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₱$totalAmount',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: clearOrder,
                          child: Text('Clear'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => viewOrder(context),
                          child: Text('View Order'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 5),
                TextField(
                  controller: moneyGivenController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Kwarta Niya',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    suffixIcon: IconButton(
                      icon: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.green, // Green color for the "OK" text
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: calculateChange, // Call the calculateChange function
                    ),
                  ),
                ),
                SizedBox(height: 5),
                if (change > 0)
                  Text(
                    'Change: ₱${change.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                if (change == 0 && moneyGivenController.text.isNotEmpty)
                  Text(
                    'Kulang imong kwarta',
                    style: TextStyle(fontSize: 14, color: Colors.red),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IncomeSummaryScreen extends StatefulWidget {
  final Box<Dish> dishBox;
  final Map<String, int> dishSalesCount; // Add this to track sales count

  IncomeSummaryScreen({required this.dishBox, required this.dishSalesCount});

  @override
  _IncomeSummaryScreenState createState() => _IncomeSummaryScreenState();
}

class _IncomeSummaryScreenState extends State<IncomeSummaryScreen> {
  // Map to track whether a category is expanded or not
  Map<String, bool> categoryExpanded = {};

  // Map to store total income for each category
  Map<String, double> categoryIncome = {};

  // Variable to store selected date range
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Calculate total income for each category based on sales count
    _calculateCategoryIncome();
  }

  // Function to calculate total income for each category
  void _calculateCategoryIncome() {
    for (var dish in widget.dishBox.values) {
      int salesCount = widget.dishSalesCount[dish.name] ?? 0;
      double totalSales = dish.price * salesCount;

      if (categoryIncome.containsKey(dish.category)) {
        categoryIncome[dish.category] = categoryIncome[dish.category]! + totalSales;
      } else {
        categoryIncome[dish.category] = totalSales;
      }
    }
  }

  // Function to calculate the total of all category incomes
  double _calculateTotalCategoryIncome() {
    return categoryIncome.values.fold(0, (previousValue, income) => previousValue + income);
  }

  // Function to clear sales data and reset category totals
  void clearAllSalesData() {
    setState(() {
      widget.dishSalesCount.clear(); // Clear all sales data
      categoryIncome.clear(); // Clear total income for each category
      _calculateCategoryIncome(); // Recalculate totals (will be 0 since sales are cleared)
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sales data and totals cleared!')),
    );
  }

  // Function to select date range
  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked; // Store the selected date range
        _calculateCategoryIncome(); // Recalculate income based on the selected date range
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group dishes by category
    Map<String, List<Dish>> categoryDishes = {};
    for (var dish in widget.dishBox.values) {
      if (categoryDishes.containsKey(dish.category)) {
        categoryDishes[dish.category]!.add(dish);
      } else {
        categoryDishes[dish.category] = [dish];
      }
    }

    // Calculate the total of all category incomes
    double totalCategoryIncome = _calculateTotalCategoryIncome();

    return Scaffold(
      appBar: AppBar(
        title: Text('Income Summary'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _selectDateRange, // Add date range picker
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedDateRange != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selected Date Range: ${selectedDateRange!.start.toLocal()} - ${selectedDateRange!.end.toLocal()}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: categoryIncome.length,
              itemBuilder: (context, index) {
                String category = categoryIncome.keys.elementAt(index);
                double totalIncome = categoryIncome[category]!;
                List<Dish> dishes = categoryDishes[category]!;

                return ExpansionTile(
                  title: Text(category),
                  trailing: Text('₱${totalIncome.toStringAsFixed(2)}'),
                  initiallyExpanded: categoryExpanded[category] ?? false,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      categoryExpanded[category] = expanded;
                    });
                  },
                  children: dishes.map((dish) {
                    // Get the sales count for the dish
                    int salesCount = widget.dishSalesCount[dish.name] ?? 0;

                    return ListTile(
                      title: Text(dish.name),
                      subtitle: Text('Sales: $salesCount'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          // Display the total of all category incomes
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Total Income: ₱${totalCategoryIncome.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Clear Data Button
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: ElevatedButton(
                onPressed: clearAllSalesData,
                child: Text('Clear Data'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}