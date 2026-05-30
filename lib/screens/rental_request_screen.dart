import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/location_manager.dart';
import '/models/product.dart';
import '/widgets/location_refresh_button.dart';

class RentalRequestScreen extends StatefulWidget {
  const RentalRequestScreen({super.key});

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isPhase2 = false;
  String? _selectedPlaceId;
  String? _placeError;
  final _placeMenuController = TextEditingController();

  // 이미지 로고로 전환하려면 true로 변경
  static const _useAssetLogo = false;
  static const _logoAssetPath = 'assets/logo.png';

  // 로고(160) + SizedBox(8) + 앱이름 텍스트(~28) + SizedBox(20) + 여유
  static const _logoSectionHeight = 220.0;

  static const _frequentItems = [
    ('📟', '공학용 계산기'),
    ('🥼', '실험복'),
    ('✏️', '필기구'),
    ('☂️', '우산'),
    ('🔌', '충전기'),
    ('🔋', '보조배터리'),
    ('📏', '자'),
    ('📐', '삼각자'),
    ('🖊️', '볼펜'),
    ('📎', '클립'),
    ('📌', '압정'),
    ('🗂️', '파일 홀더'),
    ('📦', '택배 박스'),
    ('🧲', '자석'),
    ('🔦', '손전등'),
    ('⌚', '스톱워치'),
  ];

  @override
  void initState() {
    super.initState();
    _itemNameController.addListener(_onItemNameChanged);
    final currentBuilding = LocationManager().currentBuildingName;
    if (currentBuilding != null) {
      _selectedPlaceId = currentBuilding;
      _placeMenuController.text = currentBuilding;
    }
  }

  void _onItemNameChanged() {
    if (_isPhase2 && _itemNameController.text.isEmpty) {
      setState(() => _isPhase2 = false);
    }
  }

  @override
  void dispose() {
    _itemNameController.removeListener(_onItemNameChanged);
    _itemNameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _placeMenuController.dispose();
    super.dispose();
  }

  InputDecoration _roundedDecoration({
    required BuildContext context,
    String? label,
    String? hint,
    Widget? prefixIcon,
    String? suffixText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      alignLabelWithHint: alignLabelWithHint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: context.primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildLogo(BuildContext context) {
    return _useAssetLogo
        ? Image.asset(_logoAssetPath, height: 160)
        : Icon(Icons.school_rounded, size: 160, color: context.primaryColor);
  }

  void _goToPhase2(String itemName) {
    if (itemName.isEmpty) return;
    setState(() => _isPhase2 = true);
  }

  void _submitRequest() async {
    DataManager dataManager = DataManager();
    setState(
      () => _placeError = _selectedPlaceId == null ? '위치를 선택해주세요' : null,
    );
    if (_formKey.currentState!.validate() && _selectedPlaceId != null) {
      await dataManager.addRentalItem(
        product: Product(name: _itemNameController.text, category: "none"),
        placeId: _selectedPlaceId!,
        price: int.parse(_priceController.text),
        duration: int.parse(_durationController.text) * 60,
        description: _descriptionController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 500),
          content: Text(
            '대여 요청이 등록되었습니다',
            style: TextStyle(color: context.onGoodColor),
          ),
          backgroundColor: context.goodColor,
        ),
      );

      _formKey.currentState!.reset();
      _itemNameController.clear();
      _priceController.clear();
      _durationController.clear();
      _descriptionController.clear();
      _placeMenuController.clear();
      setState(() {
        _isPhase2 = false;
        _selectedPlaceId = null;
        _placeError = null;
      });
    }
  }

  Widget _buildFrequentItemsSection() {
    return Column(
      key: const ValueKey('phase1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '자주 찾는 물건',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: _frequentItems.map((item) {
            final (emoji, name) = item;
            return GestureDetector(
              onTap: () {
                _itemNameController.text = name;
                _itemNameController.selection = TextSelection.fromPosition(
                  TextPosition(offset: name.length),
                );
                _goToPhase2(name);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 22)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '자주 찾음',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPhase2Form() {
    return Column(
      key: const ValueKey('phase2'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        const Text(
          '대여하고 싶은 위치를 입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: LocationManager(),
          builder: (context, _) {
            return Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: context.primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              child: DropdownMenu<String>(
                expandedInsets: EdgeInsets.zero,
                controller: _placeMenuController,
                initialSelection: _selectedPlaceId,
                label: const Text('위치'),
                leadingIcon: const Icon(Icons.location_on),
                hintText: '장소를 선택해주세요',
                errorText: _placeError,
                menuHeight: 260,
                enableFilter: false,
                requestFocusOnTap: false,
                menuStyle: MenuStyle(
                  elevation: const WidgetStatePropertyAll(6),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
                dropdownMenuEntries: LocationManager().buildingNames.map((
                  name,
                ) {
                  final isSelected = _selectedPlaceId == name;
                  return DropdownMenuEntry(
                    value: name,
                    label: name,
                    leadingIcon: isSelected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: context.primaryColor,
                          )
                        : const SizedBox(width: 18),
                    style: MenuItemButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  );
                }).toList(),
                onSelected: (value) => setState(() {
                  _selectedPlaceId = value;
                  _placeError = null;
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '지불할 금액을 입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: _roundedDecoration(
            context: context,
            label: '대여 금액 (원)',
            hint: '예: 10000',
            prefixIcon: const Icon(Icons.attach_money),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '금액을 입력해주세요';
            if (int.tryParse(value) == null) return '숫자만 입력해주세요';
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '대여하고 싶은 시간을 입력해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: _roundedDecoration(
            context: context,
            label: '대여 시간',
            hint: '예: 60',
            prefixIcon: const Icon(Icons.timer_outlined),
            suffixText: '분',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '대여 시간을 입력해주세요';
            final n = int.tryParse(value);
            if (n == null || n <= 0) return '1 이상의 숫자를 입력해주세요';
            return null;
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '빌려줄 사람에게 설명해주세요',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: _roundedDecoration(
            context: context,
            label: '상세 설명',
            hint: '물건에 대한 상세 설명을 입력해주세요',
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return '설명을 입력해주세요';
            return null;
          },
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submitRequest,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryColor,
            foregroundColor: context.onPrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            '요청 등록하기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [LocationRefreshButton(), SizedBox(width: 8)],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 고정 헤더 (스크롤 안 됨)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 로고 + 앱이름: 높이 축소 + 페이드 아웃
                  ClipRect(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: _isPhase2 ? 0 : _logoSectionHeight,
                      child: OverflowBox(
                        maxHeight: _logoSectionHeight,
                        alignment: Alignment.topCenter,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isPhase2 ? 0.0 : 1.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildLogo(context),
                              const SizedBox(height: 8),
                              Text(
                                '빌릿 Villit',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: context.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '필요한 물건을 찾아보세요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _itemNameController,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: _goToPhase2,
                    decoration: _roundedDecoration(
                      context: context,
                      hint: '무엇을 빌리고 싶나요?',
                      prefixIcon: const Icon(Icons.search),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '물건명을 입력해주세요';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            // 스크롤 영역: AnimatedCrossFade로 그리드 ↔ 폼 전환
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 500),
                  firstCurve: Curves.easeIn,
                  secondCurve: Curves.easeOut,
                  sizeCurve: Curves.easeInOut,
                  crossFadeState: _isPhase2
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _buildFrequentItemsSection(),
                  secondChild: _buildPhase2Form(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
