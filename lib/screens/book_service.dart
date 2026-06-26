import 'package:flutter/material.dart';
import 'date_and_time.dart';
import 'notifications.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  int? _selectedServiceIndex;
  final TextEditingController _notesController = TextEditingController();

  final List<Service> services = [
    Service(
      icon: 'EP',
      iconColor: const Color(0xFFFF8A00),
      title: 'Electric Pro Services',
      description: 'Wiring - Panel repair - Installation',
      rating: 4.8,
      reviews: 120,
      price: 500,
    ),
    Service(
      icon: 'QF',
      iconColor: const Color(0xFF34C759),
      title: 'Quick Fix Plumbing',
      description: 'Plumber',
      rating: 4.6,
      reviews: 57,
      price: 400,
    ),
    Service(
      icon: 'CH',
      iconColor: const Color(0xFF007AFF),
      title: 'Cleaning Services',
      description: 'Cleaning',
      rating: 4.5,
      reviews: 54,
      price: 800,
    ),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1C1C1E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book a service',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stepper
                      Row(
                        children: [
                          _buildStepCircle(1, 'Select\nService', true),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: const Color(0xFFFF8A00),
                            ),
                          ),
                          _buildStepCircle(2, 'Date &\nTime', false),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: const Color(0xFFE5E5EA),
                            ),
                          ),
                          _buildStepCircle(3, 'Confirm\nBooking', false),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Step 1 of 3',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'SELECT SERVICE',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8E93),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final isSelected = _selectedServiceIndex == index;
                          return _buildServiceCard(
                            service: service,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedServiceIndex = index;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Add Notes (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE5E5EA)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Describe your requirements...',
                            hintStyle: TextStyle(
                              color: Color(0xFFC6C6C8),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _selectedServiceIndex != null
                              ? () {
                                  final selectedService = services[_selectedServiceIndex!];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DateTimeSelectionScreen(
                                            serviceName: selectedService.title,
                                            servicePrice: selectedService.price.toDouble(),
                                            providerName: selectedService.title, // or some other logic
                                          ),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8A00),
                            disabledBackgroundColor: const Color(0xFFE5E5EA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'CONTINUE TO DATE AND TIME',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFF8A00) : Colors.white,
            border: Border.all(
              color: isActive
                  ? const Color(0xFFFF8A00)
                  : const Color(0xFFE5E5EA),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color:
                    isActive ? Colors.white : const Color(0xFF8E8E93),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: isActive
                ? const Color(0xFFFF8A00)
                : const Color(0xFFC6C6C8),
            fontWeight:
                isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required Service service,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF8A00).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8A00)
                : const Color(0xFFE5E5EA),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: service.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  service.icon,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: service.iconColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 4),
                      Text(
                        '${service.rating}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      Text(
                        ' (${service.reviews})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Starts from Rs. ${service.price}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF8A00),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF8A00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}

class Service {
  final String icon;
  final Color iconColor;
  final String title;
  final String description;
  final double rating;
  final int reviews;
  final int price;

  Service({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.price,
  });
}
