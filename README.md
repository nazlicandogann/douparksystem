# 🚗 DouPark - Akıllı Otopark Sistemi

DouPark, kullanıcıların otopark doluluk durumunu görüntüleyebildiği ve rezervasyon oluşturabildiği **fullstack bir akıllı otopark uygulamasıdır.**

---

## 🚀 Proje Özeti

- 📱 **Frontend:** Flutter  
- ⚙️ **Backend:** Spring Boot  
- 🗄️ **Database:** PostgreSQL (Docker)  
- 🔐 **Authentication:** JWT + BCrypt  

---

## 🔐 Kimlik Doğrulama

- Kullanıcı kayıt (register)
- Kullanıcı giriş (login)
- Şifreler BCrypt ile hashlenir
- JWT ile güvenli oturum yönetimi

---

## 🗄️ Veritabanı

- PostgreSQL Docker container üzerinde çalışır
- `users` tablosu oluşturulmuştur
- Spring Data JPA ile bağlantı sağlanmıştır

---

## ⚙️ Backend (Spring Boot)

- REST API geliştirilmiştir
- `/api/auth/register` → kullanıcı kayıt
- `/api/auth/login` → kullanıcı giriş
- JWT üretimi ve doğrulama yapılır
- CORS ve security ayarları yapılandırılmıştır

---

## 📱 Frontend (Flutter)

- Login ve Register ekranları
- API entegrasyonu
- HTTP istekleri ile backend bağlantısı
- Kullanıcı işlemleri UI üzerinden çalışır

---

## 📂 Proje Yapısı
douparksystem/
├── backend/ # Spring Boot API
└── frontend/ # Flutter App

---

## 🛠️ Kullanılan Teknolojiler

- Java (Spring Boot)
- Flutter (Dart)
- PostgreSQL
- Docker
- JWT Authentication

---

## ✅ Mevcut Durum

- ✔️ Kayıt sistemi çalışıyor
- ✔️ Giriş sistemi çalışıyor
- ✔️ Veritabanı bağlantısı aktif
- ✔️ Frontend & Backend entegre

---

## 🚀 Geliştirme Planı

- 🔐 Token saklama (auto login)
- 📅 Rezervasyon sistemi
- 👤 Kullanıcı profil ekranı
- 🔑 Role-based authorization

---

## 📌 Not

Bu proje fullstack geliştirme pratiği amacıyla yapılmıştır.