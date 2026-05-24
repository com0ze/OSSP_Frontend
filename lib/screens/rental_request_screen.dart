import 'package:flutter/material.dart';
import 'package:open_source_software/extensions/theme_extension.dart';
import 'package:open_source_software/managers/data_manager.dart';
import 'package:open_source_software/managers/location_manager.dart';
import 'package:open_source_software/managers/login_manager.dart';
import 'package:open_source_software/managers/test_data_manager.dart';
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
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _preferencesController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _itemNameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _preferencesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// 현재 위치(건물) 가져오기.
  ///
  /// LocationManager 가 지오펜싱으로 판별해 둔 현재 건물명을 입력칸에 채운다.
  /// 좌표 문자열 대신 '원흥관' 같은 건물명이 들어간다.
  void _fillCurrentBuilding() {
    final String? building = LocationManager().currentBuildingName;

    if (building == null) {
      // 아직 건물 판별 전이거나, 캠퍼스 건물 밖에 있는 경우
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '현재 건물을 찾지 못했습니다. 직접 입력해주세요.',
            style: TextStyle(color: context.onErrorColor),
          ),
          duration: const Duration(milliseconds: 800),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _locationController.text = building;
    });
  }

  void _submitRequest() {
    DataManager dataManager = TestDataManager();
    if (_formKey.currentState!.validate()) {
      // 1. 현재 로그인한 사용자 정보 가져오기
      final currentUser = LoginManager().currentUser;

      // 로그인이 안 된 상태(null)라면 처리 방지
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

      // 2. 입력된 데이터로 새로운 RentalItem 생성
      final newItem = RentalItem(
        // 고유 ID는 현재 시간의 밀리초를 문자열로 사용
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        // 카테고리는 우선 '기타'로 지정 (필요 시 선택 UI 추가 가능)
        product: Product(name: _itemNameController.text, category: '기타'),
        location: _locationController.text,
        price: int.parse(_priceController.text),
        description: _descriptionController.text,
        preferences: _preferencesController.text,
        requesterID: currentUser.id,
        createdAt: DateTime.now(),
      );

      // 3. DataManager에 데이터 추가 및 상태 변경 알림
      dataManager.addRentalItem(newItem);

      // 4. 성공 메시지 띄우기
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

      // 5. 폼 초기화
      _formKey.currentState!.reset();
      _titleController.clear();
      _itemNameController.clear();
      _locationController.clear();
      _priceController.clear();
      _preferencesController.clear();
      _descriptionController.clear();

      // (선택) 등록 완료 후 이전 화면(홈)으로 돌아가기
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('대여 요청하기'), centerTitle: true),
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
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
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
                if (value == null || value.isEmpty) {
                  return '물건명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '위치 (건물)',
                hintText: '예: 원흥관',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _fillCurrentBuilding,
                  tooltip: '현재 건물 가져오기',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '위치를 입력해주세요';
                }
                return null;
              },
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
                if (value == null || value.isEmpty) {
                  return '금액을 입력해주세요';
                }
                if (int.tryParse(value) == null) {
                  return '숫자만 입력해주세요';
                }
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
                if (value == null || value.isEmpty) {
                  return '설명을 입력해주세요';
                }
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