import 'package:flutter/material.dart';
import 'package:pis_management_system/screens/venus/form/bank_form.dart';
import 'package:pis_management_system/screens/venus/form/certificate_qualification_form.dart';
import 'package:pis_management_system/screens/venus/form/documents_form.dart';
import 'package:pis_management_system/screens/venus/form/family_form.dart';
import 'package:pis_management_system/screens/venus/form/formal_education_form.dart';
import 'package:pis_management_system/screens/venus/form/medical_test_form.dart';
import 'package:pis_management_system/screens/venus/form/personal_data_form.dart';


class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // Reference to PersonalDataFormScreen state
  final GlobalKey<PersonalDataFormScreenState> _personalDataFormKey = GlobalKey<PersonalDataFormScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveAsDraft() async {
    if (_currentTabIndex == 0) {
      try {
        await _personalDataFormKey.currentState?.saveAllData();
      } catch (e) {
        // Error already handled in PersonalDataFormScreen
      }
    }
  }

  Future<void> _saveAndNext() async {
    if (_currentTabIndex == 0) {
      if (!_formKey.currentState!.validate()) return;

      try {
        await _personalDataFormKey.currentState?.saveAllData();
        _tabController.animateTo(1);
      } catch (e) {
        // Error already handled in PersonalDataFormScreen
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PersonalDataFormScreen(
                  key: _personalDataFormKey,
                  formKey: _formKey,
                  onSavingChanged: (saving) => setState(() => _isSaving = saving),
                  onError: _showError,
                  onSuccess: _showSuccess,
                ),
                const DocumentsScreen(),
                const BankAccountScreen(),
                const FamilyScreen(),
                const FormalEducationScreen(),
               const MedicalTestScreen(),
                const CertificateQualificationScreen(),
                _buildComingSoon('OLP Certificates'),
                _buildComingSoon('Sea Experience'),
                _buildComingSoon('Appraisals'),
                _buildComingSoon('Medical History'),
              ],
            ),
          ),
          if (_currentTabIndex == 0) _buildBottomActionButtons(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Personal Data Management',
        style: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey[200],
          height: 1,
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: const Color(0xFF1E88E5),
        unselectedLabelColor: Colors.grey[600],
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        indicatorColor: const Color(0xFF1E88E5),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'PERSONAL DATA'),
          Tab(text: 'DOCUMENTS'),
          Tab(text: 'BANK ACCOUNT'),
          Tab(text: 'FAMILY'),
          Tab(text: 'FORMAL EDUCATION'),
          Tab(text: 'MEDICAL CERTIFICATE / TEST'),
          Tab(text: 'CERTIFICATES AND QUALIFICATIONS'),
          // Tab(text: 'OLP CERTIFICATES'),
          Tab(text: 'SEA EXPERIENCE'),
          Tab(text: 'APPRAISALS'),
          Tab(text: 'MEDICAL HISTORY'),
          Tab(text: 'GENERAL'),
        ],
      ),
    );
  }

  Widget _buildComingSoon(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('Coming Soon', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : _saveAsDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E88E5),
                side: const BorderSide(color: Color(0xFF1E88E5), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save as Draft', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAndNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : const Text('Save and Next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}