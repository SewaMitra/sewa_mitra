import 'package:flutter/material.dart';

class FilterSortScreen extends StatefulWidget {
  const FilterSortScreen({super.key});

  @override
  State<FilterSortScreen> createState() => _FilterSortScreenState();
}

class _FilterSortScreenState extends State<FilterSortScreen> {
  String selectedCategory = "All";
  String selectedSort = "Rating";
  double maxPrice = 2000.0;
  bool verifiedOnly = true;
  bool availableToday = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter & Sort",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

              const SizedBox(height: 20),
              const Text("CATEGORY", style: TextStyle(fontWeight: FontWeight.bold)),

              Wrap(
                spacing: 10,
                children: ["All", "Electrical", "Plumber", "Cleaning"].map((item) {
                  return ChoiceChip(
                    label: Text(item),
                    selected: selectedCategory == item,
                    onSelected: (_) => setState(() => selectedCategory = item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Text("SORT BY", style: TextStyle(fontWeight: FontWeight.bold)),

              Wrap(
                spacing: 10,
                children: ["Rating", "Price: Low-High", "Price: High-Low"].map((item) {
                  return ChoiceChip(
                    label: Text(item),
                    selected: selectedSort == item,
                    onSelected: (_) => setState(() => selectedSort = item),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              const Text("MAX PRICE", style: TextStyle(fontWeight: FontWeight.bold)),

              Slider(
                value: maxPrice,
                min: 0,
                max: 6000,
                divisions: 6,
                label: "Rs. ${maxPrice.toInt()}",
                onChanged: (value) => setState(() => maxPrice = value),
              ),

              FilterChip(
                label: const Text("Verified Only"),
                selected: verifiedOnly,
                onSelected: (_) => setState(() => verifiedOnly = !verifiedOnly),
              ),

              FilterChip(
                label: const Text("Available Today"),
                selected: availableToday,
                onSelected: (_) => setState(() => availableToday = !availableToday),
              ),
            ],
          ),
        ),
      ),
    );
  }
}