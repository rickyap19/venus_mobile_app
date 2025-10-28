import 'package:flutter/material.dart';
import 'package:pis_management_system/service/document_service.dart';
import 'package:pis_management_system/service/personal_data_service.dart';
import 'package:pis_management_system/widgets/form_components.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({Key? key}) : super(key: key);

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _documents = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _editingIndex;

  // Document Type Options
  final List<String> _documentTypes = [
    'Passport',
    'Seaman\'s Book',
    'Family Register (KK)',
    'BPJS Kesehatan',
    'BPJS Ketenagakerjaan',
    'SID',
    'KTP',
    'Visa',
    'CDC',
    'GOC',
    'Other',
  ];

  // Form Controllers
  final _documentTypeController = TextEditingController();
  final _numberController = TextEditingController();
  final _issuingCountryController = TextEditingController();
  final _issuingPlaceController = TextEditingController();
  final _dateOfIssueController = TextEditingController();
  final _validUntilController = TextEditingController();
  File? _photoFile;
  bool _isAdditional = false;

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

      if (!mounted) return;
      setState(() => _countries = countries);

      // Load existing documents
      final documentsData = await PersonalDataService.getCompletePersonalData();

      if (!mounted) return;
      if (documentsData != null && documentsData['documents'] != null) {
        setState(() => _documents = List<Map<String, dynamic>>.from(documentsData['documents']));
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to load data: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _photoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E88E5),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && mounted) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _clearForm() {
    _documentTypeController.clear();
    _numberController.clear();
    _issuingCountryController.clear();
    _issuingPlaceController.clear();
    _dateOfIssueController.clear();
    _validUntilController.clear();
    if (mounted) {
      setState(() {
        _photoFile = null;
        _isAdditional = false;
        _isEditMode = false;
        _editingIndex = null;
      });
    }
  }

  void _editDocument(int index) {
    final doc = _documents[index];
    setState(() {
      _isEditMode = true;
      _editingIndex = index;
      _documentTypeController.text = doc['type'] ?? '';
      _numberController.text = doc['number'] ?? '';
      _issuingCountryController.text = doc['issuingCountry'] ?? '';
      _issuingPlaceController.text = doc['issuingPlace'] ?? '';
      _dateOfIssueController.text = doc['dateOfIssue'] ?? '';
      _validUntilController.text = doc['validUntil'] ?? '';
      _isAdditional = doc['isAdditional'] ?? false;
      // Note: Can't restore file from path
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
      // Prepare data sesuai struktur API
      final data = {
        "number": _numberController.text,
        "issuingCountry": _issuingCountryController.text,
        "issuingPlace": _issuingPlaceController.text,
        "photoPath": _photoFile?.path ?? "",
        "dateOfIssue": _dateOfIssueController.text.isEmpty
            ? DateTime.now().toIso8601String()
            : "${_dateOfIssueController.text}T00:00:00.000Z",
        "validUntil": _validUntilController.text.isEmpty
            ? DateTime.now().toIso8601String()
            : "${_validUntilController.text}T00:00:00.000Z",
        "type": _documentTypeController.text,
        "isAdditional": _isAdditional,
      };

      if (_isEditMode && _editingIndex != null) {
        // Update existing document
        await DocumentService.updateDocument(data);

        if (!mounted) return;
        setState(() {
          _documents[_editingIndex!] = {
            'type': _documentTypeController.text,
            'number': _numberController.text,
            'issuingCountry': _issuingCountryController.text,
            'dateOfIssue': _dateOfIssueController.text,
            'issuingPlace': _issuingPlaceController.text,
            'validUntil': _validUntilController.text,
            'photoPath': _photoFile?.path ?? '',
            'isAdditional': _isAdditional,
          };
        });
        _showSuccess('Document updated successfully');
      } else {
        // Add new document
        await DocumentService.saveDocument(data);

        if (!mounted) return;
        setState(() {
          _documents.add({
            'type': _documentTypeController.text,
            'number': _numberController.text,
            'issuingCountry': _issuingCountryController.text,
            'dateOfIssue': _dateOfIssueController.text,
            'issuingPlace': _issuingPlaceController.text,
            'validUntil': _validUntilController.text,
            'photoPath': _photoFile?.path ?? '',
            'isAdditional': _isAdditional,
          });
        });
        _showSuccess('Document added successfully');
      }

      _clearForm();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save document: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _deleteDocument(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _documents.removeAt(index);
              });
              _showSuccess('Document deleted successfully');
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocumentForm(),
                const SizedBox(height: 32),
                _buildDocumentTable(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildDocumentForm() {
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
                  _isEditMode ? 'Edit Document' : 'Add New Document',
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
                      FormComponents.buildSectionTitle('Document Type *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _documentTypeController.text.isEmpty ? null : _documentTypeController.text,
                        label: 'Document Type',
                        hint: 'Document Type',
                        items: _documentTypes,
                        onChanged: (value) => setState(() => _documentTypeController.text = value ?? ''),
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Country Of Issue *'),
                      const SizedBox(height: 8),
                      FormComponents.buildCountryDropdownField(
                        value: _issuingCountryController.text.isEmpty ? null : _issuingCountryController.text,
                        label: 'Country Of Issue',
                        hint: 'Country Of Issue',
                        countries: _countries,
                        onChanged: (value) => setState(() => _issuingCountryController.text = value ?? ''),
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
                      FormComponents.buildSectionTitle('Issued at (Place) *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _issuingPlaceController,
                        label: 'Issued at (Place)',
                        hint: 'Issued at (Place)',
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
                      FormComponents.buildSectionTitle('Date Of Issue *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDateField(
                        context: context,
                        controller: _dateOfIssueController,
                        label: 'Date Of Issue',
                        hint: 'Date Of Issue',
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
                      FormComponents.buildSectionTitle('Valid Until *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDateField(
                        context: context,
                        controller: _validUntilController,
                        label: 'Valid Until',
                        hint: 'Valid Until',
                        required: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('Attachment ( jpg/jpeg/png/pdf max 2 MB) *'),
            const SizedBox(height: 8),
            FormComponents.buildDocumentUpload(
              'Drop file here or click to upload',
              _photoFile,
              _pickPhoto,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Is Additional Document', style: TextStyle(fontSize: 13)),
              value: _isAdditional,
              onChanged: (value) => setState(() => _isAdditional = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF1E88E5),
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

  Widget _buildDocumentTable() {
    if (_documents.isEmpty) {
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
              Icon(Icons.description_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No documents yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first document using the form above',
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
                  'Document List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_documents.length} document(s)',
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
                DataColumn(label: Text('Document Type')),
                DataColumn(label: Text('Number')),
                DataColumn(label: Text('Country Of Issue')),
                DataColumn(label: Text('Date Of Issue')),
                DataColumn(label: Text('Issued at (Place)')),
                DataColumn(label: Text('Valid Until')),
                DataColumn(label: Text('Attachment')),
                DataColumn(label: Text('Is Additional')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _documents.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> doc = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(doc['type'] ?? '-')),
                    DataCell(Text(doc['number'] ?? '-')),
                    DataCell(Text(doc['issuingCountry'] ?? '-')),
                    DataCell(Text(_formatDate(doc['dateOfIssue']))),
                    DataCell(Text(doc['issuingPlace'] ?? '-')),
                    DataCell(Text(_formatDate(doc['validUntil']))),
                    DataCell(
                      doc['photoPath'] != null && doc['photoPath'].toString().isNotEmpty
                          ? TextButton(
                        onPressed: () {
                          // Open attachment
                        },
                        child: const Text('View', style: TextStyle(color: Color(0xFF1E88E5))),
                      )
                          : const Text('-'),
                    ),
                    DataCell(
                      Icon(
                        doc['isAdditional'] == true ? Icons.check_circle : Icons.cancel,
                        color: doc['isAdditional'] == true ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Color(0xFF1E88E5)),
                            onPressed: () => _editDocument(index),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                            onPressed: () => _deleteDocument(index),
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
    _documentTypeController.dispose();
    _numberController.dispose();
    _issuingCountryController.dispose();
    _issuingPlaceController.dispose();
    _dateOfIssueController.dispose();
    _validUntilController.dispose();
    super.dispose();
  }
}