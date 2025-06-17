import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// 頭像選擇和管理服務
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  final ImagePicker _picker = ImagePicker();

  /// 預設頭像類型
  static const List<String> _avatarCategories = ['cat', 'dog', 'girl', 'man'];
  static const int _avatarsPerCategory = 10;

  /// 獲取所有預設頭像
  static List<String> getAllDefaultAvatars() {
    final List<String> avatars = [];
    for (String category in _avatarCategories) {
      for (int i = 0; i < _avatarsPerCategory; i++) {
        avatars.add('${category}_$i');
      }
    }
    return avatars;
  }

  /// 根據分類獲取頭像
  static List<String> getAvatarsByCategory(String category) {
    final List<String> avatars = [];
    for (int i = 0; i < _avatarsPerCategory; i++) {
      avatars.add('${category}_$i');
    }
    return avatars;
  }

  /// 獲取頭像資源路徑
  static String getAvatarPath(String avatarType) {
    return 'assets/images/$avatarType.png';
  }

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
      );
      
      if (image != null) {
        return await _cropImage(image.path);
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
        return await _cropImage(image.path);
      }
    } catch (e) {
      debugPrint('選擇照片失敗: $e');
    }
    return null;
  }

  /// 裁剪圖片
  Future<String?> _cropImage(String imagePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪頭像',
            toolbarColor: const Color(0xFF8B4513),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: '裁剪頭像',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return await _saveAvatarToAppDirectory(croppedFile.path);
      }
    } catch (e) {
      debugPrint('裁剪圖片失敗: $e');
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
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '選擇頭像',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await _avatarService.takePhoto();
                      if (result != null && context.mounted) {
                        Navigator.of(context).pop(result);
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('拍照'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await _avatarService.pickFromGallery();
                      if (result != null && context.mounted) {
                        Navigator.of(context).pop(result);
                      }
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('相簿'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 標籤欄
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: '全部'),
                Tab(text: '貓咪'),
                Tab(text: '狗狗'),
                Tab(text: '女生'),
                Tab(text: '男生'),
                Tab(text: '隨機'),
              ],
            ),
            
            // 內容區域
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvatarGrid(AvatarService.getAllDefaultAvatars()),
                  _buildAvatarGrid(AvatarService.getAvatarsByCategory('cat')),
                  _buildAvatarGrid(AvatarService.getAvatarsByCategory('dog')),
                  _buildAvatarGrid(AvatarService.getAvatarsByCategory('girl')),
                  _buildAvatarGrid(AvatarService.getAvatarsByCategory('man')),
                  _buildRandomAvatarSelector(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarGrid(List<String> avatars) {
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
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                AvatarService.getAvatarPath(avatarType),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.person, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRandomAvatarSelector() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shuffle, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('隨機選擇頭像', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final allAvatars = AvatarService.getAllDefaultAvatars();
              final randomAvatar = allAvatars[
                DateTime.now().millisecondsSinceEpoch % allAvatars.length
              ];
              Navigator.of(context).pop(randomAvatar);
            },
            child: const Text('隨機選擇'),
          ),
        ],
      ),
    );
  }
}
