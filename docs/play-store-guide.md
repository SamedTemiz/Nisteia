# Play Store'a Çıkış Rehberi — Nisteia

> Hedef: internal test → kapalı test → production. Launch penceresi: Nativity Fast (15 Kas 2026) öncesi.
> Paket adı: `com.nisteia.nisteia` · IAP ürünü: `nisteia_pro` ($3.99) · Uygulama ücretsiz + tek IAP.

---

## 0. Ön hazırlık (bilgisayarında, ~15 dk)

### 0.1 Upload keystore üret (BİR KEZ — kaybedersen uygulamayı güncelleyemezsin!)
```
cd C:\Users\helmsdeep\MyProjects\nisteia
keytool -genkey -v -keystore android\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Soracakları: **parola** (güçlü seç, parola yöneticisine kaydet), ad-soyad, organizasyon (boş geçilebilir), şehir/ülke (TR).

### 0.2 `android/key.properties` oluştur (gitignore'da, asla commit edilmez)
```
storeFile=../upload-keystore.jks
storePassword=<keystore parolan>
keyAlias=upload
keyPassword=<aynı parola>
```

### 0.3 Yayın paketini derle
```
flutter build appbundle --release
```
Çıktı: `build\app\outputs\bundle\release\app-release.aab` — Play'e yüklenecek dosya bu (APK değil).

### 0.4 Gizlilik politikası URL'si (Play zorunlu tutuyor — veri toplamasak bile)
En kolay yol: repo'ya `PRIVACY.md` ekle → GitHub'da yayınla → URL'sini kullan
(`https://github.com/SamedTemiz/Nisteia/blob/main/PRIVACY.md`).
İçerik özü: *"Nisteia hiçbir kişisel veri toplamaz, iletmez, saklamaz. Hesap yok, analitik yok. Tüm hesaplama cihazda yapılır. Satın almalar Google Play tarafından işlenir."*

---

## 1. Play Console — Uygulama oluştur

**Tüm uygulamalar → Uygulama oluştur**, doldurulacaklar:

| Alan | Değer |
|---|---|
| Uygulama adı | `Nisteia — Orthodox Fasting` (30 karakter sınırı) |
| Varsayılan dil | `İngilizce (ABD) — en-US` (hedef pazar ABD diasporası) |
| Uygulama mı oyun mu | Uygulama |
| Ücretsiz mi ücretli mi | **Ücretsiz** (para IAP'den; "ücretli" seçersen sonradan ücretsize çeviremezsin ama tersi olur) |
| Beyanlar | Geliştirici Program Politikaları + ABD ihracat yasaları → onayla |

---

## 2. "Uygulamayı kur" (Set up your app) kontrol listesi

Panelde sırayla dolduracakların:

### 2.1 Gizlilik politikası
- URL: yukarıdaki GitHub linki.

### 2.2 Uygulama erişimi (App access)
- **"Tüm işlevler kısıtlama olmadan kullanılabilir"** — login yok, hepsi açık.

### 2.3 Reklamlar
- **Reklam yok.**

### 2.4 İçerik derecelendirmesi (IARC anketi)
- E-posta: kendi adresin. Kategori: **"Referans, haber veya eğitim"**.
- Şiddet/cinsellik/kumar/uyuşturucu/küfür: hepsine **Hayır**.
- "Din veya inançla ilgili içerik var mı?" → **Evet, referans amaçlı** (uygulama ibadet takvimi referansı).
- Sonuç: "Herkes / PEGI 3" civarı çıkar.

### 2.5 Hedef kitle (Target audience)
- Yaş: **18 ve üzeri** seç (en temizi; çocuklara yönelik değiliz → "çocuklara hitap ediyor mu" = Hayır).

### 2.6 Veri güvenliği (Data safety) — bizim en güçlü yanımız
- Veri topluyor musun? → **Hayır**
- Veri paylaşıyor musun? → **Hayır**
- (Satın alma Google Play üzerinden; uygulama kendisi hiçbir veri işlemez. Crashlytics EKLEMEDİK, o yüzden bu beyan %100 doğru.)

### 2.7 Devlet uygulaması / Finans / Sağlık
- Hepsi **Hayır**.

### 2.8 Uygulama kategorisi & iletişim
| Alan | Değer |
|---|---|
| Kategori | **Yaşam Tarzı (Lifestyle)** |
| Etiketler | Lifestyle, Events |
| İletişim e-postası | hello@nisteia.app (ya da kişisel adres — mağazada görünür) |
| Web sitesi | GitHub repo veya boş |

---

## 3. Mağaza girişi (Store listing) — metinler hazır

| Alan | Sınır | Önerilen içerik |
|---|---|---|
| Kısa açıklama | 80 kr | `What can I eat today? Orthodox fasting guide — accurate, private, no subscription.` |
| Tam açıklama | 4000 kr | Aşağıdaki taslak ↓ |

**Tam açıklama taslağı (EN):**
```
Nisteia answers one question at a glance: what can I eat today?

• Today screen — fasting level, allowed foods (meat, dairy, fish, wine, oil), the reason, and the saints of the day
• Color-coded monthly calendar — plan meals and shopping for the whole fast
• Seasons — countdown to the next fast, progress through the current one
• Food guide — what's allowed and avoided today, including the shellfish rule that surprises everyone
• New AND Old Calendar support — choose during setup
• 6 languages: English, Greek, Romanian, Russian, Serbian, Bulgarian

Accurate by design: fasting rules follow the OCA guide, computed entirely on your
device and validated day-by-day against orthocal.info across 14 years with zero
mismatches. Fasting accuracy is never behind a paywall.

Private by design: no account, no login, no ads, no analytics. Nothing leaves
your phone.

Nisteia Pro (one-time $3.99, NO subscription): unlimited calendar years,
home-screen widgets, meal planner and fasting recipes.

Fasting practice is personal — consult your priest for your own situation.
```

**Görseller (yüklemeden yayın olmaz):**
| Varlık | Boyut | Not |
|---|---|---|
| Uygulama ikonu | 512×512 PNG | Hazır: `assets/icon/ic_legacy.png`'den üret (1024→512) |
| Feature graphic | 1024×500 PNG/JPG | Koyu zemin + altın haç + "What can I eat today?" — istersen üretirim |
| Telefon ekran görüntüleri | En az 2 (öneri 4-6), 16:9 veya 9:16 | Today, Calendar, Seasons, Guide, dil seçici — emülatörden alırız |

---

## 4. Para: IAP ürünü + ödeme profili

1. **Ödeme profili** (Play Console → Kurulum → Ödeme profili): IAP satmak için zorunlu.
   İstenenler: ad/adres, **banka hesabı (IBAN)**, vergi bilgileri (bireysel geliştirici olarak beyan edilir; ABD vergi formu W-8BEN çıkar — bireysel için 5 dk).
2. **Ürün oluştur** (Para kazanma → Uygulama içi ürünler → Ürün oluştur):
   | Alan | Değer |
   |---|---|
   | Ürün kimliği | `nisteia_pro` (kodla birebir aynı — DEĞİŞTİRME) |
   | Ad | `Nisteia Pro` |
   | Açıklama | `One-time unlock: full calendar, widgets, meal planner. No subscription.` |
   | Fiyat | $3.99 (launch sonrası $5.99'a yükseltilebilir) |
   | Tür | Tek seferlik (managed/non-consumable) |
   → **Etkinleştir**'e basmayı unutma.

---

## 5. Test ve yayın sırası

1. **Internal testing** (aynı gün): AAB yükle → kendi Gmail'ini test kullanıcısı ekle → linkten yükle, gerçek cihazda doğrula (özellikle: bildirimler, satın alma akışı — Kurulum → Lisans testi'ne Gmail'ini ekle ki test satın alması ücretsiz olsun).
2. **Closed testing**: ⚠️ **Kasım 2023'ten sonra açılmış bireysel hesaplarda zorunlu**: production'a geçmeden önce **12+ testçiyle 14 gün kesintisiz** kapalı test şartı var. Hesabın eskiyse bu şart yok. Testçi kaynağı: r/OrthodoxChristianity, cemaat grupları (ROADMAP Faz 2 planı zaten bu).
3. **Production**: AAB + sürüm notları → **incelemeye gönder**. İlk inceleme 1-7 gün sürer (yeni hesapta uzayabilir). Kademeli yayın (%20 → %100) önerilir.

**Sürüm notu taslağı (v0.1.0):**
```
First release: fasting-first Orthodox companion.
Today screen, color-coded calendar, seasons countdown, food guide,
New/Old calendar, 6 languages. No account, no ads, no subscription.
```

---

## 6. Yayın sonrası ilk hafta

- Play Console → Yorumlar: **her yoruma cevap ver** (güven = bu niş için her şey).
- Kural hatası bildirimi gelirse: `hello@nisteia.app` → motoru orthocal'a karşı test et → 48 saat içinde yama.
- Sıralama anahtar kelimeleri zaten başlık+açıklamada: *orthodox fasting, orthodox calendar, lent*.

## Sık yapılan hatalar (bizden kaçınılmış olanlar ✓)
- ✓ Ürün ID kod/console uyuşmazlığı (`nisteia_pro` sabit)
- ✓ Veri güvenliği beyanı ile gerçek davranış çelişkisi (hiç veri toplamıyoruz)
- ⚠️ Keystore kaybı → güncelleme imkânsız. `upload-keystore.jks` + parolasını **iki ayrı yerde** yedekle (parola yöneticisi + harici disk). Google "Play App Signing" kullandığı için upload key kaybında kurtarma başvurusu mümkün ama haftalar sürer.
