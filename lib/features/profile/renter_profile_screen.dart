import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session.dart';

class RenterProfileScreen extends StatefulWidget {
  const RenterProfileScreen({super.key});

  @override
  State<RenterProfileScreen> createState() => _RenterProfileScreenState();
}

class _RenterProfileScreenState extends State<RenterProfileScreen> {
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final List<TextEditingController> _phoneControllers = [];

  @override
  void initState() {
    super.initState();
    // Demo defaults (could be loaded from backend in production)
    _emailController.text = '';
    _addressController.text = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    for (final c in _phoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addPhoneField() {
    setState(() {
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhoneField(int index) {
    setState(() {
      final c = _phoneControllers.removeAt(index);
      c.dispose();
    });
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile details saved (demo).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance;
    final name = session.userName.value ?? 'Tenant';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(name),
              subtitle: Text(session.propertyName.value ?? 'Assigned property'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Personal details',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: name,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.badge_outlined),
                      helperText: 'Name cannot be changed',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your address',
                      prefixIcon: Icon(Icons.home_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text('Additional phone numbers',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      TextButton.icon(
                        onPressed: _addPhoneField,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_phoneControllers.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'No additional phone numbers added.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  for (int i = 0; i < _phoneControllers.length; i++) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneControllers[i],
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone number ${i + 1}',
                              hintText: 'Enter phone number',
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: () => _removePhoneField(i),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(children: [
              const ListTile(
                  leading: Icon(Icons.home_work_outlined),
                  title: Text('Property'),
                  subtitle: Text('Linked to owner-managed property (demo)')),
              const ListTile(
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Role permissions'),
                  subtitle: Text('View tank/usage/charges/payments. No hardware or pricing controls.')),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  session.logout();
                  context.go(AppRoutes.login);
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
