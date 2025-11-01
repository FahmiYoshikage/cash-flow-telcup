# 🚀 SETUP NOTION - Step by Step

## LANGKAH 1: Install Notion (5 menit)

### Download & Install
1. **Buka:** https://notion.so/download
2. **Pilih:** Windows Desktop App (atau pakai Web version)
3. **Install** aplikasinya
4. **Sign up** dengan email (GRATIS!)

**Atau pakai Web:** https://notion.so → Sign up → Langsung pakai di browser

---

## LANGKAH 2: Buat Database (10 menit)

### Step-by-Step:

#### 1️⃣ Create New Page
```
- Klik "+ New Page" (sidebar kiri)
- Nama page: "Transparansi Dana Telkom Cup TRI"
- Icon: 💰 (klik icon, pilih emoji)
- Cover: Tambah cover image (optional, klik "Add cover")
```

#### 2️⃣ Add Database
```
- Di dalam page, ketik: /database
- Pilih: "Database - Inline"
- Atau: "Table - Inline"
- Nama database: "Pengeluaran"
```

#### 3️⃣ Setup Columns (Properties)

Klik **"+ New property"** dan tambahkan:

**Column 1: Tanggal**
```
- Name: Tanggal
- Type: Date
- Date format: DD/MM/YYYY
- Include time: NO
```

**Column 2: Keterangan**
```
- Name: Keterangan  
- Type: Text
```

**Column 3: Kategori**
```
- Name: Kategori
- Type: Select
- Options:
  🚗 Transport (warna: Blue)
  🍔 Konsumsi (warna: Green)
  ⚽ Perlengkapan (warna: Purple)
  📄 Administrasi (warna: Yellow)
  📦 Lainnya (warna: Gray)
```

**Column 4: Jumlah**
```
- Name: Jumlah
- Type: Number
- Number format: Indonesian Rupiah (Rp)
```

**Column 5: Status** (Optional)
```
- Name: Status
- Type: Select
- Options:
  ✅ Paid (warna: Green)
  ⏳ Pending (warna: Orange)
```

---

## LANGKAH 3: Input Sample Data (5 menit)

Klik **"+ New"** dan input contoh:

### Entry 1:
```
Tanggal: 25/10/2025
Keterangan: Transport tim ke venue
Kategori: Transport
Jumlah: 150000
Status: Paid
```

### Entry 2:
```
Tanggal: 26/10/2025
Keterangan: Makan siang tim (10 orang)
Kategori: Konsumsi
Jumlah: 200000
Status: Paid
```

### Entry 3:
```
Tanggal: 27/10/2025
Keterangan: Beli bola futsal 2 pcs
Kategori: Perlengkapan
Jumlah: 300000
Status: Paid
```

---

## LANGKAH 4: Tambah Ringkasan di Atas (5 menit)

**Di atas database, tambahkan text blocks:**

### Block 1: Heading
```
Ketik: /heading1
Text: "📊 RINGKASAN KEUANGAN"
```

### Block 2: Callout (Info Budget)
```
Ketik: /callout
Icon: 💰
Background: Blue
Text:
─────────────────────────────
💵 TOTAL BUDGET: Rp 5.000.000
─────────────────────────────
```

### Block 3: Columns (3 kolom)
```
Ketik: /column
Buat 3 kolom:

┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ 💸 TOTAL KELUAR  │  │ 💵 SISA DANA     │  │ 📈 PERSENTASE    │
│                  │  │                  │  │                  │
│ Rp XXX.XXX       │  │ Rp XXX.XXX       │  │ XX%              │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

**Update manual setiap ada transaksi baru.**

---

## LANGKAH 5: Create Multiple Views (10 menit)

Database bisa punya banyak "view" berbeda!

### View 1: Table (Default) ✅
```
- Sudah ada by default
- Tampilan seperti Excel
- Sort by: Tanggal (Descending)
```

### View 2: Board (Kanban by Kategori)
```
1. Klik "..." (3 dots di pojok database)
2. Klik "+ Add a view"
3. View type: Board
4. Name: "Board by Kategori"
5. Group by: Kategori
6. Save

Hasilnya: Card per kategori (seperti Trello)
```

### View 3: Calendar (by Tanggal)
```
1. Klik "..." → "+ Add a view"
2. View type: Calendar
3. Name: "Calendar"
4. Show on calendar: Tanggal
5. Save

Hasilnya: Kalender visual pengeluaran
```

### View 4: Gallery (Card view)
```
1. Klik "..." → "+ Add a view"
2. View type: Gallery
3. Name: "Gallery"
4. Card preview: Keterangan
5. Card size: Medium
6. Save

Hasilnya: Card besar per transaksi
```

---

## LANGKAH 6: Share Sebagai Website Publik (3 menit)

**Ini yang penting untuk TRANSPARANSI!**

### Cara Share:

#### 1️⃣ Klik **"Share"** (pojok kanan atas)

#### 2️⃣ Toggle **"Share to web"** → ON

#### 3️⃣ Settings:
```
✅ Allow search engines to index page
✅ Allow comments (opsional - biar orang bisa komen)
✅ Allow duplicate as template
```

#### 4️⃣ Copy Link
```
Link: https://notion.so/your-username/page-id

Contoh: 
https://notion.so/telkomcup/Transparansi-Dana-12a34b56
```

#### 5️⃣ Share!
```
- Post di grup WhatsApp
- Post di social media
- Tempel di poster event
- QR code (buat QR dari link)
```

---

## LANGKAH 7: Customize Tampilan (5 menit)

### Add Icon & Cover
```
1. Klik icon (kiri atas page)
2. Pilih emoji: 💰 atau 📊
3. Klik "Add cover"
4. Pilih cover image atau upload foto event
```

### Color & Style
```
- Highlight text: Select text → Color
- Add divider: Ketik /divider
- Add toggle: Ketik /toggle (untuk FAQ)
```

### Add Charts (Advanced)
```
Option 1: Embed Google Charts
- Buat chart di Google Sheets
- Publish → Embed
- Di Notion ketik /embed → paste link

Option 2: Screenshot chart
- Upload gambar chart
```

---

## BONUS: Template Lengkap

### Page Structure:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💰 TRANSPARANSI DANA TELKOM CUP TRI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 RINGKASAN KEUANGAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💵 TOTAL BUDGET: Rp 5.000.000
Last Update: 01/11/2025

┌─────────────────────────────────────────┐
│ 💸 Total Pengeluaran: Rp XXX.XXX        │
│ 💵 Sisa Dana: Rp XXX.XXX                │
│ 📈 Persentase Terpakai: XX%             │
└─────────────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 DAFTAR PENGELUARAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[DATABASE TABLE HERE]

Views:
📊 Table   |   📋 Board   |   📅 Calendar   |   🎴 Gallery

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 INFORMASI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Halaman ini dibuat untuk transparansi pengelolaan
dana Telkom Cup TRI. Semua pengeluaran tercatat
dan dapat diakses publik.

Contact: [Nama PIC]
WhatsApp: [Nomor]
Email: [Email]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## TIPS NOTION PRO:

### 1️⃣ Keyboard Shortcuts
```
Ctrl + N = New page
Ctrl + Shift + N = New window
@ = Mention page/person
/  = Slash command (semua block types)
```

### 2️⃣ Auto-Update Total (Workaround)
```
Karena Notion ga bisa sum otomatis di text block,
ada 2 cara:

Cara 1: Manual update (simple)
- Update angka manual tiap ada transaksi

Cara 2: Linked Database
- Buat page baru "Dashboard"
- Add "Linked view" dari database Pengeluaran
- Filter/rollup bisa lebih advanced
```

### 3️⃣ Mobile App
```
- Download Notion app (Android/iOS)
- Login dengan akun sama
- Input pengeluaran langsung dari HP
- Sync otomatis ke web
```

### 4️⃣ Comments untuk Transparansi
```
Public bisa komen kalau enable "Allow comments":
- Tanya jawab langsung di page
- Feedback dari audience
- Accountability lebih tinggi
```

### 5️⃣ Version History
```
Notion auto-save semua perubahan:
- Klik "..." → "Page history"
- Lihat siapa edit apa
- Bisa rollback kalau salah
```

---

## TROUBLESHOOTING:

### ❓ Ga bisa share publik?
```
✅ Pastikan toggle "Share to web" ON
✅ Cek internet connection
✅ Refresh page
```

### ❓ Link ga bisa dibuka orang?
```
✅ Pastikan link full (https://...)
✅ Test di incognito/private browser
✅ Pastikan "Share to web" masih ON
```

### ❓ Database ga muncul di mobile?
```
✅ Pastikan app sudah update
✅ Sync: Pull down to refresh
✅ Re-login kalau masih error
```

### ❓ Pengen custom domain?
```
Notion ga support custom domain gratis.
Options:
1. Super.so ($12/mo) - custom domain
2. Atau pakai notion.so/your-page (gratis)
```

---

## CHECKLIST FINAL:

- [ ] Download Notion app
- [ ] Sign up account
- [ ] Buat page "Transparansi Dana"
- [ ] Buat database "Pengeluaran"
- [ ] Setup 5 columns (Tanggal, Keterangan, Kategori, Jumlah, Status)
- [ ] Input 3 sample data
- [ ] Tambah ringkasan di atas database
- [ ] Create multiple views (Table, Board, Calendar)
- [ ] Share to web (toggle ON)
- [ ] Copy public link
- [ ] Test link di incognito browser
- [ ] Share link ke tim/publik

**Total waktu setup: 30-45 menit** ⏱️

**Setelah itu tinggal update aja!** 🎉

---

## SUPPORT:

Ada pertanyaan? DM saya atau:
- Notion Help Center: https://notion.so/help
- YouTube: Search "Notion tutorial Indonesia"
- Notion Community: https://reddit.com/r/Notion

**Good luck!** 💪
