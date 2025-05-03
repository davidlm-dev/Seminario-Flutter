import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser;
    if (user != null) {
      nameController.text = user['name'] ?? '';
      ageController.text = user['age']?.toString() ?? '';
      emailController.text = user['email'] ?? '';
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      final userId = AuthService.currentUser?['id'];
      if (userId == null) return;

      final response = await http.put(
        Uri.parse('http://localhost:9000/api/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nameController.text,
          'age': int.tryParse(ageController.text) ?? 0,
          'email': emailController.text,
        }),
      );

      if (response.statusCode == 200) {
        // Update currentUser with the new data
        AuthService.currentUser = {
          'id': userId,
          'email': emailController.text,
        };

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el perfil')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.isEmpty
                    ? 'El nombre no puede estar vacío'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La edad no puede estar vacía';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 0) {
                    return 'Por favor, introduce una edad válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo electrónico no puede estar vacío';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor, introduce un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Actualizar Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}