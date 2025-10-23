import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:pis_management_system/service/auth_service.dart';

// Custom HTTP Client that allows self-signed certificates
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// API Configuration - GANTI DENGAN IP KOMPUTER ANDA
class ApiConfig {
  // PENTING: Ganti dengan HTTPS dan IP/hostname yang sesuai
  // Untuk Android Emulator gunakan 10.0.2.2
  // Untuk Physical Device gunakan IP komputer (contoh: 192.168.1.100)
  // Untuk iOS Simulator gunakan localhost
  static const String baseUrl = 'https://10.0.2.2:50314/api';

  static String get manningAgentsUrl => '$baseUrl/Auth/manning-agents';
  static String get ranksUrl => '$baseUrl/Rank';
  static String get loginUrl => '$baseUrl/Auth/login';
  static String get registerUrl => '$baseUrl/Auth/register';
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // State untuk toggle antara login dan register
  bool _isLoginMode = true;

  // Controllers untuk register
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _seafarerIdController = TextEditingController();
  final _registerCaptchaController = TextEditingController();

  // Dropdown values
  int? _selectedManningAgent;
  int? _selectedRank;

  // Data dari API
  List<dynamic> _manningAgents = [];
  List<dynamic> _ranks = [];
  bool _isLoadingManningAgents = true;
  bool _isLoadingRanks = true;

  // CAPTCHA
  String _generatedCaptcha = '';
  String _registerGeneratedCaptcha = '';

  // File upload
  File? _bstAttachment;
  String? _bstAttachmentName;

  @override
  void initState() {
    super.initState();

    // Allow self-signed certificates for development
    HttpOverrides.global = MyHttpOverrides();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _generateCaptcha();
    _generateRegisterCaptcha();
    _fetchManningAgents();
    _fetchRanks();
  }

  void _generateCaptcha() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    _generatedCaptcha = String.fromCharCodes(
        Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
    setState(() {});
  }

  void _generateRegisterCaptcha() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    _registerGeneratedCaptcha = String.fromCharCodes(
        Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
    setState(() {});
  }

  Future<void> _fetchManningAgents() async {
    setState(() => _isLoadingManningAgents = true);

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        print('Attempt ${retryCount + 1}/$maxRetries - Fetching Manning Agents from: ${ApiConfig.manningAgentsUrl}');

        final response = await http.get(
          Uri.parse(ApiConfig.manningAgentsUrl),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Connection timeout - Backend may not be running');
          },
        );

        print('Manning Agents Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            setState(() {
              _manningAgents = jsonResponse['data'];
              _isLoadingManningAgents = false;
            });
            print('✅ Manning Agents loaded: ${_manningAgents.length}');
            return; // Success, exit retry loop
          } else {
            setState(() => _isLoadingManningAgents = false);
            print('❌ Invalid response structure');
            return;
          }
        } else {
          setState(() => _isLoadingManningAgents = false);
          print('❌ Failed to load manning agents: ${response.statusCode}');
          return;
        }
      } catch (e) {
        retryCount++;
        print('❌ Error (attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          setState(() => _isLoadingManningAgents = false);
          if (mounted) {
            _showErrorDialog(
                'Cannot connect to server.\n\n'
                    'Please check:\n'
                    '✓ Backend is running on port 50314\n'
                    '✓ Using correct IP: 10.0.2.2 for emulator\n'
                    '✓ Network connection is active\n\n'
                    'Error: $e'
            );
          }
          return;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  Future<void> _fetchRanks() async {
    setState(() => _isLoadingRanks = true);

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        print('Attempt ${retryCount + 1}/$maxRetries - Fetching Ranks from: ${ApiConfig.ranksUrl}');

        final response = await http.get(
          Uri.parse(ApiConfig.ranksUrl),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Connection timeout - Backend may not be running');
          },
        );

        print('Ranks Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
            setState(() {
              _ranks = jsonResponse['data'];
              _isLoadingRanks = false;
            });
            print('✅ Ranks loaded: ${_ranks.length}');
            return; // Success, exit retry loop
          } else {
            setState(() => _isLoadingRanks = false);
            print('❌ Invalid response structure');
            return;
          }
        } else {
          setState(() => _isLoadingRanks = false);
          print('❌ Failed to load ranks: ${response.statusCode}');
          return;
        }
      } catch (e) {
        retryCount++;
        print('❌ Error (attempt $retryCount/$maxRetries): $e');

        if (retryCount >= maxRetries) {
          setState(() => _isLoadingRanks = false);
          // Don't show dialog twice, already shown in manning agents
          return;
        }

        // Wait before retry
        await Future.delayed(Duration(seconds: retryCount));
      }
    }
  }

  Future<void> _handleLogin() async {
    // Validasi CAPTCHA
    if (_captchaController.text.toLowerCase() != _generatedCaptcha.toLowerCase()) {
      _showErrorDialog('Invalid CAPTCHA. Please try again.');
      _generateCaptcha();
      _captchaController.clear();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // Simpan data login
          await AuthService.saveLoginData(
            token: data['token'] ?? '',
            email: data['email'] ?? '',
            fullName: data['fullName'] ?? '',
            role: data['role'] ?? '',
            expiresAt: data['expiresAt'] ?? '',
          );

          print('✅ Login successful - Role: ${data['role']}');

          // Navigate ke portal
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/portal');
          }
        } else {
          _showErrorDialog(jsonResponse['message'] ?? 'Login failed');
          _generateCaptcha();
          _captchaController.clear();
        }
      } else {
        final error = json.decode(response.body);
        _showErrorDialog(error['message'] ?? 'Login failed');
        _generateCaptcha();
        _captchaController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: $e');
      _generateCaptcha();
      _captchaController.clear();
    }
  }

  Future<void> _handleRegister() async {
    // Validasi
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Passwords do not match');
      return;
    }

    // Validasi CAPTCHA
    if (_registerCaptchaController.text.toLowerCase() != _registerGeneratedCaptcha.toLowerCase()) {
      _showErrorDialog('Invalid CAPTCHA. Please try again.');
      _generateRegisterCaptcha();
      _registerCaptchaController.clear();
      return;
    }

    if (_selectedManningAgent == null || _selectedRank == null) {
      _showErrorDialog('Please select Manning Agent and Rank');
      return;
    }

    if (_bstAttachment == null) {
      _showErrorDialog('Please upload BST Attachment');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var dio = Dio();
      var formData = FormData.fromMap({
        'email': _emailController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'fullName': _fullNameController.text,
        'seafarerId': _seafarerIdController.text,
        'manningAgentId': _selectedManningAgent!,
        'rankAppliedId': _selectedRank!,
        'bstAttachment': await MultipartFile.fromFile(
          _bstAttachment!.path,
          filename: _bstAttachmentName,
        ),
      });

      var response = await dio.post(
        ApiConfig.registerUrl,
        data: formData,
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog('Registration successful! Please login.');
        setState(() {
          _isLoginMode = true;
        });
        _clearRegisterFields();
      } else {
        _showErrorDialog(response.data['message'] ?? 'Registration failed');
        _generateRegisterCaptcha();
        _registerCaptchaController.clear();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error: $e');
      _generateRegisterCaptcha();
      _registerCaptchaController.clear();
    }
  }

  void _clearRegisterFields() {
    _confirmPasswordController.clear();
    _fullNameController.clear();
    _seafarerIdController.clear();
    _registerCaptchaController.clear();
    _selectedManningAgent = null;
    _selectedRank = null;
    _bstAttachment = null;
    _bstAttachmentName = null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Error Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK, Got It',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Success Icon with Checkmark
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),

              // Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button with gradient
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _seafarerIdController.dispose();
    _registerCaptchaController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1976D2),
              Color(0xFF1565C0),
              Color(0xFF0D47A1),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Card(
                  elevation: 16,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey[50]!,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 32),
                          _buildTitle(),
                          const SizedBox(height: 24),
                          if (_isLoginMode) ..._buildLoginForm() else ..._buildRegisterForm(),
                          const SizedBox(height: 16),
                          _buildToggleButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Image.asset(
        'assets/images/pertamina_logo.png',
        height: 120,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            children: const [
              Icon(
                Icons.directions_boat_rounded,
                size: 80,
                color: Color(0xFF1976D2),
              ),
              SizedBox(height: 16),
              Text(
                'PERTAMINA',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'INTERNATIONAL SHIPPING',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1976D2),
                Color(0xFF1565C0),
                Color(0xFF0D47A1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1976D2).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 1,
              ),
            ],
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Color(0xFFE3F2FD)],
            ).createShader(bounds),
            child: const Text(
              'VENUS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Crew Management System',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1565C0),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _isLoginMode ? 'Sign in to start your session' : 'Create your account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      _buildIdamanSSOButton(),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[400])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[400])),
        ],
      ),
      const SizedBox(height: 24),
      _buildTextField(
        controller: _emailController,
        label: 'Email',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _passwordController,
        label: 'Password',
        icon: Icons.lock_outlined,
        isPassword: true,
      ),
      const SizedBox(height: 20),
      _buildCaptchaSection(_generatedCaptcha, _captchaController, _generateCaptcha),
      const SizedBox(height: 24),
      _buildLoginButton(),
    ];
  }

  List<Widget> _buildRegisterForm() {
    return [
      _buildTextField(
        controller: _emailController,
        label: 'Email',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _passwordController,
        label: 'Password',
        icon: Icons.lock_outlined,
        isPassword: true,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _confirmPasswordController,
        label: 'Confirm Password',
        icon: Icons.lock_outlined,
        isPassword: true,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _fullNameController,
        label: 'Full Name',
        icon: Icons.person_outlined,
      ),
      const SizedBox(height: 16),
      _buildTextField(
        controller: _seafarerIdController,
        label: 'Seafarer ID',
        icon: Icons.badge_outlined,
      ),
      const SizedBox(height: 16),
      _buildDropdown(
        value: _selectedManningAgent,
        items: _manningAgents,
        label: 'Manning Agent',
        onChanged: (value) => setState(() => _selectedManningAgent = value),
        isLoading: _isLoadingManningAgents,
      ),
      const SizedBox(height: 16),
      _buildDropdown(
        value: _selectedRank,
        items: _ranks,
        label: 'Rank Applied For',
        onChanged: (value) => setState(() => _selectedRank = value),
        isLoading: _isLoadingRanks,
      ),
      const SizedBox(height: 16),
      _buildFileUpload(),
      const SizedBox(height: 20),
      _buildCaptchaSection(_registerGeneratedCaptcha, _registerCaptchaController, _generateRegisterCaptcha),
      const SizedBox(height: 24),
      _buildRegisterButton(),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required int? value,  // UBAH: dari String? ke int?
    required List<dynamic> items,
    required String label,
    required Function(int?) onChanged,  // UBAH: dari String? ke int?
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(  // UBAH: dari <String> ke <int>
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: isLoading
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : null,
          ),
          items: items.isEmpty
              ? null
              : items.map((item) {
            return DropdownMenuItem<int>(  // UBAH: dari <String> ke <int>
              value: item['id'] as int,  // UBAH: langsung cast ke int, hapus .toString()
              child: Text(
                item['name'] ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: items.isEmpty ? null : onChanged,
          hint: Text(
            items.isEmpty && !isLoading
                ? 'No data available'
                : isLoading
                ? 'Loading...'
                : 'Select $label',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptchaSection(String captcha, TextEditingController controller, VoidCallback regenerate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                captcha,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: regenerate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter Validation Code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Login',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Register',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              _isLoginMode = !_isLoginMode;
              _emailController.clear();
              _passwordController.clear();
              _captchaController.clear();
              if (!_isLoginMode) {
                _clearRegisterFields();
              }
            });
          },
          child: Text(
            _isLoginMode ? "Don't have an account? Register" : 'Already have an account? Login',
            style: const TextStyle(
              color: Color(0xFF1976D2),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _testConnection,
          icon: const Icon(Icons.network_check, size: 16),
          label: const Text('Test Connection'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[700],
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _testConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Testing connection...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.manningAgentsUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        _showSuccessDialog(
            '✅ Connection Successful!\n\n'
                'Status: ${response.statusCode}\n'
                'URL: ${ApiConfig.manningAgentsUrl}\n\n'
                'Backend is running properly.'
        );
      } else {
        _showErrorDialog(
            '⚠️ Backend responded but with error\n\n'
                'Status Code: ${response.statusCode}\n'
                'URL: ${ApiConfig.manningAgentsUrl}'
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      _showErrorDialog(
          '❌ Connection Failed\n\n'
              'URL: ${ApiConfig.manningAgentsUrl}\n\n'
              'Error: $e\n\n'
              'Troubleshooting:\n'
              '1. Check if backend is running\n'
              '2. Verify port number (50314)\n'
              '3. For emulator use: 10.0.2.2\n'
              '4. For physical device use your PC IP'
      );
    }
  }

  Widget _buildIdamanSSOButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1976D2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Handle Idaman SSO login
          Navigator.pushReplacementNamed(context, '/portal');
        },
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified_user_rounded,
            size: 24,
            color: Color(0xFF1976D2),
          ),
        ),
        label: const Text(
          'Login with Idaman SSO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFileUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'BST Attachment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '(.jpg/.jpeg/.png/.pdf max 2 MB)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400]!,
                style: BorderStyle.solid,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Column(
              children: [
                Icon(
                  _bstAttachment == null ? Icons.cloud_upload_outlined : Icons.check_circle_outline,
                  size: 48,
                  color: _bstAttachment == null ? Colors.grey[400] : const Color(0xFF1976D2),
                ),
                const SizedBox(height: 12),
                Text(
                  _bstAttachment == null
                      ? 'Drop file here or click to upload'
                      : _bstAttachmentName ?? 'File selected',
                  style: TextStyle(
                    color: _bstAttachment == null ? Colors.grey[600] : const Color(0xFF1976D2),
                    fontSize: 14,
                    fontWeight: _bstAttachment == null ? FontWeight.normal : FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFile() async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Choose Document (PDF)'),
                  onTap: () {
                    Navigator.pop(context);
                    _showErrorDialog('For PDF, please use gallery and select PDF file');
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      _showErrorDialog('Error opening file picker: $e');
    }
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        File file = File(image.path);
        int fileSize = await file.length();

        // Check file size (max 2 MB = 2 * 1024 * 1024 bytes)
        if (fileSize > 2 * 1024 * 1024) {
          _showErrorDialog('File size must be less than 2 MB');
          return;
        }

        setState(() {
          _bstAttachment = file;
          _bstAttachmentName = image.name;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking file: $e');
    }
  }
}