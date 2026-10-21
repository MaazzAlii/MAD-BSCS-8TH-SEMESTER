import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Navigation Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text("Form Example"),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(20),
          child: FormWidget(),
        ),
      ),
    );
  }
}

class FormWidget extends StatefulWidget {
  const FormWidget({super.key});

  @override
  State<FormWidget> createState() => FormWidgetState();
}

class FormWidgetState extends State<FormWidget> {
  final _formKey = GlobalKey<FormState>();

  String _name = "";
  String _email = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: "John Doe",
              labelText: "Please enter your name",
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter a valid name";
              }
              return null;
            },
            onSaved: (value) {
              _name = value ?? "";
            },
          ),

          const SizedBox(height: 20),

          // Email field
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              icon: Icon(Icons.email),
              hintText: "example@gmail.com",
              labelText: "Please enter your email",
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Please enter your email";
              }

              final emailRegex = RegExp(
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
              );

              if (!emailRegex.hasMatch(value.trim())) {
                return "Please enter a valid email";
              }

              return null;
            },
            onSaved: (value) {
              _email = value ?? "";
            },
          ),

          const SizedBox(height: 20),

          // Submit button with Navigation
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Navigate to the DetailsScreen and pass data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        name: _name,
                        email: _email,
                      ),
                    ),
                  );
                }
              },
              child: const Text("Submit & Navigate"),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------------
// Second Screen to display the submitted data
// -------------------------------------------------------------------------
class DetailsScreen extends StatelessWidget {
  final String name;
  final String email;

  const DetailsScreen({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submitted Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Form Submitted Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Name: $name",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Email: $email",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Go back to the form screen
                  Navigator.pop(context);
                },
                child: const Text("Back to Form"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}