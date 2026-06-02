import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );
  static String get baseUrl {
    if (_apiBaseUrlOverride.isNotEmpty) return _apiBaseUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  static String? authToken;
  static int? currentUserId;
  static String? currentUserName;
  static String? currentUserEmail;
  static String? currentUserRole;
  static bool currentUserIsActive = true;
  static String? currentUserPhotoUrl;
  static String? currentUserFavoriteGenres;
  static String? currentUserPhone;
  static String? currentUserBio;
  static String? currentUserGender;

  static bool get isAdmin => currentUserRole == 'admin';
  static bool get isLoggedIn => authToken != null;

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
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
        body: json.encode({'email': email, 'password': password}),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        _setCurrentUser(data['data']['user'], data['data']['token']);
        return data;
      }

      throw Exception(
        _messageFromResponse(data, fallback: 'Email atau password salah.'),
      );
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      throw Exception(message.startsWith('Error Login') ? message : message);
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
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      final data = _decodeResponse(response);

      if (response.statusCode == 201) {
        _setCurrentUser(data['data']['user'], data['data']['token']);
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
        final data = _decodeResponse(response);
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
      }

      final data = _decodeResponse(response);
      throw Exception(
        _messageFromResponse(data, fallback: 'Gagal menambahkan review.'),
      );
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> deleteReview(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reviews/$id'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> updateReview(
    int id,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/reviews/$id'),
        headers: headers,
        body: json.encode(reviewData),
      );

      if (response.statusCode == 200) return true;

      final data = _decodeResponse(response);
      throw Exception(
        _messageFromResponse(data, fallback: 'Gagal memperbarui review.'),
      );
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<List<dynamic>> getMovies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/movies'));

      if (response.statusCode == 200) {
        final data = _decodeResponse(response);
        return data['data'];
      }

      throw Exception('Gagal mengambil data movie');
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> addMovie(
    Map<String, dynamic> movieData, {
    String? posterPath,
  }) async {
    try {
      if (posterPath != null && posterPath.isNotEmpty) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/movies'),
        );
        request.headers.addAll(multipartHeaders);
        request.fields.addAll(
          movieData.map((key, value) => MapEntry(key, value.toString())),
        );
        request.files.add(
          await http.MultipartFile.fromPath('poster_image', posterPath),
        );

        final response = await http.Response.fromStream(await request.send());
        if (response.statusCode == 201) return true;

        final data = _decodeResponse(response);
        throw Exception(
          _messageFromResponse(data, fallback: 'Gagal menambahkan movie.'),
        );
      }

      final response = await http.post(
        Uri.parse('$baseUrl/movies'),
        headers: headers,
        body: json.encode(movieData),
      );

      if (response.statusCode == 201) return true;

      final data = _decodeResponse(response);
      throw Exception(
        _messageFromResponse(data, fallback: 'Gagal menambahkan movie.'),
      );
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> updateMovie(
    int id,
    Map<String, dynamic> movieData, {
    String? posterPath,
  }) async {
    try {
      if (posterPath != null && posterPath.isNotEmpty) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/movies/$id'),
        );
        request.headers.addAll(multipartHeaders);
        request.fields['_method'] = 'PATCH';
        request.fields.addAll(
          movieData.map((key, value) => MapEntry(key, value.toString())),
        );
        request.files.add(
          await http.MultipartFile.fromPath('poster_image', posterPath),
        );

        final response = await http.Response.fromStream(await request.send());
        if (response.statusCode == 200) return true;

        final data = _decodeResponse(response);
        throw Exception(
          _messageFromResponse(data, fallback: 'Gagal memperbarui movie.'),
        );
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/movies/$id'),
        headers: headers,
        body: json.encode(movieData),
      );

      if (response.statusCode == 200) return true;

      final data = _decodeResponse(response);
      throw Exception(
        _messageFromResponse(data, fallback: 'Gagal memperbarui movie.'),
      );
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
        final data = _decodeResponse(response);
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

  static Future<bool> toggleUserStatus(int id, bool isActive) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/users/$id/status'),
        headers: headers,
        body: json.encode({'is_active': isActive}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static Future<bool> updateProfile({
    required String name,
    required String favoriteGenres,
    required String phone,
    required String bio,
    required String gender,
    String? photoPath,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile'),
      );
      request.headers.addAll(multipartHeaders);
      request.fields.addAll({
        'name': name,
        'favorite_genres': favoriteGenres,
        'phone': phone,
        'bio': bio,
        'gender': gender,
      });
      if (photoPath != null && photoPath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photoPath),
        );
      }

      final response = await http.Response.fromStream(await request.send());
      final data = _decodeResponse(response);

      if (response.statusCode == 200) {
        _setCurrentUser(data['data']['user'], authToken);
        return true;
      }

      throw Exception(
        _messageFromResponse(data, fallback: 'Profil gagal diperbarui'),
      );
    } catch (e) {
      throw Exception('Error Koneksi: $e');
    }
  }

  static void _setCurrentUser(dynamic user, String? token) {
    authToken = token;
    currentUserId = user['id'];
    currentUserName = user['name'];
    currentUserEmail = user['email'];
    currentUserRole = (user['role'] ?? 'user').toString().trim().toLowerCase();
    currentUserIsActive = user['is_active'] != false;
    currentUserPhotoUrl = normalizeMediaUrl(user['photo_url']);
    currentUserFavoriteGenres = user['favorite_genres'];
    currentUserPhone = user['phone'];
    currentUserBio = user['bio'];
    currentUserGender = user['gender'];
  }

  static String? normalizeMediaUrl(dynamic value) {
    final url = value?.toString();
    if (url == null || url.isEmpty) return null;
    final apiUri = Uri.parse(baseUrl);
    final mediaHost = '${apiUri.scheme}://${apiUri.host}:${apiUri.port}';
    return url
        .replaceFirst('http://127.0.0.1:8000', mediaHost)
        .replaceFirst('http://localhost:8000', mediaHost);
  }

  static Map<String, String> get multipartHeaders {
    return {
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Response server tidak sesuai format.');
    } on FormatException {
      final shortBody = response.body.replaceAll(RegExp(r'\s+'), ' ').trim();
      final preview = shortBody.length > 120
          ? '${shortBody.substring(0, 120)}...'
          : shortBody;
      throw Exception(
        'Server tidak mengirim JSON (HTTP ${response.statusCode}). '
        'Pastikan backend Laravel berjalan di $baseUrl. $preview',
      );
    }
  }

  static String _messageFromResponse(
    Map<String, dynamic> data, {
    required String fallback,
  }) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return (data['message'] ?? fallback).toString();
  }

  static void logout() {
    authToken = null;
    currentUserId = null;
    currentUserName = null;
    currentUserEmail = null;
    currentUserRole = null;
    currentUserIsActive = true;
    currentUserPhotoUrl = null;
    currentUserFavoriteGenres = null;
    currentUserPhone = null;
    currentUserBio = null;
    currentUserGender = null;
  }
}
