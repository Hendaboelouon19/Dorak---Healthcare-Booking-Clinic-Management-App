import 'package:flutter/material.dart';

class ClinicEditScreen extends StatelessWidget {
  const ClinicEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clinic Edit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              TextField(decoration: InputDecoration(labelText: 'Clinic name')),
              SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: 'Address')),
              SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: 'Working hours')),
              SizedBox(height: 16),
              TextField(decoration: InputDecoration(labelText: 'Assigned assistant')),
              SizedBox(height: 20),
              Text('Doctors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 10),
              Text('Dr. Hassan Nasser'),
              Text('Dr. Noor Badr'),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: null, child: Text('Cancel'))),
                  SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: null, child: Text('Save'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
