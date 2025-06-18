import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'avatar/avatar_generator.dart';
import 'avatar/avatar_storage.dart';

/// 頭像選擇和管理服務 - 重構版
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final ImagePicker _picker = ImagePicker();

  /// 獲取所有預設頭像 (委託給 AvatarGenerator)
  static List<String> getAllDefaultAvatars() => AvatarGenerator.getAllDefaultAvatars();

  /// 根據分類獲取頭像 (委託給 AvatarGenerator)
  static List<String> getAvatarsByCategory(String category) => AvatarGenerator.getAvatarsByCategory(category);

  /// 獲取頭像資源路徑 (委託給 AvatarGenerator)
  static String getAvatarPath(String avatarType) => AvatarGenerator.getAvatarPath(avatarType);

  /// 保存用戶頭像 (委託給 AvatarStorage)
  static Future<bool> saveUserAvatar(String avatarPath) => AvatarStorage.saveUserAvatar(avatarPath);

  /// 獲取用戶頭像 (委託給 AvatarStorage)
  static Future<String?> getUserAvatar() => AvatarStorage.getUserAvatar();

  /// 清除用戶頭像 (委託給 AvatarStorage)
  static Future<bool> clearUserAvatar() => AvatarStorage.clearUserAvatar();

  /// 檢查是否有頭像 (委託給 AvatarStorage)
  static Future<bool> hasUserAvatar() => AvatarStorage.hasUserAvatar();

  /// 顯示頭像選擇對話框
  Future<String?> showAvatarPicker(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => const AvatarPickerDialog(),
    );
  }

  /// 從相機拍照
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      
      if (image != null) {
        final croppedPath = await _cropImage(image.path);
        await _cleanupTempFile(image.path);
        return croppedPath;
      }
    } catch (e) {
      debugPrint('拍照失敗: $e');
    }
    return null;
  }

  /// 從相簿選擇
  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final croppedPath = await _cropImage(image.path);
        await _cleanupTempFile(image.path);
        return croppedPath;
      }
    } catch (e) {
      debugPrint('選擇照片失敗: $e');
      rethrow;
    }
    return null;
  }

  /// 裁剪圖片
  Future<String?> _cropImage(String imagePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        maxWidth: 512,
        maxHeight: 512,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪頭像',
            toolbarColor: const Color(0xFF2196F3),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF1976D2),
            backgroundColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF2196F3),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
            cropGridRowCount: 3,
            cropGridColumnCount: 3,
          ),
          IOSUiSettings(
            title: '裁剪頭像',
            doneButtonTitle: '完成',
            cancelButtonTitle: '取消',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return await _saveAvatarToAppDirectory(croppedFile.path);
      }
    } catch (e) {
      debugPrint('裁剪圖片失敗: $e');
      rethrow;
    }
    return null;
  }

  /// 將頭像保存到應用目錄
  Future<String> _saveAvatarToAppDirectory(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarDir = Directory(p.join(directory.path, 'avatars'));
    
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = p.join(avatarDir.path, fileName);
    
    final File imageFile = File(imagePath);
    await imageFile.copy(newPath);
    
    return newPath;
  }

  /// 刪除自定義頭像
  Future<void> deleteCustomAvatar(String? avatarPath) async {
    if (avatarPath != null && avatarPath.isNotEmpty) {
      try {
        final file = File(avatarPath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('刪除頭像失敗: $e');
      }
    }
  }

  /// 清理臨時文件
  Future<void> _cleanupTempFile(String filePath) async {
    try {
      await File(filePath).delete();
    } catch (e) {
      debugPrint('刪除臨時文件失敗: $e');
    }
  }
}

/// 頭像選擇對話框
class AvatarPickerDialog extends StatefulWidget {
  const AvatarPickerDialog({super.key});

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AvatarService _avatarService = AvatarService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 500,
        width: 350,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '選擇頭像',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '預設'),
                Tab(text: '相機'),
                Tab(text: '相簿'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDefaultAvatarsTab(),
                  _buildCameraTab(),
                  _buildGalleryTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatarsTab() {
    final avatars = AvatarService.getAllDefaultAvatars();
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatarType = avatars[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(avatarType),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                AvatarService.getAvatarPath(avatarType),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraTab() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final avatarPath = await _avatarService.takePhoto();
          if (avatarPath != null && mounted) {
            Navigator.of(context).pop(avatarPath);
          }
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('拍照'),
      ),
    );
  }

  Widget _buildGalleryTab() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final avatarPath = await _avatarService.pickFromGallery();
          if (avatarPath != null && mounted) {
            Navigator.of(context).pop(avatarPath);
          }
        },
        icon: const Icon(Icons.photo_library),
        label: const Text('選擇照片'),
      ),
    );
  }
}
