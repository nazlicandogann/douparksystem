import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  InputDecoration customInputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColors.red),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    );
  }

  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tamam',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showPopup('Uyarı', 'Lütfen tüm alanları doldurun.');
      return;
    }

    if (password != confirmPassword) {
      _showPopup('Uyarı', 'Şifreler eşleşmiyor.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
    );

    setState(() {
      isLoading = false;
    });

    print(result); // 🔥 debug

    if (result['success'] == true) {
      _showPopup('Başarılı', 'Kayıt tamamlandı');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _showPopup('Hata', result['message'] ?? 'Kayıt başarısız');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 8,
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 12),
                      const Center(
                        child: Text(
                          "DouPark",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          "Email ve şifre ile kayıt ol",
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // NAME
                      TextField(
                        controller: nameController,
                        decoration: customInputDecoration(
                          hintText: "İsim",
                          icon: Icons.person_outline,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // EMAIL
                      TextField(
                        controller: emailController,
                        decoration: customInputDecoration(
                          hintText: "E-posta",
                          icon: Icons.email_outlined,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: customInputDecoration(
                          hintText: "Şifre",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CONFIRM
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPassword,
                        decoration: customInputDecoration(
                          hintText: "Şifre Tekrar",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword =
                                    !obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : registerUser,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text("Kayıt Ol"),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Zaten hesabın var mı? Giriş yap",
                          style: TextStyle(color: AppColors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}