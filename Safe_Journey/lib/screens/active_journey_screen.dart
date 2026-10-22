import 'dart:async';
import 'package:flutter/material.dart';
import '../models/journey_data.dart';
import '../theme/app_theme.dart';

class ActiveJourneyScreen extends StatefulWidget {
  final JourneyData journey;
  final VoidCallback onEndJourney;
  final VoidCallback onTriggerSOS;
  final VoidCallback onTriggerCheckIn;
  final VoidCallback onGoToPlan;

  const ActiveJourneyScreen({
    super.key,
    required this.journey,
    required this.onEndJourney,
    required this.onTriggerSOS,
    required this.onTriggerCheckIn,
    required this.onGoToPlan,
  });

  @override
  State<ActiveJourneyScreen> createState() => _ActiveJourneyScreenState();
}

class _ActiveJourneyScreenState extends State<ActiveJourneyScreen> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initCountdown();
  }

  @override
  void didUpdateWidget(covariant ActiveJourneyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.journey.isActive && (!oldWidget.journey.isActive || widget.journey.expectedArrival != oldWidget.journey.expectedArrival)) {
      _initCountdown();
    }
  }

  void _initCountdown() {
    _timer?.cancel();
    if (!widget.journey.isActive || widget.journey.expectedArrival == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }

    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    if (widget.journey.expectedArrival == null) return;
    final diff = widget.journey.expectedArrival!.difference(DateTime.now());
    if (diff <= Duration.zero) {
      _timer?.cancel();
      setState(() => _remaining = Duration.zero);
      widget.onTriggerCheckIn();
    } else {
      setState(() => _remaining = diff);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedRemaining {
    final s = _remaining.inSeconds.clamp(0, 999999);
    final mins = (s ~/ 60).toString().padLeft(2, '0');
    final secs = (s % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _confirmEndJourney() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End this journey?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Confirming will end active safety tracking and mark your journey as safely completed.',
          style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Active', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.safe),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Yes, I'm Safe"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onEndJourney();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.journey.isActive) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Journey')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.navigation_outlined, color: AppColors.primary, size: 36),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No Active Journey',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Set your starting location, destination, and expected arrival time to begin safety monitoring.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: widget.onGoToPlan,
                  icon: const Icon(Icons.add_road_outlined, size: 18),
                  label: const Text('Plan a Journey'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Journey'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.safeLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: AppColors.safe, size: 8),
                SizedBox(width: 5),
                Text('Active', style: TextStyle(color: AppColors.safe, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Countdown Display Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Time Remaining',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formattedRemaining,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      'Check-in at: ${widget.journey.formattedExpectedArrival}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Route & Timeline Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Journey Route',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 14),

                  // Timeline: Origin
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.trip_origin, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Starting Location', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(
                              widget.journey.source,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Vertical Line
                  Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: SizedBox(
                      height: 28,
                      child: VerticalDivider(
                        color: AppColors.cardBorder,
                        thickness: 2,
                        width: 2,
                      ),
                    ),
                  ),

                  // Timeline: Destination
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on_outlined, color: AppColors.sos, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Destination', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            Text(
                              widget.journey.destination,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: 12),

                  // Metadata Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _metaItem('Started at', widget.journey.formattedStartTime),
                      _metaItem('Duration', '${widget.journey.durationMinutes} min'),
                      _metaItem('Expected', widget.journey.formattedExpectedArrival),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // End Journey Button
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _confirmEndJourney,
                icon: const Icon(Icons.check_circle_outline, color: AppColors.safe, size: 20),
                label: const Text(
                  "I'm Safe — End Journey",
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Emergency SOS Button (visible, soft red, not oversized)
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sos,
                ),
                onPressed: widget.onTriggerSOS,
                icon: const Icon(Icons.emergency_outlined, size: 20),
                label: const Text(
                  'SOS — Emergency Alert',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Test Check-in Prompt
            Center(
              child: TextButton.icon(
                onPressed: widget.onTriggerCheckIn,
                icon: const Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.primary),
                label: const Text(
                  'Test Safety Check-In Prompt',
                  style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }
}
