import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  // Fungsi untuk mengambil semua review dari Laravel (GET)
  static Future<List<dynamic>> getReviews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']; // Mengambil array data review dari json Laravel
      } else {
        throw Exception('Gagal mengambil data dari server');
      }
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }
  static Future<bool> addReview(Map<String, dynamic> reviewData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reviewData),
      );

      if (response.statusCode == 201) {
        return true; // Berhasil menyimpan
      } else {
        return false;
      }
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }
}