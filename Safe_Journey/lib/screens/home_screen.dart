import 'package:flutter/material.dart';
import '../models/journey_data.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final JourneyData journey;
  final VoidCallback onStartJourney;
  final VoidCallback onOpenSettings;
  final VoidCallback onTriggerSOS;

  const HomeScreen({
    super.key,
    required this.journey,
    required this.onStartJourney,
    required this.onOpenSettings,
    required this.onTriggerSOS,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _sourceController;
  late TextEditingController _destinationController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _sourceController = TextEditingController(text: widget.journey.source);
    _destinationController = TextEditingController(text: widget.journey.destination);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
  }

  void _swapLocations() {
    setState(() {
      final temp = _sourceController.text;
      _sourceController.text = _destinationController.text;
      _destinationController.text = temp;
      widget.journey.source = _sourceController.text;
      widget.journey.destination = _destinationController.text;
    });
  }

  void _useCurrentLocation() {
    setState(() {
      _sourceController.text = 'Current Location (GPS: 28.6139° N, 77.2090° E)';
      widget.journey.source = _sourceController.text;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Source set to current GPS coordinates.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showCustomDurationDialog() async {
    int tempMins = widget.journey.durationMinutes;
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Custom duration',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempMins minutes',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select expected arrival time between 5 and 180 minutes.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: tempMins.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setDialogState(() {
                        tempMins = val.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, tempMins),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        widget.journey.durationMinutes = selected;
      });
    }
  }

  void _handleStartJourney() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.journey.source = _sourceController.text.trim();
      widget.journey.destination = _destinationController.text.trim();
      widget.onStartJourney();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = ![15, 20, 30].contains(widget.journey.durationMinutes);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Safe Journey', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                Text('Your safety, every journey.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings & Profile',
            icon: const Icon(Icons.tune_outlined, color: AppColors.textPrimary),
            onPressed: widget.onOpenSettings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            children: [
              // Active Journey Alert Banner (if journey is already running)
              if (widget.journey.isActive)
                Container(
                  margin: const EdgeInsets.bottom: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.safeLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.safe.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.navigation_outlined, color: AppColors.safe, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'A journey is currently in progress.',
                          style: TextStyle(color: Color(0xFF065F46), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onStartJourney,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                        ),
                        child: const Text('View', style: TextStyle(color: AppColors.safe, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              // Plan Your Journey Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.edit_road_outlined, color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Plan your journey',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // 1. Source Location
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Starting from',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        InkWell(
                          onTap: _useCurrentLocation,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.my_location, size: 13, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'Use current location',
                                  style: TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        hintText: 'Enter starting location',
                        prefixIcon: Icon(Icons.trip_origin, color: AppColors.primary, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a starting location';
                        }
                        return null;
                      },
                    ),

                    // Swap Button
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.swap_vert_rounded, color: AppColors.textSecondary, size: 22),
                        tooltip: 'Swap source and destination',
                        onPressed: _swapLocations,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),

                    // 2. Destination Location
                    const Text(
                      'Going to',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        hintText: 'Enter destination',
                        prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.sos, size: 20),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a destination';
                        }
                        return null;
                      },
                    ),

                    // Quick Destination Suggestions
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _suggestionChip('Home', Icons.home_outlined),
                          _suggestionChip('Campus Dorm', Icons.apartment_outlined),
                          _suggestionChip('Metro Station', Icons.train_outlined),
                          _suggestionChip('Main Library', Icons.menu_book_outlined),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Expected Journey Time
                    const Text(
                      'Expected arrival time',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _durationButton(15),
                        const SizedBox(width: 8),
                        _durationButton(20),
                        const SizedBox(width: 8),
                        _durationButton(30),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: _showCustomDurationDialog,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 42,
                              decoration: BoxDecoration(
                                color: isCustom ? AppColors.primary : AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCustom ? AppColors.primary : AppColors.cardBorder,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                isCustom ? '${widget.journey.durationMinutes}m' : 'Custom',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isCustom ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // 4. Start Safe Journey Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _handleStartJourney,
                        icon: const Icon(Icons.navigation_outlined, size: 20),
                        label: const Text('Start Safe Journey'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // SOS Quick Button
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sos,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: widget.onTriggerSOS,
                  icon: const Icon(Icons.emergency_outlined, size: 20),
                  label: const Text(
                    'SOS — Emergency Alert',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Subtle informative safety note
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your trusted contacts will be alerted if arrival check-in is missed.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestionChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () {
          setState(() {
            _destinationController.text = label;
            widget.journey.destination = label;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationButton(int minutes) {
    final isSelected = widget.journey.durationMinutes == minutes;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            widget.journey.durationMinutes = minutes;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$minutes min',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
