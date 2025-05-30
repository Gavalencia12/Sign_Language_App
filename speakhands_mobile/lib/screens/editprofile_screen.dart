import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/service/text_to_speech_service.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/main_nav.dart';



class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _ageController = TextEditingController();
  final _disabilityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aboutController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  File? _imageFile;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();
  final TextToSpeechService ttsService = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakIntro());
  }

  Future<void> _speakIntro() async {
    final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
    if (speakOn) {
      final texto = AppLocalizations.of(context)!.profile_edit_intro;
      final locale = Localizations.localeOf(context).languageCode;
      await ttsService.stop();
      await ttsService.speak(texto, languageCode: locale);
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseDatabase.instance.ref("usuarios").child(user.uid).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _nameController.text = data["nombre"] ?? "";
          _birthDateController.text = data["fecha_nacimiento"] ?? "";
          _ageController.text = data["edad"] ?? "";
          _disabilityController.text = data["discapacidad"] ?? "";
          _phoneController.text = data["telefono"] ?? "";
          _aboutController.text = data["about"] ?? "";
          _selectedGender = data["sexo"];
          _imageUrl = data["foto"];
        });
      }
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 20);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _ageController.text = (now.year - picked.year).toString();
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile, String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref('profile_images/$uid.jpg');
      final uploadTask = ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Image upload error: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? newImageUrl = _imageUrl;
    if (_imageFile != null) {
      newImageUrl = await _uploadImage(_imageFile!, user.uid);
    }

    await FirebaseDatabase.instance.ref("usuarios").child(user.uid).update({
      "nombre": _nameController.text.trim(),
      "fecha_nacimiento": _birthDateController.text.trim(),
      "edad": _ageController.text.trim(),
      "sexo": _selectedGender,
      "discapacidad": _disabilityController.text.trim(),
      "telefono": _phoneController.text.trim(),
      "about": _aboutController.text.trim(),
      if (newImageUrl != null) "foto": newImageUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    ttsService.stop();
    _nameController.dispose();
    _birthDateController.dispose();
    _ageController.dispose();
    _disabilityController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF2F3A4A);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_imageUrl != null ? NetworkImage(_imageUrl!) as ImageProvider : null),
                    child: (_imageFile == null && _imageUrl == null)
                        ? Icon(Icons.person, size: 55, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField("Name", _nameController, textColor),
            _buildDatePicker("Birth of date", _birthDateController, context),
            _buildTextField("Age", _ageController, textColor, readOnly: true),
            _buildDropdown("Sex", _selectedGender, textColor),
            _buildTextField("Disability", _disabilityController, textColor),
            _buildTextField("Phone Number", _phoneController, textColor),
            _buildTextField("About you", _aboutController, textColor, maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26C6DA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveProfile,
                child: const Text("Save Profile", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, Color textColor, {bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, TextEditingController controller, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _pickDate(context),
        child: AbsorbPointer(
          child: _buildTextField(label, controller, Theme.of(context).textTheme.bodyMedium!.color!),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: textColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: const [
          DropdownMenuItem(value: "Male", child: Text("Male")),
          DropdownMenuItem(value: "Female", child: Text("Female")),
          DropdownMenuItem(value: "Other", child: Text("Other")),
        ],
        onChanged: (value) => setState(() => _selectedGender = value),
      ),
    );
  }
}
