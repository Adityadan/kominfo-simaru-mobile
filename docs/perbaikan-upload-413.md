# Perbaikan unggah PDF SIMARU: HTTP 413

## Hasil pemeriksaan server

Diuji pada 1 Oktober 2026, sekitar 20:28 WIB, terhadap
`https://simaru.adityadan.my.id/api`. Semua permintaan tanpa token dan tanpa
data pemesanan lengkap; tidak ada booking yang dibuat.

| Endpoint | Ukuran body | Hasil |
| --- | ---: | --- |
| `POST /booking` (multipart) | 524.445 byte | 401 JSON `Unauthenticated.` |
| `POST /booking` (multipart) | 2.097.309 byte | 413 HTML dengan penanda `nginx` |
| `POST /booking/upload-raw` | 2.097.152 byte | 413 HTML dengan penanda `nginx` |
| `POST /booking/upload-raw` | 1.048.576 byte | 401 JSON `Unauthenticated.` |
| `POST /booking/upload-raw` | 1.048.577 byte | 413 HTML dengan penanda `nginx` |

401 adalah hasil yang diharapkan untuk tes tanpa token: body sudah melewati
batas ukuran web server dan mencapai pemeriksaan autentikasi API.
Batas yang terukur pada rute upload-raw tepat 1 MiB. Respons 413 dari Nginx
menunjukkan penolakan sebelum validasi berkas di aplikasi Laravel.
Mengganti multipart dengan raw tidak menyelesaikan penolakan tersebut.

## Kesesuaian aplikasi dengan API

[Dokumentasi SIMARU](https://simaru.adityadan.my.id/docs/api#/)
mendefinisikan `POST /booking` dengan `multipart/form-data`, field
`attachment` berformat `binary`, serta autentikasi Bearer. Aplikasi sudah
mengirim berkas melalui field tersebut; PDF menggunakan `application/pdf`
untuk bagian berkas di dalam multipart. Batas berkas aplikasi kurang dari
5 × 1.024 × 1.024 byte.

## Perubahan untuk pengelola backend

Pada konfigurasi Nginx **yang melayani domain simaru.adityadan.my.id**, ubah
atau tambahkan direktif ini dalam blok `server` yang sudah ada:

```nginx
client_max_body_size 10m;
```

Jika terdapat beberapa reverse proxy/Nginx, periksa setiap lapisan. Pastikan
blok `location` untuk `/api` atau PHP tidak menimpa nilai tersebut dengan
batas lebih kecil. Jangan mengganti seluruh konfigurasi virtual host.
Batas request 10 MiB memberi ruang bagi berkas 5 MiB, field pemesanan, dan
pembungkus multipart; batas per berkas tetap diperiksa oleh aplikasi.

Periksa konfigurasi PHP yang benar-benar dipakai PHP-FPM/container API
(konfigurasi PHP CLI bisa berbeda). Bila nilainya lebih kecil, sesuaikan:

```ini
upload_max_filesize = 5M
post_max_size = 10M
```

Pastikan validasi `attachment` pada backend mengizinkan PDF dengan batas
berkas 5 MB sesuai kebutuhan produk. Ini pemeriksaan tambahan: penyebab
413 yang telah dibuktikan adalah batas Nginx, bukan hasil validasi PDF.

Setelah perubahan, validasi konfigurasi dan muat ulang Nginx:

```sh
sudo nginx -t
# Jalankan hanya jika pemeriksaan di atas berhasil:
sudo nginx -s reload
```

Muat ulang PHP-FPM/container yang melayani API jika konfigurasi PHP ikut
diubah, mengikuti metode deployment server tersebut.

## Verifikasi setelah deployment

1. Kirim body 2 MiB dan multipart PDF mendekati 5 MiB tanpa token ke endpoint
   yang sama. Hasil yang diharapkan 401 JSON, bukan 413 HTML.
2. Dari aplikasi yang login, buat pemesanan uji dengan PDF 1–4 MiB dan
   pastikan API mengembalikan sukses, booking muncul di riwayat, serta
   lampiran dapat dibuka.
3. Pastikan berkas berukuran 5 MiB atau lebih tetap ditolak aplikasi.

Perubahan server belum diterapkan dari repository Flutter ini. Hasil tes
401 hanya membuktikan lolosnya batas web server, bukan keberhasilan booking.

Referensi konfigurasi:

- [Nginx: client_max_body_size](https://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
- [PHP: post_max_size dan upload_max_filesize](https://www.php.net/manual/en/ini.core.php#ini.post-max-size)
