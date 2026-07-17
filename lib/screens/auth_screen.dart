import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/utils/input_validators.dart';
import 'package:subh_warrior/features/auth/data/auth_service.dart';
import 'package:subh_warrior/features/challenge/presentation/challenge_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isRegister = false;
  bool _obscurePassword = true;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  AuthService get _auth => context.read<AuthService>();

  /// Pill-rounded, borderless edge shared by all auth text fields. The filled
  /// background carries the shape, so the outline is hidden until focus.
  OutlineInputBorder get _fieldBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      );

  /// Subtle fill behind each auth text field.
  Color get _fillColor => Theme.of(context)
      .colorScheme
      .surfaceContainerHighest
      .withValues(alpha: 0.5);

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Maps Firebase/Google auth errors to friendly text.
  String _authErrorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'That email is already registered. Try logging in instead.';
        case 'invalid-email':
          return 'That email address is not valid.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'user-not-found':
          return 'No account found for that email.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'weak-password':
          return 'Password is too weak (minimum 6 characters).';
        case 'network-request-failed':
          return 'Network error. Check your connection and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return e.message ?? 'Authentication failed. Please try again.';
      }
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_isRegister) {
        await _register();
      } else {
        await _login();
      }
    } catch (e) {
      _showError(_authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    final challenge = context.read<ChallengeProvider>();

    // Best-effort pre-check so we fail fast before creating the account.
    if (await challenge.checkUsernameExists(username)) {
      _showError('That username is already taken. Please choose another.');
      return;
    }

    await _auth.registerWithEmail(email: email, password: password);

    await challenge.updateUserSettings(
      name: username,
      location: '',
      latitude: 0,
      longitude: 0,
    );
  }

  Future<void> _login() async {
    await _auth.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _busy = true);
    try {
      final cred = await _auth.signInWithGoogle();
      if (!mounted) return;

      final challenge = context.read<ChallengeProvider>();
      if (challenge.userName.trim().isEmpty) {
        final unique =
            await _uniqueUsername(challenge, _deriveUsername(cred.user));
        await challenge.updateUserSettings(
          name: unique,
          location: '',
          latitude: 0,
          longitude: 0,
        );
      }
    } catch (e) {
      _showError(_authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Builds a valid base username from a Google account's display name or email.
  String _deriveUsername(User? user) {
    var name = user?.displayName?.trim() ?? '';
    if (name.isEmpty) {
      final email = user?.email ?? '';
      final at = email.indexOf('@');
      if (at > 0) name = email.substring(0, at);
    }
    name = name
        .replaceAll(RegExp(r'[^A-Za-z0-9_ ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (name.length < AppConstants.usernameMinLength) name = 'Warrior';
    if (name.length > AppConstants.usernameMaxLength) {
      name = name.substring(0, AppConstants.usernameMaxLength);
    }
    return name;
  }

  /// Returns [base] if free, otherwise appends a numeric suffix until unique
  /// (best-effort; `updateUserSettings` is the authoritative reservation).
  Future<String> _uniqueUsername(
      ChallengeProvider challenge, String base) async {
    if (!await challenge.checkUsernameExists(base)) return base;
    for (var i = 1; i < 1000; i++) {
      final suffix = i.toString();
      final maxBase = AppConstants.usernameMaxLength - suffix.length;
      final trimmed = base.length > maxBase ? base.substring(0, maxBase) : base;
      final candidate = '$trimmed$suffix';
      if (!await challenge.checkUsernameExists(candidate)) return candidate;
    }
    return base;
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    final emailError = InputValidators.email(email);
    if (emailError != null) {
      _showError('Enter your email above first, then tap "Forgot password".');
      return;
    }
    try {
      await _auth.sendPasswordReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent to $email.')),
      );
    } catch (e) {
      _showError(_authErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final googleEnabled = AuthService.googleServerClientId.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.wb_sunny,
                      size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    _isRegister ? 'Create your account' : 'Welcome back',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isRegister) ...[
                    TextFormField(
                      controller: _usernameController,
                      maxLength: AppConstants.usernameMaxLength,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.badge),
                        filled: true,
                        fillColor: _fillColor,
                        border: _fieldBorder,
                      ),
                      validator: (v) => InputValidators.username(v ?? ''),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: _fillColor,
                      border: _fieldBorder,
                    ),
                    validator: (v) => InputValidators.email(v ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      filled: true,
                      fillColor: _fillColor,
                      border: _fieldBorder,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => InputValidators.password(v ?? ''),
                  ),
                  if (!_isRegister)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isRegister ? 'Create account' : 'Log in'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() => _isRegister = !_isRegister),
                    child: Text(_isRegister
                        ? 'Already have an account? Log in'
                        : "Don't have an account? Register"),
                  ),
                  if (googleEnabled) ...[
                    const SizedBox(height: 8),
                    const Row(children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ]),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _signInWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
