# Pazar Analizi — Ortodoks Oruç Asistanı

*Son güncelleme: 2026-07-12 · Kaynaklar: App Store/Play yorumları, Pew/CES Orthodox Studies verileri, web araştırması*

## 1. Pazar büyüklüğü (gerçekçi)

- ABD'de Ortodokslar yetişkin nüfusun ~%1'i; düzenli kiliseye giden çekirdek ~500K-1M kişi.
- **Kitle genç:** cemaatin %62'si 18-45 yaş; 2013 sonrası convert'lerin %62'si 40 yaş altı. 2022-23 erkek convert sayıları istatistiksel aykırı değer düzeyinde yüksek (convert dalgası gerçek).
- Genişleme pazarları: Yunanistan, Romanya, Sırbistan, Bulgaristan, Gürcistan + diaspora (Almanya, Avustralya, Kanada, İngiltere). Küresel Ortodoks ~200-260M ama ödeme gücü ABD/diaspora'da.
- **Gelir beklentisi:** niş iş. Gerçekçi bant ilk yıl $50-200/ay, olgunlukta $150-500/ay. VC hikayesi değil, solo geliştirici işi — hedefle uyumlu.
- Kullanım sıklığı avantajı: yılda ~180-200 oruç günü + her Çarşamba/Cuma = haftada 2+ doğal açılma nedeni.

## 2. Rakipler

| Uygulama | Güçlü yanı | Zayıf yanı |
|---|---|---|
| Orthodox Calendar (Holy Trinity, Android) | Kapsamlı litürjik içerik | 10 yıl önceden kalma UI, Eski takvim varsayılan, İngilizce ikincil |
| Orthodox Calendar † (iOS 1437751976) | Bildirim + widget var | Takvim odaklı, oruç ikincil; aziz araması yok |
| Greek Orthodox Calendar (iOS) | GOARCH resmi verisi | Sadece Yunan geleneği, eski tasarım |
| Orthodox Christian Calendar+ | Rus geleneği detaylı | Abonelikli, yorumlarda "paraya değmez" tepkisi |
| GOARCH Planner | Resmi, takvim entegrasyonu | Uygulama değil, ICS aboneliği; oruç asistanlığı yok |

**Ortak nokta: hepsi TAKVİM uygulaması. "Bugün ne yiyebilirim?" sorusuna optimize edilmiş tek uygulama yok. Barkod/yemek planı hiçbirinde yok.**

## 3. Şikayet → Özellik haritası (mağaza yorumlarından)

| Kullanıcı şikayeti | Bizim cevabımız | Öncelik |
|---|---|---|
| "Çarşamba/Cuma oruçları eksik, insanları yanlış yönlendiriyor" | Kural motoru + orthocal'e karşı 5.000 günlük otomatik doğrulama; Çrş/Cum her zaman işaretli | P0 |
| Eski/Yeni takvim karışıklığı | Onboarding'de zorunlu takvim seçimi; her ekranda seçilen moda göre tutarlı gösterim | P0 |
| "Abonelik paraya değmez" | Tek seferlik Pro satın alma, abonelik yok | P0 |
| "Oruca göre yemek planlayacak görünüm yok" | Ay görünümünde renk kodlu seviyeler + Pro haftalık yemek planı | P1 |
| Eski/çirkin arayüz | Modern, Bizans estetiğinden ilham alan tasarım (ikonografik altın/derin kırmızı paleti) | P1 |
| Aziz araması yok | v2'de arama (P2) | P2 |
| Widget eksikliği | İlk günden widget (Pro) — kalıcılık + farklılaşma | P1 |

## 4. Konumlandırma

> **"The fasting companion, not another calendar."**
> Ana ekran bir soru cevaplar: bugün ne yiyebilirim? Takvim, azizler, okumalar destekleyici katman.

Farklılaştırıcılar (sırayla): (1) yiyecek-öncelikli Today ekranı, (2) çift takvim + gelenek seçimi, (3) tek seferlik fiyat, (4) widget, (5) v2'de barkod tarayıcı — kategoride benzersiz.

## 5. Monetizasyon kararı: Tek seferlik Pro ✅

**Neden abonelik değil:**
- Rakip yorumlarında abonelik nefreti açık ("not worth the money wasted")
- Dini araç kitlesi aboneliği "din üzerinden para sağma" olarak kodluyor; tek seferlik satın alma "geliştiriciyi destekle" olarak kodlanıyor
- Solo geliştirici için churn yönetimi, iptal akışları vs. gereksiz karmaşıklık

**Model:**
- **Free:** Today ekranı, 7 gün ileri görünüm, Çrş/Cum + tüm sezonlar (doğruluk asla kısıtlanmaz), temel bildirimler
- **Pro ($5.99, launch $3.99, non-consumable):** tam yıl takvimi, widget'lar, yemek planı + tarifler, gelişmiş bildirim özelleştirme, tema seçenekleri
- Kural: **oruç bilgisinin doğruluğu/kapsamı asla paywall arkasına konmaz** — kısıtlanan şey konfor özellikleri
- İleri değerlendirme (2027+): tarif içeriği büyürse opsiyonel "içerik aboneliği" eklenebilir, çekirdek Pro tek seferlik kalır

## 6. Dil stratejisi

| Aşama | Diller | Gerekçe |
|---|---|---|
| v1 (Kasım 2026) | 🇬🇧 İngilizce | Ödeyen çekirdek: ABD/UK/AU/CA diaspora + convert'ler. Convert'ler zaten İngilizce kaynak kullanıyor |
| v1.1 (Lent 2027 öncesi) | 🇬🇷 Yunanca, 🇷🇴 Romence | AB pazarları, IAP ödeme alışkanlığı görece iyi; Romanya Avrupa'nın en dindar Ortodoks nüfusu |
| v2 (2027 ortası) | 🇷🇸 Sırpça, 🇧🇬 Bulgarca, 🇷🇺 Rusça | Rusça: büyük kitle ama Google Play ödeme kısıtları + eski takvim baskın (motor zaten destekliyor) |
| Değerlendirme | 🇪🇹 Amharca (Tewahedo) | Devasa oruç kültürü AMA farklı kilise/farklı kurallar = ayrı kural seti, ayrı ürün olabilir; v1 kapsamı DIŞI |

Teknik: ARB/i18n ilk günden; sabit yortu isimleri + UI stringleri çevrilir, kural motoru dilden bağımsız.

## 7. Dağıtım kanalları (ücretsiz)

- r/OrthodoxChristianity (~900K üye) — beta duyurusu + launch (self-promo kurallarına dikkat, önce topluluk üyesi ol)
- Orthodox Twitter/X ve YouTube ekosistemi (mikro-influencer'lara ücretsiz Pro kodu)
- Cemaat bültenleri + Facebook grupları (Yunan/Rus/OCA cemaatleri)
- ASO: "orthodox fasting" araması düşük rekabetli — kategori kelimelerinde ilk 3 gerçekçi
- Sezonluk basın: Lent döneminde dini yayınlar uygulama önerisi listeleri yayınlıyor
