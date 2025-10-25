import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_dietweb/services/api_client.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dietweb/stores/goal_store.dart';

// ImageUploadSection Widget
class _ImageUploadSection extends StatefulWidget {
  final double screenWidth;
  const _ImageUploadSection({super.key, required this.screenWidth});

  @override
  State<_ImageUploadSection> createState() => _ImageUploadSectionState();
}

class _ImageUploadSectionState extends State<_ImageUploadSection> {
  Uint8List? _imageBytes;
  bool _isHovering = false;

  Future<void> _pickImage() async {
    final image = await ImagePickerWeb.getImageAsBytes();
    if (image != null) {
      setState(() {
        _imageBytes = image;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = widget.screenWidth < 600;
    final double containerHeight = isMobile ? 240 : 320; // RWD height

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: DragTarget<Uint8List>( // Corrected type
        onWillAcceptWithDetails: (details) {
          setState(() {
            _isHovering = true;
          });
          return true; // Accept any data that is dragged over
        },
        onLeave: (data) {
          setState(() {
            _isHovering = false;
          });
        },
        onAcceptWithDetails: (details) {
          setState(() {
            _imageBytes = details.data;
            _isHovering = false;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return InkWell(
            onTap: _pickImage,
            onHover: (hovering) {
              setState(() {
                _isHovering = hovering;
              });
            },
            borderRadius: BorderRadius.circular(16.0),
            child: DottedBorder(
              borderType: BorderType.RRect,
              radius: const Radius.circular(16),
              padding: EdgeInsets.zero,
              dashPattern: const [6, 6],
              color: _isHovering || candidateData.isNotEmpty
                  ? const Color(0xFF3B82F6) // 焦點色
                  : Colors.transparent,
              strokeWidth: 2,
              child: Container(
                height: containerHeight,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white, // 背景色改為白色
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: _imageBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                          Icons.cloud_upload_outlined, // 或 Icons.image_outlined
                          size: 48,
                          color: const Color(0xFF111827).withOpacity(0.75), // 次級文字顏色
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Drop or click to upload your meal photo',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827), // 文字主色
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'JPG/PNG • up to 5MB',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF111827).withOpacity(0.75), // 次級文字顏色
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _pickImage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF111827), // 主按鈕底色
                                    foregroundColor: Colors.white, // 白字
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // 輸入框圓角 10px
                                    ),
                                  ),
                                  child: const Text(
                                    'Replace',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: _removeImage,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF111827).withOpacity(0.75), // 次級文字顏色
                                    side: const BorderSide(color: Color(0xFFE5E7EB)), // 分隔線／邊框
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // 輸入框圓角 10px
                                    ),
                                  ),
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMeal;
  bool _isLoading = false;
  bool _isHoveringSubmitButton = false;

  // Controllers for numerical input fields
  final TextEditingController _wholeGrainsController = TextEditingController(text: '0');
  final TextEditingController _vegetablesController = TextEditingController(text: '0');
  final TextEditingController _proteinLowFatController = TextEditingController(text: '0');
  final TextEditingController _proteinMediumFatController = TextEditingController(text: '0');
  final TextEditingController _proteinHighFatController = TextEditingController(text: '0');
  final TextEditingController _proteinExtraHighFatController = TextEditingController(text: '0');
  final TextEditingController _junkFoodController = TextEditingController(text: '0');

  String? _dateErrorText;
  String? _wholeGrainsErrorText;
  String? _vegetablesErrorText;
  String? _proteinLowFatErrorText;
  String? _proteinMediumFatErrorText;
  String? _proteinHighFatErrorText;
  String? _proteinExtraHighFatErrorText;
  String? _junkFoodErrorText;

  // Protein total warning
  String? _proteinTotalWarning;

  @override
  void dispose() {
    _wholeGrainsController.dispose();
    _vegetablesController.dispose();
    _proteinLowFatController.dispose();
    _proteinMediumFatController.dispose();
    _proteinHighFatController.dispose();
    _proteinExtraHighFatController.dispose();
    _junkFoodController.dispose();
    super.dispose();
  }

  // Common input field styling
  InputDecoration _inputDecoration(String labelText, String hintText, {String? errorText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF111827),
      ),
      hintStyle: GoogleFonts.poppins(
        color: const Color(0xFF111827).withOpacity(0.75), // 次級文字：75% 不透明
      ),
      errorText: errorText,
      errorStyle: GoogleFonts.poppins(
        fontSize: 12,
        color: const Color(0xFFEF4444),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }

  // Common text field widget
  Widget _buildTextField({
    required String label,
    required String hintText,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    List<String>? dropdownItems,
    String? selectedDropdownValue,
    ValueChanged<String?>? onDropdownChanged,
    String? errorText, // Added errorText parameter
    FormFieldValidator<String>? validator, // Added validator parameter
    ValueChanged<String>? onChanged, // Added onChanged parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        if (dropdownItems != null)
          DropdownButtonFormField<String>(
            value: selectedDropdownValue,
            decoration: _inputDecoration('', hintText, errorText: errorText).copyWith(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: const Color(0xFF111827).withOpacity(0.75)), // 次級文字顏色
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xFF111827),
            ),
            items: dropdownItems.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onDropdownChanged,
            isExpanded: true,
            hint: Text(hintText, style: GoogleFonts.poppins(color: const Color(0xFF111827).withOpacity(0.75))), // 次級文字顏色
            validator: validator, // Pass validator to DropdownButtonFormField
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: GoogleFonts.poppins(
              fontSize: maxLines > 1 ? 14 : 16, // Font size 14px for multiline, 16px for single line
              height: maxLines > 1 ? 1.5 : null, // Line height 1.5 for multiline
              color: const Color(0xFF111827),
            ),
            decoration: _inputDecoration('', hintText, errorText: errorText).copyWith(
              contentPadding: maxLines > 1
                  ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)
                  : const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            cursorColor: const Color(0xFF3B82F6), // Cursor color
            validator: validator, // Pass validator to TextFormField
            onChanged: onChanged, // Pass onChanged to TextFormField
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = _getHorizontalPadding(screenWidth);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Navigation Bar
          Container(
            height: 64,
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Diet Web",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    _navButton(context, "Record Meal", isSelected: true),
                    const SizedBox(width: 24),
                    _navButton(context, "History", isSelected: false),
                  ],
                ),
              ],
            ),
          ),
          // Expanded section for background, overlay, and content
          Expanded(
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/back.png',
                    fit: BoxFit.cover,
                  ),
                ),
                // Semi-transparent overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.8), // 白色遮罩 rgba(255,255,255,0.8)
                  ),
                ),
                // Page Content
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _buildCard(context, screenWidth),
                              const SizedBox(height: 40),
                              _buildSubmitButton(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) {
      return 24.0; // Mobile
    } else if (screenWidth >= 600 && screenWidth < 1024) {
      return 48.0; // Tablet
    } else {
      return 72.0; // Desktop
    }
  }

  Widget _buildCard(BuildContext context, double screenWidth) {
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // 卡片圓角 16px
      ),
      elevation: 0, // Remove default elevation
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24.0 : 32.0), // Adjust padding based on screen size
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0), // 卡片圓角 16px
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15), // 陰影透明度 0.15
              offset: const Offset(0, 10),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Record Meal', // Card Title
              style: GoogleFonts.fredoka( // 標題字體 Fredoka
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w700, // Weight 700–800
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 24), // Space after title

            // Responsive layout for content within the card
            if (isMobile)
              Column(
                children: [
                  _ImageUploadSection(screenWidth: screenWidth), // Use the new widget
                  const SizedBox(height: 24), // Space between sections
                  _buildFormSection(screenWidth),
                ],
              )
            else if (isTablet)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 5,
                    child: _ImageUploadSection(screenWidth: screenWidth), // Use the new widget
                  ),
                  const SizedBox(width: 24), // Gap between columns
                  Flexible(
                    flex: 7,
                    child: _buildFormSection(screenWidth),
                  ),
                ],
              )
            else if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 6,
                    child: _ImageUploadSection(screenWidth: screenWidth), // Use the new widget
                  ),
                  const SizedBox(width: 32), // Gap between columns
                  Flexible(
                    flex: 6,
                    child: _buildFormSection(screenWidth),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    // This placeholder method is no longer needed as _ImageUploadSection is used directly.
    return Container();
  }

  Widget _buildFormSection(double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal',
          style: GoogleFonts.fredoka( // 標題字體 Fredoka
            color: const Color(0xFF111827),
            fontSize: screenWidth < 600 ? 28 : (screenWidth < 1024 ? 30 : 32), // RWD font size
            fontWeight: FontWeight.w800, // Weight 700–800
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 600;
            return Column(
              children: [
                // First Row: Date and Which Meal
                isMobile
                    ? Column(
                        children: [
                          _buildTextField(
                            label: 'Date',
                            hintText: 'Select date',
                            readOnly: true,
                            controller: TextEditingController(text: DateFormat('yyyy/MM/dd').format(_selectedDate)),
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(), // Disable future dates
                                builder: (BuildContext context, Widget? child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF3B82F6), // Header background color
                                        onPrimary: Colors.white, // Header text color
                                        onSurface: Color(0xFF111827), // Body text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xFF3B82F6), // Button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null && picked != _selectedDate) {
                                setState(() {
                                  _selectedDate = picked;
                                  _dateErrorText = null;
                                });
                              }
                            },
                            errorText: _dateErrorText,
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Which Meal',
                            hintText: 'Select a meal',
                            dropdownItems: ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
                            selectedDropdownValue: _selectedMeal,
                            onDropdownChanged: (String? newValue) {
                              setState(() {
                                _selectedMeal = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field is required.';
                              }
                              return null;
                            },
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Date',
                              hintText: 'Select date',
                              readOnly: true,
                              controller: TextEditingController(text: DateFormat('yyyy/MM/dd').format(_selectedDate)),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(), // Disable future dates
                                  builder: (BuildContext context, Widget? child) {
                                    return Theme(
                                      data: ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF3B82F6),
                                          onPrimary: Colors.white,
                                          onSurface: Color(0xFF111827),
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: const Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null && picked != _selectedDate) {
                                  setState(() {
                                    _selectedDate = picked;
                                    _dateErrorText = null;
                                  });
                                }
                              },
                              errorText: _dateErrorText,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              label: 'Which Meal',
                              hintText: 'Select a meal',
                              dropdownItems: ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
                              selectedDropdownValue: _selectedMeal,
                              onDropdownChanged: (String? newValue) {
                                setState(() {
                                  _selectedMeal = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field is required.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                // Second Row: Whole Grains and Vegetables
                isMobile
                    ? Column(
                        children: [
                          _buildTextField(
                            label: 'Whole Grains',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            controller: _wholeGrainsController,
                            validator: (value) => _numericValidator(value, 'Whole Grains'),
                            onChanged: (_) => _updateProteinTotalWarning(),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            label: 'Vegetables',
                            hintText: '0',
                            keyboardType: TextInputType.number,
                            controller: _vegetablesController,
                            validator: (value) => _numericValidator(value, 'Vegetables'),
                            onChanged: (_) => _updateProteinTotalWarning(),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'Whole Grains',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              controller: _wholeGrainsController,
                              validator: (value) => _numericValidator(value, 'Whole Grains'),
                              onChanged: (_) => _updateProteinTotalWarning(),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _buildTextField(
                              label: 'Vegetables',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              controller: _vegetablesController,
                              validator: (value) => _numericValidator(value, 'Vegetables'),
                              onChanged: (_) => _updateProteinTotalWarning(),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),
                // Third Row: Protein servings
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protein',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    isMobile
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Low-fat',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Med.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'High',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Extra High',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      label: '', // Label handled by separate Text widget
                                      hintText: '0',
                                      keyboardType: TextInputType.number,
                                      controller: _proteinLowFatController,
                                      validator: (value) => _numericValidator(value, 'Low-fat'),
                                      onChanged: (_) => _updateProteinTotalWarning(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTextField(
                                      label: '', // Label handled by separate Text widget
                                      hintText: '0',
                                      keyboardType: TextInputType.number,
                                      controller: _proteinMediumFatController,
                                      validator: (value) => _numericValidator(value, 'Medium-fat'),
                                      onChanged: (_) => _updateProteinTotalWarning(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTextField(
                                      label: '', // Label handled by separate Text widget
                                      hintText: '0',
                                      keyboardType: TextInputType.number,
                                      controller: _proteinHighFatController,
                                      validator: (value) => _numericValidator(value, 'High-fat'),
                                      onChanged: (_) => _updateProteinTotalWarning(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildTextField(
                                      label: '', // Label handled by separate Text widget
                                      hintText: '0',
                                      keyboardType: TextInputType.number,
                                      controller: _proteinExtraHighFatController,
                                      validator: (value) => _numericValidator(value, 'Extra-high-fat'),
                                      onChanged: (_) => _updateProteinTotalWarning(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Low-fat',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Med.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'High',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Extra High',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              GridView.count(
                                shrinkWrap: true,
                                crossAxisCount: constraints.maxWidth < 1024 ? 2 : 4, // 2 columns for tablet, 4 for desktop
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: constraints.maxWidth < 1024 ? (constraints.maxWidth / 2 - 24) / 100 : 1, // Adjust aspect ratio for better display
                                children: [
                                  _buildTextField(
                                    label: '', // Label handled by separate Text widget
                                    hintText: '0',
                                    keyboardType: TextInputType.number,
                                    controller: _proteinLowFatController,
                                    validator: (value) => _numericValidator(value, 'Low-fat'),
                                    onChanged: (_) => _updateProteinTotalWarning(),
                                  ),
                                  _buildTextField(
                                    label: '', // Label handled by separate Text widget
                                    hintText: '0',
                                    keyboardType: TextInputType.number,
                                    controller: _proteinMediumFatController,
                                    validator: (value) => _numericValidator(value, 'Medium-fat'),
                                    onChanged: (_) => _updateProteinTotalWarning(),
                                  ),
                                  _buildTextField(
                                    label: '', // Label handled by separate Text widget
                                    hintText: '0',
                                    keyboardType: TextInputType.number,
                                    controller: _proteinHighFatController,
                                    validator: (value) => _numericValidator(value, 'High-fat'),
                                    onChanged: (_) => _updateProteinTotalWarning(),
                                  ),
                                  _buildTextField(
                                    label: '', // Label handled by separate Text widget
                                    hintText: '0',
                                    keyboardType: TextInputType.number,
                                    controller: _proteinExtraHighFatController,
                                    validator: (value) => _numericValidator(value, 'Extra-high-fat'),
                                    onChanged: (_) => _updateProteinTotalWarning(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
                // Junk food field
                _buildTextField(
                  label: 'Junk food',
                  hintText: '0',
                  keyboardType: TextInputType.number,
                  controller: _junkFoodController,
                  validator: (value) => _numericValidator(value, 'Junk food', min: 0, max: 15),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        onHover: (value) {
          setState(() {
            _isHoveringSubmitButton = value;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return const Color.fromRGBO(17, 24, 39, 0.3);
              }
              if (states.contains(MaterialState.hovered)) {
                return const Color(0xFF111827).withOpacity(0.9); // 主按鈕底色 hover 狀態
              }
              return const Color(0xFF111827); // Deep grey
            },
          ),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          minimumSize: MaterialStateProperty.all<Size>(const Size(double.infinity, 56)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0), // 按鈕圓角 28px
            ),
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          overlayColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withOpacity(0.1); // Visual feedback for hover
              }
              return null;
            },
          ),
          mouseCursor: MaterialStateProperty.resolveWith<MouseCursor?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return SystemMouseCursors.forbidden;
              }
              if (states.contains(MaterialState.hovered)) {
                return SystemMouseCursors.click;
              }
              return SystemMouseCursors.basic;
            },
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('Save Meal'),
      ),
    );
  }

  String? _numericValidator(String? value, String fieldName, {int min = 0, int max = 15}) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    final int? parsedValue = int.tryParse(value);
    if (parsedValue == null) {
      return 'Please enter a valid integer.';
    }
    if (parsedValue < min || parsedValue > max) {
      return 'Value must be between $min and $max.';
    }
    return null;
  }

  void _updateProteinTotalWarning() {
    final int lowFat = int.tryParse(_proteinLowFatController.text) ?? 0;
    final int mediumFat = int.tryParse(_proteinMediumFatController.text) ?? 0;
    final int highFat = int.tryParse(_proteinHighFatController.text) ?? 0;
    final int extraHighFat = int.tryParse(_proteinExtraHighFatController.text) ?? 0;

    final int totalProtein = lowFat + mediumFat + highFat + extraHighFat;

    setState(() {
      if (totalProtein > 30) {
        _proteinTotalWarning = 'Protein total is unusually high.';
      } else {
        _proteinTotalWarning = null;
      }
    });
  }

  int _toInt(String s) => int.tryParse(s.trim()) ?? 0;

  Future<void> _submitForm() async {
    setState(() {
      // Date validation
      if (_selectedDate.isAfter(DateTime.now())) {
        _dateErrorText = 'Date cannot be in the future.';
      } else {
        _dateErrorText = null;
      }
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (_dateErrorText == null && _selectedMeal != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          await ApiClient.createRecord(
            {
              'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
              'meal': _selectedMeal!,
              'whole_grains': _toInt(_wholeGrainsController.text),
              'vegetables': _toInt(_vegetablesController.text),
              'protein_low': _toInt(_proteinLowFatController.text),
              'protein_med': _toInt(_proteinMediumFatController.text),
              'protein_high': _toInt(_proteinHighFatController.text),
              'protein_xhigh': _toInt(_proteinExtraHighFatController.text),
              'junk_food': _toInt(_junkFoodController.text),
              // 'note': null, // assuming no note controller for now
              // 'image_url': null, // assuming no image URL for now
            },
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved successfully!')),
          );
          // Clear form fields after successful submission
          setState(() {
            _selectedDate = DateTime.now();
            _selectedMeal = null;
            _wholeGrainsController.text = '0';
            _vegetablesController.text = '0';
            _proteinLowFatController.text = '0';
            _proteinMediumFatController.text = '0';
            _proteinHighFatController.text = '0';
            _proteinExtraHighFatController.text = '0';
            _junkFoodController.text = '0';
            _proteinTotalWarning = null;
          });
          // Optionally refresh Home page data
          if (mounted) {
            Provider.of<GoalStore>(context, listen: false).loadDays(
              from: DateTime.now().subtract(const Duration(days: 13)),
              to: DateTime.now(),
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Save failed: $e')),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields correctly.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please correct the errors in the form.')),
      );
    }
  }

  Widget _navButton(BuildContext context, String text, {bool isSelected = false}) {
    return TextButton(
      onPressed: () {
        // Handle navigation
        if (text == "Record Meal") {
          Navigator.pushReplacementNamed(context, '/'); // Navigate back to home page
        } else if (text == "History") {
          Navigator.pushNamed(context, '/history');
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: isSelected ? const Color(0xFF111827) : const Color(0xFF111827).withOpacity(0.75),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.grey.withOpacity(0.1);
            }
            return null;
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return const Color(0xFF111827);
            }
            return isSelected ? const Color(0xFF111827) : const Color(0xFF111827).withOpacity(0.75);
          },
        ),
        side: MaterialStateProperty.resolveWith<BorderSide?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.focused)) {
              return const BorderSide(color: Color(0xFF3B82F6), width: 2);
            }
            return BorderSide.none;
          },
        ),
      ),
      child: Text(text),
    );
  }
}