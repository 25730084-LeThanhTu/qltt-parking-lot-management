-- ====================================================================================
-- DỰ ÁN QUẢN LÝ CHUỖI NHIỀU BÃI ĐỖ XE (MULTI-SITE PARKING LOT MANAGEMENT)
-- BƯỚC 9: KỊCH BẢN SAO LƯU, PHỤC HỒI (BACKUP & RESTORE) VÀ NẠP DỮ LIỆU BULK INSERT
-- ====================================================================================

-- ------------------------------------------------------------------------------------
-- PHẦN 1: IMPORT & EXPORT DỮ LIỆU HÀNG LOẠT (BULK DATA)
-- ------------------------------------------------------------------------------------

-- 1.1 Lệnh BULK INSERT nạp thẻ xe chip hàng loạt từ file CSV vào bảng THE_XE
/*
BULK INSERT dbo.THE_XE
FROM 'C:\data\the_xe_import.csv'  -- Hoặc đường dẫn trong Docker: '/var/opt/mssql/data/the_xe_import.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2,
    CODEPAGE = '65001' -- Hỗ trợ UTF-8
);
*/

-- ------------------------------------------------------------------------------------
-- PHẦN 2: CHIẾN LƯỢC SAO LƯU DỮ LIỆU (BACKUP STRATEGY)
-- ------------------------------------------------------------------------------------

-- 2.1 FULL BACKUP (Sao lưu toàn bộ - Thực hiện định kỳ hàng tuần vào 00:00 Chủ Nhật)
-- Đường dẫn mẫu cho môi trường Windows hoặc thư mục Docker (/var/opt/mssql/backup/)
/*
BACKUP DATABASE QuanLyBaiDoXe
TO DISK = '/var/opt/mssql/data/QuanLyBaiDoXe_Full.bak'
WITH 
    FORMAT, 
    MEDIANAME = 'SQLServerBackups', 
    NAME = 'Full Backup QuanLyBaiDoXe',
    DESCRIPTION = 'Sao lưu toàn bộ CSDL QuanLyBaiDoXe định kỳ hàng tuần';
GO
*/

-- 2.2 DIFFERENTIAL BACKUP (Sao lưu phần thay đổi - Thực hiện hàng ngày vào 23:00)
/*
BACKUP DATABASE QuanLyBaiDoXe
TO DISK = '/var/opt/mssql/data/QuanLyBaiDoXe_Diff.bak'
WITH 
    DIFFERENTIAL,
    NAME = 'Diff Backup QuanLyBaiDoXe',
    DESCRIPTION = 'Sao lưu phần dữ liệu thay đổi trong ngày';
GO
*/

-- ------------------------------------------------------------------------------------
-- PHẦN 3: KỊCH BẢN PHỤC HỒI KHI GẶP SỰ CỐ (DISASTER RECOVERY / RESTORE)
-- ------------------------------------------------------------------------------------

-- 3.1 Khôi phục từ bản Full Backup và Diff Backup
/*
USE master;
GO

-- Đóng toàn bộ các kết nối đang mở tới CSDL để tránh xung đột
ALTER DATABASE QuanLyBaiDoXe SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Bước 1: Restore bản Full Backup trước (với tùy chọn NORECOVERY để tiếp tục nạp bản Diff)
RESTORE DATABASE QuanLyBaiDoXe
FROM DISK = '/var/opt/mssql/data/QuanLyBaiDoXe_Full.bak'
WITH 
    REPLACE, 
    NORECOVERY;
GO

-- Bước 2: Restore bản Differential Backup gần nhất và mở CSDL sẵn sàng sử dụng (RECOVERY)
RESTORE DATABASE QuanLyBaiDoXe
FROM DISK = '/var/opt/mssql/data/QuanLyBaiDoXe_Diff.bak'
WITH 
    RECOVERY;
GO

-- Chuyển trạng thái CSDL về chế độ đa người dùng
ALTER DATABASE QuanLyBaiDoXe SET MULTI_USER;
GO
*/
