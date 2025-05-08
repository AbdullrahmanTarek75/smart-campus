import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/theme/app_theme.dart';
import 'package:get/get.dart';
import '../../core/utils/app_constants.dart';

class MfaVerificationScreen extends StatefulWidget {
  final String email;
  
  const MfaVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<MfaVerificationScreen> createState() => _MfaVerificationScreenState();
}

class _MfaVerificationScreenState extends State<MfaVerificationScreen> {
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verifyAndProceed();
    });
  }
  
  // Automatic verification
  Future<void> _verifyAndProceed() async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      // This is a simplified implementation that always returns true
      final bool isVerified = await authController.isMfaVerified();
      
      if (mounted) {
        if (isVerified) {
          // Navigate to home after a short delay to show the animation
          Future.delayed(const Duration(seconds: 2), () {
            Get.offAllNamed(AppConstants.homeRoute);
          });
        } else {
          setState(() {
            _isLoading = false;
            _error = "Verification failed. Please try again.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [AppTheme.darkNavy, const Color(0xFF1A2B45)]
                : [Colors.white, Colors.grey[100]!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.electricBlue.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: 60,
                        color: AppTheme.electricBlue,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // MFA Text
                  Text(
                    "Authentication",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    "Verifying your identity...",
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading indicator or error
                  if (_isLoading)
                    Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.electricBlue),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Please wait while we verify your account...",
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else if (_error != null)
                    Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _error = null;
                            });
                            _verifyAndProceed();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.electricBlue,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text("Try Again"),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 