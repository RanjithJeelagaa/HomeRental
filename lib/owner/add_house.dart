import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final _formKey = GlobalKey<FormState>();

  final _ownerController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _rentController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _availability = 'Available';
  String _propertyType = 'Apartment';
  String _occupancy = 'Family';

  @override
  void dispose() {
    _ownerController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _rentController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> picked = await _picker.pickMultiImage(imageQuality: 80);
    setState(() => _images.addAll(picked));
  }

  Future<void> _submitHouse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one image')));
      return;
    }

    // Upload images to Firebase Storage
    List<String> imageUrls = [];
    for (var img in _images) {
      final ref = FirebaseStorage.instance.ref().child(
        'house_images/${DateTime.now().millisecondsSinceEpoch}_${img.name}',
      );
      final uploadTask = await ref.putFile(File(img.path));
      final url = await uploadTask.ref.getDownloadURL();
      imageUrls.add(url);
    }

    // Save house details in Firestore
    await FirebaseFirestore.instance.collection('houses').add({
      'owner': _ownerController.text.trim(),
      'title': _titleController.text.trim(),
      'location': _locationController.text.trim(),
      'price': double.tryParse(_rentController.text.trim()) ?? 0,
      'availability': _availability,
      'propertyType': _propertyType,
      'occupancy': _occupancy,
      'description': _descriptionController.text.trim(),
      'discount': 0,
      'rating': 0,
      'image': imageUrls.first, // first image for grid preview
      'images': imageUrls, // store all images
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('House uploaded successfully')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add House')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Images'),
            ),
            const SizedBox(height: 12),
            _images.isEmpty
                ? const Text('No images selected')
                : SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.file(File(_images[i].path)),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _ownerController,
                    decoration: const InputDecoration(labelText: 'Owner Name'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'House Title'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location'),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _rentController,
                    decoration: const InputDecoration(labelText: 'Rent'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Enter rent' : null,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _availability,
                    items: const [
                      DropdownMenuItem(
                        value: 'Available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'Not available',
                        child: Text('Not available'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _availability = v!),
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _propertyType,
                    items: const [
                      DropdownMenuItem(
                        value: 'Apartment',
                        child: Text('Apartment'),
                      ),
                      DropdownMenuItem(
                        value: 'Cottage',
                        child: Text('Cottage'),
                      ),
                      DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                      DropdownMenuItem(value: 'Studio', child: Text('Studio')),
                      DropdownMenuItem(value: 'Duplex', child: Text('Duplex')),
                    ],
                    onChanged: (v) => setState(() => _propertyType = v!),
                    decoration: const InputDecoration(
                      labelText: 'Property Type',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: _occupancy,
                    items: const [
                      DropdownMenuItem(value: 'Family', child: Text('Family')),
                      DropdownMenuItem(
                        value: 'Bachelors',
                        child: Text('Bachelors'),
                      ),
                      DropdownMenuItem(
                        value: 'Hostellers',
                        child: Text('Hostellers'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _occupancy = v!),
                    decoration: const InputDecoration(labelText: 'Occupancy'),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitHouse,
                    child: const Text('Upload House'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
