import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/service/auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';



class CompleteProfileScreen extends StatelessWidget {
  final String email;
  final DateTime createdAt;

  const CompleteProfileScreen({
    super.key,
    required this.email,
    required this.createdAt,
  });

  void _signOut(BuildContext context) async {
    // Elimina todas las pantallas previas y navega al Home
    Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false); 
  }

  @override
  Widget build(BuildContext context) {
    final _nameController = TextEditingController();
    final _birthDateController = TextEditingController();
    final _ageController = TextEditingController();
    final _disabilityController = TextEditingController();
    final _aboutController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Complete Your Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Name")),
            const SizedBox(height: 10),
            TextField(controller: _birthDateController, decoration: const InputDecoration(labelText: "Birth Date")),
            const SizedBox(height: 10),
            TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Age")),
            const SizedBox(height: 10),
            TextField(controller: _disabilityController, decoration: const InputDecoration(labelText: "Disability")),
            const SizedBox(height: 10),
            TextField(controller: _aboutController, maxLines: 3, decoration: const InputDecoration(labelText: "About you")),
            const SizedBox(height: 20),
            Text("Email: $email"),
            Text("Created at: ${createdAt.toIso8601String()}"),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No user signed in")),
                    );
                    return;
                    }

                    final uid = user.uid;
                    final databaseRef = FirebaseDatabase.instance.ref();

                    await databaseRef.child("usuarios").child(uid).update({
                    "nombre": _nameController.text.trim(),
                    "fecha_nacimiento": _birthDateController.text.trim(),
                    "edad": _ageController.text.trim(),
                    "discapacidad": _disabilityController.text.trim(),
                    "about": _aboutController.text.trim(),
                    "fecha_creacion": createdAt.toIso8601String(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Profile saved successfully")),
                    );
                    _signOut(context); // Cerrar sesión   
                },
                child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
