import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dtebs/core/theme/app_theme.dart';
import 'package:dtebs/features/restaurant/models/restaurant_model.dart';
import 'package:dtebs/features/booking/models/booking_model.dart';
import 'package:dtebs/features/booking/services/booking_service.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  final Restaurant restaurant;

  const BookingScreen({super.key, required this.restaurant});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentStep = 0;
  DateTime? _selectedDate;
  int _pax = 2;
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];
  Map<String, int> _slotAvailability = {};
  Map<String, int> _menuQuantities = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _availableSlots = _bookingService.generateTimeSlots(
      widget.restaurant.operatingHours,
    );
  }

  Future<void> _updateSlotAvailability() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);

    Map<String, int> availability = {};
    for (String slot in _availableSlots) {
      final occupiedPax = await _bookingService.getOccupiedPax(
        widget.restaurant.ownerId,
        _selectedDate!,
        slot,
      );
      final available = widget.restaurant.capacity - occupiedPax;
      availability[slot] = available;
    }

    setState(() {
      _slotAvailability = availability;
      _isLoading = false;
    });
  }

  Future<void> _confirmBooking() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a booking')),
      );
      return;
    }

    if (_selectedDate == null || _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all booking steps')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create order items from menu quantities
      List<OrderItem> orderItems = [];
      _menuQuantities.forEach((menuItemName, quantity) {
        if (quantity > 0) {
          final menuItem = widget.restaurant.menu.firstWhere(
            (item) => item.name == menuItemName,
          );
          orderItems.add(
            OrderItem(
              name: menuItem.name,
              price: menuItem.price,
              quantity: quantity,
            ),
          );
        }
      });

      final booking = Booking(
        restaurantId: widget.restaurant.ownerId,
        restaurantName: widget.restaurant.name,
        customerId: user.uid,
        customerName: user.displayName ?? user.email ?? 'Customer',
        bookingDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        pax: _pax,
        menuItems: orderItems,
        createdAt: DateTime.now(),
      );

      await _bookingService.createBooking(booking);

      setState(() => _isLoading = false);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text('Booking Confirmed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your table at ${widget.restaurant.name} has been reserved.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Time: $_selectedTimeSlot',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Party Size: $_pax people',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to detail page
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: AppTheme.errorColor, size: 32),
                const SizedBox(width: 12),
                const Text('Booking Failed'),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book a Table')),
      backgroundColor: AppTheme.backgroundColor,
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () async {
            if (_currentStep == 0 && _selectedDate != null) {
              await _updateSlotAvailability();
              setState(() => _currentStep++);
            } else if (_currentStep == 1 && _pax > 0) {
              setState(() => _currentStep++);
            } else if (_currentStep == 2 && _selectedTimeSlot != null) {
              setState(() => _currentStep++);
            } else if (_currentStep == 3) {
              await _confirmBooking();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == 3;
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : details.onStepContinue,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isLastStep ? 'Confirm Booking' : 'Continue'),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _isLoading ? null : details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            _buildDateStep(),
            _buildPaxStep(),
            _buildTimeSlotStep(),
            _buildMenuStep(),
          ],
        ),
      ),
    );
  }

  Step _buildDateStep() {
    return Step(
      title: const Text('Select Date'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose a date for your reservation:'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? 'Tap to select date'
                          : DateFormat(
                              'EEEE, MMMM dd, yyyy',
                            ).format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate == null
                            ? Colors.grey.shade600
                            : Colors.black87,
                        fontWeight: _selectedDate == null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _selectedDate != null ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildPaxStep() {
    return Step(
      title: const Text('Number of People'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How many people will be dining?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 40,
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    if (_pax > 1) {
                      setState(() => _pax--);
                    }
                  },
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_pax',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 40,
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    if (_pax < widget.restaurant.capacity) {
                      setState(() => _pax++);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Max capacity: ${widget.restaurant.capacity} people',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _pax > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildTimeSlotStep() {
    return Step(
      title: const Text('Select Time Slot'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Choose your preferred time:'),
              if (!_isLoading)
                TextButton.icon(
                  onPressed: _updateSlotAvailability,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_availableSlots.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No time slots available'),
            )
          else
            ..._availableSlots.map((slot) {
              final available = _slotAvailability[slot] ?? 0;
              final isAvailable = available >= _pax;
              final isSelected = _selectedTimeSlot == slot;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: isAvailable
                      ? () => setState(() => _selectedTimeSlot = slot)
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : (isAvailable ? Colors.white : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : (isAvailable
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade400),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: isSelected
                                  ? Colors.white
                                  : (isAvailable
                                        ? AppTheme.primaryColor
                                        : Colors.grey.shade500),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              slot,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.white
                                    : (isAvailable
                                          ? Colors.black87
                                          : Colors.grey.shade600),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : (isAvailable
                                      ? AppTheme.successColor.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isAvailable
                                ? '$available seats left'
                                : 'Fully booked',
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : (isAvailable
                                        ? AppTheme.successColor
                                        : Colors.red),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _selectedTimeSlot != null ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildMenuStep() {
    return Step(
      title: const Text('Pre-order Menu (Optional)'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select items you\'d like to order:'),
          const SizedBox(height: 16),
          if (widget.restaurant.menu.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('No menu items available'),
            )
          else
            ...widget.restaurant.menu.map((item) {
              final quantity = _menuQuantities[item.name] ?? 0;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: quantity > 0
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    width: quantity > 0 ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RM ${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppTheme.successColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle),
                          color: AppTheme.primaryColor,
                          onPressed: () {
                            if (quantity > 0) {
                              setState(() {
                                _menuQuantities[item.name] = quantity - 1;
                              });
                            }
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$quantity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: AppTheme.primaryColor,
                          onPressed: () {
                            setState(() {
                              _menuQuantities[item.name] = quantity + 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          if (widget.restaurant.menu.isNotEmpty && _getTotalAmount() > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'RM ${_getTotalAmount().toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      isActive: _currentStep >= 3,
      state: StepState.indexed,
    );
  }

  double _getTotalAmount() {
    double total = 0;
    _menuQuantities.forEach((menuItemName, quantity) {
      final menuItem = widget.restaurant.menu.firstWhere(
        (item) => item.name == menuItemName,
        orElse: () => MenuItem(name: '', price: 0),
      );
      total += menuItem.price * quantity;
    });
    return total;
  }
}
