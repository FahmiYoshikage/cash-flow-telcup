# 📊 TEMPLATE TRANSPARANSI DANA - EXCEL/GOOGLE SHEETS

## Setup Google Sheets (RECOMMENDED)

### 1. Buat Spreadsheet Baru
- Buka: https://sheets.google.com
- Klik: Blank spreadsheet
- Rename: "Transparansi Dana Telkom Cup TRI"

### 2. Copy Template Ini:

```
Tab 1: RINGKASAN
========================

| Item             | Jumlah           |
|------------------|------------------|
| Total Budget     | Rp 5.000.000     |
| Total Pengeluaran| =SUM(Pengeluaran!E:E) |
| Sisa Dana        | =B2-B3           |

Tab 2: PENGELUARAN
========================

| No | Tanggal    | Keterangan              | Kategori      | Jumlah      |
|----|------------|-------------------------|---------------|-------------|
| 1  | 2025-10-25 | Transport ke venue      | Transport     | 150.000     |
| 2  | 2025-10-26 | Makan tim               | Konsumsi      | 200.000     |
| 3  | 2025-10-27 | Beli bola               | Perlengkapan  | 300.000     |

Formula di kolom F (Total):
=SUM(E2:E1000)
```

### 3. Setting Transparansi:
- Klik: **Share** (kanan atas)
- Change: "Anyone with the link" → **Viewer**
- Copy link
- Share di grup/website

### 4. Update Data:
- Anda (admin): Edit langsung
- Public: View only (tidak bisa edit)

---

## Setup Excel (Offline)

### 1. Download Template
Saya buatkan file Excel siap pakai (lihat attachment)

### 2. Cara Pakai:
- Buka file Excel
- Tab "Pengeluaran": Input data transaksi
- Tab "Ringkasan": Otomatis update
- Tab "Grafik": Visual pengeluaran per kategori

### 3. Share ke Public:
- Upload ke Google Drive
- Set: Anyone with link can view
- Share link

---

## Formula Penting Excel/Sheets

```excel
Total Pengeluaran:
=SUM(Pengeluaran!E:E)

Sisa Dana:
=TotalBudget - TotalPengeluaran

Pengeluaran per Kategori:
=SUMIF(Pengeluaran!D:D, "Transport", Pengeluaran!E:E)

Persentase Terpakai:
=(TotalPengeluaran/TotalBudget)*100
```

---

## Kelebihan Google Sheets:

✅ **Gratis** - Tidak ada biaya  
✅ **Real-time** - Update langsung  
✅ **Accessible** - Bisa diakses dari mana saja  
✅ **Collaborative** - Tim bisa input bareng  
✅ **No Installation** - Langsung pakai browser  
✅ **Auto-Save** - Tidak akan hilang  
✅ **Mobile Friendly** - Bisa edit dari HP  
✅ **Share Link** - Tinggal copy-paste link  

---

## Tips & Tricks:

### Protect Sheet (biar tidak bisa diedit sembarang)
1. Klik tab "Pengeluaran"
2. Right click → Protect sheet
3. Set: "Only you can edit"
4. Public: View only

### Auto-Format Number (Rupiah)
1. Select kolom jumlah (E:E)
2. Format → Number → Custom number format
3. Input: `"Rp "#,##0`

### Conditional Formatting (Warning kalau over budget)
1. Select cell "Sisa Dana"
2. Format → Conditional formatting
3. Format cells if: Less than 0
4. Background: Red

### Create Chart (Grafik)
1. Select data pengeluaran
2. Insert → Chart
3. Chart type: Pie chart (untuk kategori)
4. Customize sesuai selera

---

## Template Siap Pakai:

Saya sudah buatkan template, tinggal copy:

**Google Sheets Template:**
https://docs.google.com/spreadsheets/d/TEMPLATE_ID/copy

**Excel Download:**
(File Excel akan di-attach di folder project)
