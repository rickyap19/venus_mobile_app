import 'package:flutter/material.dart';
import 'package:pis_management_system/service/bank_account_service.dart';
import 'package:pis_management_system/service/personal_data_service.dart';
import 'package:pis_management_system/widgets/form_components.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class BankAccountScreen extends StatefulWidget {
  const BankAccountScreen({Key? key}) : super(key: key);

  @override
  State<BankAccountScreen> createState() => _BankAccountScreenState();
}

class _BankAccountScreenState extends State<BankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _bankAccounts = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  int? _editingId;

  // Bank Name Options
  final List<String> _bankNames = [
    'Bank Mandiri',
    'Bank Central Asia (BCA)',
    'Bank Rakyat Indonesia (BRI)',
    'Bank Negara Indonesia (BNI)',
    'Bank CIMB Niaga',
    'Bank Danamon',
    'Bank Permata',
    'Bank Tabungan Negara (BTN)',
    'Bank Syariah Indonesia (BSI)',
    'Bank OCBC NISP',
    'Citibank',
    'HSBC',
    'Standard Chartered',
    'Other',
  ];

  // Currency Options
  final List<String> _currencies = [
    'IDR',
    'USD',
    'EUR',
  ];

  // Form Controllers
  String? _selectedBankName;
  final _otherBankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  String? _selectedCurrency;
  final _bankCountryController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _bankCityController = TextEditingController();
  final _swiftCodeController = TextEditingController();
  File? _attachmentFile;
  bool _isMainAccount = false;

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

      // Load existing bank accounts
      final bankAccountsData = await BankAccountService.getBankAccounts();

      if (!mounted) return;
      setState(() => _bankAccounts = bankAccountsData);
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

  void _clearForm() {
    _selectedBankName = null;
    _otherBankNameController.clear();
    _accountNumberController.clear();
    _accountNameController.clear();
    _selectedCurrency = null;
    _bankCountryController.clear();
    _bankBranchController.clear();
    _bankCityController.clear();
    _swiftCodeController.clear();
    if (mounted) {
      setState(() {
        _attachmentFile = null;
        _isMainAccount = false;
        _isEditMode = false;
        _editingId = null;
      });
    }
  }

  void _editBankAccount(Map<String, dynamic> account) {
    setState(() {
      _isEditMode = true;
      _editingId = account['id'];
      _selectedBankName = account['bankName'];
      _otherBankNameController.text = account['otherBankName'] ?? '';
      _accountNumberController.text = account['accountNumber'] ?? '';
      _accountNameController.text = account['accountName'] ?? '';
      _selectedCurrency = account['currency'];
      _bankCountryController.text = account['bankCountry'] ?? '';
      _bankBranchController.text = account['bankBranch'] ?? '';
      _bankCityController.text = account['bankCity'] ?? '';
      _swiftCodeController.text = account['swiftCode'] ?? '';
      _isMainAccount = account['isMainAccount'] ?? false;
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

    // Validate Bank Name or Other Bank Name
    if (_selectedBankName == null) {
      _showError('Please select a bank name');
      return;
    }

    if (_selectedBankName == 'Other' && _otherBankNameController.text.isEmpty) {
      _showError('Please enter other bank name');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        "bankName": _selectedBankName == 'Other'
            ? _otherBankNameController.text
            : _selectedBankName,
        "bankCountry": _bankCountryController.text,
        "bankBranch": _bankBranchController.text,
        "bankCity": _bankCityController.text,
        "swiftCode": _swiftCodeController.text,
        "accountNumber": _accountNumberController.text,
        "accountName": _accountNameController.text,
        "currency": _selectedCurrency ?? '',
        "isMainAccount": _isMainAccount,
        "attachmentPath": _attachmentFile?.path ?? "",
      };

      if (_isEditMode && _editingId != null) {
        // Update existing bank account
        await BankAccountService.updateBankAccount(_editingId!, data);
        _showSuccess('Bank account updated successfully');
      } else {
        // Add new bank account
        await BankAccountService.createBankAccount(data);
        _showSuccess('Bank account added successfully');
      }

      // Reload data
      await _loadData();
      _clearForm();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save bank account: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _deleteBankAccount(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bank Account'),
        content: const Text('Are you sure you want to delete this bank account?'),
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
                await BankAccountService.deleteBankAccount(account['id']);
                _showSuccess('Bank account deleted successfully');
                await _loadData();
              } catch (e) {
                _showError('Failed to delete bank account: $e');
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
    if (_isLoading && _bankAccounts.isEmpty) {
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
                _buildBankAccountForm(),
                const SizedBox(height: 32),
                _buildBankAccountTable(),
              ],
            ),
          ),
        ),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildBankAccountForm() {
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
                  _isEditMode ? 'Edit Bank Account' : 'Add New Bank Account',
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
                      FormComponents.buildSectionTitle('Bank Name *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedBankName,
                        label: 'Bank Name',
                        hint: 'Bank Name',
                        items: _bankNames,
                        onChanged: (value) => setState(() => _selectedBankName = value),
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
                      FormComponents.buildSectionTitle('Other Bank Name ${_selectedBankName == 'Other' ? '*' : ''}'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _otherBankNameController,
                        label: 'Other Bank Name',
                        hint: 'Other Bank Name',
                        enabled: _selectedBankName == 'Other',
                        required: _selectedBankName == 'Other',
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
                      FormComponents.buildSectionTitle('Account Number *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _accountNumberController,
                        label: 'Account Number',
                        hint: 'Account Number',
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
                      FormComponents.buildSectionTitle('Account Name *'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _accountNameController,
                        label: 'Account Name',
                        hint: 'Account Name',
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
                      FormComponents.buildSectionTitle('Currency *'),
                      const SizedBox(height: 8),
                      FormComponents.buildDropdownField(
                        value: _selectedCurrency,
                        label: 'Currency',
                        hint: 'Currency',
                        items: _currencies,
                        onChanged: (value) => setState(() => _selectedCurrency = value),
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
                      FormComponents.buildSectionTitle('Bank Country'),
                      const SizedBox(height: 8),
                      FormComponents.buildCountryDropdownField(
                        value: _bankCountryController.text.isEmpty ? null : _bankCountryController.text,
                        label: 'Bank Country',
                        hint: 'Bank Country',
                        countries: _countries,
                        onChanged: (value) => setState(() => _bankCountryController.text = value ?? ''),
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
                      FormComponents.buildSectionTitle('Bank Branch'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _bankBranchController,
                        label: 'Bank Branch',
                        hint: 'Bank Branch',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormComponents.buildSectionTitle('Bank City'),
                      const SizedBox(height: 8),
                      FormComponents.buildTextField(
                        controller: _bankCityController,
                        label: 'Bank City',
                        hint: 'Bank City',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('SWIFT Code'),
            const SizedBox(height: 8),
            FormComponents.buildTextField(
              controller: _swiftCodeController,
              label: 'SWIFT Code',
              hint: 'SWIFT Code',
            ),
            const SizedBox(height: 16),
            FormComponents.buildSectionTitle('Attachment (jpg/jpeg/png/pdf max 2 MB) *'),
            const SizedBox(height: 8),
            FormComponents.buildDocumentUpload(
              'Drop file here or click to upload',
              _attachmentFile,
              _pickAttachment,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Is Main Account *', style: TextStyle(fontSize: 13)),
              value: _isMainAccount,
              onChanged: (value) => setState(() => _isMainAccount = value ?? false),
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

  Widget _buildBankAccountTable() {
    if (_bankAccounts.isEmpty) {
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
              Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No bank accounts yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first bank account using the form above',
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
                  'Bank Account List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_bankAccounts.length} account(s)',
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
                DataColumn(label: Text('Bank Name')),
                DataColumn(label: Text('Account Number')),
                DataColumn(label: Text('Account Name')),
                DataColumn(label: Text('Currency')),
                DataColumn(label: Text('Is Main Account?')),
                DataColumn(label: Text('Attachment')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _bankAccounts.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> account = entry.value;

                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(account['bankName'] ?? '-')),
                    DataCell(Text(account['accountNumber'] ?? '-')),
                    DataCell(Text(account['accountName'] ?? '-')),
                    DataCell(Text(account['currency'] ?? '-')),
                    DataCell(
                      Text(
                        account['isMainAccount'] == true ? 'Yes' : 'No',
                        style: TextStyle(
                          color: account['isMainAccount'] == true
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      account['attachmentPath'] != null && account['attachmentPath'].toString().isNotEmpty
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
                            onPressed: () => _editBankAccount(account),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                            onPressed: () => _deleteBankAccount(account),
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
    _otherBankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankCountryController.dispose();
    _bankBranchController.dispose();
    _bankCityController.dispose();
    _swiftCodeController.dispose();
    super.dispose();
  }
}