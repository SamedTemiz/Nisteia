# Nisteia — Ortodoks Oruç Asistanı (çalışma adı)

> "Nisteia" (Νηστεία) = Yunanca "oruç". Marka adı henüz kesinleşmedi; alternatifler: FastGuide, Typikon, OrthoFast.

## Proje özeti

Ortodoks Hıristiyanlar için **oruç-öncelikli** mobil uygulama. Ana soru: **"Bugün ne yiyebilirim?"**
Bir takvim uygulaması DEĞİL — mevcut rakiplerin hepsi takvim; biz oruç yaşam asistanıyız.

- **Hedef pazar:** ABD/İngilizce konuşan Ortodoks diaspora + convert'ler (birincil, ödeme gücü yüksek), sonra Yunanistan/Romanya/Balkanlar.
- **İş modeli:** Solo geliştirici, düşük bakım maliyeti, mütevazı gelir hedefi (ilk hedef: $50+/ay).
- **Monetizasyon:** Freemium + tek seferlik Pro satın alma (abonelik YOK — rakip yorumlarındaki en büyük şikayet abonelik).

## Mimari ilkeler (pazarlık edilemez)

1. **Local-first, sunucusuz.** Tüm oruç hesaplaması cihazda çalışır. Backend yok, hesap yok, login yok.
2. **Kural motoru saf Dart** (`lib/core/`) — Flutter'dan bağımsız, %100 unit test kapsamı hedefi. Yanlış oruç bilgisi göstermek bu uygulamanın ölüm sebebi olur (rakip yorumlarındaki 1 numaralı şikayet: eksik/yanlış oruç günleri).
3. **i18n ilk günden** — tüm stringler ARB dosyalarında, hardcoded metin yasak. v1 sadece İngilizce çıkar ama altyapı hazır olur.
4. **Çift takvim desteği ilk günden** — Yeni (Revised Julian) / Eski (Julian) takvim seçimi onboarding'de. Rakiplerin 2 numaralı şikayeti tek takvim desteği.
5. **Teolojik iddia yok.** Uygulama fetva/hüküm vermez; "yaygın uygulama budur, kişisel durumunuz için din adamınıza danışın" tonu. Her ekranda değil, onboarding + ayarlarda bir kez disclaimer.

## Teknoloji

- **Flutter** (iOS + Android tek kod tabanı)
- **Ödeme:** Doğrudan Google Play Billing — resmi `in_app_purchase` eklentisi (tek seferlik IAP, non-consumable). ~~RevenueCat~~ v1'de gereksiz: tek ürün + tek platform + backend-yok ilkesi (karar 2026-07-12)
- **State:** Riverpod
- **Yerel veri:** Gömülü JSON/Dart sabitleri (azizler, kural tabloları); kullanıcı ayarları için shared_preferences
- **Widget'lar:** ~~home_widget paketi~~ Faz 2'ye ertelendi, v1'den kaldırıldı (karar 2026-07-14 — bkz. karar günlüğü); Faz 2'de eklenirken WorkManager ProGuard keep kuralları zorunlu
- Sunucu, veritabanı, analytics SDK şişkinliği yok. Crash raporlama: Firebase Crashlytics (yalnızca bu).

## Veri kaynakları ve lisans kuralları

- **Kural motoru referansı:** [orthocal-python](https://github.com/brianglass/orthocal-python) — **MIT lisanslı**, OCA oruç kurallarını uygular. Kural mantığını Dart'a port etmek serbest (atıf ver).
- **Doğrulama:** orthocal.info API'sine karşı 5.000+ günlük otomatik karşılaştırma testi (`test/validation/`). API'yi runtime'da KULLANMIYORUZ, sadece test zamanında.
- **Paskalya hesabı:** Meeus Julian Paschalion algoritması — kamu malı, cihazda hesaplanır.
- ⚠️ **Ponomar projesi GPL** — kod veya verisini uygulamaya GÖMME. Sadece manuel doğrulama referansı.
- ⚠️ **Aziz hayatları/synaxarion metinleri:** OCA/GOARCH web metinleri telifli. v1'de sadece aziz İSİMLERİ (gerçek bilgisi, telif yok). Uzun biyografiler için kamu malı kaynak veya kendi özetlerimiz (v2).
- Tarif içeriği (Pro): kendi ürettiğimiz içerik, telif sorunu yok.

## Dizin yapısı (hedef)

```
lib/
  core/            # Saf Dart kural motoru — Flutter import YASAK
    paschalion.dart      # Paskalya + hareketli döngü hesabı
    fasting_rules.dart   # Kural motoru (sezonlar, seviyeler, istisnalar)
    calendar_math.dart   # Julian/Gregorian dönüşümleri
    models.dart          # FastLevel, FastReason, DayInfo
  data/            # Gömülü sabit veriler (sabit yortular, aziz isimleri)
  features/        # Ekran bazlı klasörler (today/, calendar/, guide/, settings/, paywall/)
  l10n/            # ARB dosyaları
test/
  core/            # Kural motoru unit testleri
  validation/      # orthocal.info karşılaştırma testleri
docs/              # Analiz ve spesifikasyon belgeleri
```

## Komutlar

- `flutter test` — tüm testler (kural motoru değişikliğinden sonra ZORUNLU)
- `flutter test test/validation` — orthocal karşılaştırması (network gerektirir, CI'da nightly)
- `flutter gen-l10n` — ARB değişikliğinden sonra

## Karar günlüğü

| Tarih | Karar | Gerekçe |
|---|---|---|
| 2026-07-12 | Abonelik yerine tek seferlik Pro | Rakip yorumlarında abonelik nefreti; niş kitle küçük, güven kritik |
| 2026-07-12 | Oruç doğruluğu paywall ARKASINA KONMAZ | Yanlış yönlendirme = ölümcül yorumlar; free katman da %100 doğru |
| 2026-07-12 | ~~v1 dili yalnızca İngilizce~~ GÜNCELLENDİ: v1'de 6 dil (EN + EL/RO/RU/SR/BG) | Kullanıcı kararı — Ortodoks-çoğunluk ülke dilleri baştan destekleniyor. Çeviriler yerli-konuşur incelemesi bekliyor; UK/KA sonraki dalga. Desteklenmeyen sistem dili EN'e düşer |
| 2026-07-12 | Backend yok | Solo geliştirici, bakım maliyeti sıfıra yakın olmalı |
| 2026-07-12 | Barkod tarayıcı v2'ye ertelendi | MVP kapsamını küçük tut; launch penceresi Nativity Fast (15 Kasım 2026) |
| 2026-07-12 | v1 yalnızca Play Store (iOS ertelendi) | Kullanıcı kararı — Apple Developer maliyeti/karmaşası yok; kod tabanı iOS'a hazır kalır, ileride açılır |
| 2026-07-12 | RevenueCat yerine doğrudan `in_app_purchase` | Tek ürün + tek platform + backend-yok: RC'nin çözdüğü problem bizde yok; üçüncü parti bağımlılık ve hesap gereksiz. iOS gelirse yeniden değerlendirilir |
| 2026-07-14 | Android applicationId: `com.nisteia.app` | Play Store'a ilk yüklemeden önce kalıcı seçim (yayından sonra değiştirilemez); `com.nisteia.nisteia` yerine tercih edildi |
| 2026-07-14 | `home_widget` bağımlılığı kaldırıldı, widget işi Faz 2'ye ertelendi | Kod hiç kullanmıyordu ama `androidx.work`'ü transitive çekiyordu; R8 release build'de WorkManager'ın Room veritabanı init'i çöküyordu (`Failed to create an instance of androidx.work.impl.WorkDatabase`) — gerçek cihazda ilk Play sürümünde tespit edildi, kaldırılınca düzeldi |
| 2026-07-14 | Paywall'da yalnızca "Full calendar" teslim edilen özellik olarak gösteriliyor, diğer 3 Pro vaadi "Coming soon" etiketli | Audit, 4 vaatten sadece 1'inin gerçekten kodlanmış olduğunu ortaya çıkardı; yanlış vaat = ölümcül mağaza yorumu riski (bkz. "oruç doğruluğu paywall arkasına konmaz" ilkesi) — dürüstlük hız kaybından önemli |
| 2026-07-14 | Today ekranındaki hamburger menü (drawer) tamamen kaldırıldı | İçinde sadece Ayarlar + Kaynaklar vardı, ikisi de zaten profil ikonundan erişilebiliyordu — gereksiz ikinci giriş noktası |
| 2026-07-15 | Play Console'da kapalı test (closed testing) aşaması atlanıp doğrudan Production'a geçildi | Hesap, Google'ın zorunlu kapalı test eşiğinin altında kaldı; IAP akışı gerçek satın alma ile uçtan uca doğrulandı, ek bir test aşamasına gerek kalmadı |

## İlgili belgeler

- [ROADMAP.md](ROADMAP.md) — fazlar ve tarih hedefleri
- [docs/market-analysis.md](docs/market-analysis.md) — pazar, rakipler, şikayet→özellik haritası, fiyatlama
- [docs/screens.md](docs/screens.md) — ekran spesifikasyonları (tasarım seçimi için)
- [docs/data-sources.md](docs/data-sources.md) — kural motoru tasarımı, algoritma ve veri detayı
