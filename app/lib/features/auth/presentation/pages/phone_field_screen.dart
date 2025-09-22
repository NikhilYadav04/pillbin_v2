import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';

class EmailAuthScreen extends StatefulWidget {
  final bool isLogin;

  const EmailAuthScreen({Key? key, required this.isLogin}) : super(key: key);

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? sw * 0.1 : sw * 0.06),
                    child: Column(
                      children: [
                        SizedBox(height: sh * 0.08),
                        _buildLogo(sw, sh, isTablet),
                        SizedBox(height: sh * 0.06),
                        _buildWelcomeSection(sw, sh, isTablet),
                        SizedBox(height: sh * 0.08),
                        _buildEmailInputSection(sw, sh, isTablet),
                        SizedBox(height: sh * 0.04),
                        _buildActionButton(sw, sh, isTablet),
                        Expanded(child: Container()),
                        _buildFooter(sw, sh, isTablet),
                        SizedBox(height: sh * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(double sw, double sh, bool isTablet) {
    return Container(
      width: isTablet ? sw * 0.25 : sw * 0.35,
      height: isTablet ? sw * 0.25 : sw * 0.35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.06 : sw * 0.08),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? sw * 0.06 : sw * 0.08),
        child: Image.asset(
          'assets/images/logo.jpg', // Your logo image path
          fit: BoxFit.cover, // Covers the entire container
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        Text(
          widget.isLogin ? 'Welcome Back!' : 'Get Started',
          style: PillBinBold.style(
            fontSize: isTablet ? sw * 0.04 : sw * 0.07,
            color: PillBinColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: sh * 0.02),
        Text(
          widget.isLogin
              ? 'Sign in to continue managing your medicines safely'
              : 'Create your account to start tracking medicines and join disposal campaigns',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailInputSection(double sw, double sh, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: PillBinMedium.style(
            fontSize: isTablet ? sw * 0.025 : sw * 0.04,
            color: PillBinColors.textPrimary,
          ),
        ),
        SizedBox(height: sh * 0.015),
        Container(
          decoration: BoxDecoration(
            color: PillBinColors.surface,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(color: PillBinColors.greyLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Email icon
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                  vertical: isTablet ? sh * 0.02 : sh * 0.015,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: PillBinColors.greyLight),
                  ),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: PillBinColors.textSecondary,
                  size: isTablet ? sw * 0.025 : sw * 0.05,
                ),
              ),
              // Email input
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.022 : sw * 0.035,
                      color: PillBinColors.textLight,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isTablet ? sw * 0.025 : sw * 0.04,
                      vertical: isTablet ? sh * 0.02 : sh * 0.015,
                    ),
                  ),
                  style: PillBinRegular.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                    color: PillBinColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sh * 0.015),
        Text(
          'We\'ll send you a verification code via email',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.02 : sw * 0.03,
            color: PillBinColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(double sw, double sh, bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            PillBinColors.primary,
            PillBinColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: PillBinColors.primary.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          onTap: _isLoading
              ? null
              : () {
                  _handleAuth(_emailController.text.toString(), widget.isLogin);
                },
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: isTablet ? sh * 0.02 : sh * 0.018,
              horizontal: isTablet ? sw * 0.03 : sw * 0.05,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: isTablet ? sw * 0.025 : sw * 0.04,
                    height: isTablet ? sw * 0.025 : sw * 0.04,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    widget.isLogin ? Icons.login : Icons.person_add,
                    color: Colors.white,
                    size: isTablet ? sw * 0.025 : sw * 0.05,
                  ),
                SizedBox(width: sw * 0.03),
                Text(
                  _isLoading
                      ? 'Please wait...'
                      : widget.isLogin
                          ? 'Sign In'
                          : 'Create Account',
                  style: PillBinMedium.style(
                    fontSize: isTablet ? sw * 0.025 : sw * 0.045,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(double sw, double sh, bool isTablet) {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our Terms of Service\nand Privacy Policy',
          style: PillBinRegular.style(
            fontSize: isTablet ? sw * 0.018 : sw * 0.028,
            color: PillBinColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleAuth(String email, bool login) {
    Navigator.pushNamed(
      context,
      '/otp-field-screen',
      arguments: {
        'email': email, // Changed from 'phone' to 'email'
        'login': login,
        'transition': TransitionType.rightToLeft,
        'duration': 300,
      },
    );
  }
}
