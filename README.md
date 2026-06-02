# MovieLog

MovieLog adalah aplikasi katalog dan review film/series. Aplikasi ini dibuat dengan Flutter untuk frontend dan Laravel untuk backend API. User bisa melihat katalog, membuat review, memberi rating, mengedit review pribadi, serta melihat review dari user lain. Admin dapat mengelola katalog movie, user, dan review.

## Fitur Utama

- Login dan register user.
- Mode guest untuk melihat review tanpa akun.
- Dashboard review film dan series.
- Review movie digabung berdasarkan judul, jenis, dan tahun agar tidak tampil double.
- Detail movie menampilkan semua komentar/review dari user.
- User dapat menambah, mengedit, dan menghapus review miliknya.
- Rating tampil konsisten dalam format satu desimal, misalnya `4.0/5`.
- Filter dan pencarian review berdasarkan judul, genre, reviewer, jenis, dan urutan.
- Profil user dengan nama, foto, gender, genre kesukaan, nomor telepon, dan biodata.
- Admin console untuk mengelola katalog movie, user, dan review.
- Admin dapat menambah, mengedit, dan menghapus movie.
- Admin dapat melihat komentar review yang diberikan user.
- Upload poster movie dan foto profil.

## Role Pengguna

### Guest

- Melihat daftar review.
- Melihat detail movie dan komentar user.
- Diarahkan untuk login/register ketika ingin membuat review.

### User

- Membuat review dari katalog movie yang disediakan admin.
- Memberi rating 1 sampai 5.
- Mengedit rating dan isi review.
- Menghapus review sendiri.
- Mengedit profil.

### Admin

- Melihat ringkasan jumlah movie, user, admin, dan review.
- Menambah movie/series untuk direview user.
- Mengedit data movie, termasuk genre, tahun, poster, dan deskripsi.
- Menghapus movie.
- Mengelola status user.
- Melihat dan menghapus review.
- Membaca komentar review user.

## Teknologi

### Frontend

- Flutter
- Dart
- `http` untuk request API
- `file_picker` untuk memilih gambar poster/foto

### Backend

- Laravel 10
- PHP 8.1+
- Laravel Sanctum untuk autentikasi token
- MySQL/MariaDB

## Struktur Project

```text
movielog/
+-- backend/     # Laravel API
+-- frontend/    # Flutter app
```

## Cara Menjalankan

### 1. Clone Repository

```bash
git clone <url-repository>
cd movielog
```

### 2. Setup Backend Laravel

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

Atur koneksi database di file `.env`, contoh:

```env
DB_DATABASE=movielog
DB_USERNAME=root
DB_PASSWORD=
```

Jalankan migration dan seeder:

```bash
php artisan migrate --seed
```

Jalankan server backend:

```bash
php artisan serve
```

Default API berjalan di:

```text
http://localhost:8000/api
```

### 3. Setup Frontend Flutter

```bash
cd ../frontend
flutter pub get
flutter run
```

Pastikan backend Laravel berjalan karena frontend memakai API:

```dart
http://localhost:8000/api
```

Konfigurasi API berada di:

```text
frontend/lib/services/api_services.dart
```

Secara default aplikasi otomatis memakai:

```text
Windows/Chrome : http://localhost:8000/api
Android emulator: http://10.0.2.2:8000/api
```

Untuk HP Android fisik, jalankan backend dengan:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Lalu jalankan Flutter dengan IP laptop:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Ganti `192.168.1.10` dengan IP laptop dari `ipconfig`.

## Akun Default

Seeder menyediakan akun contoh:

```text
Admin:
Email    : admin@movielog.test
Password : password

User:
Email    : user@movielog.test
Password : password
```

Jika password berbeda, cek atau ubah di:

```text
backend/database/seeders/DatabaseSeeder.php
```

## Endpoint API Utama

| Method | Endpoint | Keterangan |
| --- | --- | --- |
| POST | `/api/register` | Register user |
| POST | `/api/login` | Login user/admin |
| GET | `/api/movies` | Ambil katalog movie |
| POST | `/api/movies` | Tambah movie, admin |
| PATCH | `/api/movies/{id}` | Edit movie, admin |
| DELETE | `/api/movies/{id}` | Hapus movie, admin |
| GET | `/api/reviews` | Ambil semua review |
| POST | `/api/reviews` | Tambah review |
| PATCH | `/api/reviews/{id}` | Edit review |
| DELETE | `/api/reviews/{id}` | Hapus review |
| PATCH | `/api/profile` | Edit profil |
| GET | `/api/admin/users` | Kelola user, admin |

## Catatan Pengembangan

- Movie yang sama di dashboard user digabung agar tampilan tidak double.
- Komentar tetap ditampilkan satu per satu di detail movie.
- Genre review otomatis mengikuti genre movie dari katalog admin.
- Untuk menyimpan data profil lengkap, pastikan migration kolom profil user sudah dijalankan.
- Folder upload seperti `backend/public/uploads` berisi file hasil upload poster atau foto profil.

## Status

Project ini dibuat sebagai aplikasi review movie/series dengan fitur user dan admin yang sudah dapat digunakan secara lokal.
