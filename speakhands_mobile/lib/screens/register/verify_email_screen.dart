import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/screens/register/verify_email_screen.dart';
import 'package:speakhands_mobile/service/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
    final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());

    final _authService = AuthService();

    void _verifyCode() async {
    String code = _controllers.map((c) => c.text).join();

    if (code.length != 5 || !RegExp(r'^\d{5}$').hasMatch(code)) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 5-digit code")),
        );
        return;
    }

    final email = ModalRoute.of(context)?.settings.arguments as String;

    try {
        bool isValid = await _authService.verifyCode(email, code);
        if (isValid) {
        Navigator.pushNamed(context, '/create_password', arguments: email);
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Incorrect code. Please try again.")),
        );
        }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error verifying code: $e")),
        );
    }
    }

    Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        bool isCurrent = index == currentStep - 2;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 20,
          height: 6,
          decoration: BoxDecoration(
            color: isCurrent ? const Color(0xFFA0E7E5) : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

    void _resendCode() async {
        final email = ModalRoute.of(context)?.settings.arguments as String;
        final _authService = AuthService();

        try {
            await _authService.sendVerificationCode(email);
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Code resent")),
            );
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error resending code: $e")),
            );
        }
    }


  @override
    Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? 'your@email.com';
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
            padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text("Verify your email 2 / 3", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 8),
                _buildStepIndicator(3),
                const SizedBox(height: 12),
                Text(
                "We just sent 5-digit code to\n$email, enter it below:",
                style: TextStyle(color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(height: 24),
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                    return SizedBox(
                    width: 48,
                    child: TextField(
                        controller: _controllers[index],
                        maxLength: 1,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(counterText: ''),
                        onChanged: (value) {
                        if (value.length == 1 && index < 4) {
                            FocusScope.of(context).nextFocus();
                        }
                        },
                    ),
                    );
                }),
                ),
                const SizedBox(height: 30),
                SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF26C6DA),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Verify email", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                ),
                const SizedBox(height: 20),
                Center(
                child: GestureDetector(
                    onTap: _resendCode,
                    child: const Text(
                    "Wrong email? Send to different email",
                    style: TextStyle(color: Colors.blue),
                    ),
                ),
                ),
                const SizedBox(height: 40),
                Center(
                child: Text(
                    "By using Classroom, you agree to the\nTerms and Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold),
                ),
                ),
            ],
            ),
        ),
        ),
    );
    }
}
