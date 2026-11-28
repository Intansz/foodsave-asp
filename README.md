# FoodSave (Tugas Akhir Arsitektur Sistem Perusahaan, P13)

FoodSave adalah platform web penjualan makanan layak konsumsi berlebih dari UMKM kuliner di sekitar
Universitas Jambi (Mendalo). Mitra mengunggah produk surplus berdiskon, konsumen mencari dan memesan,
lalu mengambil makanan dan membayar langsung ke mitra.

Repository ini adalah fondasi aplikasi untuk P13 (Architecture Freeze & Desain Sistem). Desainnya mengikuti
laporan P13 Kelompok 4 IP 4 (ERD, use case, dan matriks ketelusuran). Repository ini terpisah dari
repository produksi FoodSave PMW (foodsave.id).

## Status

Fondasi: pola MVC, struktur folder, repo dengan branch, serta login dan role (Konsumen, Mitra, Admin).
Fitur lain (katalog, produk, pemesanan, verifikasi mitra) dikerjakan pada branch `feature/*` berikutnya.

## Teknologi

| Aspek | Pilihan |
|---|---|
| Framework | Laravel 12 (PHP 8.2+) |
| Pola | MVC (Model, View/Blade, Controller) |
| Frontend | Blade + Vite |
| Autentikasi | Laravel Breeze (Blade) |
| Role | Tabel `roles` + kolom `role_id` pada `users`, dibatasi `RoleMiddleware` |
| Basis data | MySQL |

## Prasyarat

- PHP 8.2 atau lebih baru (XAMPP)
- Composer
- Node.js dan npm
- MySQL (XAMPP)
- Git

## Instalasi

```bash
git clone https://github.com/Intansz/foodsave-asp.git
cd foodsave-asp
git checkout feature/auth-role
composer install
npm install
```

> Catatan: selama pull request `feature/auth-role` belum digabung, pakai branch `feature/auth-role`
> seperti di atas. Setelah digabung, ganti dengan `git checkout dev`.

Buat berkas environment (di PowerShell):

```powershell
Copy-Item .env.example .env
php artisan key:generate
```

Nyalakan **Apache** dan **MySQL** di XAMPP, lalu buat database kosong bernama `foodsave_asp`
(lewat phpMyAdmin, collation `utf8mb4_unicode_ci`). Pastikan `.env` berisi:

```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=foodsave_asp
DB_USERNAME=root
DB_PASSWORD=
```

Jalankan migrasi dan data awal (role + akun uji), lalu bangun aset:

```bash
php artisan migrate:fresh --seed
npm run build
```

## Menjalankan

```bash
php artisan serve
```

Buka http://127.0.0.1:8000. Untuk pengembangan tampilan, jalankan `npm run dev` di terminal lain.

## Akun uji

Akun ini hanya untuk pengembangan lokal. Jangan memakai kata sandi asli.

| Role | Email | Kata sandi | Halaman setelah login |
|---|---|---|---|
| Konsumen | konsumen@foodsave.test | FoodSaveUji2026 | /konsumen |
| Mitra | mitra@foodsave.test | FoodSaveUji2026 | /mitra |
| Admin | admin@foodsave.test | FoodSaveUji2026 | /admin |

Membuka halaman role lain (misalnya konsumen membuka `/admin`) menghasilkan galat 403.

## Struktur folder (ringkas)

| Folder | Fungsi |
|---|---|
| `app/Models` | Model Eloquent (User, Role, dst.) |
| `app/Http/Controllers` | Controller (termasuk autentikasi Breeze) |
| `app/Http/Middleware` | `RoleMiddleware`, pembatas akses per role |
| `app/Services` | Logika bisnis (mis. pengamanan stok pada pemesanan) |
| `resources/views` | Tampilan Blade, dikelompokkan per role |
| `routes` | `web.php` dan `auth.php` |
| `database/migrations` | Skema tabel |
| `database/seeders` | Role dan akun uji |

## Alur kerja Git

- `main`: versi stabil, tidak boleh commit langsung.
- `dev`: integrasi semua fitur.
- `feature/[nama-fitur]`: satu fitur satu branch, dibuat dari `dev`, digabung ke `dev` lewat pull request.
- Pesan commit memakai awalan `feat:`, `fix:`, `docs:`, atau `chore:`.

## Kendala yang sering muncul

| Pesan | Penyebab dan solusi |
|---|---|
| `SQLSTATE[HY000] [2002]` | MySQL belum menyala. Start MySQL di XAMPP. |
| `Unknown database 'foodsave_asp'` | Database belum dibuat di phpMyAdmin. |
| `Vite manifest not found` | Jalankan `npm run build` (atau `npm run dev`). |
| Perubahan `.env` tidak terbaca | Jalankan `php artisan config:clear`. |

## Keamanan

Berkas `.env` tidak boleh di-commit (sudah diabaikan oleh `.gitignore`). Simpan pengaturan contoh
hanya di `.env.example`, tanpa kata sandi asli.
