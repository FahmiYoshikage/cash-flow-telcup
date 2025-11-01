# 📊 CARA PAKAI SPREADSHEET TRANSPARANSI DANA

## FILE YANG SUDAH DIBUAT:
✅ **`Transparansi-Dana-Telkom-Cup.csv`** - File Excel/Google Sheets

---

## 🚀 CARA 1: Buka di Excel (Windows)

### Step-by-Step:

1. **Buka file:** `Transparansi-Dana-Telkom-Cup.csv`
2. **Double-click** atau klik kanan → Open with Microsoft Excel
3. **Save As** → Excel Workbook (.xlsx) agar bisa pakai formula

### Setup Formula:

#### Sheet 1: Data Pengeluaran (sudah ada)
```
Kolom A: Tanggal
Kolom B: Keterangan  
Kolom C: Kategori
Kolom D: Jumlah
Kolom E: Status
Kolom F: Catatan
```

#### Tambah Sheet 2: RINGKASAN
```
Buat sheet baru, ketik:

A1: TRANSPARANSI DANA TELKOM CUP TRI
A3: Total Budget
B3: Rp 5.000.000

A5: Total Pengeluaran
B5: =SUM(Sheet1!D:D)

A6: Sisa Dana
B6: =B3-B5

A7: Persentase Terpakai
B7: =B5/B3
Format B7: Percentage (0.00%)

A9: Breakdown per Kategori:
A10: Transport
B10: =SUMIF(Sheet1!C:C,"Transport",Sheet1!D:D)

A11: Konsumsi
B11: =SUMIF(Sheet1!C:C,"Konsumsi",Sheet1!D:D)

A12: Perlengkapan
B12: =SUMIF(Sheet1!C:C,"Perlengkapan",Sheet1!D:D)

A13: Administrasi
B13: =SUMIF(Sheet1!C:C,"Administrasi",Sheet1!D:D)

A14: Lainnya
B14: =SUMIF(Sheet1!C:C,"Lainnya",Sheet1!D:D)
```

#### Format Rupiah:
```
1. Select kolom D (Jumlah)
2. Klik kanan → Format Cells
3. Category: Currency
4. Symbol: Rp
5. Decimal places: 0
6. OK
```

#### Conditional Formatting (Warna):
```
1. Select range D2:D100 (kolom Jumlah)
2. Home → Conditional Formatting → Color Scales
3. Pilih: Red-Yellow-Green

Atau custom:
- Jumlah > 300000: Background merah
- Jumlah < 100000: Background hijau
```

---

## 🌐 CARA 2: Upload ke Google Sheets (RECOMMENDED!)

### Step-by-Step:

1. **Buka:** https://sheets.google.com
2. **Login** dengan akun Google
3. **File → Import → Upload**
4. **Pilih file:** `Transparansi-Dana-Telkom-Cup.csv`
5. **Import!**

### Setup Google Sheets:

#### Tambah Sheet "Ringkasan":
```
Klik + di tab bawah → Rename: "Ringkasan"

Ketik di sheet Ringkasan:

A1: TRANSPARANSI DANA TELKOM CUP TRI
(Bold, Size 18, Align Center)

A3: 💰 Total Budget
B3: Rp 5.000.000

A5: 💸 Total Pengeluaran  
B5: =SUM(Sheet1!D:D)
Format: Rp0

A6: 💵 Sisa Dana
B6: =B3-B5
Format: Rp0

A7: 📈 Persentase Terpakai
B7: =B5/B3
Format: 0.00%

A9: 📊 BREAKDOWN PER KATEGORI
A10: 🚗 Transport
B10: =SUMIF(Sheet1!C:C,"Transport",Sheet1!D:D)

A11: 🍔 Konsumsi
B11: =SUMIF(Sheet1!C:C,"Konsumsi",Sheet1!D:D)

A12: ⚽ Perlengkapan
B12: =SUMIF(Sheet1!C:C,"Perlengkapan",Sheet1!D:D)

A13: 📄 Administrasi
B13: =SUMIF(Sheet1!C:C,"Administrasi",Sheet1!D:D)

A14: 📦 Lainnya
B14: =SUMIF(Sheet1!C:C,"Lainnya",Sheet1!D:D)
```

#### Auto-Format Rupiah di Google Sheets:
```
1. Select kolom D (Sheet1)
2. Format → Number → Custom number format
3. Ketik: Rp#,##0
4. Apply
```

#### Buat Chart (Grafik):
```
1. Select data kategori (A10:B14)
2. Insert → Chart
3. Chart type: Pie chart
4. Customize:
   - Title: "Pengeluaran per Kategori"
   - Legend: Right
   - Slice labels: Value & Percentage
5. Insert chart
```

---

## 🔗 SHARE UNTUK TRANSPARANSI

### Google Sheets (Public Access):

1. **Klik "Share"** (pojok kanan atas)
2. **Change to "Anyone with the link"**
3. **Set permission:** Viewer (agar ga bisa diedit sembarangan)
4. **Copy link**
5. **Share ke:**
   - WhatsApp group
   - Social media
   - QR code (pakai QR generator online)

### Embed di Website (Bonus):
```html
<iframe 
  src="https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit?usp=sharing&rm=minimal"
  width="100%" 
  height="600">
</iframe>
```

---

## 📱 CARA INPUT DARI HP

### Pakai Google Sheets App:

1. **Download:** Google Sheets app (Android/iOS)
2. **Login** dengan akun sama
3. **Buka file** yang sudah diupload
4. **Tap sheet "Sheet1"**
5. **Tap + (bawah)** untuk tambah row baru
6. **Input data:**
   - Tanggal: Hari ini
   - Keterangan: Misal "Transport"
   - Kategori: Pilih dari dropdown
   - Jumlah: 150000
   - Status: Paid/Pending
7. **Done!** Auto-sync ke web

### Tips Mobile:
- Pakai voice typing untuk lebih cepat
- Save draft kalau belum sempat lengkap
- Notifikasi kalau ada yang edit (enable di settings)

---

## 🎨 STYLING TIPS

### Make it Pretty:

#### Header Row (Row 1):
```
- Background: Dark blue
- Text color: White
- Bold: Yes
- Align: Center
- Font size: 12
```

#### Alternate Row Colors:
```
1. Select all data rows
2. Format → Alternating colors
3. Choose style (default atau custom)
```

#### Freeze Header:
```
View → Freeze → 1 row
(Header tetap terlihat saat scroll)
```

#### Add Borders:
```
1. Select all data
2. Border icon → All borders
3. Choose border style
```

---

## 🔐 PROTEKSI DATA

### Protect Sheet (agar ga sembarangan diedit):

#### Google Sheets:
```
1. Data → Protect sheets and ranges
2. Set permissions:
   - Sheet1: Only you can edit
   - Ringkasan: Only you can edit
3. Show a warning (optional: warning aja, bukan block)
```

#### Excel:
```
1. Review → Protect Sheet
2. Password: (optional)
3. Allow:
   - ✅ Select locked cells
   - ✅ Select unlocked cells
   - ❌ Insert rows
   - ❌ Delete rows
4. OK
```

---

## 📊 TEMPLATE LENGKAP

### Sheet 1: Data Pengeluaran
```
| Tanggal    | Keterangan           | Kategori      | Jumlah    | Status  | Catatan          |
|------------|---------------------|---------------|-----------|---------|------------------|
| 2025-10-25 | Transport ke venue  | Transport     | Rp150,000 | Paid    | Mobil rental     |
| 2025-10-26 | Makan tim           | Konsumsi      | Rp200,000 | Paid    | Warteg           |
| 2025-10-27 | Bola futsal         | Perlengkapan  | Rp300,000 | Paid    | 2 pcs            |
```

### Sheet 2: Ringkasan
```
╔═══════════════════════════════════════════╗
║   TRANSPARANSI DANA TELKOM CUP TRI        ║
╚═══════════════════════════════════════════╝

💰 Total Budget:           Rp 5,000,000
💸 Total Pengeluaran:      Rp   900,000
💵 Sisa Dana:              Rp 4,100,000
📈 Persentase Terpakai:           18.00%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 BREAKDOWN PER KATEGORI

🚗 Transport:              Rp   150,000
🍔 Konsumsi:               Rp   350,000
⚽ Perlengkapan:            Rp   300,000
📄 Administrasi:           Rp   100,000
📦 Lainnya:                Rp         0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CHART: Pie Chart showing breakdown]
```

### Sheet 3: Grafik (Optional)
```
- Chart 1: Pie chart (Breakdown kategori)
- Chart 2: Line chart (Pengeluaran per hari)
- Chart 3: Bar chart (Top 10 pengeluaran)
```

---

## 🛠️ ADVANCED FEATURES

### 1. Data Validation (Dropdown):

#### Kategori Dropdown:
```
1. Select kolom C (Kategori)
2. Data → Data validation
3. Criteria: List of items
4. Items: Transport,Konsumsi,Perlengkapan,Administrasi,Lainnya
5. Show dropdown: ✅
6. Save
```

#### Status Dropdown:
```
1. Select kolom E (Status)
2. Data → Data validation
3. List: Paid,Pending
4. Save
```

### 2. Auto-Timestamp:
```
Kolom G: Waktu Input
Formula di G2: =NOW()
(Auto-update setiap edit)
```

### 3. Search/Filter:
```
1. Select header row
2. Data → Create a filter
3. Klik dropdown di header
4. Filter by:
   - Kategori tertentu
   - Tanggal range
   - Jumlah > X
```

### 4. Pivot Table (Advanced):
```
1. Select all data
2. Data → Pivot table
3. Rows: Kategori
4. Values: SUM of Jumlah
5. Create
```

---

## 📥 BACKUP & EXPORT

### Google Sheets:
```
File → Download → Excel (.xlsx)
Atau: PDF, CSV, ODS
```

### Auto-Backup:
```
Google Sheets auto-save ke Google Drive.
Bisa lihat Version History:
File → Version history → See version history
```

---

## ✅ CHECKLIST SETUP:

- [ ] Download file `Transparansi-Dana-Telkom-Cup.csv`
- [ ] Upload ke Google Sheets (atau buka di Excel)
- [ ] Buat sheet "Ringkasan" dengan formula
- [ ] Format kolom Jumlah jadi Rupiah
- [ ] Tambah conditional formatting (warna)
- [ ] Buat chart/grafik
- [ ] Setup dropdown untuk Kategori & Status
- [ ] Freeze header row
- [ ] Set sharing: "Anyone with link" (Viewer)
- [ ] Copy public link
- [ ] Test link di incognito browser
- [ ] Share ke WhatsApp group / social media
- [ ] (Optional) Generate QR code dari link

**Total waktu setup: 15-20 menit** ⏱️

---

## 💡 TIPS TRANSPARANSI:

1. **Update rutin:** Setiap ada transaksi, langsung input
2. **Screenshot ringkasan:** Post ke IG Story/WhatsApp
3. **Announcement:** "Link transparansi dana ada di bio"
4. **QR Code:** Print dan tempel di venue
5. **Reminder:** "Cek transparansi dana di link ini: [link]"

---

## 🆘 TROUBLESHOOTING:

### ❓ Formula ga jalan?
```
- Pastikan format cell "Number" bukan "Text"
- Cek reference sheet name (Sheet1 atau sheet1?)
- Pakai absolute reference ($A$1) kalau perlu
```

### ❓ Rupiah format ga keluar?
```
Google Sheets: Format → Number → Custom → Rp#,##0
Excel: Format Cells → Currency → Rp
```

### ❓ Chart ga muncul?
```
- Pastikan data sudah diselect
- Chart type cocok dengan data
- Refresh page
```

### ❓ Link ga bisa dibuka orang?
```
- Pastikan sharing setting: "Anyone with link"
- Pastikan permission: Viewer (bukan Restricted)
- Test di incognito/private browsing
```

---

## 🎉 DONE!

**File sudah siap pakai!**

Tinggal:
1. Upload ke Google Sheets
2. Setup formula di sheet Ringkasan
3. Share link
4. Update tiap ada transaksi

**Jauh lebih simple dari VPS/Docker/Notion!** 🚀

Ada pertanyaan? Langsung tanya! 💪
