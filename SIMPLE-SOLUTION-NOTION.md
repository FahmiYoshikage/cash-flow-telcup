# 🎨 TRANSPARANSI DANA dengan NOTION

## Kenapa Notion?

✅ **Modern & Clean UI** - Tampilan keren  
✅ **Database System** - Lebih powerful dari Excel  
✅ **Public Share** - Bisa share sebagai website  
✅ **Mobile App** - Ada app iOS/Android  
✅ **Templates** - Banyak template siap pakai  
✅ **Gratis** - Free plan cukup  

---

## Setup Notion Database

### 1. Buat Workspace Baru
- Download Notion: https://notion.so/download
- Atau: Pakai web version
- Buat account (gratis)

### 2. Create Database

**Database: Pengeluaran**

Properties:
```
📅 Tanggal        → Date
📝 Keterangan     → Text
🏷️ Kategori       → Select (Transport, Konsumsi, Perlengkapan, Administrasi, Lainnya)
💰 Jumlah         → Number (format: Rupiah)
✅ Status         → Select (Paid, Pending)
```

### 3. Create Dashboard

**Page: Dashboard Keuangan**

Blocks yang perlu dibuat:
```
1. Heading: "Transparansi Dana Telkom Cup TRI"

2. Callout Block: Total Budget
   Icon: 💰
   Text: "Total Budget: Rp 5.000.000"

3. Database View: Pengeluaran (Table)
   - Show all entries
   - Sort: Tanggal (descending)

4. Database View: Pengeluaran (Board by Kategori)
   - Group by: Kategori
   - Visual per kategori

5. Database View: Pengeluaran (Gallery)
   - Card preview per transaksi

6. Formula untuk Total:
   - Create new property: "Total"
   - Formula: sum(prop("Jumlah"))
```

### 4. Add Summary Stats

Create text blocks:
```
📊 **RINGKASAN**

💰 Total Budget: Rp 5.000.000
💸 Total Pengeluaran: [Link to database sum]
💵 Sisa Dana: [Budget - Pengeluaran]
📈 Persentase Terpakai: XX%
```

### 5. Share as Public Page

1. Klik **Share** (kanan atas)
2. Toggle: **Share to web** ON
3. Settings:
   - ✅ Allow search engines to index
   - ✅ Allow comments (optional)
   - ✅ Allow duplicate as template
4. Copy public link
5. Share!

---

## Template View Options

### View 1: Table (Default)
```
| Tanggal    | Keterangan        | Kategori     | Jumlah    |
|------------|-------------------|--------------|-----------|
| 2025-10-25 | Transport         | Transport    | 150.000   |
| 2025-10-26 | Makan tim         | Konsumsi     | 200.000   |
```

### View 2: Board (Kanban by Kategori)
```
Transport       Konsumsi        Perlengkapan
┌─────────┐    ┌─────────┐     ┌─────────┐
│ Trans 1 │    │ Makan 1 │     │ Bola    │
│ 150k    │    │ 200k    │     │ 300k    │
└─────────┘    └─────────┘     └─────────┘
```

### View 3: Calendar (by Tanggal)
```
Kalender visual per tanggal pengeluaran
```

### View 4: Gallery (Card view)
```
Card besar untuk setiap transaksi
```

---

## Advanced Features

### 1. Auto-Calculate Total
Create rollup property:
```
Property: Total Pengeluaran
Type: Rollup
Relation: All entries
Calculate: Sum of Jumlah
```

### 2. Conditional Formatting
```
If Jumlah > 500.000:
  Background: Red
  
If Kategori = "Transport":
  Icon: 🚗
```

### 3. Filter Views
```
View: Pengeluaran Besar
Filter: Jumlah > 300.000

View: Bulan Ini
Filter: Tanggal within last month
```

### 4. Add Charts (via Integrations)
- Connect Google Sheets
- Or use Notion Charts (third-party)
- Or embed Chart.js/Google Charts

---

## How to Input Data

### Method 1: Direct Input
1. Open database
2. Click "+ New"
3. Fill form
4. Save

### Method 2: Quick Add (Mobile)
1. Open Notion app
2. Swipe down
3. Quick add to database

### Method 3: Email to Notion
1. Setup email integration
2. Email format pengeluaran
3. Auto-parse to database

---

## Make it Public Website

Notion page bisa jadi website langsung!

### Custom Domain (Optional)
1. Use notion.so/your-page
2. Or use custom domain with Super.so
3. Looks like: transparansi.telkomcup.com

### Embed to Website
```html
<iframe 
  src="https://notion.so/your-public-page"
  width="100%" 
  height="600px">
</iframe>
```

---

## Template Siap Pakai

**Notion Template:** (Bisa duplicate)

1. Open: https://notion.so/templates
2. Search: "Finance Tracker" atau "Budget"
3. Click: **Duplicate**
4. Customize untuk Telkom Cup

**Atau:**

Saya buatkan custom template khusus untuk Anda
(Link akan di-share setelah dibuat)

---

## Perbandingan: Notion vs Google Sheets

| Fitur           | Notion          | Google Sheets   |
|-----------------|-----------------|-----------------|
| UI              | ⭐⭐⭐⭐⭐      | ⭐⭐⭐         |
| Ease of Use     | ⭐⭐⭐⭐        | ⭐⭐⭐⭐⭐     |
| Flexibility     | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⭐       |
| Formula         | ⭐⭐⭐          | ⭐⭐⭐⭐⭐     |
| Mobile App      | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⭐       |
| Public Share    | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⭐       |
| Learning Curve  | Medium          | Easy            |

**Recommendation:**
- **Google Sheets**: Kalau mau simple & familiar
- **Notion**: Kalau mau modern & keren

---

## Tips Notion untuk Transparansi

### 1. Pin Important Info
Pin ringkasan di atas:
```
📌 PINNED
Total Budget: Rp 5.000.000
Sisa Dana: Rp 2.500.000
Last Update: 2025-10-31
```

### 2. Add Comments Section
Enable comments untuk transparansi:
- Public bisa komen
- Tanya jawab langsung di Notion

### 3. Version History
Notion auto-save version history:
- Bisa rollback kalau salah input
- Track siapa yang edit

### 4. Collaboration
Invite team:
- Full access: Bisa edit
- Comment only: Bisa komen
- View only: Cuma bisa lihat

---

## Mobile App Features

### Android/iOS App:
- Push notifications
- Quick add widget
- Offline mode
- Camera scan receipt (OCR)

---

## Integration Options

### Connect to Other Tools:
- **Zapier**: Auto-add from email/WhatsApp
- **IFTTT**: Auto-log from Google Forms
- **Make (Integromat)**: Complex automation

### Example Automation:
```
Google Form (submit expense)
    ↓
Zapier
    ↓
Auto-add to Notion Database
    ↓
Notification to WhatsApp group
```

---

## Free vs Paid

### Free Plan (Cukup!)
✅ Unlimited pages
✅ Unlimited blocks
✅ 10 guests
✅ Public share
✅ Mobile app
✅ Basic integrations

### Paid Plan ($10/mo)
- Unlimited guests
- Advanced permissions
- Version history (unlimited)
- Priority support

**For transparansi dana: FREE PLAN ENOUGH!**

---

## Quick Start Checklist

- [ ] Download Notion app
- [ ] Create account
- [ ] Create page: "Transparansi Dana"
- [ ] Add database: "Pengeluaran"
- [ ] Setup properties (Tanggal, Keterangan, Kategori, Jumlah)
- [ ] Input sample data
- [ ] Create views (Table, Board, Calendar)
- [ ] Share to web
- [ ] Copy public link
- [ ] Share to team/public

**Total setup time: 15 menit!** ⏱️

---

## Support & Help

- Notion Help: https://notion.so/help
- Notion Templates: https://notion.so/templates
- YouTube Tutorials: Search "Notion budget tracker"
- Community: Reddit r/Notion

---

**Notion = Excel on Steroids!** 💪
