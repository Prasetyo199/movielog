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

Default API:

- Windows/Chrome: `http://localhost:8000/api`
- Android emulator: `http://10.0.2.2:8000/api`

Untuk HP fisik:

```bash
flutter run --dart-define=API_BASE_URL=http://IP-LAPTOP:8000/api
```

## Fitur Frontend

- Login dan register.
- Dashboard review film/series.
- Tambah, edit, dan hapus review user.
- Detail movie dengan daftar komentar user.
- Edit profil user.
- Admin console untuk kelola movie, user, dan review.

Dokumentasi lengkap project ada di README root repository.
