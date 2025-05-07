## 🧾 Product Requirements Document (PRD)

### 📌 Nama Produk: *Celenganku*

### 🧠 Deskripsi Singkat:

*Celenganku* adalah aplikasi tabungan pribadi berbasis *Flutter, yang ringan, privat, dan mudah digunakan. Aplikasi ini memungkinkan pengguna membuat dan memantau berbagai tujuan menabung dengan visualisasi progres yang menarik. Versi ini mendukung **multi-device sync* melalui *Supabase Auth dan Database*.

---

### 🎯 Tujuan Produk:

* Membantu pengguna menabung dengan cara yang terstruktur berdasarkan tujuan spesifik.
* Menyediakan pengalaman menabung digital yang *modern, aman, dan mudah diakses dari berbagai perangkat*.
* Memberikan visualisasi progres tabungan agar pengguna semakin termotivasi.

---

### 👥 Target Pengguna:

* Pelajar, mahasiswa, pekerja, atau siapa saja yang ingin menabung dengan target.
* Pengguna yang mengutamakan *sinkronisasi cloud dan akses multiplatform*.
* Mereka yang mencari aplikasi keuangan yang *privat namun terhubung*.

---

### 🧩 Fitur Utama:

#### 1. 🎯 *Manajemen Tujuan Tabungan*

* Tambah/edit/hapus tujuan tabungan:

  * Judul
  * Nominal target
  * Deskripsi (opsional)
  * Tanggal target

#### 2. 💰 *Transaksi Nabung*

* Tambahkan catatan transaksi untuk tiap tujuan.
* Lihat riwayat transaksi lengkap berdasarkan tujuan.

#### 3. 📊 *Visualisasi Progress*

* Progress bar dinamis dengan indikator presentase pencapaian.
* Indikator jumlah tercapai dan sisa tabungan.

#### 4. 👤 *Autentikasi Pengguna*

* Daftar/Login menggunakan email dan password (via Supabase Auth).
* Logout & session handling.

#### 5. 🧠 *Database Realtime (Supabase)*

* Menyimpan data tabungan dan transaksi secara cloud.
* Auto-sync antar device.

#### 6. 🌓 *Dark Mode / Light Mode*

* Switch tema terang & gelap secara manual atau otomatis.

#### 7. 📱 *Mobile-first UX*

* UI/UX fokus pada kenyamanan penggunaan di layar ponsel.
* Responsive dan touch-friendly.

---

### 🛠 Teknologi yang Digunakan:

| Kebutuhan             | Teknologi                                  |
| --------------------- | ------------------------------------------ |
| Framework             | Flutter                                    |
| Backend               | Supabase (Auth & DB)                       |
| State Management      | Riverpod / Provider                        |
| UI Kit                | Flutter + Tailwind-style (Custom)          |
| Local Storage (cache) | Hive / SharedPreferences                   |
| Deployment            | Android / iOS / Web (Flutter Web optional) |

---

### 🧱 Struktur Navigasi:

* **Home (/)** — Daftar semua tujuan tabungan
* **Detail Goal (/goal/:id)** — Rincian tabungan + transaksi
* **Login/Register (/login)** — Autentikasi user
* **Settings (/settings)** — Tema, logout, dll.

---

### 🧪 MVP Scope:

* Autentikasi pengguna (register/login/logout)
* CRUD tujuan tabungan
* Tambah & lihat transaksi per tujuan
* Visualisasi progres tabungan
* Dark mode / light mode
* Supabase integration working
* UI mobile-friendly

---

### 🪜 Roadmap Tambahan (Post-MVP):

* Notifikasi client-side untuk rutin nabung
* Pencapaian atau badge ketika milestone tercapai
* Export data ke CSV/JSON
* Support Flutter Web & PWA
* Backup & Restore tambahan
* Kolaborasi (berbagi tabungan dengan teman/keluarga)