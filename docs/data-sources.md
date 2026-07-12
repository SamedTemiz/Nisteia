# Veri Kaynakları ve Kural Motoru Tasarımı

## Temel gerçek: her şey hesaplanabilir, sunucu gerekmez

Ortodoks oruç takvimi iki bileşenden türetilir; ikisi de deterministik:

1. **Hareketli döngü** — Paskalya tarihine bağlı (Büyük Perhiz, Pentecost, Apostles' Fast başlangıcı)
2. **Sabit döngü** — sabit tarihli yortular ve sezonlar (Nativity Fast 15 Kas–24 Ara, Dormition 1–14 Ağu, tek günlük oruçlar)

## 1. Paskalya hesabı (Paschalion)

- **Meeus Julian algoritması** (kamu malı) → Julian Paskalya tarihi → Gregorian'a dönüşüm (+13 gün, 1900–2099 aralığında sabit fark)
- Saf fonksiyon: `DateTime pascha(int year)`
- Test verisi: 2020–2035 bilinen Paskalya tarihleri (ör. 2026: 12 Nisan, 2027: 2 Mayıs)

## 2. Oruç kural motoru

### Seviye enum'u
```
enum FastLevel { fastFree, dairyAllowed, fishWineOil, wineOil, strict }
```
(+ `FastReason`: weekday | season | feast | fastFreeWeek — UI'daki "neden" satırı için)

### Kural katmanları (öncelik sırasıyla uygulanır)
1. **Oruçsuz haftalar (override her şeyi):** Nativity–Theophany arası (25 Ara–4 Oca), Publican & Pharisee haftası, Bright Week (Paskalya haftası), Trinity haftası
2. **Yortu istisnaları:** Annunciation (25 Mar) ve Palm Sunday → Lent içinde balık; Transfiguration (6 Ağu) → Dormition içinde balık; Lent hafta sonları → şarap+yağ; vb.
3. **Sezon kuralları:** Great Lent (48 gün, gün-gün değişen), Nativity Fast (dönem içi balık günleri), Apostles' Fast, Dormition Fast, tek günlük oruçlar (Theophany arifesi 5 Oca, Vaftizci Yahya'nın kesilmesi 29 Ağu, Haç'ın Yüceltilmesi 14 Eyl)
4. **Haftalık taban:** Çarşamba + Cuma orucu (yıl boyu, oruçsuz haftalar hariç)
5. Hiçbiri değilse: `fastFree`

### Eski/Yeni takvim modu
- Motor her zaman "litürjik gün" üzerinden çalışır; Eski takvim modunda sabit yortular sivil tarihte +13 gün kayar (hareketli döngü zaten Julian Paskalya'ya bağlı, iki modda aynı)
- Tek kural motoru + tarih eşleme katmanı = iki takvim de aynı testlerden geçer

### Sıkılık ayarı
- "Yaygın uygulama" vs "manastır" farkı yalnızca sunum katmanında (ör. bazı günlerde balık toleransı) — motor her iki yorumu da etiketleyip UI'da seçime göre gösterir

## 3. Referans ve doğrulama kaynakları

| Kaynak | Lisans | Kullanım |
|---|---|---|
| [orthocal-python](https://github.com/brianglass/orthocal-python) (orthocal.info) | **MIT** ✅ | Kural mantığını Dart'a port etme referansı (OCA kuralları); atıf verilecek |
| [orthocal.info API](https://orthocal.info/api/) | Ücretsiz servis | **Yalnızca test zamanı** doğrulama: 2020–2033 arası 5.000 günün seviyesini motorumuzla karşılaştıran test |
| [Ponomar](https://github.com/typiconman/ponomar) | **GPL** ⚠️ | Kod/veri GÖMÜLMEZ. Sadece elle çapraz kontrol referansı |
| OCA "Fasting & Fast-Free Seasons" rehberi | Web içeriği | Kural kaynağı olarak atıf; metin kopyalanmaz |
| GOARCH takvimi | Web içeriği | Yunan geleneği çapraz kontrolü |

## 4. Aziz verileri

- v1: yalnızca **isimler + yortu adları** (gerçek bilgisi, telif korumasız) — gömülü JSON, gün başına majör anmalar
- Kaynak derleme: orthocal-python'un MIT verisi baz alınabilir
- v2: biyografiler için kamu malı synaxarion çevirileri veya kendi kısa özetlerimiz

## 5. v2 — Barkod tarayıcı verisi

- [Open Food Facts](https://world.openfoodfacts.org/) — ODbL lisanslı, ücretsiz API; ürün içerik listesi → hayvansal içerik tespiti (et/süt/yumurta/balık türevleri) → günün seviyesiyle karşılaştır
- Offline öncelikli tasarımı bozan tek özellik → bu yüzden v2'de ve "internet gerektirir" etiketiyle

## 6. Test stratejisi

- `test/core/`: her kural katmanı için birim testler + bilinen zor vakalar (Annunciation Kutsal Hafta'ya denk gelirse, Lent'te yortu çakışmaları, artık yıllar)
- `test/validation/`: orthocal.info'dan çekilmiş snapshot JSON'a karşı toplu karşılaştırma (snapshot repo'ya commit edilir → test offline çalışır, API'ye saygı)
- Kural motorunda coverage hedefi: %100. UI'da test lüks, motorda zorunluluk.
