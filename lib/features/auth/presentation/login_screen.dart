import 'package:material_ui/material_ui.dart';

import '../../../core/theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onSignIn, this.onViewShopMenu});

  /// Optional callback wired to your Supabase auth / role logic.
  final Future<void> Function(
    String username,
    String password,
    bool rememberMe,
  )?
  onSignIn;

  /// Optional callback to open the non-login shop menu view.
  final VoidCallback? onViewShopMenu;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Local login-specific surface tones matching the FR-11 wireframe
  static const Color _cardTaupe = Color(0xFF5C4B46);
  static const Color _customerBoxDark = Color(0xFF24140E);
  static const Color _customerBoxBorder = Color(0xFF3A241B);
  static const Color _inputCream = Color(0xFFF3EFEA);
  static const Color _mutedLight = Color(0xFFD8C8C2);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      if (widget.onSignIn != null) {
        await widget.onSignIn!(
          _usernameController.text.trim(),
          _passwordController.text,
          _rememberMe,
        );
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Login failed. Please check your username and password.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _handleForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content: const Text(
          'Please contact the shop owner to reset your staff account password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _handleViewShopMenu() {
    if (widget.onViewShopMenu != null) {
      widget.onViewShopMenu!();
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Opening shop menu...')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            return isWide ? _buildDesktopLayout() : _buildMobileLayout();
          },
        ),
      ),
    );
  }

  Widget _buildBrandLogo({double size = 36}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF2E1E18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A352D)),
      ),
      child: Icon(Icons.image_outlined, color: _mutedLight, size: size * 0.55),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildBrandLogo(size: 36),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mawar Cake House',
                      style: TextStyle(
                        color: kCream,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Cakes . Pastries . More',
                      style: TextStyle(color: _mutedLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome Back',
            style: TextStyle(
              color: kCream,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to manage your shop',
            style: TextStyle(color: _mutedLight, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildFormBody(showCardHeading: false),
          const SizedBox(height: 18),
          _buildCustomerMenuBox(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              _buildBrandLogo(size: 38),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mawar Cake House',
                    style: TextStyle(
                      color: kCream,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'MANAGEMENT PORTAL',
                    style: TextStyle(
                      color: _mutedLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: _cardTaupe,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: _buildFormBody(showCardHeading: true),
                    ),
                    const SizedBox(height: 16),
                    _buildCustomerMenuBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 18),
          child: Text(
            'MAWAR CAKE HOUSE . MANAGEMENT PORTAL',
            style: TextStyle(
              color: Color(0xFF8E7B73),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormBody({required bool showCardHeading}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showCardHeading) ...[
            const Text(
              'Staff and owner sign in',
              style: TextStyle(
                color: kCream,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Secure access for the shop team.',
              style: TextStyle(color: _mutedLight, fontSize: 13),
            ),
            const SizedBox(height: 24),
          ],
          const Text(
            'Username',
            style: TextStyle(
              color: kCream,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _usernameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: kOnPink, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputCream,
              hintText: 'Staff / Admin',
              hintStyle: const TextStyle(color: Color(0xFF7A6E6A)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Password',
            style: TextStyle(
              color: kCream,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleSignIn(),
            style: const TextStyle(color: kOnPink, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: _inputCream,
              hintText: 'Enter your password',
              hintStyle: const TextStyle(color: Color(0xFF7A6E6A)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _cardTaupe,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: kPink,
                      checkColor: Colors.white,
                      side: const BorderSide(color: kCream, width: 1.5),
                      onChanged: (val) {
                        setState(() => _rememberMe = val ?? false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: const Text(
                      'Remember me',
                      style: TextStyle(color: kCream, fontSize: 13),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: kCream,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A1C1C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: kCream, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isSubmitting ? null : _handleSignIn,
            style: FilledButton.styleFrom(
              backgroundColor: kPink,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Authorized Staff and owners only',
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMenuBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _customerBoxDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _customerBoxBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Customers do not log in.',
            style: TextStyle(
              color: kCream,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: _handleViewShopMenu,
            style: FilledButton.styleFrom(
              backgroundColor: _inputCream,
              foregroundColor: kOnPink,
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View shop menu',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
