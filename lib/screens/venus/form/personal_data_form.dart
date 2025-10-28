import 'package:flutter/material.dart';
import 'package:pis_management_system/service/personal_data_service.dart';
import 'package:pis_management_system/widgets/form_components.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PersonalDataFormScreen extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Function(bool) onSavingChanged;
  final Function(String) onError;
  final Function(String) onSuccess;

  const PersonalDataFormScreen({
    Key? key,
    required this.formKey,
    required this.onSavingChanged,
    required this.onError,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PersonalDataFormScreen> createState() => PersonalDataFormScreenState();
}

class PersonalDataFormScreenState extends State<PersonalDataFormScreen> {
  List<Map<String, dynamic>> _countries = [];
  String? _userRank;
  String? _userManningAgent;

  bool _hasExistingPersonalData = false;
  bool _hasExistingAddress = false;
  bool _hasExistingMeasurement = false;
  bool _hasExistingNextOfKin = false;

  // ✅ ADD LOADING STATE
  bool _isLoading = true;

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
  String? _selectedCoverallSize;
  String? _selectedSafetyShoesSize;
  String? _selectedShirtSize;
  String? _selectedTrousersSize;

  // Next of Kin Controllers
  final _nokFullNameController = TextEditingController();
  String? _selectedNokRelationship;
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
    _loadData();
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
      widget.onError('Failed to load data: $e');
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
          _dobController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

    if (data['address'] != null && data['address'] is List && (data['address'] as List).isNotEmpty) {
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
      _selectedCoverallSize = measurement['coverallSize'];
      _selectedSafetyShoesSize = measurement['safetyShoesSize'];
      _selectedShirtSize = measurement['shirtSize'];
      _selectedTrousersSize = measurement['trousersSize'];
    }

    if (data['nextOfKin'] != null) {
      _hasExistingNextOfKin = true;
      final nok = data['nextOfKin'];
      _nokFullNameController.text = nok['fullNameAsIDCard'] ?? '';
      _nokSelectedGender = nok['gender'];
      _selectedNokRelationship = nok['relationship'];
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

  Future<void> saveAllData() async {
    widget.onSavingChanged(true);
    try {
      await _saveBasicInformation();
      await _saveAddress();
      await _saveMeasurement();
      await _saveNextOfKin();
      widget.onSuccess('Data saved successfully');
    } catch (e) {
      widget.onError('Failed to save: $e');
      rethrow;
    } finally {
      widget.onSavingChanged(false);
    }
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
    setState(() => _hasExistingPersonalData = true);
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

    setState(() => _hasExistingAddress = true);
  }

  Future<void> _saveMeasurement() async {
    final data = {
      "weight": double.tryParse(_weightController.text) ?? 0,
      "height": double.tryParse(_heightController.text) ?? 0,
      "coverallSize": _selectedCoverallSize ?? '',
      "safetyShoesSize": _selectedSafetyShoesSize ?? '',
      "shirtSize": _selectedShirtSize ?? '',
      "trousersSize": _selectedTrousersSize ?? '',
    };

    await PersonalDataService.saveMeasurement(data, isUpdate: _hasExistingMeasurement);
    setState(() => _hasExistingMeasurement = true);
  }

  Future<void> _saveNextOfKin() async {
    final data = {
      "fullNameAsIDCard": _nokFullNameController.text,
      "gender": _nokSelectedGender,
      "relationship": _selectedNokRelationship ?? '',
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
    setState(() => _hasExistingNextOfKin = true);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ SHOW LOADING SPINNER
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInformation(),
            const SizedBox(height: 40),
            _buildAddressInformation(),
            const SizedBox(height: 40),
            _buildOtherInformation(),
            const SizedBox(height: 40),
            _buildMeasurementInformation(),
            const SizedBox(height: 40),
            _buildNextOfKin(),
            const SizedBox(height: 40),
            _buildKTP(),
            const SizedBox(height: 40),
            _buildPersonalTax(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('Basic Information'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Photos'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: FormComponents.buildPhotoUpload('Pass Photo (3 x 4 ( jpg/jpeg/jpg max 2 MB) )', _photoFile, () => _pickImage(true))),
            const SizedBox(width: 16),
            Expanded(child: FormComponents.buildPhotoUpload('Visa Photo ( jpg/jpeg/jpg max 2 MB)', _visaPhotoFile, () => _pickImage(false))),
          ],
        ),
        const SizedBox(height: 24),
        FormComponents.buildSectionTitle('Individual\'s Seafarer ID'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _seafarerIDController, label: 'Seafarer ID', hint: 'Enter seafarer ID', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Rank'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(text: _userRank ?? 'Third Officer'), label: 'Rank', hint: 'Third Officer', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Email'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _emailController, label: 'Email', hint: 'novariano@gmail.com', keyboardType: TextInputType.emailAddress, required: true, enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Full Name (Same As ID Card)'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _fullNameController, label: 'Full Name (Same As ID Card)', hint: 'Pairu Ruciata Dewi', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('BP JS Kesehatan/Japen Number'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _bpjsKesehatanController, label: 'BP JS Kesehatan/Japen Number', hint: '0243320368557'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('BP JS Ketenagakerjaan Number'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _bpjsKetenagakerjaanController, label: 'BP JS Ketenagakerjaan Number', hint: '0243320368557'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Mobile No. (Without Leading Zero)'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _mobileController, label: 'Mobile No. (Without Leading Zero)', hint: '+62 (Indonesia) 8321661-9087', keyboardType: TextInputType.phone, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Date of Birth'),
        const SizedBox(height: 16),
        FormComponents.buildDateField(context: context, controller: _dobController, label: 'Date of Birth', hint: '09 Feb 2000', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Country of Origin'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _countryOfOriginController.text.isEmpty ? null : _countryOfOriginController.text, label: 'Country of Origin', hint: 'Select Country', countries: _countries, onChanged: (value) => setState(() => _countryOfOriginController.text = value ?? ''), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('City of Birth (Same As ID Card)'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _cityOfBirthController, label: 'City of Birth (Same As ID Card)', hint: 'Tebum', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Nationality / Current Citizenship'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _nationalityController.text.isEmpty ? null : _nationalityController.text, label: 'Nationality / Current Citizenship', hint: 'Select Nationality', countries: _countries, onChanged: (value) => setState(() => _nationalityController.text = value ?? ''), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Gender'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedGender, label: 'Gender', hint: 'Female', items: ['Male', 'Female'], onChanged: (value) => setState(() => _selectedGender = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Marital Status'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedMaritalStatus, label: 'Marital Status', hint: 'Single', items: ['Single', 'Married', 'Divorced', 'Widowed'], onChanged: (value) => setState(() => _selectedMaritalStatus = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Religion'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedReligion, label: 'Religion', hint: 'Islam', items: ['Islam', 'Christianity', 'Catholicism', 'Hinduism', 'Buddhism', 'Confucianism'], onChanged: (value) => setState(() => _selectedReligion = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Blood Type'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedBloodType, label: 'Blood Type', hint: 'B B+', items: ['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'], onChanged: (value) => setState(() => _selectedBloodType = value)),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Status'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(text: 'Active'), label: 'Status', hint: 'Active', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Reason'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(), label: 'Reason', hint: '', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Contract Status'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(), label: 'Contract Status', hint: '', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Employee ID'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(), label: 'Employee ID', hint: '', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Manning Agent'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _manningAgentController, label: 'Manning Agent', hint: _userManningAgent ?? 'PT. Pertamina Marine Solutions', enabled: false),
      ],
    );
  }

  Widget _buildAddressInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('Address Information'),
        const SizedBox(height: 16),
        FormComponents.buildSubSectionHeader('1. Permanent/Primary Address'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Address *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _addressController, label: 'Address', hint: 'Dsun Dliluk RT 003 RW 004 Ds NgulukKec Kabuagaten Tembono', maxLines: 3, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('City *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _cityController, label: 'City', hint: 'Tebum', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Post Code *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _postCodeController, label: 'Post Code', hint: '50392', keyboardType: TextInputType.number, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Country *'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _countryController.text.isEmpty ? null : _countryController.text, label: 'Country', hint: 'Select Country', countries: _countries, onChanged: (value) => setState(() => _countryController.text = value ?? ''), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Province *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _provinceController, label: 'Province', hint: 'Jawa Timur', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Home Tel (Without Leading Zero) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _telpNumberController, label: 'Home Tel (Without Leading Zero)', hint: '+62 (Indonesia) 8321661-9087', keyboardType: TextInputType.phone, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Nearest Airport *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nearestAirportController, label: 'Nearest Airport', hint: 'Bandara Juanda Surabaya', required: true),
        const SizedBox(height: 24),
        FormComponents.buildSubSectionHeader('2. Temporary/Alternative Address'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Address'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _tempAddressController, label: 'Address', hint: 'Address', maxLines: 3),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('City'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _tempCityController, label: 'City', hint: 'City'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Post Code'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _tempPostCodeController, label: 'Post Code', hint: 'Post Code', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Country'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _tempCountryController.text.isEmpty ? null : _tempCountryController.text, label: 'Country', hint: 'Select Country', countries: _countries, onChanged: (value) => setState(() => _tempCountryController.text = value ?? '')),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Province'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _tempProvinceController, label: 'Province', hint: 'Province'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Home Tel (Without Leading Zero)'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _tempTelpNumberController, label: 'Home Tel (Without Leading Zero)', hint: 'Home Tel', keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Nearest Airport'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _tempNearestAirportController, label: 'Nearest Airport', hint: 'Nearest Airport'),
      ],
    );
  }

  Widget _buildOtherInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('Other Informations'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Rank Applied For *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(text: _userRank ?? 'Third Officer'), label: 'Rank Applied For', hint: 'Third Officer', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Willing to Accept Lower Rank'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(), label: 'Willing to Accept Lower Rank', hint: '', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Available From *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(text: '01 Mar 2025'), label: 'Available From', hint: '01 Mar 2025', enabled: false),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Available Until *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(text: '01 Sep 2025'), label: 'Available Until', hint: '01 Sep 2025', enabled: false),
      ],
    );
  }

  Widget _buildMeasurementInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('Measurement Information'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Weight (kg) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _weightController, label: 'Weight (kg)', hint: '53', keyboardType: TextInputType.number, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Height (cm) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _heightController, label: 'Height (cm)', hint: '165', keyboardType: TextInputType.number, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Coverall Size *'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedCoverallSize, label: 'Coverall Size', hint: 'S, M, L, XL, XXL, 3XL, 4XL, 5XL, 6XL etc', items: ['S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL'], onChanged: (value) => setState(() => _selectedCoverallSize = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Safety Shoes Size *'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedSafetyShoesSize, label: 'Safety Shoes Size', hint: 'UK 5.5, S.5, etc UK 8.5, EU -d2', items: ['UK 5', 'UK 5.5', 'UK 6', 'UK 6.5', 'UK 7', 'UK 7.5', 'UK 8', 'UK 8.5', 'UK 9', 'UK 9.5', 'UK 10'], onChanged: (value) => setState(() => _selectedSafetyShoesSize = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Shirt Size *'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedShirtSize, label: 'Shirt Size', hint: 'S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL etc', items: ['S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL'], onChanged: (value) => setState(() => _selectedShirtSize = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Trousers Size *'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedTrousersSize, label: 'Trousers Size', hint: 'S, M, L, XL, 2XL, 3XL, 4XL, 5XL, 6XL etc', items: ['S', 'M', 'L', 'XL', 'XXL', '3XL', '4XL', '5XL', '6XL'], onChanged: (value) => setState(() => _selectedTrousersSize = value), required: true),
      ],
    );
  }

  Widget _buildNextOfKin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('Next of KIN'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Full Name (Same As ID Card) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokFullNameController, label: 'Full Name (Same As ID Card)', hint: 'Khumomo', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Gender *'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _nokSelectedGender, label: 'Gender', hint: 'Male', items: ['Male', 'Female'], onChanged: (value) => setState(() => _nokSelectedGender = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Relationship *'),
        const SizedBox(height: 16),
        FormComponents.buildDropdownField(value: _selectedNokRelationship, label: 'Relationship', hint: 'Parent', items: ['Parent', 'Spouse', 'Sibling', 'Child', 'Other'], onChanged: (value) => setState(() => _selectedNokRelationship = value), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Relationship Detail (If Choosing Other Relatives)'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokRelationshipOtherController, label: 'Relationship Detail', hint: 'Relationship Detail'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Nationality *'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _nokNationalityController.text.isEmpty ? null : _nokNationalityController.text, label: 'Nationality', hint: 'Select Nationality', countries: _countries, onChanged: (value) => setState(() => _nokNationalityController.text = value ?? ''), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('City *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokCityController, label: 'City', hint: 'Tebum', required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Post Code *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokPostCodeController, label: 'Post Code', hint: '63252', keyboardType: TextInputType.number, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Country *'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _nokCountryController.text.isEmpty ? null : _nokCountryController.text, label: 'Country', hint: 'Select Country', countries: _countries, onChanged: (value) => setState(() => _nokCountryController.text = value ?? ''), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Email *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokEmailController, label: 'Email', hint: 'Rio.Nikarja@gmail.com', keyboardType: TextInputType.emailAddress, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Home Tel (Without Leading Zero) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokTelpController, label: 'Home Tel (Without Leading Zero)', hint: '+62 (Indonesia)', keyboardType: TextInputType.phone, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Mobile No. (Without Leading Zero) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokMobileController, label: 'Mobile No. (Without Leading Zero)', hint: '+62 (Indonesia) 81229054263', keyboardType: TextInputType.phone, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Address *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _nokAddressController, label: 'Address', hint: 'Dsun Diluk RT 003 RW 004 Ds Ngalubuke Kabuagaten Tembono Kotacatan Tumbung', maxLines: 3, required: true),
      ],
    );
  }

  Widget _buildKTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('KTP'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Number (16 digits) *'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: _ktpNumberController, label: 'Number (16 digits)', hint: '3525080240300081', keyboardType: TextInputType.number, required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Issuing Country *'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: _ktpIssuingCountryController.text.isEmpty ? null : _ktpIssuingCountryController.text, label: 'Issuing Country', hint: 'Select Country', countries: _countries, onChanged: (value) => setState(() => _ktpIssuingCountryController.text = value ?? ''), required: true),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Attachment ( jpg/jpeg/png/pdf max 2 MB)'),
        const SizedBox(height: 16),
        FormComponents.buildDocumentUpload('Drop file here or click to upload', _ktpFile, _pickKTP),
      ],
    );
  }

  Widget _buildPersonalTax() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormComponents.buildMainSectionHeader('Personal Tax (Only If Requested)'),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Number (15-16 digits)'),
        const SizedBox(height: 16),
        FormComponents.buildTextField(controller: TextEditingController(), label: 'Number (15-16 digits)', hint: '608037329424903', keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Issuing Country'),
        const SizedBox(height: 16),
        FormComponents.buildCountryDropdownField(value: null, label: 'Issuing Country', hint: 'Select Country', countries: _countries, onChanged: (value) {}),
        const SizedBox(height: 16),
        FormComponents.buildSectionTitle('Attachment ( jpg/jpeg/png/pdf max 2 MB)'),
        const SizedBox(height: 16),
        FormComponents.buildDocumentUpload('Drop file here or click to upload', null, () {}),
      ],
    );
  }

  @override
  void dispose() {
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
    _nokFullNameController.dispose();
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
}