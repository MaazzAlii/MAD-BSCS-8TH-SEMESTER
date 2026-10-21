import 'package:flutter/material.dart';

// ============================================================================
// 🟢 [60% UNIVERSAL SKELETON] - IDENTICAL ENTRY POINT
// ============================================================================
void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FormValidationScreen(),
    ));

class FormValidationScreen extends StatefulWidget {
  const FormValidationScreen({super.key});

  @override
  State<FormValidationScreen> createState() => _FormValidationScreenState();
}

class _FormValidationScreenState extends State<FormValidationScreen> {
  // ==========================================================================
  // 🔴 [40% FORM VALIDATION CORE LOGIC]
  // 1. Declare GlobalKey<FormState>
  // 2. Declare Controllers
  // 3. Call _formKey.currentState!.validate()
  // ==========================================================================
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form Submitted! Welcome ${_nameController.text}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ==========================================================================
  // 🟢 [60% UNIVERSAL SKELETON] - SCAFFOLD + APPBAR + PADDING
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Validation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // 🔴 Connect key to Form widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔴 Name Field with validator
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null; // Valid
                },
              ),
              const SizedBox(height: 16),

              // 🔴 Email Field with validator
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null; // Valid
                },
              ),
              const SizedBox(height: 24),

              // 🔴 Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Submit Form', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
