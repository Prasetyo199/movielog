import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? authToken;
  static int? currentUserId;
  static String? currentUserName;
  static String? currentUserEmail;
  static String? currentUserRole;

  static bool get isAdmin => currentUserRole == 'admin';

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final user = data['data']['user'];
        authToken = data['data']['token'];
        currentUserId = user['id'];
        currentUserName = user['name'];
        currentUserEmail = user['email'];
        currentUserRole = (user['role'] ?? 'user')
            .toString()
            .trim()
            .toLowerCase();
        return data;
      }

      throw Exception(data['message'] ?? 'Login gagal');
    } catch (e) {
      throw Exception('Error Login: $e');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        final user = data['data']['user'];
        authToken = data['data']['token'];
        currentUserId = user['id'];
        currentUserName = user['name'];
        currentUserEmail = user['email'];
        currentUserRole = (user['role'] ?? 'user')
            .toString()
            .trim()
            .toLowerCase();
        return data;
      }

      throw Exception(data['message'] ?? 'Register gagal');
    } catch (e) {
      throw Exception('Error Register: $e');
    }
  }

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
        headers: headers,
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

  static Future<List<dynamic>> getMovies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/movies'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }

      throw Exception('Gagal mengambil data movie');
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> addMovie(Map<String, dynamic> movieData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/movies'),
        headers: headers,
        body: json.encode(movieData),
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> deleteMovie(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/movies/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }

      throw Exception('Gagal mengambil data user');
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static void logout() {
    authToken = null;
    currentUserId = null;
    currentUserName = null;
    currentUserEmail = null;
    currentUserRole = null;
  }
}
