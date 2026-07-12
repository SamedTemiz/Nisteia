# Ekran Spesifikasyonları — MVP

*Tasarım seçimi bu belge üzerinden yapılacak. 6 ekran + widget = MVP.*

## Tasarım dili (öneri)

- **Estetik:** Bizans ikonografisinden ilham — koyu zemin üzerinde altın vurgular, derin bordo/lacivert; ama modern tipografi ve bol boşluk. "Eski uygulama" hissinden kaçınmanın yolu süsleme değil sadelik.
- **Renk kodu (oruç seviyeleri)** — tüm ekranlarda tutarlı:
  - 🟥 Sıkı oruç (et, süt, balık, yağ, şarap yok)
  - 🟧 Şarap + yağ serbest
  - 🟨 Balık + şarap + yağ serbest
  - 🟦 Süt ürünleri serbest (Cheesefare haftası)
  - 🟩 Oruç yok / oruçsuz hafta
- Dark mode ilk günden (kitle gece kullanıyor: akşam "yarın ne yiyeceğim" kontrolü).

---

## 1. Onboarding (3 adım, ilk açılışta bir kez)

1. **Takvim seçimi:** "Yeni Takvim (Revised Julian)" / "Eski Takvim (Julian)" — kısa açıklama + "Kilisenizi bilmiyorsanız: Yunan/Antakya/Romen → Yeni; Rus/Sırp/Gürcü → Eski" yardımcı metni
2. **Uygulama sıkılığı:** "Yaygın cemaat uygulaması" (varsayılan) / "Sıkı (manastır) uygulaması" — altında disclaimer: *"Oruç uygulaması kişiseldir; ruhani rehberinize danışın."*
3. **Bildirim izni:** "Yarın oruç günü" akşam hatırlatması + sezon başlangıçları

Ayarlardan her zaman değiştirilebilir. Login YOK, e-posta YOK.

## 2. Today (ana ekran) ⭐ uygulamanın kalbi

- **Üstte:** tarih — seçili takvime göre + karşılığı ("July 12 · June 29 O.S.")
- **Büyük durum kartı:** bugünün oruç seviyesi, renk + büyük tipografi ("Strict Fast" / "Fast-free")
- **Yiyecek ikon satırı:** 🥩 🧀 🐟 🫒 🍷 — her biri izinli/yasak durumunda (✓/✗). Bir bakışta cevap.
- **Neden satırı:** "Friday" / "Great Lent, day 23" / "Feast of Transfiguration — fish allowed"
- **İkincil kart:** günün azizleri (isim listesi, v1'de biyografi yok)
- **Alt şerit:** sonraki 7 gün mini önizleme (renk noktaları) — hafta planlaması için
- Free katmanda tam çalışır.

## 3. Calendar (ay görünümü)

- Ay ızgarası, her gün oruç seviyesi rengiyle dolgulu; yortu günlerinde küçük yıldız işareti
- Alt kısımda renk lejantı (kalıcı, kaydırmasız görünür — rakiplerdeki "plan yapamıyorum" şikayetinin cevabı)
- Güne dokun → bottom sheet: seviye, izinler, neden, azizler
- **Free:** içinde bulunulan ay + sonraki ay. **Pro:** sınırsız ileri/geri yıl.

## 4. Seasons (sezonlar & geri sayım)

- Sıradaki oruç sezonu kartı: "Nativity Fast starts in 126 days"
- Aktif sezonda: ilerleme çubuğu ("Great Lent · day 23 of 48") + sezon kural özeti
- Yıl içindeki 4 büyük oruç + tek günlük oruçlar + oruçsuz haftalar listesi
- Lent'te paylaş butonu: geri sayım görseli üret (organik yayılım — v1.5)

## 5. Food Guide ("Ne yiyebilirim?")

- Bugünün seviyesine göre iki liste: ✅ Serbest / ❌ Kaçınılır — kategori bazlı (et, süt ürünleri, yumurta, balık, kabuklu deniz ürünleri*, yağ, şarap/alkol, bal vb.)
- *Kabuklu deniz ürünleri nüansı (sıkı oruçta bile serbest olması) — rakiplerde hiç anlatılmayan, convert'lerin en çok şaşırdığı kural → bizim öğretici anlarımız
- Sık sorulan yiyecekler için arama kutusu (statik liste v1; barkod tarayıcı v2 burada yaşayacak)
- **Pro:** haftalık yemek planı görünümü + oruca uygun tarifler

## 6. Settings

- Takvim (Yeni/Eski), uygulama sıkılığı, dil (v1: EN)
- Bildirim tercihleri (akşam hatırlatma saati, sezon uyarıları)
- Pro durumu + restore purchase
- Kaynaklar/hakkında: kural kaynağı şeffaflığı (OCA rehberi + orthocal atfı), disclaimer
- "Bir hata mı buldun?" mail linki — kural hatası raporu ciddiye alınır (güven inşası)

## 7. Paywall (Pro)

- Tetiklenme: widget eklemeye çalışınca, 2. aydan ileri takvime gidince, yemek planına dokununca
- Tek fiyat, tek buton: "Unlock Pro — $3.99 · one-time, forever" + "No subscription" vurgusu (pazarlama mesajının kendisi)
- Özellik listesi: widgets, full calendar, meal planner & recipes, custom notifications, themes

## 8. Widgets (Pro)

- **Küçük:** bugünün seviyesi (renk + ikon satırı)
- **Orta:** bugün + sonraki 3 gün
- Kilit ekranı widget'ı (iOS 16+): seviye ikonu
- Widget = günlük görünürlük = uygulamayı silmeme sebebi

---

## Ekran → tasarım önceliği

Tasarım seçerken şu sırayla mockup istenmeli: **Today → Calendar → Food Guide** (uygulamanın karakterini bu üçü belirler). Onboarding/Settings/Paywall standart pattern'lerden uyarlanır.
