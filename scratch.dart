import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Fetching from backend...');
  final baseUrl = 'http://192.168.29.248:3000/api';

  try {
    final curRes = await http.get(Uri.parse('$baseUrl/admin/curriculum'));
    print('/admin/curriculum status: ${curRes.statusCode}');
    if (curRes.statusCode == 200) {
      final data = jsonDecode(curRes.body) as List;
      for (var sub in data) {
        print('Subject: ${sub["name"]} (ID: ${sub["id"]})');
        final chapters = sub['chapters'] as List;
        for (var ch in chapters) {
          print('  Chapter: ${ch["name"]} (ID: ${ch["id"]})');
          final lessons = ch['lessons'] as List;
          for (var les in lessons) {
            print('    Lesson: ${les["title"]} (ID: ${les["id"]})');
          }
        }
      }
    }
  } catch (e) {
    print('Failed to fetch curriculum: $e');
    print(e);
  }
}
