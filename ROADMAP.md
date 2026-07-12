# ROADMAP — Nisteia (Ortodoks Oruç Asistanı)

> Takvim mantığı: iki doğal launch penceresi var.
> **Nativity Fast: 15 Kasım 2026** (yeni takvim) — yumuşak launch hedefi.
> **Büyük Perhiz (Great Lent) 2027: ~15 Mart 2027** (Paskalya 2 Mayıs 2027) — asıl trafik patlaması; o güne kadar mağazada yorum birikmiş olmalı.

## Faz 0 — Kural Motoru (Temmuz 2026, ~2 hafta) ✅ TAMAMLANDI (kritik yol)

Uygulamanın kalbi. UI'dan önce bu bitmeli ve kanıtlanmalı.

- [x] Paschalion (Meeus algoritması) — Julian Paskalya + Gregorian'a dönüşüm → `lib/core/paschalion.dart`, `lib/core/calendar_math.dart`
- [x] Hareketli döngü: Triodion, Büyük Perhiz, Pentecostarion, Apostles' Fast başlangıcı → pdist tabanlı, `lib/core/fasting_rules.dart`
- [x] Sabit yortular ve oruç sezonları tablosu (Nativity, Dormition, tek günlük oruçlar)
- [x] Oruç seviyesi kural motoru: hafta içi kuralları (Çrş/Cum), sezon kuralları, yortu istisnaları (balık/şarap/yağ izinleri), oruçsuz haftalar
- [x] Eski/Yeni takvim modu (sabit yortularda 13 gün kayma) — JDN üzerinden, `Calendar.oldCalendar`
- [x] Unit testler yazıldı ve **koşuldu** (`test/core/`, 54 vaka yeşil) + **orthocal.info doğrulama harness'i** kuruldu (`test/validation/`, `tool/refresh_orthocal_snapshot.dart`).
- [x] Aziz-anma oruç istisnaları: orthocal-python `fixtures/calendarium.json` tablosu Dart'a portlandı (`lib/data/commemorations.dart`, MIT + atıf) ve `_apply_fasting_adjustments` mantığı motora eklendi. İlk karşılaştırmada 38 uyumsuzluk → **0**.
- [x] orthocal doğrulaması **sıfır uyumsuzlukla** geçiyor (2026, 2027 geç-Paskalya, 2028 artık yıl teyitli; tam 2020–2033 aralığı snapshot'lanıyor).
- Çıktı: `lib/core/` + `lib/data/` yazıldı ve orthocal'a karşı doğrulandı, UI ise Today ekranı iskeleti hariç yok. **Faz 0 çıkış kriteri karşılandı.**

## Faz 1 — MVP (Ağustos–Eylül 2026, ~6 hafta)

- [x] Onboarding (3 adım: takvim + gelenek + bildirim tanıtımı + disclaimer) → `lib/features/onboarding/`
- [x] Today ekranı — üst bar, çift tarih (New · O.S.), renk-kodlu oruç kartı (5 yiyecek ✓/×), 7-günlük şerit, "Saints of the Day" kartı (gerçek aziz isimleri). EB Garamond + merkezi tema.
- [x] Ay takvimi (renk kodlu seviyeler + yortu yıldızı + gün detayı bottom sheet + Pro sınırı) → `lib/features/calendar/`
- [x] Sezonlar/geri sayım ekranı (aktif sezon ilerlemesi + sonraki oruç geri sayımı) → `lib/features/seasons/`
- [x] "Ne yiyebilirim?" rehberi (kategori bazlı statik v1 + kabuklu deniz ürünü öğretici notu) → `lib/features/guide/`
- [x] Ayarlar (takvim, sıkılık, bildirim tercihleri, kaynak/atıf, disclaimer, hata bildirimi) → `lib/features/settings/`
- [x] i18n altyapısı (tüm stringler ARB'de, yalnızca EN içerik)
- [x] Tercih katmanı: shared_preferences + Riverpod (`lib/app/settings.dart`), navigasyon shell (`lib/app/home_shell.dart`)
- [~] RevenueCat tek seferlik Pro IAP — paywall UI + tetikleyiciler hazır (`lib/features/paywall/`), gerçek satın alma akışı bağlanacak (gerçek RevenueCat hesabı/API anahtarı gerektiriyor — kullanıcı tarafında kurulacak)
- [x] Bildirimler: akşamdan "yarın oruç" + sezon başlangıçları → `flutter_local_notifications` bağlandı (`lib/app/notification_service.dart`), onboarding tamamlanınca ve ayar değişince otomatik yeniden zamanlanıyor (`lib/main.dart` `_RootGate`). Web'de ve testlerde güvenli no-op (best-effort, try/catch ile uygulamayı asla çökertmez). ⚠️ Gerçek cihazda bildirim ateşlemesi bu ortamda (Android SDK cmdline-tools/emulator yok) doğrulanamadı — kod derleniyor ve mantık test edildi, ama gerçek cihaz testi gerekiyor.

- [x] Modern geçişler: sekmeler arası Material fade-through (state korunur — takvim ayı/scroll kaybolmaz, `lib/app/home_shell.dart`), push edilen sayfalarda shared-axis (`animations` paketi, tema seviyesinde `lib/theme/app_theme.dart`)
- [x] "Hata bildir" gerçek mailto linki (`url_launcher`; mail uygulaması yoksa adresli dialog'a düşer)
- [x] Burger menü → navigation drawer (Settings + Kaynaklar) ve **Kaynaklar & atıf ekranı** (`lib/features/settings/sources_screen.dart`)
- [x] **Çoklu dil**: EN + EL/RO/RU/SR/BG ARB'leri, Settings'te dil seçici (sistem varsayılanı destekli), tüm tarihler locale-aware, hardcoded string ihlalleri temizlendi (seasons/settings/paywall/calendar). Desteklenmeyen sistem dili artık İngilizce'ye düşüyor (alfabetik-ilk-dil hatası düzeltildi). ⚠️ Çeviriler yerli konuşur incelemesi bekliyor; UK/KA (Ukraynaca/Gürcüce) sonraki dalga.
- [x] Today durum kartına hafif blurlu kamu malı ikon arka planı (6. yy Sina Pantokrator'u, Wikimedia PD — `assets/images/ATTRIBUTION.md`)

**Durum:** 6 ekran + navigasyon + onboarding + paywall stub + local notifications + modern geçişler çalışıyor; `flutter analyze` temiz, 68 test yeşil. Kalan gerçek-entegrasyon işleri: RevenueCat satın alma (hesap gerektirir), gerçek cihazda bildirim + mailto doğrulaması.

## Faz 2 — Cila + Beta (Ekim 2026, ~4 hafta)

> ⚠️ 2026-07-12 kararı: **v1 yalnızca Play Store** — iOS işleri ertelendi (kod tabanı hazır kalır).

- [ ] Home screen widget (Android AppWidget) — Pro özelliği (~~iOS küçük/orta~~ ertelendi)
- [ ] Play beta (internal → closed testing): r/OrthodoxChristianity + 2-3 cemaat Discord/Facebook grubundan 30-50 beta kullanıcı
- [ ] Beta geri bildirimiyle kural motoru yurisdiksiyon ayarları düzeltmesi
- [ ] ASO: anahtar kelimeler ("orthodox fasting", "orthodox calendar", "lent fasting guide"), ekran görüntüleri, mağaza metinleri
- [ ] Play Console hesabı ($25 tek seferlik) + başvuru süreci (~~App Store~~ ertelendi)
- [ ] RevenueCat hesabı (yalnızca Google Play platformu) + `purchases_flutter` entegrasyonu
- [ ] Upload keystore üret (`keytool`, talimat `android/app/build.gradle.kts` içinde) + `android/key.properties`

## 🚀 Launch — Kasım başı 2026 (Nativity Fast 15 Kasım'dan 1-2 hafta önce)

- [ ] ProductHunt değil (kitle orada değil) → Reddit, Orthodox Twitter/X, cemaat bültenleri, Ancient Faith podcast topluluk forumları
- [ ] Launch fiyatı: Pro $3.99 (sonra $5.99)

## Faz 3 — Büyük Perhiz hazırlığı (Aralık 2026 – Şubat 2027)

- [ ] Mağaza yorumlarına göre iterasyon (haftalık minor release ritmi)
- [ ] Yunanca + Romence çeviri (v1.1)
- [ ] Pro içerik: oruca uygun tarif koleksiyonu + haftalık yemek planı görünümü
- [ ] Lent countdown paylaşılabilir görselleri (organik yayılım)
- [ ] Şubat sonu: Lent push — yılın en büyük indirme dalgası

## Faz 4 — Lent sonrası (Nisan 2027+)

- [ ] Barkod tarayıcı (Open Food Facts) — "bu ürün bugünkü oruca uygun mu?"
- [ ] Aziz arama + kamu malı synaxarion içeriği
- [ ] Rusça/Sırpça/Bulgarca
- [ ] Değerlendirme: Helal tarayıcı kardeş uygulaması (aynı kural motoru mimarisi, Müslüman pazar)

## Başarı metrikleri

| Zaman | Hedef |
|---|---|
| Launch + 30 gün | 300+ indirme, 4.5★+, ilk 10 Pro satışı |
| Lent 2027 sonu (Nisan) | 1.500+ indirme, $50+/ay gelir ✅ (ana hedef) |
| 2027 sonu | $150+/ay, 2. dil pazarında çekiş |

## Riskler

- **Kural doğruluğu tartışmaları:** yurisdiksiyonlar arası farklar → çözüm: ayarlarda gelenek seçimi + kaynak şeffaflığı ("OCA rehberini takip eder")
- **Sezonluk trafik:** Lent dışı ölü aylar → çözüm: Çrş/Cum haftalık döngü + widget kalıcılığı
- **Apple/Google gecikmeleri:** launch penceresi kaçarsa → Nativity kaçarsa hedef Lent 2027, panik yok
