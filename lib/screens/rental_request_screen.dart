import 'package:flutter/material.dart';
import '/extensions/theme_extension.dart';
import '/managers/data_manager.dart';
import '/managers/login_manager.dart';
import '/models/product.dart';
import '/models/rental_item.dart';

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

  String? _selectedPlaceId;
  String? _placeError;
  final _placeMenuController = TextEditingController();

  @override
  void dispose() {
    _itemNameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _placeMenuController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    DataManager dataManager = DataManager();
    setState(
      () => _placeError = _selectedPlaceId == null ? '위치를 선택해주세요' : null,
    );
    if (_formKey.currentState!.validate() && _selectedPlaceId != null) {
      final currentUser = LoginManager().currentUser;

      final newItem = RentalItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: Product(name: _itemNameController.text, category: '기타'),
        placeID: _selectedPlaceId!,
        price: int.parse(_priceController.text),
        duration: int.parse(_durationController.text) * 60,
        description: _descriptionController.text,
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
      _itemNameController.clear();
      _priceController.clear();
      _durationController.clear();
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
            DropdownMenu<String>(
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
                      ? Icon(Icons.check, size: 18, color: context.primaryColor)
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
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '대여 시간 (분)',
                hintText: '예: 60',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer_outlined),
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
