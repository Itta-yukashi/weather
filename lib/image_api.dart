import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PixabayService {
  static Future<List<Map<String, dynamic>>> getInstagramData(int tag) async {
    try {
      var apiUrl =
          "https://graph.facebook.com/v18.0/$tag/top_media?fields=media_url%2Cmedia_type%2Cchildren%7Bmedia_url%2Cmedia_type%7D&limit=18&access_token=EAAVZBohuUl9UBO9QCIM5PYMJ6thJjKnZA44ULz57cAGqdGPUxBh1ZAy4AnzCqtoQwEWq6FRbs0QHBFbZCcNOd3E0c1pEESkbPbZB9IXuBhKD3hRK3RTKVYHgXu2Hft9dqKZAIqGi0rlMco7dNSkcQtv8EoRmJaJwkH2YLNQXqhiwJNbgv2EHxyBACdHVehqwZBe&user_id=17841447989897674";

      var result = await http.get(Uri.parse(apiUrl));
      String responseString = utf8.decode(result.bodyBytes);
      var data = jsonDecode(responseString);

      if (result.statusCode == 200) {
        if (data is Map && data.containsKey("data") && data["data"] is List) {
          return List<Map<String, dynamic>>.from(data["data"]).where((item) {
            if (item.containsKey("media_url")) {
              return true; // 単一のメディアエントリ
            } else if (item.containsKey("children") &&
                item["children"].containsKey("data") &&
                item["children"]["data"] is List) {
              return true; // 子要素を持つエントリ
            }
            return false;
          }).toList();
        }
      }
    } catch (e) {
      throw Exception('データの取得に失敗しました');
    }

    return [];
  }
}

class InstagramGrid extends StatelessWidget {
  final List<Map<String, dynamic>> datas;

  const InstagramGrid({super.key, required this.datas});

  @override
  Widget build(BuildContext context) {
    // VIDEOのメディアタイプを持つエントリをフィルタリング
    var filteredDatas = datas.where((data) => data["media_type"] != "VIDEO").toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: filteredDatas.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> data = filteredDatas[index];

        if (data.containsKey("media_url")) {
          // 単一のメディアエントリ
          return _buildMediaWidget(context, data["media_url"]);
        } else if (data.containsKey("children") &&
            data["children"].containsKey("data") &&
            data["children"]["data"] is List) {
          // 子要素を持つエントリ
          List<Map<String, dynamic>> childrenData =
              List<Map<String, dynamic>>.from(data["children"]["data"]);

          return _buildMediaWidget(context, childrenData.first["media_url"]);
        }

        return Container();
      },
    );
  }

  Widget _buildMediaWidget(BuildContext context, String imageUrl) {
    return InkWell(
      onTap: () {
        _showImageDialog(context, imageUrl);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            margin: const EdgeInsets.all(1.0),
            color: Colors.grey,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InkWell(
          onTap: () {
            // 画像をタップしたときの処理

            Navigator.pop(context); // ダイアログを閉じる
          },
          child: Image.network(
            imageUrl,
            errorBuilder: (context, error, stackTrace) {
              // エラー時の処理
              print("画像の読み込みエラー: $error");
              return Center(child: Text("画像の読み込みエラー"));
            },
          ),
        ),
      ),
    );
  }
}
