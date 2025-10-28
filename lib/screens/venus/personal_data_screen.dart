import 'package:flutter/material.dart';
import 'package:pis_management_system/service/personal_data_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasExistingData = false;
  bool _hasExistingPersonalData = false;
  bool _hasExistingAddress = false;
  bool _hasExistingMeasurement = false;
  bool _hasExistingNextOfKin = false;

  // Countries list
  List<Map<String, dynamic>> _countries = [];

  // User profile data
  String? _userRank;
  String? _userManningAgent;

  // Basic Information Controllers
  final _seafarerIDController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bpjsKesehatanController = TextEditingController();
  final _bpjsKetenagakerjaanController = TextEditingController();
  final _dobController = TextEditingController();
  final _countryOfOriginController = TextEditingController();
  final _cityOfBirthController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _manningAgentController = TextEditingController();
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedReligion;
  String? _selectedBloodType;
  File? _photoFile;
  File? _visaPhotoFile;

  // Address Controllers (Primary)
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _provinceController = TextEditingController();
  final _telpNumberController = TextEditingController();
  final _nearestAirportController = TextEditingController();

  // Address Controllers (Temporary)
  final _tempAddressController = TextEditingController();
  final _tempCityController = TextEditingController();
  final _tempPostCodeController = TextEditingController();
  final _tempCountryController = TextEditingController();
  final _tempProvinceController = TextEditingController();
  final _tempTelpNumberController = TextEditingController();
  final _tempNearestAirportController = TextEditingController();

  // Measurement Controllers
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _coverallSizeController = TextEditingController();
  final _safetyShoesController = TextEditingController();
  final _shirtSizeController = TextEditingController();
  final _trousersSizeController = TextEditingController();

  // Next of Kin Controllers
  final _nokFullNameController = TextEditingController();
  final _nokRelationshipController = TextEditingController();
  final _nokRelationshipOtherController = TextEditingController();
  final _nokNationalityController = TextEditingController();
  final _nokCityController = TextEditingController();
  final _nokPostCodeController = TextEditingController();
  final _nokCountryController = TextEditingController();
  final _nokEmailController = TextEditingController();
  final _nokTelpController = TextEditingController();
  final _nokMobileController = TextEditingController();
  final _nokAddressController = TextEditingController();
  String? _nokSelectedGender;

  // KTP
  File? _ktpFile;
  final _ktpNumberController = TextEditingController();
  final _ktpIssuingCountryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _seafarerIDController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _fullNameController.dispose();
    _bpjsKesehatanController.dispose();
    _bpjsKetenagakerjaanController.dispose();
    _dobController.dispose();
    _countryOfOriginController.dispose();
    _cityOfBirthController.dispose();
    _nationalityController.dispose();
    _manningAgentController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postCodeController.dispose();
    _countryController.dispose();
    _provinceController.dispose();
    _telpNumberController.dispose();
    _nearestAirportController.dispose();
    _tempAddressController.dispose();
    _tempCityController.dispose();
    _tempPostCodeController.dispose();
    _tempCountryController.dispose();
    _tempProvinceController.dispose();
    _tempTelpNumberController.dispose();
    _tempNearestAirportController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _coverallSizeController.dispose();
    _safetyShoesController.dispose();
    _shirtSizeController.dispose();
    _trousersSizeController.dispose();
    _nokFullNameController.dispose();
    _nokRelationshipController.dispose();
    _nokRelationshipOtherController.dispose();
    _nokNationalityController.dispose();
    _nokCityController.dispose();
    _nokPostCodeController.dispose();
    _nokCountryController.dispose();
    _nokEmailController.dispose();
    _nokTelpController.dispose();
    _nokMobileController.dispose();
    _nokAddressController.dispose();
    _ktpNumberController.dispose();
    _ktpIssuingCountryController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final countries = await PersonalDataService.getCountries();
      setState(() => _countries = countries);

      final profile = await PersonalDataService.getUserProfile();
      if (profile != null) {
        setState(() {
          _seafarerIDController.text = profile['seafarerId'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _fullNameController.text = profile['fullName'] ?? '';
          _userRank = profile['rank'];
          _userManningAgent = profile['manningAgent'];
        });
      }

      final completeData = await PersonalDataService.getCompletePersonalData();
      if (completeData != null) {
        _populateCompleteFields(completeData);
      }
    } catch (e) {
      _showError('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _populateCompleteFields(Map<String, dynamic> data) {
    if (data['personalData'] != null) {
      _hasExistingPersonalData = true;
      final personal = data['personalData'];
      _seafarerIDController.text = personal['seafarerID'] ?? '';
      _emailController.text = personal['email'] ?? '';
      _mobileController.text = personal['mobilePhoneNumber'] ?? '';
      _fullNameController.text = personal['fullName'] ?? '';
      _bpjsKesehatanController.text = personal['bpjsKesehatanNumber'] ?? '';
      _bpjsKetenagakerjaanController.text = personal['bpjsKetenagakerjaanNumber'] ?? '';

      if (personal['dateOfBirth'] != null) {
        try {
          final date = DateTime.parse(personal['dateOfBirth']);
          _dobController.text = DateFormat('yyyy-MM-dd').format(date);
        } catch (e) {
          print('Error parsing date: $e');
        }
      }

      _countryOfOriginController.text = personal['countryOfOrigin'] ?? '';
      _cityOfBirthController.text = personal['cityOfBirth'] ?? '';
      _nationalityController.text = personal['nationality'] ?? '';
      _manningAgentController.text = personal['manningAgent'] ?? '';
      _selectedGender = personal['gender'];
      _selectedMaritalStatus = personal['maritalStatus'];
      _selectedReligion = personal['religion'];
      _selectedBloodType = personal['bloodType'];


    }

    if (data['address'] != null && data['address'] is List) {
      _hasExistingAddress = true;
      final addresses = data['address'] as List;
      for (var addr in addresses) {
        if (addr['isTemporary'] == false) {
          _addressController.text = addr['address'] ?? '';
          _cityController.text = addr['city'] ?? '';
          _postCodeController.text = addr['postCode'] ?? '';
          _countryController.text = addr['country'] ?? '';
          _provinceController.text = addr['province'] ?? '';
          _telpNumberController.text = addr['telpNumber'] ?? '';
          _nearestAirportController.text = addr['nearestAirPort'] ?? '';
        } else {
          _tempAddressController.text = addr['address'] ?? '';
          _tempCityController.text = addr['city'] ?? '';
          _tempPostCodeController.text = addr['postCode'] ?? '';
          _tempCountryController.text = addr['country'] ?? '';
          _tempProvinceController.text = addr['province'] ?? '';
          _tempTelpNumberController.text = addr['telpNumber'] ?? '';
          _tempNearestAirportController.text = addr['nearestAirPort'] ?? '';
        }
      }
    }

    if (data['measurementInfo'] != null) {
      _hasExistingMeasurement = true;
      final measurement = data['measurementInfo'];
      _weightController.text = measurement['weight']?.toString() ?? '';
      _heightController.text = measurement['height']?.toString() ?? '';
      _coverallSizeController.text = measurement['coverallSize'] ?? '';
      _safetyShoesController.text = measurement['safetyShoesSize'] ?? '';
      _shirtSizeController.text = measurement['shirtSize'] ?? '';
      _trousersSizeController.text = measurement['trousersSize'] ?? '';
    }

    if (data['nextOfKin'] != null) {
      _hasExistingNextOfKin = true;
      final nok = data['nextOfKin'];
      _nokFullNameController.text = nok['fullNameAsIDCard'] ?? '';
      _nokSelectedGender = nok['gender'];
      _nokRelationshipController.text = nok['relationship'] ?? '';
      _nokRelationshipOtherController.text = nok['relationshipOther'] ?? '';
      _nokNationalityController.text = nok['nationality'] ?? '';
      _nokCityController.text = nok['city'] ?? '';
      _nokPostCodeController.text = nok['postCode'] ?? '';
      _nokCountryController.text = nok['country'] ?? '';
      _nokEmailController.text = nok['email'] ?? '';
      _nokTelpController.text = nok['telpNumber'] ?? '';
      _nokMobileController.text = nok['mobilePhoneNumber'] ?? '';
      _nokAddressController.text = nok['address'] ?? '';
    }
  }

  Future<void> _pickImage(bool isPhoto) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isPhoto) {
          _photoFile = File(pickedFile.path);
        } else {
          _visaPhotoFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickKTP() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _ktpFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
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
    if (date != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  Future<void> _saveAsDraft() async {
    setState(() => _isSaving = true);
    try {
      if (_currentTabIndex == 0) {
        await _saveAllPersonalData();
        _showSuccess('Draft saved successfully');
      }
    } catch (e) {
      _showError('Failed to save draft: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAndNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    print('✅ tab loaded: ${_currentTabIndex}');
    try {
      if (_currentTabIndex == 0) {
        await _saveAllPersonalData();
        _showSuccess('Data saved successfully');
        _tabController.animateTo(1);
      }
    } catch (e) {
      _showError('Failed to save: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAllPersonalData() async {
    await _saveBasicInformation();
    await _saveAddress();
    await _saveMeasurement();
    await _saveNextOfKin();
  }

  Future<void> _saveBasicInformation() async {
    final data = {
      "photoPath": "",
      "visaPhotoPath": "",
      "seafarerID": _seafarerIDController.text,
      "email": _emailController.text,
      "mobilePhoneNumber": _mobileController.text,
      "fullName": _fullNameController.text,
      "bpjsKesehatanNumber": _bpjsKesehatanController.text,
      "bpjsKetenagakerjaanNumber": _bpjsKetenagakerjaanController.text,
      "dateOfBirth": _dobController.text,
      "countryOfOrigin": _countryOfOriginController.text,
      "cityOfBirth": _cityOfBirthController.text,
      "nationality": _nationalityController.text,
      "gender": _selectedGender,
      "maritalStatus": _selectedMaritalStatus,
      "religion": _selectedReligion,
      "bloodType": _selectedBloodType,
      "status": "Active",
      "reason": "",
      "manningAgent": _manningAgentController.text,
    };

    await PersonalDataService.savePersonalData(data, isUpdate: _hasExistingPersonalData);
  }

  Future<void> _saveAddress() async {
    final primaryAddress = {
      "address": _addressController.text,
      "city": _cityController.text,
      "postCode": _postCodeController.text,
      "country": _countryController.text,
      "province": _provinceController.text,
      "telpNumber": _telpNumberController.text,
      "nearestAirPort": _nearestAirportController.text,
      "isTemporary": false,
    };

    await PersonalDataService.saveAddress(primaryAddress, isUpdate: _hasExistingAddress);

    if (_tempAddressController.text.isNotEmpty) {
      final tempAddress = {
        "address": _tempAddressController.text,
        "city": _tempCityController.text,
        "postCode": _tempPostCodeController.text,
        "country": _tempCountryController.text,
        "province": _tempProvinceController.text,
        "telpNumber": _tempTelpNumberController.text,
        "nearestAirPort": _tempNearestAirportController.text,
        "isTemporary": true,
      };
      await PersonalDataService.saveAddress(tempAddress, isUpdate: _hasExistingAddress);
    }
  }

  Future<void> _saveMeasurement() async {
    final data = {
      "weight": double.tryParse(_weightController.text) ?? 0,
      "height": double.tryParse(_heightController.text) ?? 0,
      "coverallSize": _coverallSizeController.text,
      "safetyShoesSize": _safetyShoesController.text,
      "shirtSize": _shirtSizeController.text,
      "trousersSize": _trousersSizeController.text,
    };

    await PersonalDataService.saveMeasurement(data, isUpdate: _hasExistingMeasurement);
  }

  Future<void> _saveNextOfKin() async {
    final data = {
      "fullNameAsIDCard": _nokFullNameController.text,
      "gender": _nokSelectedGender,
      "relationship": _nokRelationshipController.text,
      "relationshipOther": _nokRelationshipOtherController.text,
      "nationality": _nokNationalityController.text,
      "city": _nokCityController.text,
      "postCode": _nokPostCodeController.text,
      "country": _nokCountryController.text,
      "email": _nokEmailController.text,
      "telpNumber": _nokTelpController.text,
      "mobilePhoneNumber": _nokMobileController.text,
      "address": _nokAddressController.text,
    };

    await PersonalDataService.saveNextOfKin(data, isUpdate: _hasExistingNextOfKin);
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                _buildPersonalDataForm(),
                _buildComingSoon('Documents'),
                _buildComingSoon('Bank Account'),
                _buildComingSoon('Family'),
                _buildComingSoon('Formal Education'),
                _buildComingSoon('Medical Certificate / Test'),
                _buildComingSoon('Certificates and Qualifications'),
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
          Tab(text: 'OLP CERTIFICATES'),
          Tab(text: 'SEA EXPERIENCE'),
          Tab(text: 'APPRAISALS'),
          Tab(text: 'MEDICAL HISTORY'),
        ],
      ),
    );
  }

  Widget _buildPersonalDataForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            _buildSectionTitle('Photos'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildPhotoUpload('Pass Photo (3 x 4 ( jpg/jpeg/jpg max 2 MB) )', _photoFile, () => _pickImage(true))),
                const SizedBox(width: 16),
                Expanded(child: _buildPhotoUpload('Visa Photo ( jpg/jpeg/jpg max 2 MB)', _visaPhotoFile, () => _pickImage(false))),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Individual\'s Seafarer ID'),
            const SizedBox(height: 16),
            _buildTextField(controller: _seafarerIDController, label: 'Seafarer ID', hint: 'Enter seafarer ID', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Rank'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(text: _userRank ?? 'Third Officer'), label: 'Rank', hint: 'Third Officer', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Email'),
            const SizedBox(height: 16),
            _buildTextField(controller: _emailController, label: 'Email', hint: 'novariano@gmail.com', keyboardType: TextInputType.emailAddress, required: true , enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Full Name (Same As ID Card)'),
            const SizedBox(height: 16),
            _buildTextField(controller: _fullNameController, label: 'Full Name (Same As ID Card)', hint: 'Pairu Ruciata Dewi', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('BP JS Kesehatan/Japen Number'),
            const SizedBox(height: 16),
            _buildTextField(controller: _bpjsKesehatanController, label: 'BP JS Kesehatan/Japen Number', hint: '0243320368557'),
            const SizedBox(height: 16),
            _buildSectionTitle('BP JS Ketenagakerjaan Number'),
            const SizedBox(height: 16),
            _buildTextField(controller: _bpjsKetenagakerjaanController, label: 'BP JS Ketenagakerjaan Number', hint: '0243320368557'),
            const SizedBox(height: 16),
            _buildSectionTitle('Mobile No. (Without Leading Zero)'),
            const SizedBox(height: 16),
            _buildTextField(controller: _mobileController, label: 'Mobile No. (Without Leading Zero)', hint: '+62 (Indonesia) 8321661-9087', keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Date of Birth'),
            const SizedBox(height: 16),
            _buildDateField(controller: _dobController, label: 'Date of Birth', hint: '09 Feb 2000', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Country of Origin'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _countryOfOriginController.text.isEmpty ? null : _countryOfOriginController.text, label: 'Country of Origin', hint: 'Select Country', onChanged: (value) => setState(() => _countryOfOriginController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('City of Birth (Same As ID Card)'),
            const SizedBox(height: 16),
            _buildTextField(controller: _cityOfBirthController, label: 'City of Birth (Same As ID Card)', hint: 'Tebum', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Nationality / Current Citizenship'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _nationalityController.text.isEmpty ? null : _nationalityController.text, label: 'Nationality / Current Citizenship', hint: 'Select Nationality', onChanged: (value) => setState(() => _nationalityController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Gender'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _selectedGender, label: 'Gender', hint: 'Female', items: ['Male', 'Female'], onChanged: (value) => setState(() => _selectedGender = value), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Marital Status'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _selectedMaritalStatus, label: 'Marital Status', hint: 'Single', items: ['Single', 'Married', 'Divorced', 'Widowed'], onChanged: (value) => setState(() => _selectedMaritalStatus = value), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Religion'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _selectedReligion, label: 'Religion', hint: 'Islam', items: ['Islam', 'Christianity', 'Catholicism', 'Hinduism', 'Buddhism', 'Confucianism'], onChanged: (value) => setState(() => _selectedReligion = value), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Blood Type'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _selectedBloodType, label: 'Blood Type', hint: 'B B+', items: ['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], onChanged: (value) => setState(() => _selectedBloodType = value)),
            const SizedBox(height: 16),
            _buildSectionTitle('Status'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(text: 'Active'), label: 'Status', hint: 'Active', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Reason'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(), label: 'Reason', hint: '', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Contract Status'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(), label: 'Contract Status', hint: '', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Employee ID'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(), label: 'Employee ID', hint: '', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Manning Agent'),
            const SizedBox(height: 16),
            _buildTextField(controller: _manningAgentController, label: 'Manning Agent', hint: _userManningAgent ?? 'PT. Pertamina Marine Solutions', enabled: false),
            const SizedBox(height: 40),
            _buildMainSectionHeader('Address Information'),
            const SizedBox(height: 16),
            _buildSubSectionHeader('1. Permanent/Primary Address'),
            const SizedBox(height: 16),
            _buildSectionTitle('Address *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _addressController, label: 'Address', hint: 'Dsun Dliluk RT 003 RW 004 Ds NgulukKec Kabuagaten Tembono', maxLines: 3, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('City *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _cityController, label: 'City', hint: 'Tebum', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Post Code *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _postCodeController, label: 'Post Code', hint: '50392', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Country *'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _countryController.text.isEmpty ? null : _countryController.text, label: 'Country', hint: 'Select Country', onChanged: (value) => setState(() => _countryController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Province *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _provinceController, label: 'Province', hint: 'Jawa Timur', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Home Tel (Without Leading Zero) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _telpNumberController, label: 'Home Tel (Without Leading Zero)', hint: '+62 (Indonesia) 8321661-9087', keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Nearest Airport *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nearestAirportController, label: 'Nearest Airport', hint: 'Bandara Juanda Surabaya', required: true),
            const SizedBox(height: 24),
            _buildSubSectionHeader('2. Temporary/Alternative Address'),
            const SizedBox(height: 16),
            _buildSectionTitle('Address'),
            const SizedBox(height: 16),
            _buildTextField(controller: _tempAddressController, label: 'Address', hint: 'Address', maxLines: 3),
            const SizedBox(height: 16),
            _buildSectionTitle('City'),
            const SizedBox(height: 16),
            _buildTextField(controller: _tempCityController, label: 'City', hint: 'City'),
            const SizedBox(height: 16),
            _buildSectionTitle('Post Code'),
            const SizedBox(height: 16),
            _buildTextField(controller: _tempPostCodeController, label: 'Post Code', hint: 'Post Code', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildSectionTitle('Country'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _tempCountryController.text.isEmpty ? null : _tempCountryController.text, label: 'Country', hint: 'Select Country', onChanged: (value) => setState(() => _tempCountryController.text = value ?? '')),
            const SizedBox(height: 16),
            _buildSectionTitle('Province'),
            const SizedBox(height: 16),
            _buildTextField(controller: _tempProvinceController, label: 'Province', hint: 'Province'),
            const SizedBox(height: 16),
            _buildSectionTitle('Home Tel (Without Leading Zero)'),
            const SizedBox(height: 16),
            _buildTextField(controller: _tempTelpNumberController, label: 'Home Tel (Without Leading Zero)', hint: 'Home Tel', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildSectionTitle('Nearest Airport'),
            const SizedBox(height: 16),
            _buildTextField(controller: _tempNearestAirportController, label: 'Nearest Airport', hint: 'Nearest Airport'),
            const SizedBox(height: 40),
            _buildMainSectionHeader('Other Informations'),
            const SizedBox(height: 16),
            _buildSectionTitle('Rank Applied For *'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(text: _userRank ?? 'Third Officer'), label: 'Rank Applied For', hint: 'Third Officer', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Willing to Accept Lower Rank'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(), label: 'Willing to Accept Lower Rank', hint: '', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Available From *'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(text: '01 Mar 2025'), label: 'Available From', hint: '01 Mar 2025', enabled: false),
            const SizedBox(height: 16),
            _buildSectionTitle('Available Until *'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(text: '01 Sep 2025'), label: 'Available Until', hint: '01 Sep 2025', enabled: false),
            const SizedBox(height: 40),
            _buildMainSectionHeader('Measurement Information'),
            const SizedBox(height: 16),
            _buildSectionTitle('Weight (kg) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _weightController, label: 'Weight (kg)', hint: '53', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Height (cm) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _heightController, label: 'Height (cm)', hint: '165', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Coverall Size *'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _coverallSizeController.text.isEmpty ? null : _coverallSizeController.text, label: 'Coverall Size', hint: 'S, M, L, XL, XXL, 3XL, 4XL, 5XL, 6XL etc', items: ['S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL'], onChanged: (value) => setState(() => _coverallSizeController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Safety Shoes Size *'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _safetyShoesController.text.isEmpty ? null : _safetyShoesController.text, label: 'Safety Shoes Size', hint: 'UK 5.5, S.5, etc UK 8.5, EU -d2', items: ['UK 5', 'UK 5.5', 'UK 6', 'UK 6.5', 'UK 7', 'UK 7.5', 'UK 8', 'UK 8.5', 'UK 9', 'UK 9.5', 'UK 10'], onChanged: (value) => setState(() => _safetyShoesController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Shirt Size *'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _shirtSizeController.text.isEmpty ? null : _shirtSizeController.text, label: 'Shirt Size', hint: 'S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL etc', items: ['S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL'], onChanged: (value) => setState(() => _shirtSizeController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Trousers Size *'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _trousersSizeController.text.isEmpty ? null : _trousersSizeController.text, label: 'Trousers Size', hint: 'S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL etc', items: ['S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL'], onChanged: (value) => setState(() => _trousersSizeController.text = value ?? ''), required: true),
            const SizedBox(height: 40),
            _buildMainSectionHeader('Next of KIN'),
            const SizedBox(height: 16),
            _buildSectionTitle('Full Name (Same As ID Card) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokFullNameController, label: 'Full Name (Same As ID Card)', hint: 'Khumomo', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Gender *'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _nokSelectedGender, label: 'Gender', hint: 'Male', items: ['Male', 'Female'], onChanged: (value) => setState(() => _nokSelectedGender = value), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Relationship *'),
            const SizedBox(height: 16),
            _buildDropdownField(value: _nokRelationshipController.text.isEmpty ? null : _nokRelationshipController.text, label: 'Relationship', hint: 'Parent', items: ['Parent', 'Spouse', 'Sibling', 'Child', 'Other'], onChanged: (value) => setState(() => _nokRelationshipController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Relationship Detail (If Choosing Other Relatives) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokRelationshipOtherController, label: 'Relationship Detail', hint: 'Relationship Detail'),
            const SizedBox(height: 16),
            _buildSectionTitle('Nationality *'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _nokNationalityController.text.isEmpty ? null : _nokNationalityController.text, label: 'Nationality', hint: 'Select Nationality', onChanged: (value) => setState(() => _nokNationalityController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('City *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokCityController, label: 'City', hint: 'Tebum', required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Post Code *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokPostCodeController, label: 'Post Code', hint: '63252', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Country *'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _nokCountryController.text.isEmpty ? null : _nokCountryController.text, label: 'Country', hint: 'Select Country', onChanged: (value) => setState(() => _nokCountryController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Email *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokEmailController, label: 'Email', hint: 'Rio.Nikarja@gmail.com', keyboardType: TextInputType.emailAddress, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Home Tel (Without Leading Zero) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokTelpController, label: 'Home Tel (Without Leading Zero)', hint: '+62 (Indonesia)', keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Mobile No. (Without Leading Zero) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokMobileController, label: 'Mobile No. (Without Leading Zero)', hint: '+62 (Indonesia) 81229054263', keyboardType: TextInputType.phone, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Address *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _nokAddressController, label: 'Address', hint: 'Dsun Diluk RT 003 RW 004 Ds Ngalubuke Kabuagaten Tembono Kotacatan Tumbung', maxLines: 3, required: true),
            const SizedBox(height: 40),
            _buildMainSectionHeader('KTP'),
            const SizedBox(height: 16),
            _buildSectionTitle('Number (16 digits) *'),
            const SizedBox(height: 16),
            _buildTextField(controller: _ktpNumberController, label: 'Number (16 digits)', hint: '3525080240300081', keyboardType: TextInputType.number, required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Issuing Country *'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: _ktpIssuingCountryController.text.isEmpty ? null : _ktpIssuingCountryController.text, label: 'Issuing Country', hint: 'Select Country', onChanged: (value) => setState(() => _ktpIssuingCountryController.text = value ?? ''), required: true),
            const SizedBox(height: 16),
            _buildSectionTitle('Attachment ( jpg/jpeg/png/pdf max 2 MB)'),
            const SizedBox(height: 16),
            _buildDocumentUpload('Drop file here or click to upload', _ktpFile, _pickKTP),
            const SizedBox(height: 40),
            _buildMainSectionHeader('Personal Tax (Only If Requested)'),
            const SizedBox(height: 16),
            _buildSectionTitle('Number (15-16 digits)'),
            const SizedBox(height: 16),
            _buildTextField(controller: TextEditingController(), label: 'Number (15-16 digits)', hint: '608037329424903', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildSectionTitle('Issuing Country'),
            const SizedBox(height: 16),
            _buildCountryDropdownField(value: null, label: 'Issuing Country', hint: 'Select Country', onChanged: (value) {}),
            const SizedBox(height: 16),
            _buildSectionTitle('Attachment ( jpg/jpeg/png/pdf max 2 MB)'),
            const SizedBox(height: 16),
            _buildDocumentUpload('Drop file here or click to upload', null, () {}),
            const SizedBox(height: 80),
          ],
        ),
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
              child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save as Draft', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
              child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Text('Save and Next', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E88E5).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
        ],
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)));
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A237E)));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    bool enabled = true,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE53935))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE53935), width: 2)),
      ),
      validator: required && enabled ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null : null,
    );
  }

  Widget _buildDateField({required TextEditingController controller, required String label, required String hint, bool required = false}) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(controller),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: const Icon(Icons.calendar_today, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2)),
      ),
      validator: required ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null : null,
    );
  }

  Widget _buildDropdownField({required String? value, required String label, required String hint, required List<String> items, required Function(String?) onChanged, bool required = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2)),
      ),
      items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      validator: required ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null : null,
    );
  }

  Widget _buildCountryDropdownField({required String? value, required String label, required String hint, required Function(String?) onChanged, bool required = false}) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2)),
      ),
      items: _countries.map((country) => DropdownMenuItem<String>(value: country['name'], child: Text(country['name'], style: const TextStyle(fontSize: 13)))).toList(),
      onChanged: onChanged,
      validator: required ? (value) => (value == null || value.isEmpty) ? 'This field is required' : null : null,
    );
  }

  Widget _buildPhotoUpload(String label, File? file, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[800])),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 180,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!, width: 1.5)),
            child: file != null
                ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('Drop file here or click to upload', style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String label, File? file, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!, width: 1.5)),
        child: file != null
            ? Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover)),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}