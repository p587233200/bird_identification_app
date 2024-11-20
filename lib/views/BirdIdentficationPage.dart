import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';

class BirdIdentificationPage extends StatefulWidget {
  const BirdIdentificationPage({super.key});

  @override
  State<BirdIdentificationPage> createState() => _BirdIdentificationPageState();
}

class _BirdIdentificationPageState extends State<BirdIdentificationPage> {
  File? _selectedImage; // 用於存儲選擇的圖片
  bool _isUploading = false; // 上傳進度狀態
  List<String> birdNames=[];
  List<String> imageFilenames=[];
  // List<String?> imageUrls = List.filled(imageFilenames.length, null);
  List<String?> imageUrls = [];

  var latitude = null;  // 可以是 null
  var longitude = null; // 可以是 null
  var observationDate = null; // 可以是 null

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery); // 開啟圖片庫
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // 保存圖片路徑
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未選擇任何圖片')),
      );
    }
  }

  // 上傳圖片到後端
  Future<void> _uploadImage() async {
    if (loggedInUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先登入，才能使用')),
      );
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇圖片')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    const String uploadUrl = 'http://10.0.2.2:5001/POST/identify_image'; // 替換為你的 API URL
    String? username = loggedInUsername; // 替換為真實的 username

    try {
      // 創建請求
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));

      // 添加其他表單欄位（這裡是 username）
      request.fields['username'] = username!;

      // 發送請求
      final response = await request.send();
      print(response);

      // 獲取回應
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('圖片上傳成功')),
        );

        // 解析伺服器回應的 JSON
        final Map<String, dynamic> responseData = jsonDecode(responseBody.body);
        // 提取 timestamp
        final String timestamp = responseData['timestamp'];

        // 輸出 timestamp
        print('Timestamp: $timestamp');

        print('伺服器回應: ${responseBody.body}');
        await _sendTimestampToServer(username, timestamp);


      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('圖片上傳失敗')),
        );
      }
    } catch (e) {
      print('圖片上傳失敗：$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('上傳失敗：$e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _sendTimestampToServer(String username, String timestamp) async {
    const String apiUrl = 'http://10.0.2.2:5001/SELECT/user_identification_record_by_timestamp'; // 新的 API 路徑

    try {
      // 創建 JSON 資料
      final Map<String, String> data = {
        'username': username,
        'timestamp': timestamp,
      };

      // 發送 POST 請求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data), // 將資料轉換為 JSON 格式
      );
      if (response.statusCode == 201) {
        print("user_identification_record_by_timestamp成功");

        print('user_identification_record_by_timestamp伺服器回應: ${response.body}');
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // 取出各個回應的參數
        birdNames = List<String>.from(responseData['bird_names'] ?? []);
        imageFilenames = await List<String>.from(responseData['image_filenames'] ?? []);
        latitude = responseData['latitude'];  // 可以是 null
        longitude = responseData['longitude']; // 可以是 null
        observationDate = responseData['observation_date']; // 可以是 null
        List<String?> newImageUrls = List<String?>.filled(imageFilenames.length, null);

        // 印出各個變數的值
        print('Bird Names: $birdNames');
        print('Image Filenames: $imageFilenames');
        print('Latitude: $latitude');
        print('Longitude: $longitude');
        print('Observation Date: $observationDate');

        for (int i = 0; i < imageFilenames.length; i++) {
          String? url=await _getImageUrl(imageFilenames[i]);
          newImageUrls[i] = url!;
        }
        setState(() {
          imageUrls = newImageUrls; // 更新圖片列表
          _isUploading = false; // 停止載入
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('user_identification_record_by_timestamp成功發送')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('user_identification_record_by_timestamp發送失敗')),
        );
      }
    } catch (e) {
      print("user_identification_record_by_timestamp資料失敗：$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('user_identification_record_by_timestamp資料失敗：$e')),
      );
    }
  }

  Future<String?> _getImageUrl(String filename) async {
    try {
      const String imageApiUrl = 'http://10.0.2.2:5001'; // 假設的圖片 API 路徑
      final response = await http.get(Uri.parse('$imageApiUrl/$filename'));

      if (response.statusCode == 200) {
        print('成功獲取圖片 URL: ${response.body}');
        var imageBytes = response.bodyBytes;
        String base64String = base64Encode(imageBytes);

        print('成功轉換圖片為 Base64: $base64String');
        // return 'data:image/png;base64,$base64String';
        return '$base64String';

        // print('成功轉換 Blob 為 URL: $url');
        // return url; // 假設伺服器直接回傳 URL
      } else {
        print('圖片請求失敗，狀態碼: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('圖片請求異常: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('鳥類識別'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 顯示選擇的圖片
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Text('尚未選擇圖片')),
                ),
              const SizedBox(height: 16),
              // 選擇圖片按鈕
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('選擇圖片'),
              ),
              const SizedBox(height: 16),
              // 上傳圖片按鈕
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadImage,
                icon: const Icon(Icons.cloud_upload),
                label: _isUploading
                    ? const Text('上傳中...')
                    : const Text('上傳圖片'),
              ),
              const SizedBox(height: 16),
              for (int i = 0; i < imageUrls.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      // 顯示圖片
                      Image.memory(
                        base64Decode(imageUrls[i]!.split(',').last),
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.contain,  // 保持等比例顯示
                      ),
        
                      // 顯示對應的文字（鳥的名稱）
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          birdNames.isNotEmpty && birdNames.length > i ? birdNames[i] : '無名稱', // 顯示鳥的名稱，如果沒有則顯示 '無名稱'
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
        
                      // 顯示其他參數
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '觀察時間: ${observationDate ?? "未知"}', // 顯示觀察時間
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // if (latitude != null && longitude != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '緯度: $latitude, 經度: $longitude', // 顯示緯度和經度
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
  }
}
