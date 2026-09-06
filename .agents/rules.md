# Özel Kurallar (Genişletilmiş ve Sıkılaştırılmış)

- **İletişim Dili**: Tüm iletişimde kesinlikle Türkçe kullanılmalıdır.
- **Ton**: Sıcak, yapıcı ve empatik bir dil tercih edilmeli; resmi ve soğuk üslup yasaktır.
- **Kodlama İlkeleri**: Ponytail kurallarına tam uyum; mümkün olduğunca az kod, tek satır çözümler, ekstra bağımlılıklar yasaktır.
- **Yerelleştirme**: `easy_localization` zorunludur; tüm metinler `.tr()` ile çevrilebilir olmalı ve sabit stringler doğrudan kod içinde bulunmamalıdır.
- **Tasarım**: Sadece Claymorphism stiline kesinlikle uyulmalı; pastel renk paleti ve belirlenen gölge formülü zorunludur. Koyu tema ve glassmorphism gibi diğer tasarım stilleri yasaktır.
- **UI Basitliği**: Arayüz bileşenleri sade olmalı, gereksiz animasyon, karmaşık layout ve çok katmanlı widgetlar kullanılmamalıdır. Tek bir sorumluluk ilkesine uygun, minimal widget hiyerarşisi.
- **Metin ve UI Slop**: Metinlerde “lorem ipsum”, placeholder vb. sahte içerik yasaktır. Tüm UI etiketleri, butonlar ve açıklamalar anlamlı ve kullanıcı dostu olmalı.
- **Gereksiz Bağımlılıklar**: Projeye yeni paket eklemek sadece standart kütüphane veya Flutter SDK içinde mevcutsa kabul edilecektir; aksi takdirde ekleme yapılmayacak.
- **Kod Yorumları**: `ponytail:` etiketiyle işaretlenmiş kısaltma açıklamaları zorunlu; her kısaltma için sınırlama ve yükseltme yolu belirtilmelidir.
- **Test ve Doğrulama**: Her yeni özellik en az bir basit test ile doğrulanmalı; büyük test paketleri eklemek YAGNI prensibine aykırıdır.
- **Güvenlik ve Erişilebilirlik**: Kullanıcı girişleri doğrulanmalı; UI elementleri erişilebilirlik standartlarına (WCAG) uygun olmalı.

> **Not**: Bu kurallar, proje tutarlılığı ve kalite standardını korumak için uygulanacaktır. İhlal durumunda kod gözden geçirilmeli ve gerekli düzeltmeler yapılmalıdır.
