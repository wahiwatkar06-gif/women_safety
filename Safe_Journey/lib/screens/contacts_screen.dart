import 'package:flutter/material.dart';
import '../models/trusted_contact.dart';
import '../theme/app_theme.dart';

class ContactsScreen extends StatefulWidget {
  final List<TrustedContact> contacts;
  final Function(TrustedContact) onAddContact;
  final Function(TrustedContact) onUpdateContact;
  final Function(String) onDeleteContact;
  final Function(TrustedContact) onTestAlert;

  const ContactsScreen({
    super.key,
    required this.contacts,
    required this.onAddContact,
    required this.onUpdateContact,
    required this.onDeleteContact,
    required this.onTestAlert,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  void _openContactDialog({TrustedContact? contact}) {
    final isEditing = contact != null;
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    String relationship = contact?.relationship ?? 'Family';
    bool alertEnabled = contact?.isAlertEnabled ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing ? 'Edit Trusted Contact' : 'Add Trusted Contact',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(hintText: 'e.g. Mom, Best friend, Maya'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      const Text('Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(hintText: '+91 9876543210'),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a phone number';
                          final clean = val.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                          if (clean.length < 7) return 'Please enter a valid phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      const Text('Relationship', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: relationship,
                        decoration: const InputDecoration(),
                        items: ['Family', 'Friend', 'Colleague', 'Guardian', 'Other']
                            .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => relationship = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Checkbox(
                            value: alertEnabled,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setDialogState(() => alertEnabled = val ?? true);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Receive safety escalations & SMS',
                              style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      if (isEditing) {
                        widget.onUpdateContact(contact.copyWith(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          relationship: relationship,
                          isAlertEnabled: alertEnabled,
                        ));
                      } else {
                        widget.onAddContact(TrustedContact(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          relationship: relationship,
                          isAlertEnabled: alertEnabled,
                        ));
                      }
                      Navigator.pop(ctx);
                      setState(() {});
                    }
                  },
                  child: Text(isEditing ? 'Save Changes' : 'Add Contact'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(TrustedContact contact) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text(
          'Remove ${contact.name} from your trusted guardian circle? They will no longer receive emergency alerts.',
          style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.sos),
            onPressed: () {
              widget.onDeleteContact(contact.id);
              Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeGuardians = widget.contacts.where((c) => c.isAlertEnabled).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          IconButton(
            tooltip: 'Add Contact',
            icon: const Icon(Icons.person_add_alt_outlined, color: AppColors.primary),
            onPressed: () => _openContactDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Informative Notice Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${activeGuardians.length} of ${widget.contacts.length} guardians active',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Selected contacts will receive emergency SMS & GPS tracking if a check-in is unanswered.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Contacts List
            if (widget.contacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No Contacts Added Yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add friends or family members who should be alerted during emergencies.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _openContactDialog(),
                        icon: const Icon(Icons.person_add_alt_outlined, size: 18),
                        label: const Text('Add Guardian Contact'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...widget.contacts.map((contact) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: contact.isAlertEnabled ? AppColors.primaryLight : AppColors.cardBorder,
                      foregroundColor: contact.isAlertEnabled ? AppColors.primary : AppColors.textSecondary,
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            contact.relationship,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      contact.phone,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle alert status
                        Switch(
                          value: contact.isAlertEnabled,
                          activeColor: AppColors.primary,
                          onChanged: (val) {
                            widget.onUpdateContact(contact.copyWith(isAlertEnabled: val));
                            setState(() {});
                          },
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                          onSelected: (action) {
                            if (action == 'edit') {
                              _openContactDialog(contact: contact);
                            } else if (action == 'test') {
                              widget.onTestAlert(contact);
                            } else if (action == 'delete') {
                              _confirmDelete(contact);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16, color: AppColors.textPrimary),
                                  SizedBox(width: 8),
                                  Text('Edit Contact', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'test',
                              child: Row(
                                children: [
                                  Icon(Icons.send_outlined, size: 16, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Simulate Test Alert', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16, color: AppColors.sos),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.sos)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 16),

            // Add Contact Full Button
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _openContactDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Another Trusted Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
