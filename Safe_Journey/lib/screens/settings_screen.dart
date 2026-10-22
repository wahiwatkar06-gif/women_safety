import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String emergencyNote;
  final int defaultDuration;
  final int reminderIntervalSeconds;
  final Function(String name, String note) onUpdateProfile;
  final Function(int duration) onUpdateDefaultDuration;
  final Function(int seconds) onUpdateReminderInterval;
  final VoidCallback onGoToContacts;

  const SettingsScreen({
    super.key,
    required this.userName,
    required this.emergencyNote,
    required this.defaultDuration,
    required this.reminderIntervalSeconds,
    required this.onUpdateProfile,
    required this.onUpdateDefaultDuration,
    required this.onUpdateReminderInterval,
    required this.onGoToContacts,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _openEditProfileDialog() {
    final nameCtrl = TextEditingController(text: widget.userName);
    final noteCtrl = TextEditingController(text: widget.emergencyNote);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile & Emergency Note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g. Tushar')),
            const SizedBox(height: 14),
            const Text('Emergency Medical / Safety Note', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'e.g. Blood Group O+, Asthma inhaler in bag'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              widget.onUpdateProfile(nameCtrl.text.trim(), noteCtrl.text.trim());
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Privacy & Security Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Text(
            'Safe Journey values your privacy above all.\n\n'
            '• Local Data: Your locations, contacts, and journey history are kept locally in-memory during this prototype session.\n\n'
            '• No Third-Party Selling: Your personal information and location coordinates are never sold or shared with advertisers.\n\n'
            '• Emergency Transmission: In production, location data is only broadcast to your explicitly chosen trusted contacts upon an unconfirmed check-in or manual SOS panic trigger.\n\n'
            '• Permissions: You retain control over location tracking and can terminate journeys at any time.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
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

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
            SizedBox(width: 8),
            Text('About Safe Journey', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Safe Journey v1.0.0\n'
          'Designed to empower women and solo travelers with proactive journey monitoring, automated check-ins, and guardian escalation.\n\n'
          'Notice: This prototype runs client-side in-memory. For production emergency service, integrate native GPS background permissions, Firebase backend, and verified SMS gateways.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName.isNotEmpty ? widget.userName : 'User Profile',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.emergencyNote.isNotEmpty ? widget.emergencyNote : 'No emergency note added',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                    onPressed: _openEditProfileDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionHeader('JOURNEY PREFERENCES'),

            // Default Duration
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: ListTile(
                leading: const Icon(Icons.timer_outlined, color: AppColors.primary),
                title: const Text('Default Journey Duration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${widget.defaultDuration} minutes', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: DropdownButton<int>(
                  value: widget.defaultDuration,
                  underline: const SizedBox(),
                  items: [15, 20, 30, 45, 60]
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d min', style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) widget.onUpdateDefaultDuration(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Safety Reminder Interval
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                title: const Text('Safety Check-In Interval', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${widget.reminderIntervalSeconds}s between reminders (3 attempts max)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                trailing: DropdownButton<int>(
                  value: widget.reminderIntervalSeconds,
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: 10, child: Text('10s (Demo)', style: TextStyle(fontSize: 13))),
                    const DropdownMenuItem(value: 30, child: Text('30s (Fast)', style: TextStyle(fontSize: 13))),
                    const DropdownMenuItem(value: 60, child: Text('1 min', style: TextStyle(fontSize: 13))),
                    const DropdownMenuItem(value: 120, child: Text('2 min', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (val) {
                    if (val != null) widget.onUpdateReminderInterval(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),
            _sectionHeader('DEVICE & PERMISSIONS STATUS'),

            // Permission statuses (explicitly realistic and transparent)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _permissionRow(
                    icon: Icons.location_on_outlined,
                    title: 'Location Permissions',
                    status: 'Simulation Mode (Starter)',
                    isLive: false,
                  ),
                  const Divider(color: AppColors.cardBorder, height: 16),
                  _permissionRow(
                    icon: Icons.notifications_none_outlined,
                    title: 'Push Notifications',
                    status: 'In-App Modal Active',
                    isLive: true,
                  ),
                  const Divider(color: AppColors.cardBorder, height: 16),
                  _permissionRow(
                    icon: Icons.sms_outlined,
                    title: 'SMS Gateway',
                    status: 'Client Simulated (Twilio/AWS pending)',
                    isLive: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _sectionHeader('GENERAL'),

            // Manage Contacts Shortcut
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_outline, color: AppColors.primary),
                    title: const Text('Manage Trusted Contacts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: widget.onGoToContacts,
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    title: const Text('Privacy Policy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: _showPrivacyPolicy,
                  ),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.primary),
                    title: const Text('About Safe Journey', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: _showAboutDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8),
      ),
    );
  }

  Widget _permissionRow({required IconData icon, required String title, required String status, required bool isLive}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              Text(status, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isLive ? AppColors.safeLight : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isLive ? AppColors.safe.withOpacity(0.3) : AppColors.cardBorder),
          ),
          child: Text(
            isLive ? 'Active' : 'Simulated',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isLive ? AppColors.safe : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
