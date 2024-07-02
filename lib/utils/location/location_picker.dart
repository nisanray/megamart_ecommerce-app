import 'package:flutter/material.dart';
import 'location_models.dart';
import 'location_service.dart';

class LocationPicker extends StatefulWidget {
  final ValueChanged<String?>? onAddressChanged;
  final Function(String?, String?, String?, String?)? onLocationChanged; // Callback to update location info

  LocationPicker({Key? key, this.onAddressChanged, this.onLocationChanged, String? initialDivision, String? initialDistrict, String? initialUpazila, String? initialArea}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final LocationService locationService = LocationService();

  List<Division> divisions = [];
  List<District> districts = [];
  List<Upazila> upazilas = [];

  List<District> filteredDistricts = [];
  List<Upazila> filteredUpazilas = [];

  String? selectedDivisionId;
  String? selectedDistrictId;
  String? selectedUpazilaId;
  String? selectedArea; // Add selected area

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    divisions = await locationService.loadDivisions();
    districts = await locationService.loadDistricts();
    upazilas = await locationService.loadUpazilas();
    setState(() {});
  }

  void onDivisionChanged(String? id) {
    setState(() {
      selectedDivisionId = id;
      selectedDistrictId = null;
      selectedUpazilaId = null;
      filteredDistricts = districts.where((district) => district.divisionId == id).toList();
      filteredUpazilas = [];
      selectedArea = null; // Reset selected area when division changes
      widget.onLocationChanged?.call(selectedDivisionName, selectedDistrictName, selectedUpazilaName, selectedArea);
      widget.onAddressChanged?.call(''); // Clear address when division changes
    });
  }

  void onDistrictChanged(String? id) {
    setState(() {
      selectedDistrictId = id;
      selectedUpazilaId = null;
      filteredUpazilas = upazilas.where((upazila) => upazila.districtId == id).toList();
      selectedArea = null; // Reset selected area when district changes
      widget.onLocationChanged?.call(selectedDivisionName, selectedDistrictName, selectedUpazilaName, selectedArea);
      // Update address based on district selection
      if (filteredDistricts.isNotEmpty) {
        District selectedDistrictObject =
        filteredDistricts.firstWhere((element) => element.id == id);
        widget.onAddressChanged?.call(selectedDistrictObject.name);
      }
    });
  }

  void onUpazilaChanged(String? id) {
    setState(() {
      selectedUpazilaId = id;
      selectedArea = null; // Reset selected area when upazila changes
      widget.onLocationChanged?.call(selectedDivisionName, selectedDistrictName, selectedUpazilaName, selectedArea);
      // Update address based on upazila selection
      if (filteredUpazilas.isNotEmpty) {
        Upazila selectedUpazilaObject =
        filteredUpazilas.firstWhere((element) => element.id == id);
        widget.onAddressChanged?.call(selectedUpazilaObject.name);
      }
    });
  }

  String get selectedDivisionName {
    if (selectedDivisionId != null) {
      return divisions.firstWhere((division) => division.id == selectedDivisionId).name;
    }
    return '';
  }

  String get selectedDistrictName {
    if (selectedDistrictId != null) {
      return districts.firstWhere((district) => district.id == selectedDistrictId).name;
    }
    return '';
  }

  String get selectedUpazilaName {
    if (selectedUpazilaId != null) {
      return upazilas.firstWhere((upazila) => upazila.id == selectedUpazilaId).name;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Select Division',
          value: selectedDivisionId,
          items: divisions.map<DropdownMenuItem<String>>((division) {
            return DropdownMenuItem<String>(
              value: division.id,
              child: Text(division.name),
            );
          }).toList(),
          onChanged: onDivisionChanged,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Select District',
          value: selectedDistrictId,
          items: filteredDistricts.map<DropdownMenuItem<String>>((district) {
            return DropdownMenuItem<String>(
              value: district.id,
              child: Text(district.name),
            );
          }).toList(),
          onChanged: onDistrictChanged,
        ),
        SizedBox(height: 16),
        _buildDropdown(
          label: 'Select Upazila',
          value: selectedUpazilaId,
          items: filteredUpazilas.map<DropdownMenuItem<String>>((upazila) {
            return DropdownMenuItem<String>(
              value: upazila.id,
              child: Text(upazila.name),
            );
          }).toList(),
          onChanged: onUpazilaChanged,
        ),
        SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(labelText: 'Enter Area'),
          onChanged: (value) {
            setState(() {
              selectedArea = value;
              widget.onLocationChanged?.call(selectedDivisionName, selectedDistrictName, selectedUpazilaName, selectedArea);
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            isDense: true,
            isExpanded: true,
            value: value,
            onChanged: onChanged,
            items: items,
          ),
        ),
      ],
    );
  }
}
