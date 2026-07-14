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
- [x] Tek seferlik Pro IAP — doğrudan Google Play Billing (`in_app_purchase`, RevenueCat yok, karar 2026-07-12), Play Console'da `nisteia_pro` ürünü ($3.99) oluşturuldu, **gerçek satın alma ile uçtan uca test edildi ve başarılı** (2026-07-15). Paywall'da yalnızca teslim edilen özellik (full calendar) gösteriliyor, kalan 3 vaat "Coming soon" etiketli (karar 2026-07-14, `lib/features/paywall/paywall.dart`)
- [x] Bildirimler: akşamdan "yarın oruç" + sezon başlangıçları → `flutter_local_notifications` bağlandı (`lib/app/notification_service.dart`), onboarding tamamlanınca ve ayar değişince otomatik yeniden zamanlanıyor (`lib/main.dart` `_RootGate`). Web'de ve testlerde güvenli no-op (best-effort, try/catch ile uygulamayı asla çökertmez). ⚠️ Gerçek cihazda bildirim ateşlemesi bu ortamda (Android SDK cmdline-tools/emulator yok) doğrulanamadı — kod derleniyor ve mantık test edildi, ama gerçek cihaz testi gerekiyor.

- [x] Modern geçişler: sekmeler arası Material fade-through (state korunur — takvim ayı/scroll kaybolmaz, `lib/app/home_shell.dart`), push edilen sayfalarda shared-axis (`animations` paketi, tema seviyesinde `lib/theme/app_theme.dart`)
- [x] "Hata bildir" gerçek mailto linki (`url_launcher`; mail uygulaması yoksa adresli dialog'a düşer)
- [x] Kaynaklar & atıf ekranı (`lib/features/settings/sources_screen.dart`), Ayarlar'dan erişilebilir. Today ekranındaki hamburger menü (drawer) **tamamen kaldırıldı** (karar 2026-07-14) — içeriği zaten profil ikonundan (Ayarlar) erişilebiliyordu, gereksiz ikinci giriş noktasıydı
- [x] **Çoklu dil**: EN + EL/RO/RU/SR/BG ARB'leri, Settings'te dil seçici (sistem varsayılanı destekli), tüm tarihler locale-aware, hardcoded string ihlalleri temizlendi (seasons/settings/paywall/calendar). Desteklenmeyen sistem dili artık İngilizce'ye düşüyor (alfabetik-ilk-dil hatası düzeltildi). ⚠️ Çeviriler yerli konuşur incelemesi bekliyor; UK/KA (Ukraynaca/Gürcüce) sonraki dalga.
- [x] Today durum kartına hafif blurlu kamu malı ikon arka planı (6. yy Sina Pantokrator'u, Wikimedia PD — `assets/images/ATTRIBUTION.md`)

**Durum: Faz 1 TAMAMLANDI.** 6 ekran + navigasyon + onboarding + gerçek Google Play Billing + local notifications + modern geçişler çalışıyor; `flutter analyze` temiz, 68 test yeşil. Bildirimler ve satın alma gerçek cihazda doğrulandı. **Uygulama 2026-07-15'te Play Store Production'a gönderildi ve gerçek satın alma testiyle onaylandı** (ayrıntılar Faz 2'de).

## Faz 2 — Play Store yayını ✅ TAMAMLANDI (2026-07-14 – 2026-07-15, planlanandan ~3 ay erken)

> ⚠️ 2026-07-12 kararı: **v1 yalnızca Play Store** — iOS işleri ertelendi (kod tabanı hazır kalır).
> Not: Beta/kapalı test aşaması resmi olarak yapılmadı — hesap Google'ın zorunlu kapalı test eşiğinin altında kaldı, doğrudan Production'a geçildi (karar 2026-07-15). Formal ASO/beta geri bildirim döngüsü Faz 3'e kaydı.

- [x] Play Console hesabı oluşturuldu, ödeme profili (bireysel) kuruldu
- [x] Upload keystore üretildi (`keytool`) + `android/key.properties` (kullanıcı tarafından, gitignored)
- [x] Android package ID kararı: `com.nisteia.app` (karar 2026-07-14)
- [x] Release build sertlendirmesi: `isMinifyEnabled`/`isShrinkResources` açık, R8 keep kuralları (`android/app/proguard-rules.pro`) — `flutter_local_notifications`, Play Billing, WorkManager/Room için
- [x] Release-only crash bulundu ve düzeltildi: kullanılmayan `home_widget` bağımlılığı → `androidx.work` → R8 altında WorkManager Room DB init hatası. Kaldırıldı (widget işi Faz 2.5/3'e ertelendi), gerçek cihazda `adb`/logcat ile doğrulandı
- [x] Mağaza görselleri: feature graphic (1024×500, `assets/images/banner.jpg`, `nisteia-banner-2.jpg`), ekran görüntüleri, uygulama simgesi
- [x] İçerik beyanları: içerik sınıflandırması, hedef kitle (18+), gizlilik politikası (`PRIVACY.md`, GitHub üzerinden), reklam beyanı (yok), sağlık uygulamaları beyanı, veri güvenliği anketi
- [x] Tüm ülkeler/bölgeler seçildi (diaspora hedefi — coğrafi kısıtlama yok)
- [x] `nisteia_pro` IAP ürünü oluşturuldu ve etkinleştirildi ($3.99, tek seferlik)
- [x] **Production'a gönderildi ve gerçek satın alma ile uçtan uca doğrulandı** (2026-07-15)
- [ ] Home screen widget (Android AppWidget) — Pro özelliği, `home_widget` paketiyle birlikte tekrar eklenecek (Faz 3'e kaydı)
- [ ] Formal ASO (anahtar kelime optimizasyonu) ve topluluk beta geri bildirim döngüsü — launch sonrası, Faz 3

## 🚀 Launch — GERÇEKLEŞTİ: 2026-07-15 (Nativity Fast hedefinden ~4 ay erken)

- [x] Launch fiyatı: Pro $3.99 (sonra $5.99'a çıkarılabilir)
- [ ] Topluluk duyurusu: Reddit (r/OrthodoxChristianity), Orthodox Twitter/X, cemaat bültenleri, Ancient Faith podcast forumları — henüz yapılmadı, ProductHunt değil (kitle orada değil)
- [ ] Destek e-postası: kod içindeki `hello@nisteia.app` placeholder'ı gerçek bir adrese (Gmail veya domain) bağlanacak

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
