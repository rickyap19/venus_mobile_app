import 'package:flutter/material.dart';
import 'package:pis_management_system/service/family_service.dart';
import 'package:pis_management_system/widgets/form_components.dart';
import 'dart:io';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _familyMembers = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _editingId;

  // Relationship Options
  final List<String> _relationships = [
    'Parent',
    'Spouse',
    'Sibling',
    'Child',
    'Other',
  ];

  // Gender Options
  final List<String> _genders = ['Male', 'Female'];

  // Form Fields
  String? _selectedRelationship;
  final _fullNameController = TextEditingController();
  String? _selectedGender;
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _ktpNumberController = TextEditingController();
  final _kkNumberController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final familyData = await FamilyService.getFamilyMembers();

      if (!mounted) return;
      setState(() => _familyMembers = familyData);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load data: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _selectedRelationship = null;
    _fullNameController.clear();
    _selectedGender = null;
    _dobController.clear();
    _mobileController.clear();
    _emailController.clear();
    _ktpNumberController.clear();
    _kkNumberController.clear();
    _addressController.clear();
    if (mounted) {
      setState(() {
        _isEditMode = false;
        _editingId = null;
      });
    }
  }

  void _editFamilyMember(Map<String, dynamic> member) {
    setState(() {
      _isEditMode = true;
      _editingId = member['id'];
      _selectedRelationship = member['relationship'];
      _fullNameController.text = member['fullName'] ?? '';
      _selectedGender = member['gender'];

      if (member['dateOfBirth'] != null) {
        try {
          final date = DateTime.parse(member['dateOfBirth']);
          _dobController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        } catch (e) {
          _dobController.text = '';
        }
      }

      _mobileController.text = member['mobilePhoneNumber'] ?? '';
      _emailController.text = member['email'] ?? '';
      _ktpNumberController.text = member['idCardNumber'] ?? '';
      _kkNumberController.text = member['familyRegisterNumber'] ?? '';
      _addressController.text = member['address'] ?? '';
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        _formKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _cancelEdit() {
    _clearForm();
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        "relationship": _selectedRelationship ?? '',
        "fullName": _fullNameController.text,
        "gender": _selectedGender ?? '',
        "dateOfBirth": _dobController.text.isEmpty
            ? DateTime.now().toIso8601String()
            : "${_dobController.text}T00:00:00.000Z",
        "mobilePhoneNumber": _mobileController.text,
        "email": _emailController.text,
        "idCardNumber": _ktpNumberController.text,
        "familyRegisterNumber": _kkNumberController.text,
        "address": _addressController.text,
      };

      if (_isEditMode && _editingId != null) {
        await FamilyService.updateFamilyMember(_editingId!, data);
        _showSuccess('Family member updated successfully');
      } else {
        await FamilyService.createFamilyMember(data);
        _showSuccess('Family member added successfully');
      }

      await _loadData();
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save family member: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _deleteFamilyMember(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: const Text('Are you sure you want to delete this family member?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await FamilyService.deleteFamilyMember(member['id']);
                _showSuccess('Family member deleted successfully');
                await _loadData();
              } catch (e) {
                _showError('Failed to delete family member: $e');
              } finally {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showSuccess(String message) {
    if (!mounted) return;
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
    if (!mounted) return;
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
    if (_isLoading && _familyMembers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFamilyForm(),
                const SizedBox(height: 32),
                _buildFamilyTable(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildFamilyForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditMode ? 'Edit Family Member' : 'Add New Family Member',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Relationship *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedRelationship,
                        label: 'Relationship',
                        hint: 'Relationship',
                        items: _relationships,
                        onChanged: (value) => setState(() => _selectedRelationship = value),
                        required: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Full Name (Same As ID Card) *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _fullNameController,
                        label: 'Full Name (Same As ID Card)',
                        hint: 'Full Name (Same As ID Card)',
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Gender *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedGender,
                        label: 'Gender',
                        hint: 'Gender',
                        items: _genders,
                        onChanged: (value) => setState(() => _selectedGender = value),
                        required: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Date Of Birth *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDateField(
                        context: context,
                        controller: _dobController,
                        label: 'Date Of Birth',
                        hint: 'Date Of Birth',
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Mobile No. (Without Leading Zero) *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _mobileController,
                        label: 'Mobile No.',
                        hint: 'Mobile No.',
                        keyboardType: TextInputType.phone,
                        required: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Email *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('KTP Number *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _ktpNumberController,
                        label: 'KTP Number',
                        hint: 'KTP Number',
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Family Register (KK) Number *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _kkNumberController,
                        label: 'Family Register (KK) Number',
                        hint: 'Family Register (KK) Number',
                        keyboardType: TextInputType.number,
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('Address *'),
            const SizedBox(height: 8),
            FormComponents.buildTextField(
              controller: _addressController,
              label: 'Address',
              hint: 'Address',
              maxLines: 3,
              required: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isEditMode) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _cancelEdit,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                _isEditMode ? 'Update Entry' : 'Add Entry',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTable() {
    if (_familyMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No family members yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first family member using the form above',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.list_alt, size: 20, color: Color(0xFF1E88E5)),
                const SizedBox(width: 8),
                const Text(
                  'Family Member List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_familyMembers.length} member(s)',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              headingRowHeight: 56,
              dataRowHeight: 56,
              headingRowColor: MaterialStateProperty.all(const Color(0xFF1E88E5).withOpacity(0.1)),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A237E),
              ),
              dataTextStyle: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
              columns: const [
                DataColumn(label: Text('No.')),
                DataColumn(label: Text('Relationship')),
                DataColumn(label: Text('Full Name (Same As ID Card)')),
                DataColumn(label: Text('Gender')),
                DataColumn(label: Text('Date Of Birth')),
                DataColumn(label: Text('Mobile No.')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('KTP Number')),
                DataColumn(label: Text('Family Register (KK) Number')),
                DataColumn(label: Text('Address')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _familyMembers.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> member = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(member['relationship'] ?? '-')),
                    DataCell(Text(member['fullName'] ?? '-')),
                    DataCell(Text(member['gender'] ?? '-')),
                    DataCell(Text(_formatDate(member['dateOfBirth']))),
                    DataCell(Text(member['mobilePhoneNumber'] ?? '-')),
                    DataCell(Text(member['email'] ?? '-')),
                    DataCell(Text(member['idCardNumber'] ?? '-')),
                    DataCell(Text(member['familyRegisterNumber'] ?? '-')),
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          member['address'] ?? '-',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF1E88E5)),
                            onPressed: () => _editFamilyMember(member),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                            onPressed: () => _deleteFamilyMember(member),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _ktpNumberController.dispose();
    _kkNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}