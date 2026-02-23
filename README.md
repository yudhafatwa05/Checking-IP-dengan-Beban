📡 LPR Network Test Script

Masukkan daftar IP ke dalam file .txt.

Contoh:

# daftar ip test
8.8.8.8
1.1.1.1
192.168.1.1

Kamu bisa menyimpan banyak file .txt dalam satu folder.

⚙️ Cara Menjalankan
 masuk ke folder Checking-IP-dengan-Beban
lalu berikan permission executable

sudo chmod +x Check_latency_raw.sh

2️⃣ Jalankan script
sudo bash Check_latency_raw.sh

tunggu Hasilnya


🧪 Parameter Default Test
Parameter	Nilai	Keterangan
COUNT	100	Jumlah paket
SIZE	65500	Ukuran packet (stress test)
DELAY	0.1	Interval antar ping
📊 Output Contoh
🔹 IP: 8.8.8.8
   Packet Loss : 0%
   Avg Latency : 12.3 ms
   Status LPR  : RECOMMENDED ✅
--------------------------------------------------
📁 Log File

Hasil test otomatis tersimpan dengan format:

hasil_lpr_test_YYYY-MM-DD_HH-MM-SS.log
📌 Kategori Status
Packet Loss	Status
0%	RECOMMENDED ✅
≤ 1%	SAFE ✅
≤ 3%	WARNING ⚠️
> 3%	NOT RECOMMENDED ❌
No Response	NO RESPONSE ❌
