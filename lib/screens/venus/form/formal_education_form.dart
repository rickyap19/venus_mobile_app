import 'package:flutter/material.dart';
import 'package:pis_management_system/service/formal_education_service.dart';
import 'package:pis_management_system/widgets/form_components.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FormalEducationScreen extends StatefulWidget {
  const FormalEducationScreen({Key? key}) : super(key: key);

  @override
  State<FormalEducationScreen> createState() => _FormalEducationScreenState();
}

class _FormalEducationScreenState extends State<FormalEducationScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _educationRecords = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _editingId;

  // Education Level Options
  final List<String> _educationLevels = [
    'Primary',
    'Secondary',
    'High / Vocational',
    'Associate D1',
    'Associate D2',
    'Associate D3',
    'Bachelor',
    'Master',
    'Doctoral',
  ];

  // Form Fields
  String? _selectedEducationLevel;
  final _schoolNameController = TextEditingController();
  final _cityController = TextEditingController();
  File? _certificateFile;
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final educationData = await FormalEducationService.getEducationRecords();

      if (!mounted) return;
      setState(() => _educationRecords = educationData);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load data: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _certificateFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectYear(TextEditingController controller, String label) async {
    final currentYear = DateTime.now().year;
    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select $label'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                final year = currentYear - index;
                return ListTile(
                  title: Text(year.toString()),
                  onTap: () => Navigator.pop(context, year),
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedYear != null && mounted) {
      controller.text = selectedYear.toString();
    }
  }

  void _clearForm() {
    _selectedEducationLevel = null;
    _schoolNameController.clear();
    _cityController.clear();
    _startYearController.clear();
    _endYearController.clear();
    if (mounted) {
      setState(() {
        _certificateFile = null;
        _isEditMode = false;
        _editingId = null;
      });
    }
  }

  void _editEducationRecord(Map<String, dynamic> record) {
    setState(() {
      _isEditMode = true;
      _editingId = record['id'];
      _selectedEducationLevel = record['educationLevel'];
      _schoolNameController.text = record['schoolName'] ?? '';
      _cityController.text = record['city'] ?? '';
      _startYearController.text = record['startYear']?.toString() ?? '';
      _endYearController.text = record['endYear']?.toString() ?? '';
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
        "educationLevel": _selectedEducationLevel ?? '',
        "schoolName": _schoolNameController.text,
        "city": _cityController.text,
        "certificatePhoto": _certificateFile?.path ?? "",
        "startYear": int.tryParse(_startYearController.text) ?? 0,
        "endYear": int.tryParse(_endYearController.text) ?? 0,
      };

      if (_isEditMode && _editingId != null) {
        await FormalEducationService.updateEducationRecord(_editingId!, data);
        _showSuccess('Education record updated successfully');
      } else {
        await FormalEducationService.createEducationRecord(data);
        _showSuccess('Education record added successfully');
      }

      await _loadData();
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save education record: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _deleteEducationRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Education Record'),
        content: const Text('Are you sure you want to delete this education record?'),
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
                await FormalEducationService.deleteEducationRecord(record['id']);
                _showSuccess('Education record deleted successfully');
                await _loadData();
              } catch (e) {
                _showError('Failed to delete education record: $e');
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
    if (_isLoading && _educationRecords.isEmpty) {
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
                _buildEducationForm(),
                const SizedBox(height: 32),
                _buildEducationTable(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildEducationForm() {
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
                  _isEditMode ? 'Edit Education Record' : 'Add New Education Record',
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
                      FormComponents.buildSectionTitle('Education Level *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedEducationLevel,
                        label: 'Education Level',
                        hint: 'Education Level',
                        items: _educationLevels,
                        onChanged: (value) => setState(() => _selectedEducationLevel = value),
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
                      FormComponents.buildSectionTitle('School Name *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _schoolNameController,
                        label: 'School Name',
                        hint: 'School Name',
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('City *'),
            const SizedBox(height: 8),
            FormComponents.buildTextField(
              controller: _cityController,
              label: 'City',
              hint: 'City',
              required: true,
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('Certificate (jpg/jpeg/png/pdf max 2 MB) *'),
            const SizedBox(height: 8),
            FormComponents.buildDocumentUpload(
              'Drop file here or click to upload',
              _certificateFile,
              _pickCertificate,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Start Year *'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectYear(_startYearController, 'Start Year'),
                        child: AbsorbPointer(
                          child: FormComponents.buildTextField(
                            controller: _startYearController,
                            label: 'Start Year',
                            hint: 'Start Year',
                            required: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('End Year *'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectYear(_endYearController, 'End Year'),
                        child: AbsorbPointer(
                          child: FormComponents.buildTextField(
                            controller: _endYearController,
                            label: 'End Year',
                            hint: 'End Year',
                            required: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildEducationTable() {
    if (_educationRecords.isEmpty) {
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
              Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No education records yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first education record using the form above',
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
                  'Education Record List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_educationRecords.length} record(s)',
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
                DataColumn(label: Text('Education Level')),
                DataColumn(label: Text('School Name')),
                DataColumn(label: Text('City')),
                DataColumn(label: Text('Certificate')),
                DataColumn(label: Text('Start Year')),
                DataColumn(label: Text('End Year')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _educationRecords.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> record = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(record['educationLevel'] ?? '-')),
                    DataCell(Text(record['schoolName'] ?? '-')),
                    DataCell(Text(record['city'] ?? '-')),
                    DataCell(
                      record['certificatePhoto'] != null && record['certificatePhoto'].toString().isNotEmpty
                          ? TextButton(
                        onPressed: () {
                          // Open certificate
                        },
                        child: const Text('Attachment', style: TextStyle(color: Color(0xFF1E88E5))),
                      )
                          : const Text('-'),
                    ),
                    DataCell(Text(record['startYear']?.toString() ?? '-')),
                    DataCell(Text(record['endYear']?.toString() ?? '-')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF1E88E5)),
                            onPressed: () => _editEducationRecord(record),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                            onPressed: () => _deleteEducationRecord(record),
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
    _schoolNameController.dispose();
    _cityController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    super.dispose();
  }
}