# 🏠 ATMS - Android Tenant Management System

**ATMS** is a simple yet effective mobile app built with Flutter to manage rental tenants, track rent payments, and streamline landlord workflows. Designed for Android, it features intuitive screens, clean UI, and essential functionality for small property managers.

---

## 📱 Features

### 🧭 Splash + Navigation
- **Landing screen** with app title and a button to go to the Home screen.

### 🏡 Home Screen
- Displays a list of tenants **sorted alphabetically** by:
  - Plot name → House name
- Each list item shows:
  - Tenant's name  
  - Phone number  
  - Buttons:  
    - 📞 **Call** – opens native dialer with tenant’s number  
    - ✏️ **Edit** – edit tenant info  
    - ❌ **Delete** – remove tenant

- **Floating Action Buttons**:
  - ➕ **Add Tenant**
  - 💰 **Manage Payment** – opens rent screen

### 💳 Rent Screen
- Similar tenant list (without phone, edit, delete)
- Each tenant has a **"Monthly Payment"** button
- Tapping it opens a **month selection dialog**:
  - Select a month
  - Tapped month changes color to indicate payment made from Red to Green

---

## 🛠 Tech Stack

- **Flutter** (Dart)
- Built using **VS Code**
- Local storage (SQLite)
- Android native integration for dialer

---

## 📸 Screenshots
---

## 🧑‍💻 Author

**Amos Otieno**  @mohmohrap   
_Android Flutter Developer | Kenya_

---

## 📦 APK

Download latest APK release 👉 

---
