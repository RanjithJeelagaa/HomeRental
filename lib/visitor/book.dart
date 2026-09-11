import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _jobCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _companyNameCtrl = TextEditingController();
  final _companyAddressCtrl = TextEditingController();

  bool _isEditing = false;
  Map<String, dynamic> _house = {};
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _house = Map<String, dynamic>.from(args);

      final userName =
          args['userName'] ?? args['name'] ?? args['user']?['name'];
      final userPhone =
          args['userPhone'] ??
          args['phone'] ??
          args['user']?['phone'] ??
          args['user']?['contact'];
      final userEmail =
          args['userEmail'] ?? args['email'] ?? args['user']?['email'];

      if (userName != null) _nameCtrl.text = userName.toString();
      if (userPhone != null) _phoneCtrl.text = userPhone.toString();
      if (userEmail != null) _emailCtrl.text = userEmail.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _emailCtrl.dispose();
    _jobCtrl.dispose();
    _salaryCtrl.dispose();
    _companyNameCtrl.dispose();
    _companyAddressCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final bookingId = DateTime.now().millisecondsSinceEpoch.toString();

    final booking = {
      'id': bookingId,
      'houseId': _house['id'] ?? '',
      'houseTitle': _house['title'] ?? 'House',
      'ownerId': _house['ownerId'] ?? '',
      'owner': _house['owner'] ?? '',
      'price': _house['price'] ?? 0,
      'location': _house['location'] ?? '',
      'images': _house['images'] ?? [],
      'userName': _nameCtrl.text.trim(),
      'userContact': _phoneCtrl.text.trim(),
      'altContact': _altPhoneCtrl.text.trim(),
      'userEmail': _emailCtrl.text.trim(),
      'jobTitle': _jobCtrl.text.trim(),
      'salary': _salaryCtrl.text.trim(),
      'companyName': _companyNameCtrl.text.trim(),
      'companyAddress': _companyAddressCtrl.text.trim(),
      'fromDate': _house['fromDate'],
      'toDate': _house['toDate'],
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    final firestore = FirebaseFirestore.instance;

    // Save booking under visitor’s bookings
    await firestore.collection('bookings').doc(bookingId).set(booking);

    // Save booking under owner’s bookings
    if (_house['ownerId'] != null) {
      await firestore
          .collection('ownerBookings')
          .doc(_house['ownerId'])
          .collection('bookings')
          .doc(bookingId)
          .set(booking);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request sent to owner')),
    );

    Navigator.pushNamed(context, '/myBookings', arguments: booking);
  }

  @override
  Widget build(BuildContext context) {
    final title = _house['title']?.toString() ?? 'Booking';
    final price = _house['price']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Book: $title'),
        actions: [
          IconButton(
            tooltip: _isEditing ? 'Done' : 'Edit',
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (price.isNotEmpty)
                Text(
                  'Price: ₹$price/month',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                readOnly: !_isEditing,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                readOnly: !_isEditing,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter phone' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _altPhoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Alternative Phone',
                  prefixIcon: Icon(Icons.phone_forwarded),
                ),
                keyboardType: TextInputType.phone,
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                readOnly: !_isEditing,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter email';
                  final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!pattern.hasMatch(v.trim())) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jobCtrl,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  prefixIcon: Icon(Icons.work),
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Salary',
                  prefixIcon: Icon(Icons.money),
                ),
                keyboardType: TextInputType.number,
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  prefixIcon: Icon(Icons.business),
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyAddressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Company Address',
                  prefixIcon: Icon(Icons.location_city),
                ),
                readOnly: !_isEditing,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _confirmBooking,
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
