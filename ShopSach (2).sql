-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Máy chủ: mariadb:3306
-- Thời gian đã tạo: Th10 06, 2025 lúc 09:30 AM
-- Phiên bản máy phục vụ: 10.11.14-MariaDB-ubu2204
-- Phiên bản PHP: 8.3.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `ShopSach`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `don_hang`
--

CREATE TABLE `don_hang` (
  `id` int(11) NOT NULL,
  `ma_don_hang` varchar(50) DEFAULT NULL,
  `nguoi_dung_id` int(11) DEFAULT NULL,
  `tong_tien` decimal(12,2) NOT NULL,
  `trang_thai` enum('moi','xac_nhan','da_gui','hoan_thanh','huy') DEFAULT 'moi',
  `ngay_tao` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `don_hang_chi_tiet`
--

CREATE TABLE `don_hang_chi_tiet` (
  `id` int(11) NOT NULL,
  `don_hang_id` int(11) NOT NULL,
  `san_pham_id` int(11) NOT NULL,
  `so_luong` int(11) NOT NULL,
  `don_gia` decimal(12,2) NOT NULL,
  `thanh_tien` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nguoi_dung`
--

CREATE TABLE `nguoi_dung` (
  `id` int(11) NOT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `mat_khau` varchar(255) NOT NULL,
  `la_admin` int(10) NOT NULL,
  `ngay_tao` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nhom_san_pham`
--

CREATE TABLE `nhom_san_pham` (
  `id` int(11) NOT NULL,
  `ten_nhom` varchar(100) NOT NULL,
  `mo_ta` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `san_pham`
--

CREATE TABLE `san_pham` (
  `id` int(11) NOT NULL,
  `ten_san_pham` varchar(200) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `gia` decimal(12,2) NOT NULL,
  `so_luong` int(11) DEFAULT 0,
  `hinh_anh` varchar(255) DEFAULT NULL,
  `nhom_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `don_hang`
--
ALTER TABLE `don_hang`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `ma_don_hang` (`ma_don_hang`),
  ADD KEY `nguoi_dung_id` (`nguoi_dung_id`);

--
-- Chỉ mục cho bảng `don_hang_chi_tiet`
--
ALTER TABLE `don_hang_chi_tiet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `don_hang_id` (`don_hang_id`),
  ADD KEY `san_pham_id` (`san_pham_id`);

--
-- Chỉ mục cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Chỉ mục cho bảng `nhom_san_pham`
--
ALTER TABLE `nhom_san_pham`
  ADD PRIMARY KEY (`id`);

--
-- Chỉ mục cho bảng `san_pham`
--
ALTER TABLE `san_pham`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nhom_id` (`nhom_id`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `don_hang`
--
ALTER TABLE `don_hang`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT cho bảng `don_hang_chi_tiet`
--
ALTER TABLE `don_hang_chi_tiet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT cho bảng `nguoi_dung`
--
ALTER TABLE `nguoi_dung`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT cho bảng `nhom_san_pham`
--
ALTER TABLE `nhom_san_pham`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT cho bảng `san_pham`
--
ALTER TABLE `san_pham`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- Ràng buộc đối với các bảng kết xuất
--

--
-- Ràng buộc cho bảng `don_hang`
--
ALTER TABLE `don_hang`
  ADD CONSTRAINT `don_hang_ibfk_1` FOREIGN KEY (`nguoi_dung_id`) REFERENCES `nguoi_dung` (`id`) ON DELETE SET NULL;

--
-- Ràng buộc cho bảng `don_hang_chi_tiet`
--
ALTER TABLE `don_hang_chi_tiet`
  ADD CONSTRAINT `don_hang_chi_tiet_ibfk_1` FOREIGN KEY (`don_hang_id`) REFERENCES `don_hang` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `don_hang_chi_tiet_ibfk_2` FOREIGN KEY (`san_pham_id`) REFERENCES `san_pham` (`id`) ON DELETE CASCADE;

--
-- Ràng buộc cho bảng `san_pham`
--
ALTER TABLE `san_pham`
  ADD CONSTRAINT `san_pham_ibfk_1` FOREIGN KEY (`nhom_id`) REFERENCES `nhom_san_pham` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
