# MovieLog Frontend

Frontend MovieLog dibuat menggunakan Flutter. Aplikasi ini terhubung ke backend Laravel di `http://localhost:8000/api`.

## Menjalankan Frontend

```bash
flutter pub get
flutter run
```

## Konfigurasi API

Base URL API dapat diubah di:

```text
lib/services/api_services.dart
```

## Fitur Frontend

- Login dan register.
- Dashboard review film/series.
- Tambah, edit, dan hapus review user.
- Detail movie dengan daftar komentar user.
- Edit profil user.
- Admin console untuk kelola movie, user, dan review.

Dokumentasi lengkap project ada di README root repository.
