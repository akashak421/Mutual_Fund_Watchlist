import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../utils/snackbar_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isValidNumber = false;
  final _supabase = Supabase.instance.client;
  String _completePhoneNumber = '';
  String? _errorMessage;
  String _phoneLength = '';
  int _maxLength = 10; // Default for India

  String _formatPhoneNumber(String number) {
    return _completePhoneNumber;
  }

  Future<void> _signIn() async {
    if (!_isValidNumber) {
      SnackBarUtils.showCustomSnackBar(
        context: context,
        message: 'Please enter a valid phone number',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text);
      
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
      );

      if (mounted) {
        Navigator.pushNamed(
          context,
          '/otp',
          arguments: {'phoneNumber': formattedPhone},
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred';
        
        if (e.statusCode == 400 && e.message.contains('phone_provider_disabled')) {
          errorMessage = 'Phone authentication is not enabled. Please contact support.';
        } else {
          errorMessage = e.message;
        }
        
        SnackBarUtils.showCustomSnackBar(
          context: context,
          message: errorMessage,
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showCustomSnackBar(
          context: context,
          message: 'Unexpected error occurred. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome Back,\nWe Missed You! 🎉',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  text: 'Glad to have you back at ',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Dhan Saarthi',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _errorMessage != null ? Colors.red[400]! : Colors.grey[800]!,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: IntlPhoneField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    dropdownTextStyle: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Phone number',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      fillColor: Colors.transparent,
                      filled: true,
                      errorStyle: const TextStyle(height: 0),
                    ),
                    initialCountryCode: 'IN',
                    dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 16),
                    showDropdownIcon: false,
                    disableLengthCheck: true,
                    onCountryChanged: (country) {
                      setState(() {
                        _phoneController.clear();
                        _isValidNumber = false;
                        _errorMessage = null;
                        _phoneLength = '';
                        // Update maxLength based on country
                        _maxLength = country.maxLength;
                      });
                    },
                    onChanged: (PhoneNumber phone) {
                      setState(() {
                        // Manual validation based on length
                        _isValidNumber = phone.number.length == _maxLength;
                        if (_isValidNumber) {
                          _completePhoneNumber = phone.completeNumber;
                          _errorMessage = null;
                          _phoneLength = ''; // Hide length indicator when valid
                        } else {
                          _errorMessage = phone.number.isEmpty ? null : 'Please enter a valid number';
                          // Show length indicator only when number is incomplete
                          if (phone.number.isNotEmpty) {
                            _phoneLength = '${phone.number.length}/$_maxLength';
                          } else {
                            _phoneLength = '';
                          }
                        }
                      });
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_errorMessage != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red[400],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox.shrink(),
                    if (_phoneLength.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.grey[800]!, // Always grey since it's only shown when invalid
                          ),
                        ),
                        child: Text(
                          _phoneLength,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isValidNumber && !_isLoading) ? _signIn : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValidNumber ? Colors.blue : Colors.grey[800],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Proceed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const Spacer(),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'By signing in, you agree to our ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    children: const [
                      TextSpan(
                        text: 'T&C',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
} 