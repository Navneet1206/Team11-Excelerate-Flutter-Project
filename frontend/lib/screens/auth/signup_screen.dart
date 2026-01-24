import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth_controller.dart';
import '../../services/api_client.dart';
import '../../ui/app_popups.dart';

class SignupScreen extends StatefulWidget {
  final AuthController auth;

  const SignupScreen({super.key, required this.auth});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await widget.auth.signupLearner(
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      // AuthController updates auth state; router redirect will take user to /learner.
      context.go('/learner');
    } on ApiException catch (e) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Signup failed', message: e.message);
    } catch (_) {
      if (!mounted) return;
      await showAppErrorPopup(context, title: 'Signup failed', message: 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Defined colors for Signup
    const secondaryGradientStart = Color(0xFF2EC4B6);
    const secondaryGradientEnd = Color(0xFF7EE8D4);
    const headerBackground = Color(0xFFEFFFFB);
    const inputBackground = Color(0xFFFFFFFF);
    const borderColor = Color(0xFFE4E8F3);
    const primaryText = Color(0xFF1F2937);
    const secondaryText = Color(0xFF6B7280);
    const mintIconColor = Color(0xFF4FD1C5);
    const primaryLinkColor = Color(0xFF2EC4B6); 

    final textTheme = Theme.of(context).textTheme;

    // Gradient Button Style
    final secondaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 0,
    );

    // Input decoration helper
    InputDecoration inputDecor(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: secondaryText),
        prefixIcon: Icon(icon, color: mintIconColor.withValues(alpha: 0.8)),
        filled: true,
        fillColor: inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: secondaryGradientStart, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      );
    }


    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Premium Header
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                      decoration: BoxDecoration(
                        color: headerBackground,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryGradientStart.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryGradientStart.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_add_rounded, size: 40, color: mintIconColor),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Join SkillTrack',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: primaryText,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Begin your learning journey today',
                            style: textTheme.bodyMedium?.copyWith(
                              color: secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _fullName,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: primaryText),
                            decoration: inputDecor('Full Name', Icons.person_outline_rounded),
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'Full name is required';
                              if (value.length < 2) return 'Enter a valid name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: primaryText),
                            decoration: inputDecor('Email Address', Icons.mail_outline_rounded),
                            validator: (v) {
                              final value = (v ?? '').trim();
                              if (value.isEmpty) return 'Email is required';
                              if (!value.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _password,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: primaryText),
                            decoration: inputDecor('Create Password', Icons.lock_outline_rounded).copyWith(
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                            validator: (v) {
                              final value = v ?? '';
                              if (value.isEmpty) return 'Password is required';
                              if (value.length < 6) return 'Minimum 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPassword,
                            obscureText: _obscure,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(color: primaryText),
                            decoration: inputDecor('Confirm Password', Icons.lock_clock_outlined),
                            validator: (v) {
                              final value = v ?? '';
                              if (value.isEmpty) return 'Confirm your password';
                              if (value != _password.text) return 'Passwords do not match';
                              return null;
                            },
                            onFieldSubmitted: (_) => _loading ? null : _submit(),
                          ),
                          const SizedBox(height: 32),
                          
                          // Secondary Gradient Button
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [secondaryGradientStart, secondaryGradientEnd],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: secondaryGradientStart.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: secondaryButtonStyle,
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ', style: TextStyle(color: secondaryText)),
                              GestureDetector(
                                onTap: _loading ? null : () => context.go('/login'),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: primaryLinkColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
