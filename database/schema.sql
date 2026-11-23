-- ============================================================
-- FoodSave P13: DDL MySQL/MariaDB + data dummy
-- Sumber: Bab IV laporan P13 (ERD, relasi, kamus data). Kelompok 4 IP 4.
-- Cara pakai (phpMyAdmin): Import file ini, atau jalankan:  mysql -u root < database/schema.sql
-- Catatan: kolom created_at/updated_at (dan email_verified_at, remember_token pada users)
-- adalah kolom bawaan Laravel. Tabel bawaan framework (sessions, cache, jobs, dst.)
-- dibuat oleh `php artisan migrate`, bukan oleh file ini.
-- ============================================================

CREATE DATABASE IF NOT EXISTS foodsave_asp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE foodsave_asp;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS reviews, order_items, orders, products, categories, merchant_locations, merchants, users, roles;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- 1. DDL
-- ============================================================
CREATE TABLE roles (
  role_id     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  role_name   VARCHAR(30)     NOT NULL,
  created_at  TIMESTAMP NULL DEFAULT NULL,
  updated_at  TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (role_id),
  UNIQUE KEY uq_roles_role_name (role_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE users (
  user_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  role_id            BIGINT UNSIGNED NOT NULL,
  name               VARCHAR(100)    NOT NULL,
  email              VARCHAR(120)    NOT NULL,
  email_verified_at  TIMESTAMP NULL DEFAULT NULL,
  password_hash      VARCHAR(255)    NOT NULL,
  status             VARCHAR(20)     NOT NULL DEFAULT 'aktif',
  remember_token     VARCHAR(100)    NULL,
  created_at         TIMESTAMP NULL DEFAULT NULL,
  updated_at         TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (user_id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_role_id (role_id),
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles (role_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_users_status CHECK (status IN ('aktif','nonaktif'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE merchants (
  merchant_id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id              BIGINT UNSIGNED NOT NULL,
  business_name        VARCHAR(120)    NOT NULL,
  verification_status  VARCHAR(20)     NOT NULL DEFAULT 'menunggu',
  created_at           TIMESTAMP NULL DEFAULT NULL,
  updated_at           TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (merchant_id),
  UNIQUE KEY uq_merchants_user_id (user_id),
  CONSTRAINT fk_merchants_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_merchants_verification CHECK (verification_status IN ('menunggu','terverifikasi','ditolak'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE merchant_locations (
  location_id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  merchant_id  BIGINT UNSIGNED NOT NULL,
  address      VARCHAR(255)    NOT NULL,
  city         VARCHAR(100)    NOT NULL,
  province     VARCHAR(100)    NOT NULL,
  latitude     DECIMAL(10,7)   NULL,
  longitude    DECIMAL(10,7)   NULL,
  created_at   TIMESTAMP NULL DEFAULT NULL,
  updated_at   TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (location_id),
  KEY idx_locations_merchant_id (merchant_id),
  KEY idx_locations_city (city, province),
  CONSTRAINT fk_locations_merchant FOREIGN KEY (merchant_id) REFERENCES merchants (merchant_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE categories (
  category_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_name  VARCHAR(50)     NOT NULL,
  created_at     TIMESTAMP NULL DEFAULT NULL,
  updated_at     TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (category_id),
  UNIQUE KEY uq_categories_name (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE products (
  product_id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  location_id      BIGINT UNSIGNED NOT NULL,
  category_id      BIGINT UNSIGNED NOT NULL,
  product_name     VARCHAR(150)    NOT NULL,
  description      TEXT            NULL,
  photo_url        VARCHAR(255)    NULL,
  normal_price     DECIMAL(12,2)   NOT NULL,
  discount_price   DECIMAL(12,2)   NOT NULL,
  stock            INT             NOT NULL DEFAULT 0,
  pickup_deadline  DATETIME        NOT NULL,
  status           VARCHAR(20)     NOT NULL DEFAULT 'aktif',
  created_at       TIMESTAMP NULL DEFAULT NULL,
  updated_at       TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (product_id),
  KEY idx_products_location_id (location_id),
  KEY idx_products_category_id (category_id),
  KEY idx_products_status_deadline (status, pickup_deadline),
  CONSTRAINT fk_products_location FOREIGN KEY (location_id) REFERENCES merchant_locations (location_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories (category_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_products_normal_price CHECK (normal_price > 0),
  CONSTRAINT chk_products_discount CHECK (discount_price >= 0 AND discount_price <= normal_price),
  CONSTRAINT chk_products_stock CHECK (stock >= 0),
  CONSTRAINT chk_products_status CHECK (status IN ('aktif','nonaktif'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE orders (
  order_id      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  merchant_id   BIGINT UNSIGNED NOT NULL,
  order_code    VARCHAR(30)     NOT NULL,
  order_date    DATETIME        NOT NULL,
  order_status  VARCHAR(30)     NOT NULL DEFAULT 'dipesan',
  total_amount  DECIMAL(12,2)   NOT NULL DEFAULT 0,
  created_at    TIMESTAMP NULL DEFAULT NULL,
  updated_at    TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (order_id),
  UNIQUE KEY uq_orders_order_code (order_code),
  KEY idx_orders_user_id (user_id),
  KEY idx_orders_merchant_id (merchant_id),
  KEY idx_orders_status (order_status),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_orders_merchant FOREIGN KEY (merchant_id) REFERENCES merchants (merchant_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_orders_status CHECK (order_status IN ('dipesan','disiapkan','selesai','dibatalkan')),
  CONSTRAINT chk_orders_total CHECK (total_amount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE order_items (
  order_item_id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id       BIGINT UNSIGNED NOT NULL,
  product_id     BIGINT UNSIGNED NOT NULL,
  quantity       INT             NOT NULL,
  unit_price     DECIMAL(12,2)   NOT NULL,
  subtotal       DECIMAL(12,2)   NOT NULL,
  created_at     TIMESTAMP NULL DEFAULT NULL,
  updated_at     TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (order_item_id),
  UNIQUE KEY uq_order_items_order_product (order_id, product_id),
  KEY idx_order_items_product_id (product_id),
  CONSTRAINT fk_order_items_order FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products (product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_order_items_quantity CHECK (quantity > 0),
  CONSTRAINT chk_order_items_price CHECK (unit_price >= 0),
  CONSTRAINT chk_order_items_subtotal CHECK (subtotal = quantity * unit_price)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE reviews (
  review_id    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id     BIGINT UNSIGNED NOT NULL,
  user_id      BIGINT UNSIGNED NOT NULL,
  rating       TINYINT UNSIGNED NOT NULL,
  review_text  TEXT NULL,
  created_at   TIMESTAMP NULL DEFAULT NULL,
  updated_at   TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (review_id),
  UNIQUE KEY uq_reviews_order_id (order_id),
  KEY idx_reviews_user_id (user_id),
  CONSTRAINT fk_reviews_order FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_reviews_user FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. DATA DUMMY (tanpa data pribadi nyata; semua akun memakai kata sandi uji FoodSaveUji2026)
--    roles 3 | categories 7 | users 51 | merchants 30 | merchant_locations 34 | products 40
--    orders 45 | order_items 60 | reviews 22
-- ============================================================

INSERT INTO roles (role_id, role_name, created_at, updated_at) VALUES
  (1, 'konsumen', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 'mitra', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 'admin', '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO categories (category_id, category_name, created_at, updated_at) VALUES
  (1, 'Flash Deal', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 'Makanan Berat', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 'Bakery & Pastry', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (4, 'Dessert', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (5, 'Minuman', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (6, 'Snack', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (7, 'Healthy Food', '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO users (user_id, role_id, name, email, status, password_hash, email_verified_at, created_at, updated_at) VALUES
  (1, 3, 'Admin FoodSave', 'admin@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 2, 'Ratna Wulandari', 'mitra@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 2, 'Aminah Lubis', 'aminah.lubis@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (4, 2, 'Hendri Saputra', 'hendri.saputra@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (5, 2, 'Yusrizal Hakim', 'yusrizal.hakim@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (6, 2, 'Rina Marlina', 'rina.marlina@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (7, 2, 'Ucok Siregar', 'ucok.siregar@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (8, 2, 'Dedi Kurniawan', 'dedi.kurniawan@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (9, 2, 'Linda Susanti', 'linda.susanti@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (10, 2, 'Fitri Handayani', 'fitri.handayani@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (11, 2, 'Rahmat Hidayat', 'rahmat.hidayat@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (12, 2, 'Eko Prasetyo', 'eko.prasetyo@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (13, 2, 'Nurhayati', 'nurhayati@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (14, 2, 'Marlina Sari', 'marlina.sari@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (15, 2, 'Dewi Anggraini', 'dewi.anggraini@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (16, 2, 'Eli Rosdiana', 'eli.rosdiana@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (17, 2, 'Fajar Ramadhan', 'fajar.ramadhan@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (18, 2, 'Syahrul Azhar', 'syahrul.azhar@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (19, 2, 'Taufik Hidayah', 'taufik.hidayah@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (20, 2, 'Wahyu Nugroho', 'wahyu.nugroho@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (21, 2, 'Ayu Lestari', 'ayu.lestari@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (22, 2, 'Yani Mulyani', 'yani.mulyani@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (23, 2, 'Imam Santoso', 'imam.santoso@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (24, 2, 'Mardiana', 'mardiana@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (25, 2, 'Darwis Putra', 'darwis.putra@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (26, 2, 'Lestari Ningsih', 'lestari.ningsih@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (27, 2, 'Bayu Aji', 'bayu.aji@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (28, 2, 'Hendra Gunawan', 'hendra.gunawan@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (29, 2, 'Sumarni', 'sumarni@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (30, 2, 'Dian Permata', 'dian.permata@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (31, 2, 'Zulkifli', 'zulkifli@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (32, 1, 'Aulia Rahmadani', 'konsumen@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (33, 1, 'Rizky Pratama', 'rizky.pratama@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (34, 1, 'Nabila Putri', 'nabila.putri@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (35, 1, 'Dimas Aditya', 'dimas.aditya@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (36, 1, 'Salsabila Azzahra', 'salsabila.azzahra@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (37, 1, 'Fikri Ramadhan', 'fikri.ramadhan@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (38, 1, 'Putri Maharani', 'putri.maharani@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (39, 1, 'Andika Saputra', 'andika.saputra@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (40, 1, 'Nur Aini', 'nur.aini@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (41, 1, 'Bagas Firmansyah', 'bagas.firmansyah@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (42, 1, 'Citra Dewi', 'citra.dewi@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (43, 1, 'Raka Mahendra', 'raka.mahendra@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (44, 1, 'Tiara Oktaviani', 'tiara.oktaviani@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (45, 1, 'Galih Prakoso', 'galih.prakoso@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (46, 1, 'Mutiara Sari', 'mutiara.sari@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (47, 1, 'Ilham Maulana', 'ilham.maulana@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (48, 1, 'Sekar Ayu', 'sekar.ayu@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (49, 1, 'Yoga Pratama', 'yoga.pratama@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (50, 1, 'Wulan Safitri', 'wulan.safitri@foodsave.test', 'aktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (51, 1, 'Farhan Hakim', 'farhan.hakim@foodsave.test', 'nonaktif', '$2y$12$.t/Di36C0JVlDX1XQa/NTeem0H.Lnv8pVE5ZEg20hWCFAN1YdDR9O', '2026-11-18 08:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO merchants (merchant_id, user_id, business_name, verification_status, created_at, updated_at) VALUES
  (1, 2, 'Warung Nasi Bu Ratna', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 3, 'Dapur Mak Ngah Telanai', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 4, 'Pindang Patin Batanghari', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (4, 5, 'Nasi Gemuk Kenali', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (5, 6, 'Kantin Mendalo Raya', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (6, 7, 'Ayam Penyet Pak Ucok', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (7, 8, 'Mie Ayam Pangsit Sungai Kambang', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (8, 9, 'Dimsum Seberang Kita', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (9, 10, 'Dimsum Pagi Sore', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (10, 11, 'Roti Bakar Simpang Rimbo', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (11, 12, 'Bakery Angso Duo', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (12, 13, 'Toko Roti Telanaipura', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (13, 14, 'Kue Basah Bu Eli', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (14, 15, 'Donat Kampus Mendalo', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (15, 16, 'Es Cendol Tugu Juang', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (16, 17, 'Kedai Kopi Telanai', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (17, 18, 'Jus Segar Jelutung', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (18, 19, 'Martabak Telur Pasar Kota', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (19, 20, 'Risoles & Pastel Bu Yani', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (20, 21, 'Roti Jala Kari Mak Cik', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (21, 22, 'Healthy Bowl Jambi', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (22, 23, 'Salad Buah Segar Aurduri', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (23, 24, 'Puding & Dessert Box Jambi', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (24, 25, 'Brownies Kukus Ibu Dewi', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (25, 26, 'Nasi Kotak Sayur Lestari', 'terverifikasi', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (26, 27, 'Boba Corner Kampus', 'menunggu', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (27, 28, 'Pisang Goreng Madu Bu Mar', 'menunggu', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (28, 29, 'Teh Tarik Mendalo', 'menunggu', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (29, 30, 'Keripik Tempe Pak Dar', 'ditolak', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (30, 31, 'Sate Padang Pak Hendra', 'menunggu', '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO merchant_locations (location_id, merchant_id, address, city, province, latitude, longitude, created_at, updated_at) VALUES
  (1, 1, 'Jl. Jambi - Muara Bulian KM 15, Mendalo Darat No. 41', 'Muaro Jambi', 'Jambi', -1.6207698, 103.5271419, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 2, 'Jl. Telanaipura Raya No. 114', 'Jambi', 'Jambi', -1.6114274, 103.5816165, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 3, 'Jl. Gatot Subroto No. 54', 'Jambi', 'Jambi', -1.5986651, 103.6119125, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (4, 4, 'Jl. Slamet Riyadi No. 100', 'Jambi', 'Jambi', -1.5992754, 103.620041, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (5, 5, 'Jl. Lintas Jambi - Muara Bulian, Mendalo Darat No. 57', 'Muaro Jambi', 'Jambi', -1.6239208, 103.5283705, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (6, 6, 'Jl. Jambi - Muara Bulian KM 15, Mendalo Darat No. 37', 'Muaro Jambi', 'Jambi', -1.6169989, 103.5263959, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (7, 7, 'Jl. Hayam Wuruk No. 115', 'Jambi', 'Jambi', -1.6025929, 103.6171756, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (8, 8, 'Jl. Kolonel Abunjani No. 51', 'Jambi', 'Jambi', -1.6199395, 103.6291965, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (9, 9, 'Jl. Prof. Dr. Sri Soedewi Masjchun Sofwan, Mendalo Indah No. 104', 'Muaro Jambi', 'Jambi', -1.6222839, 103.5299516, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (10, 10, 'Jl. Slamet Riyadi No. 10', 'Jambi', 'Jambi', -1.6010755, 103.5935866, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (11, 11, 'Jl. Gatot Subroto No. 38', 'Jambi', 'Jambi', -1.6184959, 103.5956355, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (12, 12, 'Jl. Jenderal Sudirman, Telanaipura No. 91', 'Jambi', 'Jambi', -1.6035374, 103.576944, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (13, 13, 'Jl. Hayam Wuruk No. 91', 'Jambi', 'Jambi', -1.6152462, 103.6084429, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (14, 14, 'Jl. Jambi - Muara Bulian KM 15, Mendalo Darat No. 52', 'Muaro Jambi', 'Jambi', -1.6161084, 103.5276534, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (15, 15, 'Jl. Hayam Wuruk No. 15', 'Jambi', 'Jambi', -1.6129823, 103.622102, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (16, 16, 'Jl. Jenderal Sudirman, Telanaipura No. 113', 'Jambi', 'Jambi', -1.6071435, 103.5866681, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (17, 17, 'Jl. Orang Kayo Hitam No. 109', 'Jambi', 'Jambi', -1.6132014, 103.6270493, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (18, 18, 'Jl. Raden Mattaher No. 66', 'Jambi', 'Jambi', -1.6092805, 103.591015, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (19, 19, 'Jl. Jambi - Muara Bulian KM 15, Mendalo Darat No. 99', 'Muaro Jambi', 'Jambi', -1.625252, 103.5215867, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (20, 20, 'Jl. Lintas Jambi - Muara Bulian, Mendalo Darat No. 67', 'Muaro Jambi', 'Jambi', -1.6161581, 103.5222309, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (21, 21, 'Jl. Jenderal Sudirman, Telanaipura No. 55', 'Jambi', 'Jambi', -1.6074794, 103.5797138, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (22, 22, 'Jl. Kolonel Abunjani No. 109', 'Jambi', 'Jambi', -1.5945632, 103.6150668, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (23, 23, 'Jl. Prof. Dr. Sri Soedewi Masjchun Sofwan, Mendalo Indah No. 87', 'Muaro Jambi', 'Jambi', -1.6211671, 103.5321536, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (24, 24, 'Jl. Gatot Subroto No. 33', 'Jambi', 'Jambi', -1.6076082, 103.6167902, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (25, 25, 'Jl. Lingkar Selatan, Telanaipura No. 71', 'Jambi', 'Jambi', -1.6022032, 103.5800304, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (26, 26, 'Jl. Prof. Dr. Sri Soedewi Masjchun Sofwan, Mendalo Indah No. 104', 'Muaro Jambi', 'Jambi', -1.6161866, 103.5261968, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (27, 27, 'Jl. Prof. Dr. Sri Soedewi Masjchun Sofwan, Mendalo Indah No. 107', 'Muaro Jambi', 'Jambi', -1.6235716, 103.5213973, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (28, 28, 'Jl. Lintas Jambi - Muara Bulian, Mendalo Darat No. 113', 'Muaro Jambi', 'Jambi', -1.6196327, 103.5264987, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (29, 29, 'Jl. Gatot Subroto No. 119', 'Jambi', 'Jambi', -1.6104193, 103.6268604, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (30, 30, 'Jl. Orang Kayo Hitam No. 89', 'Jambi', 'Jambi', -1.6105772, 103.6104507, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (31, 1, 'Jl. Prof. Dr. Sri Soedewi Masjchun Sofwan, Mendalo Indah No. 104', 'Muaro Jambi', 'Jambi', -1.6215892, 103.5289668, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (32, 8, 'Jl. Sultan Thaha No. 107', 'Jambi', 'Jambi', -1.6183972, 103.6083062, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (33, 11, 'Jl. Hayam Wuruk No. 13', 'Jambi', 'Jambi', -1.612462, 103.6186607, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (34, 16, 'Jl. Jenderal Sudirman, Telanaipura No. 34', 'Jambi', 'Jambi', -1.6077533, 103.5874443, '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO products (product_id, location_id, category_id, product_name, description, photo_url, normal_price, discount_price, stock, status, pickup_deadline, created_at, updated_at) VALUES
  (1, 1, 2, 'Nasi Ayam Goreng Kremes', 'Nasi Ayam Goreng Kremes. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 18000, 9000, 6, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 31, 2, 'Nasi Rendang Daging', 'Nasi Rendang Daging. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 25000, 10000, 4, 'aktif', '2026-11-18 12:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 2, 2, 'Nasi Gulai Ikan Patin', 'Nasi Gulai Ikan Patin. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 22000, 11000, 5, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (4, 2, 2, 'Nasi Pecel Lele', 'Nasi Pecel Lele. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 17000, 7000, 5, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (5, 3, 2, 'Pindang Patin Porsi Kecil', 'Pindang Patin Porsi Kecil. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 28000, 14000, 4, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (6, 3, 1, 'Nasi Pindang Tempoyak', 'Nasi Pindang Tempoyak. Penawaran kilat menjelang jam tutup, ambil sebelum batas waktu.', NULL, 26000, 8000, 3, 'aktif', '2026-11-18 10:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (7, 4, 2, 'Nasi Gemuk Lauk Telur', 'Nasi Gemuk Lauk Telur. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 15000, 7500, 8, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (8, 4, 1, 'Nasi Gemuk Ayam Suwir', 'Nasi Gemuk Ayam Suwir. Penawaran kilat menjelang jam tutup, ambil sebelum batas waktu.', NULL, 17000, 7000, 5, 'aktif', '2026-11-18 10:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (9, 5, 2, 'Paket Nasi Sayur Kantin', 'Paket Nasi Sayur Kantin. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 14000, 7000, 10, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (10, 6, 2, 'Ayam Penyet Sambal Ijo', 'Ayam Penyet Sambal Ijo. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 20000, 8000, 6, 'aktif', '2026-11-18 12:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (11, 7, 2, 'Mie Ayam Pangsit Goreng', 'Mie Ayam Pangsit Goreng. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 16000, 8000, 7, 'aktif', '2026-11-18 12:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (12, 8, 6, 'Dimsum Ayam Isi 4', 'Dimsum Ayam Isi 4. Camilan hari ini, masih layak konsumsi.', NULL, 18000, 9000, 10, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (13, 32, 1, 'Dimsum Udang Isi 4', 'Dimsum Udang Isi 4. Penawaran kilat menjelang jam tutup, ambil sebelum batas waktu.', NULL, 22000, 6500, 4, 'aktif', '2026-11-18 10:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (14, 9, 6, 'Siomay Mix Isi 5', 'Siomay Mix Isi 5. Camilan hari ini, masih layak konsumsi.', NULL, 20000, 10000, 8, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (15, 9, 6, 'Bakpao Coklat', 'Bakpao Coklat. Camilan hari ini, masih layak konsumsi.', NULL, 8000, 4000, 12, 'aktif', '2026-11-18 12:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (16, 10, 3, 'Roti Bakar Coklat Keju', 'Roti Bakar Coklat Keju. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 15000, 6000, 6, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (17, 10, 3, 'Roti Bakar Srikaya', 'Roti Bakar Srikaya. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 13000, 6500, 5, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (18, 11, 3, 'Roti Sobek Original', 'Roti Sobek Original. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 22000, 9000, 6, 'aktif', '2026-11-18 16:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (19, 33, 3, 'Croissant Butter', 'Croissant Butter. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 18000, 9000, 6, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (20, 11, 1, 'Pastry Isi Ayam Keju', 'Pastry Isi Ayam Keju. Penawaran kilat menjelang jam tutup, ambil sebelum batas waktu.', NULL, 16000, 5000, 5, 'aktif', '2026-11-18 10:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (21, 12, 3, 'Roti Tawar Gandum', 'Roti Tawar Gandum. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 20000, 10000, 0, 'nonaktif', '2026-11-18 03:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (22, 12, 3, 'Roti Manis Aneka Isi 3', 'Roti Manis Aneka Isi 3. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 12000, 6000, 10, 'aktif', '2026-11-18 15:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (23, 13, 6, 'Kue Lapis Legit Potong', 'Kue Lapis Legit Potong. Camilan hari ini, masih layak konsumsi.', NULL, 15000, 7500, 8, 'aktif', '2026-11-18 16:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (24, 13, 6, 'Onde-onde Isi 5', 'Onde-onde Isi 5. Camilan hari ini, masih layak konsumsi.', NULL, 10000, 5000, 10, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (25, 14, 3, 'Donat Gula Isi 6', 'Donat Gula Isi 6. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 24000, 9500, 6, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (26, 14, 3, 'Donat Coklat Meses Isi 3', 'Donat Coklat Meses Isi 3. Roti dan pastry hari ini yang masih layak dan lezat.', NULL, 12000, 6000, 8, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (27, 15, 5, 'Es Cendol Durian Gelas', 'Es Cendol Durian Gelas. Minuman segar yang dibuat hari ini.', NULL, 15000, 7500, 9, 'aktif', '2026-11-18 12:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (28, 15, 5, 'Es Cendol Pandan Gelas', 'Es Cendol Pandan Gelas. Minuman segar yang dibuat hari ini.', NULL, 10000, 5000, 12, 'aktif', '2026-11-18 12:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (29, 34, 5, 'Kopi Susu Gula Aren', 'Kopi Susu Gula Aren. Minuman segar yang dibuat hari ini.', NULL, 18000, 7000, 8, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (30, 16, 5, 'Es Kopi Hitam Botol 250ml', 'Es Kopi Hitam Botol 250ml. Minuman segar yang dibuat hari ini.', NULL, 12000, 6000, 2, 'nonaktif', '2026-11-18 06:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (31, 17, 5, 'Jus Alpukat', 'Jus Alpukat. Minuman segar yang dibuat hari ini.', NULL, 16000, 8000, 6, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (32, 17, 5, 'Jus Jeruk Segar', 'Jus Jeruk Segar. Minuman segar yang dibuat hari ini.', NULL, 12000, 6000, 8, 'aktif', '2026-11-18 11:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (33, 18, 6, 'Martabak Telur Mini', 'Martabak Telur Mini. Camilan hari ini, masih layak konsumsi.', NULL, 20000, 10000, 0, 'nonaktif', '2026-11-18 02:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (34, 19, 6, 'Risoles Mayo Isi 5', 'Risoles Mayo Isi 5. Camilan hari ini, masih layak konsumsi.', NULL, 15000, 7500, 8, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (35, 20, 2, 'Roti Jala + Kuah Kari', 'Roti Jala + Kuah Kari. Makanan berat dari dapur hari ini, tersisa menjelang jam tutup.', NULL, 18000, 7000, 5, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (36, 21, 7, 'Healthy Bowl Ayam Panggang', 'Healthy Bowl Ayam Panggang. Pilihan sehat dari bahan segar hari ini.', NULL, 30000, 15000, 4, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (37, 22, 7, 'Salad Buah Segar', 'Salad Buah Segar. Pilihan sehat dari bahan segar hari ini.', NULL, 17000, 8500, 6, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (38, 23, 4, 'Puding Coklat Vla', 'Puding Coklat Vla. Dessert hari ini, masih segar dan siap dinikmati.', NULL, 12000, 6000, 10, 'aktif', '2026-11-18 14:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (39, 24, 4, 'Brownies Kukus Potong', 'Brownies Kukus Potong. Dessert hari ini, masih segar dan siap dinikmati.', NULL, 15000, 7500, 8, 'aktif', '2026-11-18 16:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (40, 25, 7, 'Nasi Kotak Sayur Lodeh', 'Nasi Kotak Sayur Lodeh. Pilihan sehat dari bahan segar hari ini.', NULL, 20000, 8000, 6, 'aktif', '2026-11-18 13:00:00', '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO orders (order_id, user_id, merchant_id, order_code, order_status, total_amount, order_date, created_at, updated_at) VALUES
  (1, 37, 5, 'FS-00001', 'dipesan', 21000, '2026-11-18 07:00:00', '2026-11-18 07:00:00', '2026-11-18 07:00:00'),
  (2, 38, 13, 'FS-00002', 'selesai', 22500, '2026-11-07 19:00:00', '2026-11-07 19:00:00', '2026-11-07 19:00:00'),
  (3, 43, 21, 'FS-00003', 'selesai', 15000, '2026-11-11 20:00:00', '2026-11-11 20:00:00', '2026-11-11 20:00:00'),
  (4, 41, 15, 'FS-00004', 'disiapkan', 27500, '2026-11-18 05:00:00', '2026-11-18 05:00:00', '2026-11-18 05:00:00'),
  (5, 38, 14, 'FS-00005', 'selesai', 15500, '2026-11-11 10:00:00', '2026-11-11 10:00:00', '2026-11-11 10:00:00'),
  (6, 38, 21, 'FS-00006', 'selesai', 15000, '2026-11-12 11:00:00', '2026-11-12 11:00:00', '2026-11-12 11:00:00'),
  (7, 47, 23, 'FS-00007', 'dipesan', 6000, '2026-11-18 07:00:00', '2026-11-18 07:00:00', '2026-11-18 07:00:00'),
  (8, 37, 22, 'FS-00008', 'selesai', 17000, '2026-11-12 18:00:00', '2026-11-12 18:00:00', '2026-11-12 18:00:00'),
  (9, 34, 13, 'FS-00009', 'selesai', 17500, '2026-11-12 08:00:00', '2026-11-12 08:00:00', '2026-11-12 08:00:00'),
  (10, 41, 15, 'FS-00010', 'selesai', 15000, '2026-11-12 13:00:00', '2026-11-12 13:00:00', '2026-11-12 13:00:00'),
  (11, 48, 9, 'FS-00011', 'selesai', 10000, '2026-11-17 05:00:00', '2026-11-17 05:00:00', '2026-11-17 05:00:00'),
  (12, 42, 14, 'FS-00012', 'dipesan', 25000, '2026-11-18 07:00:00', '2026-11-18 07:00:00', '2026-11-18 07:00:00'),
  (13, 50, 18, 'FS-00013', 'selesai', 20000, '2026-11-11 08:00:00', '2026-11-11 08:00:00', '2026-11-11 08:00:00'),
  (14, 38, 19, 'FS-00014', 'dibatalkan', 7500, '2026-11-15 01:00:00', '2026-11-15 01:00:00', '2026-11-15 01:00:00'),
  (15, 45, 6, 'FS-00015', 'dibatalkan', 16000, '2026-11-15 21:00:00', '2026-11-15 21:00:00', '2026-11-15 21:00:00'),
  (16, 35, 17, 'FS-00016', 'dibatalkan', 28000, '2026-11-15 02:00:00', '2026-11-15 02:00:00', '2026-11-15 02:00:00'),
  (17, 34, 1, 'FS-00017', 'selesai', 19000, '2026-11-16 06:00:00', '2026-11-16 06:00:00', '2026-11-16 06:00:00'),
  (18, 41, 4, 'FS-00018', 'selesai', 14000, '2026-11-08 23:00:00', '2026-11-08 23:00:00', '2026-11-08 23:00:00'),
  (19, 51, 2, 'FS-00019', 'dibatalkan', 54000, '2026-11-16 14:00:00', '2026-11-16 14:00:00', '2026-11-16 14:00:00'),
  (20, 43, 17, 'FS-00020', 'selesai', 20000, '2026-11-09 10:00:00', '2026-11-09 10:00:00', '2026-11-09 10:00:00'),
  (21, 32, 10, 'FS-00021', 'selesai', 31000, '2026-11-13 21:00:00', '2026-11-13 21:00:00', '2026-11-13 21:00:00'),
  (22, 49, 11, 'FS-00022', 'selesai', 5000, '2026-11-09 14:00:00', '2026-11-09 14:00:00', '2026-11-09 14:00:00'),
  (23, 51, 4, 'FS-00023', 'selesai', 7500, '2026-11-11 17:00:00', '2026-11-11 17:00:00', '2026-11-11 17:00:00'),
  (24, 41, 1, 'FS-00024', 'dipesan', 57000, '2026-11-18 07:00:00', '2026-11-18 07:00:00', '2026-11-18 07:00:00'),
  (25, 39, 25, 'FS-00025', 'selesai', 8000, '2026-11-10 05:00:00', '2026-11-10 05:00:00', '2026-11-10 05:00:00'),
  (26, 49, 13, 'FS-00026', 'selesai', 12500, '2026-11-14 08:00:00', '2026-11-14 08:00:00', '2026-11-14 08:00:00'),
  (27, 45, 9, 'FS-00027', 'dipesan', 14000, '2026-11-18 07:00:00', '2026-11-18 07:00:00', '2026-11-18 07:00:00'),
  (28, 42, 21, 'FS-00028', 'dibatalkan', 15000, '2026-11-17 18:00:00', '2026-11-17 18:00:00', '2026-11-17 18:00:00'),
  (29, 39, 16, 'FS-00029', 'selesai', 7000, '2026-11-09 08:00:00', '2026-11-09 08:00:00', '2026-11-09 08:00:00'),
  (30, 43, 8, 'FS-00030', 'selesai', 24500, '2026-11-13 11:00:00', '2026-11-13 11:00:00', '2026-11-13 11:00:00'),
  (31, 46, 18, 'FS-00031', 'disiapkan', 10000, '2026-11-18 06:00:00', '2026-11-18 06:00:00', '2026-11-18 06:00:00'),
  (32, 36, 16, 'FS-00032', 'selesai', 18000, '2026-11-08 19:00:00', '2026-11-08 19:00:00', '2026-11-08 19:00:00'),
  (33, 37, 3, 'FS-00033', 'selesai', 22000, '2026-11-07 15:00:00', '2026-11-07 15:00:00', '2026-11-07 15:00:00'),
  (34, 38, 23, 'FS-00034', 'selesai', 6000, '2026-11-13 02:00:00', '2026-11-13 02:00:00', '2026-11-13 02:00:00'),
  (35, 48, 21, 'FS-00035', 'selesai', 15000, '2026-11-15 18:00:00', '2026-11-15 18:00:00', '2026-11-15 18:00:00'),
  (36, 42, 18, 'FS-00036', 'selesai', 10000, '2026-11-09 10:00:00', '2026-11-09 10:00:00', '2026-11-09 10:00:00'),
  (37, 38, 6, 'FS-00037', 'selesai', 16000, '2026-11-13 11:00:00', '2026-11-13 11:00:00', '2026-11-13 11:00:00'),
  (38, 38, 24, 'FS-00038', 'selesai', 22500, '2026-11-13 11:00:00', '2026-11-13 11:00:00', '2026-11-13 11:00:00'),
  (39, 48, 1, 'FS-00039', 'selesai', 10000, '2026-11-15 13:00:00', '2026-11-15 13:00:00', '2026-11-15 13:00:00'),
  (40, 48, 22, 'FS-00040', 'disiapkan', 8500, '2026-11-18 07:00:00', '2026-11-18 07:00:00', '2026-11-18 07:00:00'),
  (41, 49, 5, 'FS-00041', 'selesai', 7000, '2026-11-16 03:00:00', '2026-11-16 03:00:00', '2026-11-16 03:00:00'),
  (42, 35, 24, 'FS-00042', 'dibatalkan', 15000, '2026-11-14 15:00:00', '2026-11-14 15:00:00', '2026-11-14 15:00:00'),
  (43, 35, 12, 'FS-00043', 'selesai', 26000, '2026-11-10 00:00:00', '2026-11-10 00:00:00', '2026-11-10 00:00:00'),
  (44, 43, 3, 'FS-00044', 'disiapkan', 42000, '2026-11-18 06:00:00', '2026-11-18 06:00:00', '2026-11-18 06:00:00'),
  (45, 39, 6, 'FS-00045', 'selesai', 16000, '2026-11-13 20:00:00', '2026-11-13 20:00:00', '2026-11-13 20:00:00');

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, subtotal, created_at, updated_at) VALUES
  (1, 1, 9, 3, 7000, 21000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (2, 2, 23, 3, 7500, 22500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (3, 3, 36, 1, 15000, 15000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (4, 4, 27, 3, 7500, 22500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (5, 4, 28, 1, 5000, 5000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (6, 5, 26, 1, 6000, 6000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (7, 5, 25, 1, 9500, 9500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (8, 6, 36, 1, 15000, 15000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (9, 7, 38, 1, 6000, 6000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (10, 8, 37, 2, 8500, 17000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (11, 9, 23, 1, 7500, 7500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (12, 9, 24, 2, 5000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (13, 10, 28, 3, 5000, 15000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (14, 11, 14, 1, 10000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (15, 12, 25, 2, 9500, 19000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (16, 12, 26, 1, 6000, 6000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (17, 13, 33, 2, 10000, 20000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (18, 14, 34, 1, 7500, 7500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (19, 15, 10, 2, 8000, 16000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (20, 16, 32, 2, 6000, 12000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (21, 16, 31, 2, 8000, 16000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (22, 17, 2, 1, 10000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (23, 17, 1, 1, 9000, 9000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (24, 18, 8, 2, 7000, 14000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (25, 19, 4, 3, 7000, 21000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (26, 19, 3, 3, 11000, 33000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (27, 20, 32, 2, 6000, 12000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (28, 20, 31, 1, 8000, 8000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (29, 21, 17, 2, 6500, 13000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (30, 21, 16, 3, 6000, 18000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (31, 22, 20, 1, 5000, 5000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (32, 23, 7, 1, 7500, 7500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (33, 24, 1, 3, 9000, 27000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (34, 24, 2, 3, 10000, 30000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (35, 25, 40, 1, 8000, 8000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (36, 26, 23, 1, 7500, 7500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (37, 26, 24, 1, 5000, 5000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (38, 27, 14, 1, 10000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (39, 27, 15, 1, 4000, 4000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (40, 28, 36, 1, 15000, 15000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (41, 29, 29, 1, 7000, 7000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (42, 30, 13, 1, 6500, 6500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (43, 30, 12, 2, 9000, 18000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (44, 31, 33, 1, 10000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (45, 32, 30, 3, 6000, 18000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (46, 33, 6, 1, 8000, 8000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (47, 33, 5, 1, 14000, 14000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (48, 34, 38, 1, 6000, 6000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (49, 35, 36, 1, 15000, 15000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (50, 36, 33, 1, 10000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (51, 37, 10, 2, 8000, 16000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (52, 38, 39, 3, 7500, 22500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (53, 39, 2, 1, 10000, 10000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (54, 40, 37, 1, 8500, 8500, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (55, 41, 9, 1, 7000, 7000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (56, 42, 39, 2, 7500, 15000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (57, 43, 22, 1, 6000, 6000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (58, 43, 21, 2, 10000, 20000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (59, 44, 5, 3, 14000, 42000, '2026-11-18 08:00:00', '2026-11-18 08:00:00'),
  (60, 45, 10, 2, 8000, 16000, '2026-11-18 08:00:00', '2026-11-18 08:00:00');

INSERT INTO reviews (review_id, order_id, user_id, rating, review_text, created_at, updated_at) VALUES
  (1, 2, 38, 2, 'Sudah agak dingin saat diambil.', '2026-11-08 07:00:00', '2026-11-08 07:00:00'),
  (2, 3, 43, 5, 'Enak, kemasan rapi, ambilnya gampang.', '2026-11-12 12:00:00', '2026-11-12 12:00:00'),
  (3, 5, 38, 4, 'Lumayan banget untuk makan malam hemat.', '2026-11-11 23:00:00', '2026-11-11 23:00:00'),
  (4, 6, 38, 4, 'Porsi agak kecil, tapi sebanding dengan harganya.', '2026-11-13 07:00:00', '2026-11-13 07:00:00'),
  (5, 8, 37, 3, 'Rasanya biasa saja, tapi lumayan untuk harga segini.', '2026-11-13 00:00:00', '2026-11-13 00:00:00'),
  (6, 9, 34, 2, 'Sudah agak dingin saat diambil.', '2026-11-12 23:00:00', '2026-11-12 23:00:00'),
  (7, 10, 41, 4, 'Porsi agak kecil, tapi sebanding dengan harganya.', '2026-11-12 18:00:00', '2026-11-12 18:00:00'),
  (8, 11, 48, 4, 'Porsi agak kecil, tapi sebanding dengan harganya.', '2026-11-17 21:00:00', '2026-11-17 21:00:00'),
  (9, 13, 50, 4, 'Enak, tapi sempat antre sebentar saat ambil.', '2026-11-12 03:00:00', '2026-11-12 03:00:00'),
  (10, 17, 34, 4, 'Enak, tapi sempat antre sebentar saat ambil.', '2026-11-16 18:00:00', '2026-11-16 18:00:00'),
  (11, 18, 41, 5, 'Porsinya pas dan masih hangat. Hemat banget buat anak kos!', '2026-11-09 09:00:00', '2026-11-09 09:00:00'),
  (12, 20, 43, 4, 'Lumayan banget untuk makan malam hemat.', '2026-11-10 02:00:00', '2026-11-10 02:00:00'),
  (13, 21, 32, 3, 'Rasanya biasa saja, tapi lumayan untuk harga segini.', '2026-11-13 23:00:00', '2026-11-13 23:00:00'),
  (14, 22, 49, 4, 'Lumayan banget untuk makan malam hemat.', '2026-11-10 05:00:00', '2026-11-10 05:00:00'),
  (15, 23, 51, 4, 'Enak, tapi sempat antre sebentar saat ambil.', '2026-11-12 10:00:00', '2026-11-12 10:00:00'),
  (16, 25, 39, 4, 'Porsi agak kecil, tapi sebanding dengan harganya.', '2026-11-10 18:00:00', '2026-11-10 18:00:00'),
  (17, 26, 49, 4, 'Enak, tapi sempat antre sebentar saat ambil.', '2026-11-14 22:00:00', '2026-11-14 22:00:00'),
  (18, 29, 39, 5, 'Porsinya pas dan masih hangat. Hemat banget buat anak kos!', '2026-11-09 18:00:00', '2026-11-09 18:00:00'),
  (19, 30, 43, 4, 'Enak, tapi sempat antre sebentar saat ambil.', '2026-11-13 23:00:00', '2026-11-13 23:00:00'),
  (20, 32, 36, 3, 'Rasanya biasa saja, tapi lumayan untuk harga segini.', '2026-11-09 12:00:00', '2026-11-09 12:00:00'),
  (21, 33, 37, 4, 'Enak, tapi sempat antre sebentar saat ambil.', '2026-11-07 18:00:00', '2026-11-07 18:00:00'),
  (22, 34, 38, 4, 'Lumayan banget untuk makan malam hemat.', '2026-11-13 07:00:00', '2026-11-13 07:00:00');

-- ============================================================
-- 3. VERIFIKASI (jalankan setelah import; tempel hasilnya ke laporan)
-- ============================================================
SELECT 'roles' AS tabel, COUNT(*) AS jumlah_baris FROM roles
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'merchants', COUNT(*) FROM merchants
UNION ALL SELECT 'merchant_locations', COUNT(*) FROM merchant_locations
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'reviews', COUNT(*) FROM reviews;

-- Setiap baris di bawah harus bernilai 0 (tidak ada pelanggaran aturan data)
SELECT 'total pesanan != jumlah subtotal item' AS cek, COUNT(*) AS pelanggaran
FROM orders o JOIN (SELECT order_id, SUM(subtotal) AS s FROM order_items GROUP BY order_id) i ON i.order_id = o.order_id
WHERE o.total_amount <> i.s
UNION ALL SELECT 'pesanan tanpa item', COUNT(*) FROM orders o WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)
UNION ALL SELECT 'ulasan: pengulas bukan pemesan', COUNT(*) FROM reviews r JOIN orders o ON o.order_id = r.order_id WHERE r.user_id <> o.user_id
UNION ALL SELECT 'ulasan pada pesanan belum selesai', COUNT(*) FROM reviews r JOIN orders o ON o.order_id = r.order_id WHERE o.order_status <> 'selesai'
UNION ALL SELECT 'produk milik mitra belum terverifikasi', COUNT(*) FROM products p JOIN merchant_locations l ON l.location_id = p.location_id JOIN merchants m ON m.merchant_id = l.merchant_id WHERE m.verification_status <> 'terverifikasi'
UNION ALL SELECT 'mitra yang akunnya bukan role mitra', COUNT(*) FROM merchants m JOIN users u ON u.user_id = m.user_id JOIN roles r ON r.role_id = u.role_id WHERE r.role_name <> 'mitra'
UNION ALL SELECT 'pesanan oleh akun bukan konsumen', COUNT(*) FROM orders o JOIN users u ON u.user_id = o.user_id JOIN roles r ON r.role_id = u.role_id WHERE r.role_name <> 'konsumen'
UNION ALL SELECT 'pesanan: merchant_id berbeda dari mitra pemilik item', COUNT(*) FROM order_items i JOIN orders o ON o.order_id = i.order_id JOIN products p ON p.product_id = i.product_id JOIN merchant_locations l ON l.location_id = p.location_id WHERE l.merchant_id <> o.merchant_id
UNION ALL SELECT 'item pesanan lintas mitra dalam satu pesanan', COUNT(*) FROM (
  SELECT i.order_id FROM order_items i JOIN products p ON p.product_id = i.product_id JOIN merchant_locations l ON l.location_id = p.location_id
  GROUP BY i.order_id HAVING COUNT(DISTINCT l.merchant_id) > 1) x;

-- ============================================================
-- 4. UJI ATURAN DATA (opsional; setiap perintah di bawah HARUS GAGAL dengan error)
-- ============================================================
-- INSERT INTO products (location_id, category_id, product_name, normal_price, discount_price, stock, pickup_deadline)
--   VALUES (1, 2, 'Uji harga', 10000, 15000, 1, NOW());          -- harga diskon > harga normal
-- INSERT INTO products (location_id, category_id, product_name, normal_price, discount_price, stock, pickup_deadline)
--   VALUES (1, 2, 'Uji stok', 10000, 5000, -1, NOW());           -- stok negatif
-- INSERT INTO users (role_id, name, email, password_hash) VALUES (1, 'Dobel', 'admin@foodsave.test', 'x');   -- email duplikat
-- INSERT INTO reviews (order_id, user_id, rating) VALUES (1, 32, 6);                                          -- rating di luar 1-5
-- INSERT INTO merchants (user_id, business_name) VALUES (999, 'Mitra Tanpa Akun');                            -- FK tidak valid
