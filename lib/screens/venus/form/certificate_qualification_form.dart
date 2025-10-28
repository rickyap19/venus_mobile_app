import 'package:flutter/material.dart';
import 'package:pis_management_system/service/certificate_qualification_service.dart';
import 'package:pis_management_system/service/personal_data_service.dart';
import 'package:pis_management_system/widgets/form_components.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CertificateQualificationScreen extends StatefulWidget {
  const CertificateQualificationScreen({Key? key}) : super(key: key);

  @override
  State<CertificateQualificationScreen> createState() => _CertificateQualificationScreenState();
}

class _CertificateQualificationScreenState extends State<CertificateQualificationScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _certificates = [];
  List<Map<String, dynamic>> _certificateNames = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _editingId;

  // Vsl Type Options
  final List<String> _vslTypes = [
    'Pax',
    'RoRoPax',
    'No.',
  ];

  // Level Options
  final List<String> _levels = [
    '1: Incharge',
    '2: Asst.',
    'Date Of Issue',
  ];

  // Form Controllers
  String? _selectedCertificateName;
  String? _selectedVslType;
  String? _selectedLevel;
  String? _selectedCountryOfIssue;
  final _numberController = TextEditingController();
  final _dateOfIssueController = TextEditingController();
  final _dateOfExpiryController = TextEditingController();
  final _placeOfIssueController = TextEditingController();
  final _issuingAuthorityhController = TextEditingController();
  File? _attachmentFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final countries = await PersonalDataService.getCountries();
      final certificateNamesData = await CertificateQualificationService.getCertificateNames();

      if (!mounted) return;
      setState(() {
        _countries = countries;
        _certificateNames = certificateNamesData;
      });

      // Load existing certificates
      final certificatesData = await CertificateQualificationService.getCertificates();

      if (!mounted) return;
      setState(() => _certificates = certificatesData);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load data: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAttachment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _attachmentFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')} ${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _clearForm() {
    _selectedCertificateName = null;
    _selectedVslType = null;
    _selectedLevel = null;
    _selectedCountryOfIssue = null;
    _numberController.clear();
    _dateOfIssueController.clear();
    _dateOfExpiryController.clear();
    _placeOfIssueController.clear();
    _issuingAuthorityhController.clear();
    if (mounted) {
      setState(() {
        _attachmentFile = null;
        _isEditMode = false;
        _editingId = null;
      });
    }
  }

  void _editCertificate(Map<String, dynamic> cert) {
    setState(() {
      _isEditMode = true;
      _editingId = cert['id'];
      _selectedCertificateName = cert['name'];
      _selectedVslType = cert['vslType'];
      _selectedLevel = cert['level'];
      _selectedCountryOfIssue = cert['countryOfIssue'];
      _numberController.text = cert['number'] ?? '';
      _dateOfIssueController.text = cert['dateOfIssue'] ?? '';
      _dateOfExpiryController.text = cert['dateOfExpiry'] ?? '';
      _placeOfIssueController.text = cert['placeOfIssue'] ?? '';
      _issuingAuthorityhController.text = cert['issuingAuthorithy'] ?? '';
    });

    // Scroll to top to show form
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

    if (_selectedCertificateName == null) {
      _showError('Please select a certificate name');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        "name": _selectedCertificateName,
        "vslType": _selectedVslType ?? '',
        "level": _selectedLevel ?? '',
        "countryOfIssue": _selectedCountryOfIssue ?? '',
        "number": _numberController.text,
        "dateOfIssue": _dateOfIssueController.text,
        "dateOfExpiry": _dateOfExpiryController.text,
        "placeOfIssue": _placeOfIssueController.text,
        "issuingAuthorithy": _issuingAuthorityhController.text,
        "photo": _attachmentFile?.path ?? "",
      };

      if (_isEditMode && _editingId != null) {
        await CertificateQualificationService.updateCertificate(_editingId!, data);
        _showSuccess('Certificate updated successfully');
      } else {
        await CertificateQualificationService.createCertificate(data);
        _showSuccess('Certificate added successfully');
      }

      await _loadData();
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save certificate: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _deleteCertificate(Map<String, dynamic> cert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: const Text('Are you sure you want to delete this certificate?'),
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
                await CertificateQualificationService.deleteCertificate(cert['id']);
                _showSuccess('Certificate deleted successfully');
                await _loadData();
              } catch (e) {
                _showError('Failed to delete certificate: $e');
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
    if (_isLoading && _certificates.isEmpty) {
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
                _buildCertificateForm(),
                const SizedBox(height: 32),
                _buildCertificateTable(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildCertificateForm() {
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
                  _isEditMode ? 'Edit Certificate' : 'Add New Certificate',
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
                      FormComponents.buildSectionTitle('Certificate Name *'),
                      const SizedBox(height: 8),
                      _buildCertificateNameDropdown(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Vsl Type'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedVslType,
                        label: 'Vsl Type',
                        hint: 'Vsl Type',
                        items: _vslTypes,
                        onChanged: (value) => setState(() => _selectedVslType = value),
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
                      FormComponents.buildSectionTitle('Level'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedLevel,
                        label: 'Level',
                        hint: 'Level',
                        items: _levels,
                        onChanged: (value) => setState(() => _selectedLevel = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Country Of Issue *'),
                      const SizedBox(height: 8),
                      FormComponents.buildCountryDropdownField(
                        value: _selectedCountryOfIssue,
                        label: 'Country Of Issue',
                        hint: 'Country Of Issue',
                        countries: _countries,
                        onChanged: (value) => setState(() => _selectedCountryOfIssue = value),
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
                      FormComponents.buildSectionTitle('No. *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _numberController,
                        label: 'No.',
                        hint: 'No.',
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
                      FormComponents.buildSectionTitle('Date Of Issue *'),
                      const SizedBox(height: 8),
                      _buildDateField(
                        controller: _dateOfIssueController,
                        label: 'Date Of Issue',
                        hint: 'Date Of Issue',
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
                      FormComponents.buildSectionTitle('Date Of Expiry *'),
                      const SizedBox(height: 8),
                      _buildDateField(
                        controller: _dateOfExpiryController,
                        label: 'Date Of Expiry',
                        hint: 'Date Of Expiry',
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
                      FormComponents.buildSectionTitle('Place Of Issue *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _placeOfIssueController,
                        label: 'Place Of Issue',
                        hint: 'Place Of Issue',
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('Issuing Authority / Body *'),
            const SizedBox(height: 8),
            FormComponents.buildTextField(
              controller: _issuingAuthorityhController,
              label: 'Issuing Authority / Body',
              hint: 'Issuing Authority / Body',
              required: true,
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('Attachment (jpg/jpeg/png/pdf max 2 MB) *'),
            const SizedBox(height: 8),
            FormComponents.buildDocumentUpload(
              'Drop file here or click to upload',
              _attachmentFile,
              _pickAttachment,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateNameDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCertificateName,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Certificate Name',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
      ),
      menuMaxHeight: 300,
      items: _certificateNames.map((cert) {
        return DropdownMenuItem<String>(
          value: cert['name'],
          child: Text(
            cert['name'],
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCertificateName = value),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a certificate name';
        }
        return null;
      },
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context, controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF1E88E5)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
        ),
      ),
      validator: required
          ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null
          : null,
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

  Widget _buildCertificateTable() {
    if (_certificates.isEmpty) {
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
              Icon(Icons.card_membership, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No certificates yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first certificate using the form above',
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
                  'Certificate List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_certificates.length} certificate(s)',
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
                DataColumn(label: Text('Certificate Name')),
                DataColumn(label: Text('Vsl Type')),
                DataColumn(label: Text('Level')),
                DataColumn(label: Text('Country Of Issue')),
                DataColumn(label: Text('No.')),
                DataColumn(label: Text('Date Of Issue')),
                DataColumn(label: Text('Date Of Expiry')),
                DataColumn(label: Text('Place Of Issue')),
                DataColumn(label: Text('Issuing Authority')),
                DataColumn(label: Text('Attachment')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _certificates.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> cert = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(cert['name'] ?? '-')),
                    DataCell(Text(cert['vslType'] ?? '-')),
                    DataCell(Text(cert['level'] ?? '-')),
                    DataCell(Text(cert['countryOfIssue'] ?? '-')),
                    DataCell(Text(cert['number'] ?? '-')),
                    DataCell(Text(cert['dateOfIssue'] ?? '-')),
                    DataCell(Text(cert['dateOfExpiry'] ?? '-')),
                    DataCell(Text(cert['placeOfIssue'] ?? '-')),
                    DataCell(Text(cert['issuingAuthorithy'] ?? '-')),
                    DataCell(
                      cert['photo'] != null && cert['photo'].toString().isNotEmpty
                          ? TextButton(
                        onPressed: () {
                          // Open attachment
                        },
                        child: const Text('View', style: TextStyle(color: Color(0xFF1E88E5))),
                      )
                          : const Text('-'),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF1E88E5)),
                            onPressed: () => _editCertificate(cert),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                            onPressed: () => _deleteCertificate(cert),
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
    _numberController.dispose();
    _dateOfIssueController.dispose();
    _dateOfExpiryController.dispose();
    _placeOfIssueController.dispose();
    _issuingAuthorityhController.dispose();
    super.dispose();
  }
}