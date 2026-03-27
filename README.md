# doupark-system
Akıllı Otopark Takip Sistemi
🚀 Proje Açıklaması

DouPark, kullanıcıların otopark doluluk durumunu görüntüleyebildiği ve rezervasyon oluşturabildiği bir akıllı otopark sistemidir.

Bu proje fullstack olarak geliştirilmiştir:

Frontend: Flutter
Backend: Spring Boot
Veritabanı: PostgreSQL (Docker ile)


🔐 Kimlik Doğrulama Sistemi
Kullanıcı kayıt (register) sistemi geliştirildi
Kullanıcı giriş (login) sistemi geliştirildi
Şifreler BCrypt ile şifrelenerek saklandı
JWT (JSON Web Token) ile güvenli oturum yapısı kuruldu

🗄️ Veritabanı
PostgreSQL Docker container üzerinde kuruldu
users tablosu oluşturuldu
Kullanıcı verileri veritabanına kaydedildi
Backend ile veritabanı bağlantısı sağlandı (Spring Data JPA)

🖥️ Backend (Spring Boot)
REST API geliştirildi
/api/auth/register → kullanıcı kayıt
/api/auth/login → kullanıcı giriş
JWT üretimi ve doğrulama mekanizması eklendi
CORS ve security ayarları yapılandırıldı

📱 Frontend (Flutter)
Login ve Register ekranları geliştirildi
API ile bağlantı kuruldu
HTTP istekleri ile backend’e veri gönderildi
Kullanıcı giriş ve kayıt işlemleri arayüz üzerinden çalışır hale getirildi

🔄 Proje Yapısı
douparksystem/
 ├── backend/   → Spring Boot API
 ├── frontend/  → Flutter uygulaması

⚙️ Kullanılan Teknolojiler
Java (Spring Boot)
Flutter (Dart)
PostgreSQL
Docker
JWT Authentication

🎯 Proje Durumu
✔️ Kayıt ve giriş sistemi çalışıyor
✔️ Veritabanı entegrasyonu tamamlandı
✔️ Frontend & Backend bağlantısı sağlandı

🚀 Geliştirme Planı
Token saklama (kalıcı login)
Rezervasyon sistemi geliştirme
Kullanıcı profil ekranı
Yetkilendirme (role-based access)