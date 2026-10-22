import 'package:flutter/material.dart';
import '../models/journey_data.dart';
import '../models/trusted_contact.dart';
import '../theme/app_theme.dart';

class SafetyCheckInDialog {
  static Future<String?> show({
    required BuildContext context,
    required int attempt,
    required int maxAttempts,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        title: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 28),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you safe?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Check-in attempt $attempt of $maxAttempts. Please confirm your status to prevent alerting your guardians.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Large Green Safe Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.safe,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx, 'safe'),
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text(
                  "Yes, I'm safe",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Large Red Help Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sos,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(ctx, 'help'),
                icon: const Icon(Icons.warning_amber_rounded, size: 20),
                label: const Text(
                  'I need help',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Simulate no-response button for demonstration
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'timeout'),
              child: const Text(
                'Simulate no response',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showEscalationModal({
    required BuildContext context,
    required bool isManualSOS,
    required JourneyData journey,
    required List<TrustedContact> contacts,
  }) {
    final alertRecipients = contacts.where((c) => c.isAlertEnabled).toList();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sosLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.emergency_outlined, color: AppColors.sos, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isManualSOS ? 'Emergency SOS Alert' : 'Check-In Missed — Alert Sent',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sos),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isManualSOS
                    ? 'Manual SOS panic triggered. In production, this immediately broadcasts high-priority emergency notifications and SMS with live GPS.'
                    : 'The user did not respond across 3 consecutive check-ins. Automated escalation has been triggered.',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.45),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Telemetry Payload', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text('• Route: ${journey.source} ➔ ${journey.destination}', style: const TextStyle(fontSize: 12)),
                    const Text('• GPS: 28.6139° N, 77.2090° E (Delhi NCR)', style: const TextStyle(fontSize: 12)),
                    Text('• Timestamp: ${DateTime.now().toLocal().toString().split('.')[0]}', style: const TextStyle(fontSize: 12)),
                    const Text('• Battery: 74% • Status: Emergency', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Text(
                'Guardians Alerted (${alertRecipients.length}):',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              ...alertRecipients.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: AppColors.safe),
                        const SizedBox(width: 6),
                        Text('${c.name} (${c.phone})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  )),

              const SizedBox(height: 12),
              const Text(
                'Notice: In this starter prototype, alert dispatch is simulated in-memory. No real SMS charges or external network calls have been made.',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
