# Celenganku

Aplikasi tabungan pribadi berbasis Flutter yang ringan, privat, dan mudah digunakan. Aplikasi ini memungkinkan pengguna membuat dan memantau berbagai tujuan menabung dengan visualisasi progres yang menarik. Mendukung multi-device sync melalui Supabase Auth dan Database.

## Fitur Utama

- 🎯 **Manajemen Tujuan Tabungan**: Tambah/edit/hapus tujuan tabungan dengan judul, nominal target, deskripsi, dan tanggal target.
- 💰 **Transaksi Nabung**: Tambahkan catatan transaksi untuk tiap tujuan dan lihat riwayat transaksi lengkap.
- 📊 **Visualisasi Progress**: Progress bar dinamis dengan indikator persentase pencapaian.
- 👤 **Autentikasi Pengguna**: Daftar/Login menggunakan email dan password (via Supabase Auth).
- 🧠 **Database Realtime**: Menyimpan data tabungan dan transaksi secara cloud dengan auto-sync antar device.
- 🌓 **Dark Mode / Light Mode**: Switch tema terang & gelap secara manual.

## Cara Menjalankan Aplikasi

### Prasyarat
- Flutter SDK versi terbaru (3.19.0 atau lebih baru)
- Dart SDK versi terbaru
- Editor (Visual Studio Code, Android Studio, dll)
- Akun Supabase (untuk backend)

### Langkah-langkah
1. Clone repository ini
   ```
   git clone https://github.com/EdoMaulanaa/celenganku.git
   cd celenganku
   ```

2. Buat file .env di root project berdasarkan template .env.example
   ```
   cp .env.example .env
   ```
   
   Kemudian isi dengan kredensial Supabase Anda:
   ```
   SUPABASE_URL=your_supabase_url_here
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

3. Install dependencies
   ```
   flutter pub get
   ```

4. Jalankan aplikasi
   ```
   flutter run
   ```

## Keamanan

### Praktik Keamanan yang Diimplementasikan
1. **Variabel Lingkungan**: Semua kredensial sensitif disimpan dalam file .env yang tidak dimasukkan ke dalam version control.
2. **Row Level Security (RLS)**: Menggunakan Supabase RLS untuk memastikan pengguna hanya dapat mengakses data mereka sendiri.
3. **Validasi Input**: Semua input pengguna divalidasi di sisi client untuk mencegah data yang tidak valid.
4. **Secure Authentication**: Hanya menggunakan email dan password untuk autentikasi melalui Supabase Auth.
5. **Error Handling**: Menangani error dengan baik tanpa mengekspos detail implementasi yang sensitif.

### Setup Database Supabase
Aplikasi ini memerlukan setup database Supabase yang tepat. Pastikan Anda telah menjalankan SQL migration untuk membuat table dan RLS policies:

1. Buat project baru di Supabase
2. Buat tabel `goals` dan `transactions` dengan struktur yang sesuai
3. Aktifkan Row Level Security pada semua tabel
4. Buat RLS policies untuk memastikan pengguna hanya dapat mengakses data mereka sendiri
5. Setup Supabase Authentication untuk Email/Password (tanpa penyedia OAuth lainnya)

## Struktur Proyek

```
lib/
├── app/                      # Konfigurasi aplikasi
│   ├── constants/            # Konstanta aplikasi
│   ├── routes/               # Routing aplikasi
│   └── theme/                # Tema aplikasi
├── core/                     # Core functionality
│   ├── constants/            # Konstanta core (API keys, dll)
│   ├── models/               # Model data
│   ├── providers/            # State management (Riverpod)
│   ├── services/             # Services (Supabase, dll)
│   └── utils/                # Utility functions
├── features/                 # Fitur aplikasi (by feature)
│   ├── auth/                 # Autentikasi
│   │   ├── screens/          # UI screens
│   │   └── widgets/          # Widgets khusus fitur ini
│   ├── goals/                # Manajemen tujuan tabungan
│   │   ├── screens/
│   │   └── widgets/
│   ├── settings/             # Pengaturan aplikasi
│   │   ├── screens/
│   │   └── widgets/
│   └── transactions/         # Transaksi tabungan
│       ├── screens/
│       └── widgets/
├── shared/                   # Shared components
│   └── widgets/              # Reusable widgets
└── main.dart                 # Entry point
```

## Teknologi yang Digunakan

- **Framework**: Flutter
- **Backend**: Supabase (Auth & DB)
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences
- **Environment Variables**: flutter_dotenv

## Kontribusi

Kontribusi selalu terbuka. Silakan kirim pull request untuk perbaikan atau penambahan fitur.

## Lisensi

MIT License
