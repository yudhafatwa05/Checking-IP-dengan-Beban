🧩 Deskripsi Proyek

Script ini digunakan untuk melakukan pengujian latency dan packet loss pada sekumpulan IP address secara otomatis menggunakan perintah ping di Linux.
Setiap pengujian dikirimkan dengan beban besar (65500 bytes) untuk mensimulasikan lalu lintas data berat, sehingga hasil lebih realistis dibandingkan ping biasa.

Script ini cocok digunakan untuk:

Pengujian performa jaringan antar site (misalnya antar lokasi kantor, NUC, atau IP Camera)

Diagnostik jaringan (latency tinggi, packet loss)

Monitoring konektivitas LAN/WAN dengan ukuran paket besar

Dokumentasi hasil uji jaringan dalam bentuk log file (.log)

⚙️ Fitur Utama

✅ Mendukung banyak IP dari file .txt dalam satu folder
✅ Menjalankan ping otomatis untuk setiap IP
✅ Menggunakan ukuran paket 65500 bytes (beban besar)
✅ Menyimpan hasil lengkap ke file log (hasil_ping_raw_<timestamp>.log)
✅ Output mengikuti format asli ping, lengkap dengan:

27 packets transmitted, 26 received, 3.7037% packet loss, time 26063ms
rtt min/avg/max/mdev = 11.965/13.216/14.758/0.577 ms


✅ Dapat diatur interval antar ping (-i)
✅ Mudah dijalankan dan ringan (bash murni, tanpa dependensi tambahan)

🧠 Cara Kerja Singkat

Script akan membaca semua file .txt di dalam folder yang diberikan,
kemudian mengeksekusi ping untuk setiap IP di file tersebut dengan parameter:

ping -c 27 -s 65500 -i 1 -W 2 <ip_address>


Hasil dari setiap pengujian akan dicetak langsung di terminal dan disimpan ke file log otomatis di folder yang sama.

Cara Menggunakan
1️Buat folder dan file daftar IP
mkdir ~/ip_monitoring
cd ~/ip_monitoring
nano ip_list.txt


Isi dengan daftar IP:

10.43.13.187
10.43.13.164
10.43.13.165
...

2️⃣ Simpan script check_latency_raw.sh
nano check_latency_raw.sh


(paste script utama di sini)

3️⃣ Jadikan executable
chmod +x check_latency_raw.sh

4️⃣ Jalankan script
./check_latency_raw.sh .

5️⃣ Lihat hasil

Output langsung tampil di terminal

File hasil otomatis tersimpan di Folder

⚙️ Parameter Default
Parameter	Nilai	Keterangan
COUNT	27	Jumlah ping per IP
SIZE	65500	Ukuran paket (bytes)
INTERVAL	1	Jeda antar paket (-i, detik)
TIMEOUT	2	Timeout per paket (detik)

Semua nilai bisa disesuaikan di bagian atas script sesuai kebutuhan.

🧭 Catatan Teknis

Ukuran paket 65500 bytes mendekati batas maksimum MTU jaringan (ideal untuk stress test).

Interval standar 1 detik (-i 1) sudah aman untuk jaringan umum.

Interval <0.2 detik (-i 0.2) memerlukan akses root (sudo).

🧰 Contoh Penggunaan Lain

Ping cepat (interval 0.5 detik):

sudo ./check_latency_raw.sh . 0.5


Ping lambat (interval 2 detik):

./check_latency_raw.sh . 2
