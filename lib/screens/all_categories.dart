import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Service Categories',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CategoriesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories count
            const Text(
              '8 categories',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // Grid of categories
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    categoryName: categories[index]['name']!,
                    providerCount: categories[index]['providers']!,
                    icon: categories[index]['icon']!,
                    color: categories[index]['color']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String categoryName;
  final int providerCount;
  final IconData icon;
  final Color color;

  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.providerCount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            // Category name
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Provider count
            Text(
              '$providerCount providers',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data for categories
final List<Map<String, dynamic>> categories = [
  {
    'name': 'Electrical',
    'providers': 18,
    'icon': Icons.electrical_services,
    'color': Color(0xFFF44336), // Red
  },
  {
    'name': 'Plumber',
    'providers': 12,
    'icon': Icons.plumbing,
    'color': Color(0xFF2196F3), // Blue
  },
  {
    'name': 'Cleaning',
    'providers': 9,
    'icon': Icons.cleaning_services,
    'color': Color(0xFF4CAF50), // Green
  },
  {
    'name': 'AC Repair',
    'providers': 7,
    'icon': Icons.ac_unit,
    'color': Color(0xFFFF9800), // Orange
  },
  {
    'name': 'Laundry',
    'providers': 5,
    'icon': Icons.local_laundry_service,
    'color': Color(0xFF9C27B0), // Purple
  },
  {
    'name': 'Painting',
    'providers': 6,
    'icon': Icons.format_paint,
    'color': Color(0xFF00BCD4), // Cyan
  },
  {
    'name': 'Carpentry',
    'providers': 4,
    'icon': Icons.handyman,
    'color': Color(0xFF795548), // Brown
  },
  {
    'name': 'Gardening',
    'providers': 3,
    'icon': Icons.grass,
    'color': Color(0xFF8BC34A), // Light Green
  },
];