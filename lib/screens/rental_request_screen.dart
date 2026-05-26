import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/location_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/models/product.dart';
import 'package:open_source_software/models/rental_item.dart';

class RentalRequestScreen extends StatefulWidget {
  const RentalRequestScreen({super.key});

  @override
  State<RentalRequestScreen> createState() => _RentalRequestScreenState();
}

class _RentalRequestScreenState extends State<RentalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedPlaceId;
  String? _placeError;
  final _placeMenuController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // GPS가 이미 건물을 감지한 상태라면 즉시 드롭다운에 반영한다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoFillIfDetected());
  }

  /// 화면 진입 시 GPS 감지 건물이 있으면 조용히 자동 선택한다 (스낵바 없음).
  void _autoFillIfDetected() {
    final String? buildingName = LocationManager().currentBuildingName;
    if (buildingName == null) return;

    final place = DataManager.places.firstWhere(
      (p) => p.name == buildingName,
      orElse: () => DataManager.places.first,
    );

    setState(() {
      _selectedPlaceId = place.id;
      _placeMenuController.text = place.name;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _priceController.dispose();
    _preferencesController.dispose();
    _descriptionController.dispose();
    _placeMenuController.dispose();
    super.dispose();
  }

  /// GPS로 감지된 현재 건물을 위치 드롭다운에 자동 선택한다.
  void _fillCurrentBuilding() {
    final String? buildingName = LocationManager().currentBuildingName;

    if (buildingName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '현재 건물을 찾지 못했습니다. 직접 선택해주세요.',
            style: TextStyle(color: context.onErrorColor),
          ),
          duration: const Duration(milliseconds: 800),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    final place = DataManager.places.firstWhere(
      (p) => p.name == buildingName,
      orElse: () => DataManager.places.first,
    );

    setState(() {
      _selectedPlaceId = place.id;
      _placeMenuController.text = place.name;
      _placeError = null;
    });
  }

  void _submitRequest() {
    DataManager dataManager = DataManager();
    setState(
      () => _placeError = _selectedPlaceId == null ? '위치를 선택해주세요' : null,
    );
    if (_formKey.currentState!.validate() && _selectedPlaceId != null) {
      final currentUser = LoginManager().currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '로그인이 필요한 서비스입니다.',
              style: TextStyle(color: context.onErrorColor),
            ),
            backgroundColor: context.errorColor,
          ),
        );
        return;
      }

      final newItem = RentalItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        product: Product(name: _itemNameController.text, category: '기타'),
        placeID: _selectedPlaceId!,
        price: int.parse(_priceController.text),
        description: _descriptionController.text,
        preferences: _preferencesController.text,
        requesterID: currentUser.id,
        createdAt: DateTime.now(),
      );

      dataManager.addRentalItem(newItem);

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
      _titleController.clear();
      _itemNameController.clear();
      _priceController.clear();
      _preferencesController.clear();
      _descriptionController.clear();
      _placeMenuController.clear();
      setState(() {
        _selectedPlaceId = null;
        _placeError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대여 요청하기'),
        centerTitle: true,
        backgroundColor: context.primaryColor,
        foregroundColor: context.onPrimaryColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text(
              '필요한 물건 정보를 입력해주세요',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '게시물 제목',
                hintText: '예: 급하게 드릴 필요해요',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '제목을 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: '원하는 물건',
                hintText: '예: 전동 드릴',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_basket),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '물건명을 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                    dropdownMenuEntries: DataManager.places.map((place) {
                      final isSelected = _selectedPlaceId == place.id;
                      return DropdownMenuEntry(
                        value: place.id,
                        label: place.name,
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
                ),
                IconButton(
                  tooltip: 'GPS로 현재 위치 자동 선택',
                  icon: const Icon(Icons.my_location),
                  onPressed: _fillCurrentBuilding,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '대여 금액 (원)',
                hintText: '예: 10000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '금액을 입력해주세요';
                if (int.tryParse(value) == null) return '숫자만 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '상세 설명',
                hintText: '물건에 대한 상세 설명을 입력해주세요',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return '설명을 입력해주세요';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _preferencesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: '희망 사항',
                hintText: '예: 오늘 저녁까지 필요합니다',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: context.onPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '요청 등록하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
