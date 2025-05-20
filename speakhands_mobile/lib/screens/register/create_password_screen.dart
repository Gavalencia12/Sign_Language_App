import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/service/auth_service.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;


  // Estados de validación
  bool hasMinLength = false;
  bool hasNumber = false;
  bool hasSymbol = false;
  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isCurrent = index == currentStep - 1;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 20,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFFB388FF) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }


  void _validatePassword(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSymbol = RegExp(r'[!@#\$&*~%^()_\-+=.,:;<>?/\\]').hasMatch(password);
    });
  }

  Color _getStrengthColor() {
    int score = [hasMinLength, hasNumber, hasSymbol].where((v) => v).length;
    if (score == 0) return Colors.grey;
    if (score == 1) return Colors.red;
    if (score == 2) return Colors.orange;
    return Colors.green;
  }

  void _registerUser(String email) async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showMessage("All fields are required");
      return;
    }

    if (password != confirm) {
      _showMessage("Passwords do not match");
      return;
    }

    if (!(hasMinLength && hasNumber && hasSymbol)) {
      _showMessage("Password does not meet all criteria");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.createUserWithEmail(email, password);
      _showMessage("Account created successfully");
      final user = _authService.currentUser;
        if (user != null) {
        Navigator.pushReplacementNamed(
            context,
            '/complete_profile',
            arguments: {
            'email': user.email!,
            'createdAt': user.metadata.creationTime ?? DateTime.now(),
            },
        );
        }
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? AppTheme.darkBackground : AppTheme.lightBackground;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2F3A4A);

    return Scaffold(
    backgroundColor: backgroundColor,
    resizeToAvoidBottomInset: true, 
    appBar: AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: textColor),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create a password 3 / 3", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            _buildStepIndicator(3),
            const SizedBox(height: 30),

            const Text("Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: _validatePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: [hasMinLength, hasNumber, hasSymbol].where((v) => v).length / 3,
              backgroundColor: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
            ),
            const SizedBox(height: 12),
            _buildCriteriaIndicator("8 characters minimum", hasMinLength),
            _buildCriteriaIndicator("a number", hasNumber),
            _buildCriteriaIndicator("a symbol", hasSymbol),
            const SizedBox(height: 20),

            const Text("Confirm your password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _registerUser(email),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26C6DA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Create account", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
              Center(
                child: Text(
                  "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6)),
                ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildCriteriaIndicator(String label, bool fulfilled) {
    return Row(
      children: [
        Icon(
          fulfilled ? Icons.check_circle : Icons.radio_button_unchecked,
          color: fulfilled ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
