import 'package:flutter/material.dart';

class FilterSortScreen extends StatelessWidget {
  const FilterSortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const Text(
              "Filter & Sort",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          const Text(
            "CATEGORY",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
            Wrap(
              spacing: 10,
              children: [],
            )
            ChoiceChip(
            label: const Text("All"),
      selected: true,
      onSelected: (_) {},
    )
    ChoiceChip(
      label: const Text("Electrical"),
      selected: false,
      onSelected: (_) {},
    )
    ChoiceChip(
      label: const Text("Plumber"),
      selected: false,
      onSelected: (_) {},
    )
    ChoiceChip(
      label: const Text("Cleaning"),
      selected: false,
      onSelected: (_) {},
    )
    const Text(
      "SORT BY",
      style: TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    ChoiceChip(
    label: const Text("Rating"),
    selected: true,
    onSelected: (_) {},
    )
    ChoiceChip(
    label: const Text("Price: Low-High"),
    selected: false,
    onSelected: (_) {},
    )
    Slider(
    value: 2000,
    min: 0,
    max: 6000,
    onChanged: (value) {},
    )
    FilterChip(
    label: const Text("Verified Only"),
    selected: true,
    onSelected: (_) {},
    )
    FilterChip(
    label: const Text("Available Today"),
    selected: false,
    onSelected: (_) {},
    )