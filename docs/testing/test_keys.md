# Dictionary of Test Keys (ValueKey)
File ini berisi daftar `ValueKey` yang disematkan ke dalam UI M-SPEED untuk keperluan *Flutter Integration Test*.

## Naming Convention
Seluruh key ditulis menggunakan string dengan pola hierarki: `[module].[component].[action_or_field]`
*Contoh*: `login.email`, `admin.buyer.list.item`, `admin.receiver.save`.

---

## 1. Modul Login (`lib/src/auth/view/login_view.dart`)
- **Email Field**: `ValueKey('login.email')`
- **Password Field**: `ValueKey('login.password')`
- **Tombol Submit Login**: `ValueKey('login.submit')`

## 2. Shared Admin Form (`lib/src/admin/user/view/admin_form_widgets.dart`)
Komponen reusable `AdminFormField` kini mewarisi properti `key` ke dalam `TextFormField` pembungkusnya, sehingga field form pada Modul Admin dapat diakses langsung menggunakan identifier dari masing-masing halaman view.

## 3. Komponen Shared Utama
- **CustomTextField (`lib/common/component/custom_textfield.dart`)**: Mendukung parsing properti `key` ke `TextFormField`.
- **CustomButton (`lib/common/component/custom_button.dart`)**: Mendukung parsing properti `key` ke `ElevatedButton`.

## Penggunaan di Masa Depan
Bila Anda menambahkan fitur baru, pastikan untuk menggunakan standar penamaan di atas (contoh: `admin.dashboard.menu.buyer`) agar skrip *End-to-End* (`integration_test`) tidak mudah rusak bila terjadi perombakan *layout* antarmuka (misalnya merubah posisi form).
