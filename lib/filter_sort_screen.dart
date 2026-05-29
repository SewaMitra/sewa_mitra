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