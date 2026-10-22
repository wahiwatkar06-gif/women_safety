import 'dart:async';
import 'package:flutter/material.dart';
import 'models/journey_data.dart';
import 'models/trusted_contact.dart';
import 'screens/active_journey_screen.dart';
import 'screens/check_in_dialog.dart';
import 'screens/contacts_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const SafeJourneyApp());
}

class SafeJourneyApp extends StatelessWidget {
  const SafeJourneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Journey',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  // Shared Application State
  final JourneyData _journey = JourneyData(
    source: 'Campus Library, North Gate',
    destination: 'Greenwood Apartments, Block B',
    durationMinutes: 20,
  );

  final List<TrustedContact> _contacts = [
    TrustedContact(
      id: '1',
      name: 'Mom',
      phone: '+91 9812345678',
      relationship: 'Family',
      isAlertEnabled: true,
    ),
    TrustedContact(
      id: '2',
      name: 'Best friend (Sarah)',
      phone: '+91 9898765432',
      relationship: 'Friend',
      isAlertEnabled: true,
    ),
  ];

  String _userName = 'Tushar';
  String _emergencyNote = 'Blood Group O+';
  int _defaultDuration = 20;
  int _reminderIntervalSeconds = 30; // 30s for smooth interactive demo

  // Journey Lifecycle Handlers
  void _startJourney() {
    setState(() {
      _journey.isActive = true;
      _journey.isCompleted = false;
      _journey.isEscalated = false;
      _journey.checkInAttempts = 0;
      _journey.startTime = DateTime.now();
      _journey.expectedArrival = DateTime.now().add(Duration(minutes: _journey.durationMinutes));
      _currentIndex = 1; // Switch to My Journey tab
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Safe Journey started to ${_journey.destination}.'),
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  void _endJourney({bool showMessage = true}) {
    setState(() {
      _journey.isActive = false;
      _journey.isCompleted = true;
      _journey.isEscalated = false;
      _journey.checkInAttempts = 0;
    });

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Journey completed safely. Tracking closed."),
          backgroundColor: AppColors.safe,
        ),
      );
    }
  }

  Future<void> _handleCheckInPrompt({int attempt = 1}) async {
    if (!mounted || !_journey.isActive || _journey.isEscalated) return;

    setState(() {
      _journey.checkInAttempts = attempt;
    });

    final result = await SafetyCheckInDialog.show(
      context: context,
      attempt: attempt,
      maxAttempts: 3,
    );

    if (!mounted) return;

    if (result == 'safe') {
      _endJourney(showMessage: true);
    } else if (result == 'help') {
      _triggerSOS();
    } else if (result == 'timeout') {
      if (attempt < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No response received. Retrying check-in in ${_reminderIntervalSeconds}s...'),
            duration: const Duration(seconds: 3),
          ),
        );
        await Future<void>.delayed(Duration(seconds: _reminderIntervalSeconds));
        if (mounted && _journey.isActive && !_journey.isEscalated) {
          _handleCheckInPrompt(attempt: attempt + 1);
        }
      } else {
        _triggerEscalation();
      }
    }
  }

  void _triggerSOS() {
    setState(() {
      _journey.isEscalated = true;
    });

    SafetyCheckInDialog.showEscalationModal(
      context: context,
      isManualSOS: true,
      journey: _journey,
      contacts: _contacts,
    );
  }

  void _triggerEscalation() {
    setState(() {
      _journey.isEscalated = true;
    });

    SafetyCheckInDialog.showEscalationModal(
      context: context,
      isManualSOS: false,
      journey: _journey,
      contacts: _contacts,
    );
  }

  void _simulateTestAlert(TrustedContact contact) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.send_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Simulated SMS to ${contact.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(
            'TEST ALERT: Safe Journey test dispatch to ${contact.phone}.\n\n'
            'User: $_userName\n'
            'Location: ${_journey.source}\n'
            'Timestamp: ${DateTime.now().toLocal().toString().split('.')[0]}\n\n'
            '(Simulation test only — no actual SMS sent)',
            style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        journey: _journey,
        onStartJourney: _startJourney,
        onOpenSettings: () => setState(() => _currentIndex = 3),
        onTriggerSOS: _triggerSOS,
      ),
      ActiveJourneyScreen(
        journey: _journey,
        onEndJourney: () => _endJourney(showMessage: true),
        onTriggerSOS: _triggerSOS,
        onTriggerCheckIn: () => _handleCheckInPrompt(attempt: 1),
        onGoToPlan: () => setState(() => _currentIndex = 0),
      ),
      ContactsScreen(
        contacts: _contacts,
        onAddContact: (contact) {
          setState(() => _contacts.add(contact));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Added ${contact.name} to trusted contacts.')),
          );
        },
        onUpdateContact: (contact) {
          setState(() {
            final idx = _contacts.indexWhere((c) => c.id == contact.id);
            if (idx != -1) _contacts[idx] = contact;
          });
        },
        onDeleteContact: (id) {
          setState(() => _contacts.removeWhere((c) => c.id == id));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact removed.')),
          );
        },
        onTestAlert: _simulateTestAlert,
      ),
      SettingsScreen(
        userName: _userName,
        emergencyNote: _emergencyNote,
        defaultDuration: _defaultDuration,
        reminderIntervalSeconds: _reminderIntervalSeconds,
        onUpdateProfile: (name, note) {
          setState(() {
            _userName = name;
            _emergencyNote = note;
          });
        },
        onUpdateDefaultDuration: (dur) {
          setState(() {
            _defaultDuration = dur;
            _journey.durationMinutes = dur;
          });
        },
        onUpdateReminderInterval: (sec) {
          setState(() => _reminderIntervalSeconds = sec);
        },
        onGoToContacts: () => setState(() => _currentIndex = 2),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.navigation_outlined),
                if (_journey.isActive)
                  const Positioned(
                    top: -2,
                    right: -2,
                    child: Icon(Icons.circle, color: AppColors.safe, size: 8),
                  ),
              ],
            ),
            activeIcon: const Icon(Icons.navigation),
            label: 'My Journey',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.people_outline),
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_contacts.length}',
                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            activeIcon: const Icon(Icons.people),
            label: 'Trusted Contacts',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
