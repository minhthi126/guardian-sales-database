CREATE DATABASE QuanLyGuardian
GO
USE QuanLyGuardian
GO

-- 1. Bảng Loại Sản Phẩm
CREATE TABLE LOAISANPHAM (
    MaLoai CHAR(10) PRIMARY KEY,
    TenLoai NVARCHAR(100) NOT NULL,
    MoTa NVARCHAR(200)
)

-- 2. Bảng Thương Hiệu
CREATE TABLE THUONGHIEU (
    MaThuongHieu CHAR(10) PRIMARY KEY,
    TenThuongHieu NVARCHAR(100) NOT NULL,
    XuatXu NVARCHAR(50)
)


-- 3. Bảng Nhà Cung Cấp
CREATE TABLE NHACUNGCAP (
    MaNCC CHAR(10) PRIMARY KEY,
    TenNCC NVARCHAR(100) NOT NULL,
    DiaChi NVARCHAR(200),
    SDT VARCHAR(15),
    Email VARCHAR(100)
)


-- 4. Bảng Chức Vụ
CREATE TABLE CHUCVU (
    MaCV CHAR(10) PRIMARY KEY,
    TenCV NVARCHAR(50) NOT NULL,
    MoTa NVARCHAR(200)
)


-- 5. Bảng Hạng Thành Viên
CREATE TABLE HANGTHANHVIEN (
    MaHang CHAR(10) PRIMARY KEY,
    TenHang NVARCHAR(50) NOT NULL,
    DiemToiThieu INT CHECK (DiemToiThieu >= 0),
    GiamGia DECIMAL(5, 2) CHECK (GiamGia >= 0 AND GiamGia <= 100) -- Ràng buộc 0-100%
)


-- 6. Bảng Sản Phẩm
CREATE TABLE SANPHAM (
    MaSP CHAR(10) PRIMARY KEY,
    TenSP NVARCHAR(100) NOT NULL,
    DonViTinh NVARCHAR(20),
    GiaBan DECIMAL(18, 0) CHECK (GiaBan >= 0),
    MucTonToiThieu INT CHECK (MucTonToiThieu >= 0),
    MoTa NVARCHAR(200),
    TrangThai NVARCHAR(50),
    MaLoai CHAR(10) REFERENCES LOAISANPHAM(MaLoai),
    MaThuongHieu CHAR(10) REFERENCES THUONGHIEU(MaThuongHieu)
)


-- 7. Bảng Nhân Viên
CREATE TABLE NHANVIEN (
    MaNV CHAR(10) PRIMARY KEY,
    TenNV NVARCHAR(100) NOT NULL,
    NgaySinh DATE,
    SDT VARCHAR(15),
    DiaChi NVARCHAR(200),
    NgayVaoLam DATE,
    TrangThaiLamViec NVARCHAR(50),
    MaCV CHAR(10) REFERENCES CHUCVU(MaCV)
)


-- 8. Bảng Tài Khoản (1-1 với Nhân Viên)
CREATE TABLE TAIKHOAN (
    TenDangNhap VARCHAR(50) PRIMARY KEY,
    MatKhau VARCHAR(100) NOT NULL,
    TrangThaiHoatDong BIT DEFAULT 1, -- 1: Active, 0: Block
    MaNV CHAR(10) UNIQUE REFERENCES NHANVIEN(MaNV) -- Unique để đảm bảo 1-1
)


-- 9. Bảng Khách Hàng
CREATE TABLE KHACHHANG (
    MaKH CHAR(10) PRIMARY KEY,
    HoTen NVARCHAR(100) NOT NULL,
    SDT VARCHAR(15) UNIQUE, -- Số điện thoại không được trùng
    NgaySinh DATE,
    GioiTinh NVARCHAR(10) CHECK (GioiTinh IN (N'Nam', N'Nữ')),
    DiemTichLuy INT DEFAULT 0 CHECK (DiemTichLuy >= 0),
    MaHang CHAR(10) REFERENCES HANGTHANHVIEN(MaHang)
)


-- 10. Bảng Phiếu Nhập
CREATE TABLE PHIEUNHAP (
    MaPhieuNhap CHAR(10) PRIMARY KEY,
    NgayNhap DATETIME DEFAULT GETDATE(),
    TongTienNhap DECIMAL(18, 0) DEFAULT 0 CHECK (TongTienNhap >= 0),
    GhiChu NVARCHAR(200),
    MaNCC CHAR(10) REFERENCES NHACUNGCAP(MaNCC),
    MaNV CHAR(10) REFERENCES NHANVIEN(MaNV)
)


-- 11. Bảng Lô Hàng
CREATE TABLE LOHANG (
    MaLo CHAR(10) PRIMARY KEY,
    NgaySX DATE,
    HanSD DATE,
    GiaNhap DECIMAL(18, 0) CHECK (GiaNhap > 0),
    SoLuongTon INT CHECK (SoLuongTon >= 0),
    MaSP CHAR(10) REFERENCES SANPHAM(MaSP),
    MaPhieuNhap CHAR(10) REFERENCES PHIEUNHAP(MaPhieuNhap),
    CONSTRAINT CK_HanSuDung CHECK (HanSD > NgaySX) -- Ràng buộc Hạn SD phải sau Ngày SX
)


-- 12. Bảng Hóa Đơn
CREATE TABLE HOADON (
    MaHD CHAR(10) PRIMARY KEY,
    NgayLap DATE DEFAULT GETDATE(),
    GioLap TIME,
    TongTienHang DECIMAL(18, 0) DEFAULT 0 CHECK (TongTienHang >= 0),
    TienGiamGia DECIMAL(18, 0) DEFAULT 0,
    ThanhTien DECIMAL(18, 0) DEFAULT 0,
    PhuongThucTT NVARCHAR(50),
    MaNV CHAR(10) REFERENCES NHANVIEN(MaNV),
    MaKH CHAR(10) REFERENCES KHACHHANG(MaKH)
)


-- 13. Bảng Chi Tiết Hóa Đơn
CREATE TABLE CHITIETHOADON (
    MaHD CHAR(10) REFERENCES HOADON(MaHD),
    MaSP CHAR(10) REFERENCES SANPHAM(MaSP),
    SoLuongBan INT CHECK (SoLuongBan > 0),
    DonGiaBan DECIMAL(18, 0) CHECK (DonGiaBan >= 0),
    PRIMARY KEY (MaHD, MaSP) -- Khóa chính phức hợp
)

-- LOẠI SẢN PHẨM
INSERT INTO LOAISANPHAM (MaLoai, TenLoai, MoTa) VALUES 
('L001', N'Chăm sóc da mặt', N'Sữa rửa mặt, Toner, Serum, Kem dưỡng'),
('L002', N'Trang điểm', N'Son môi, Phấn phủ, Kem nền, Mascara'),
('L003', N'Chăm sóc cơ thể', N'Sữa tắm, Dưỡng thể, Khử mùi'),
('L004', N'Chăm sóc tóc', N'Dầu gội, Dầu xả, Ủ tóc, Nhuộm tóc'),
('L005', N'Chăm sóc sức khỏe', N'Thực phẩm chức năng, Vitamin'),
('L006', N'Chăm sóc cá nhân', N'Băng vệ sinh, Dung dịch vệ sinh'),
('L007', N'Chăm sóc nam giới', N'Dầu gội nam, Sữa rửa mặt nam, Cạo râu'),
('L008', N'Mẹ và Bé', N'Sữa tắm bé, Phấn rôm, Tã bỉm'),
('L009', N'Nước hoa', N'Nước hoa nam, nữ, body mist'),
('L010', N'Dụng cụ làm đẹp', N'Bông tẩy trang, cọ trang điểm, kẹp mi');

-- THƯƠNG HIỆU 
INSERT INTO THUONGHIEU (MaThuongHieu, TenThuongHieu, XuatXu) VALUES 
('TH001', N'L''Oreal Paris', N'Pháp'), 
('TH002', N'Maybelline', N'Mỹ'),
('TH003', N'La Roche-Posay', N'Pháp'), 
('TH004', N'Sunplay', N'Nhật Bản'),
('TH005', N'Blackmores', N'Úc'), 
('TH006', N'Vaseline', N'Mỹ'),
('TH007', N'Nivea', N'Đức'), 
('TH008', N'Biore', N'Nhật Bản'),
('TH009', N'Vichy', N'Pháp'), 
('TH010', N'Cetaphil', N'Canada'),
('TH011', N'Cocoon', N'Việt Nam'), 
('TH012', N'Innisfree', N'Hàn Quốc'),
('TH013', N'Laneige', N'Hàn Quốc'), 
('TH014', N'Dove', N'Mỹ'),
('TH015', N'Pantene', N'Mỹ'),
('TH016', N'Head & Shoulders', N'Mỹ'),
('TH017', N'Senka', N'Nhật Bản'), 
('TH018', N'Eucerin', N'Đức'),
('TH019', N'Neutrogena', N'Mỹ'), 
('TH020', N'Listerine', N'Mỹ');

-- NHÀ CUNG CẤP
INSERT INTO NHACUNGCAP (MaNCC, TenNCC, DiaChi, SDT, Email) VALUES 
('NCC01', N'L''Oreal Việt Nam', N'45A Lý Tự Trọng, Q1, TP.HCM', '0283936999', 'contact@loreal.vn'),
('NCC02', N'DKSH Việt Nam', N'VSIP 1, Bình Dương', '0274375631', 'info@dksh.com.vn'),
('NCC03', N'Rohto-Mentholatum', N'16 VSIP, Bình Dương', '0274375678', 'enquiry@rohto.com.vn'),
('NCC04', N'Unilever Việt Nam', N'Q7, TP.HCM', '0285413568', 'info@unilever.com'),
('NCC05', N'Beiersdorf Việt Nam', N'Q1, TP.HCM', '0283911122', 'info@nivea.vn'),
('NCC06', N'Johnson & Johnson', N'Q1, TP.HCM', '0283822233', 'cs@jnj.com'),
('NCC07', N'Shiseido Việt Nam', N'Q3, TP.HCM', '0283910010', 'info@shiseido.vn'),
('NCC08', N'Cocoon Việt Nam', N'Q12, TP.HCM', '0283777888', 'hello@cocoon.vn'),
('NCC09', N'LG Vina Cosmetics', N'Nhơn Trạch, Đồng Nai', '0251356056', 'info@lgvina.com'),
('NCC10', N'Mesa Group', N'Q1, TP.HCM', '0283827282', 'partners@mesa.vn');

-- CHỨC VỤ 
INSERT INTO CHUCVU (MaCV, TenCV, MoTa) VALUES
('CV01', N'Quản lý', N'Quản lý toàn bộ hoạt động cửa hàng'),
('CV02', N'Nhân viên bán hàng', N'Tư vấn và thu ngân'),
('CV03', N'Nhân viên kho', N'Kiểm kê, nhập hàng và sắp xếp kho'),
('CV04', N'Kế toán', N'Quản lý sổ sách, báo cáo tài chính'),
('CV05', N'Marketing', N'Xây dựng chương trình khuyến mãi'),
('CV06', N'NV Bán hàng part-time', N'Nhân viên bán thời gian');

-- HẠNG THÀNH VIÊN
INSERT INTO HANGTHANHVIEN (MaHang, TenHang, DiemToiThieu, GiamGia) VALUES 
('H01', N'Thân thiết', 0, 0.00),
('H02', N'Bạc', 2000, 5.00), 
('H03', N'Vàng', 5000, 10.00), 
('H04', N'Kim Cương', 10000, 15.00);

-- NHÂN VIÊN
INSERT INTO NHANVIEN (MaNV, TenNV, NgaySinh, SDT, DiaChi, NgayVaoLam, TrangThaiLamViec, MaCV) VALUES
('NV01', N'Trần Thị Minh Thi', '2003-02-10', '0901000001', N'Gò Vấp', '2023-12-01', N'Đang làm', 'CV01'),
('NV02', N'Nguyễn Văn An', '2000-03-11', '0902000002', N'Bình Thạnh', '2024-01-05', N'Đang làm', 'CV02'),
('NV03', N'Lê Thị Hồng', '2002-04-20', '0903000003', N'Tân Bình', '2024-01-10', N'Đang làm', 'CV02'),
('NV04', N'Phạm Quốc Bảo', '1998-05-15', '0904000004', N'Q12', '2023-12-20', N'Đang làm', 'CV03'),
('NV05', N'Võ Hoàng Yến', '1999-06-25', '0905000005', N'Thủ Đức', '2024-02-01', N'Đang làm', 'CV04'),
('NV06', N'Đỗ Nhật Minh', '2001-07-12', '0906000006', N'Bình Tân', '2024-02-10', N'Đang làm', 'CV02'),
('NV07', N'Nguyễn Hữu Tài', '1997-08-08', '0907000007', N'Q3', '2023-11-10', N'Đang làm', 'CV03'),
('NV08', N'Đặng Mỹ Duyên', '2000-09-09', '0908000008', N'Q10', '2024-03-01', N'Đang làm', 'CV06'),
('NV09', N'Trương Quốc Việt', '1996-10-10', '0909000009', N'Phú Nhuận', '2023-10-15', N'Đang làm', 'CV05'),
('NV10', N'Lý Thanh Tuyền', '2001-11-11', '0910000010', N'Q7', '2024-03-05', N'Đang làm', 'CV02');

-- TÀI KHOẢN 
INSERT INTO TAIKHOAN (TenDangNhap, MatKhau, TrangThaiHoatDong, MaNV) VALUES 
('quanly.thi', '123', 1, 'NV01'),      
('bh.an', '123', 1, 'NV02'),             
('bh.hong', '123', 1, 'NV03'),   
('kho.bao', '123', 1, 'NV04'),           
('ketoan.yen', '123', 1, 'NV05'),     
('bh.minh', '123', 1, 'NV06'),           
('kho.tai', '123', 1, 'NV07'),          
('bh.duyen', '123', 1, 'NV08'),          
('mkt.viet', '123', 1, 'NV09'),          
('bh.tuyen', '123', 1, 'NV10');          
 

-- KHÁCH HÀNG 
INSERT INTO KHACHHANG (MaKH, HoTen, SDT, NgaySinh, GioiTinh, DiemTichLuy, MaHang) VALUES
('KH001', N'Lê Thị Thu Hà', '0167812490', '1995-05-01', N'Nữ', 5000, 'H03'),
('KH002', N'Nguyễn Văn Hải', '0913678911', '1990-03-15', N'Nam', 2200, 'H02'),
('KH003', N'Phạm Ngọc Trâm', '0911357981', '2001-08-20', N'Nữ', 120, 'H01'),
('KH004', N'Võ Minh Tuấn', '0911413468', '1998-09-09', N'Nam', 450, 'H01'),
('KH005', N'Trần Mỹ Hạnh', '0911256745', '1997-11-11', N'Nữ', 50, 'H01'),
('KH006', N'Ngô Bích Thảo', '0987137263', '1999-02-28', N'Nữ', 500, 'H01'),
('KH007', N'Phạm Thanh Tùng', '0355177629', '1996-06-06', N'Nam', 1700, 'H02'),
('KH008', N'Huỳnh Quốc Huy', '0987653489', '2000-07-07', N'Nam', 350, 'H01'),
('KH009', N'Trần Như Quỳnh', '0911976552', '1995-12-12', N'Nữ', 1200, 'H01'),
('KH010', N'Lý Kiều My', '0382375635', '1998-01-01', N'Nữ', 6000, 'H03'),
('KH011', N'Lê Bảo Châu', '0312621881', '1999-09-19', N'Nữ', 2500, 'H02'),
('KH012', N'Đoàn Khắc Huy', '0967853235', '1994-10-10', N'Nam', 800, 'H01'),
('KH013', N'Đặng Thanh Hân', '0966737134', '1996-04-14', N'Nữ', 75, 'H01'),
('KH014', N'Phan Gia Bảo', '0905558921', '2002-02-22', N'Nam', 125, 'H01'),
('KH015', N'Hoàng Nhật Minh', '0906688977', '1998-03-30', N'Nam', 1800, 'H02'),
('KH016', N'Trịnh Ngọc Diệp', '0912679765', '1997-07-07', N'Nữ', 300, 'H01'),
('KH017', N'Vũ Ngọc Châm', '0982965922', '1995-08-18', N'Nữ', 5100, 'H03'),
('KH018', N'Võ Quốc Long', '0376932675', '1993-09-09', N'Nam', 100, 'H01'),
('KH019', N'La Thành Tín', '0910123456', '1996-01-12', N'Nam', 890, 'H01'),
('KH020', N'Trương Anh Thư', '0910654321', '1997-04-06', N'Nữ', 1500, 'H01');

--SẢN PHẨM 
INSERT INTO SANPHAM (MaSP, TenSP, DonViTinh, GiaBan, MucTonToiThieu, MoTa, TrangThai, MaLoai, MaThuongHieu) VALUES 
('SP001', N'Nước tẩy trang L''Oreal 400ml', N'Chai', 189000, 10, N'Cho da dầu', N'Đang bán', 'L001', 'TH001'),
('SP002', N'Serum L''Oreal HA 30ml', N'Chai', 450000, 5, N'Cấp ẩm', N'Đang bán', 'L001', 'TH001'),
('SP003', N'KCN La Roche-Posay 50ml', N'Tuýp', 415000, 5, N'Kiểm soát dầu', N'Đang bán', 'L001', 'TH003'),
('SP004', N'Xịt khoáng Vichy 150ml', N'Chai', 260000, 10, N'Làm dịu da', N'Đang bán', 'L001', 'TH009'),
('SP005', N'Sữa rửa mặt Cetaphil 500ml', N'Chai', 330000, 10, N'Dịu nhẹ', N'Đang bán', 'L001', 'TH010'),
('SP006', N'Toner Bí Đao Cocoon 140ml', N'Chai', 175000, 10, N'Giảm dầu mụn', N'Đang bán', 'L001', 'TH011'),
('SP007', N'Mặt nạ Innisfree Đất sét', N'Hũ', 340000, 5, N'Se khít lỗ chân lông', N'Đang bán', 'L001', 'TH012'),
('SP008', N'Kem dưỡng Laneige Water Bank', N'Hũ', 850000, 3, N'Cấp nước', N'Đang bán', 'L001', 'TH013'),
('SP009', N'Sữa rửa mặt Senka Perfect Whip', N'Tuýp', 99000, 20, N'Bọt tơ tằm', N'Đang bán', 'L001', 'TH017'),
('SP010', N'Nước hoa hồng Eucerin 200ml', N'Chai', 390000, 5, N'Da nhạy cảm', N'Đang bán', 'L001', 'TH018'),
('SP011', N'Son Maybelline Superstay', N'Thỏi', 205000, 10, N'Lì 16h', N'Đang bán', 'L002', 'TH002'),
('SP012', N'Mascara Maybelline Hyper Curl', N'Cây', 138000, 10, N'Cong mi', N'Đang bán', 'L002', 'TH002'),
('SP013', N'Kem nền Fit Me Maybelline', N'Chai', 238000, 5, N'Kiềm dầu', N'Đang bán', 'L002', 'TH002'),
('SP014', N'Phấn phủ Innisfree Mineral', N'Hộp', 150000, 10, N'Không màu', N'Đang bán', 'L002', 'TH012'),
('SP015', N'Son dưỡng Vaseline Rosy', N'Hũ', 65000, 20, N'Hồng môi', N'Đang bán', 'L002', 'TH006'),
('SP016', N'Sữa dưỡng thể Vaseline 350ml', N'Chai', 135000, 10, N'Trắng da', N'Đang bán', 'L003', 'TH006'),
('SP017', N'Sữa tắm Dove 900g', N'Chai', 179000, 10, N'Dưỡng ẩm', N'Đang bán', 'L003', 'TH014'),
('SP018', N'Lăn khử mùi Nivea nữ', N'Chai', 72000, 10, N'Sáng da', N'Đang bán', 'L003', 'TH007'),
('SP019', N'Tẩy da chết Cocoon Cà phê', N'Hũ', 115000, 10, N'Sạch da chết', N'Đang bán', 'L003', 'TH011'),
('SP020', N'Dầu gội Pantene 650ml', N'Chai', 145000, 10, N'Ngăn rụng tóc', N'Đang bán', 'L004', 'TH015'),
('SP021', N'Dầu gội Head & Shoulders', N'Chai', 155000, 10, N'Sạch gàu', N'Đang bán', 'L004', 'TH016'),
('SP022', N'Dầu xả Pantene 300ml', N'Tuýp', 95000, 10, N'Mượt tóc', N'Đang bán', 'L004', 'TH015'),
('SP023', N'Sữa tắm Nivea Men', N'Chai', 120000, 10, N'Mát lạnh', N'Đang bán', 'L007', 'TH007'),
('SP024', N'Bọt cạo râu Gillette', N'Chai', 98000, 5, N'Mềm râu', N'Đang bán', 'L007', 'TH007'),
('SP025', N'KCN Sunplay Skin Aqua', N'Chai', 109000, 10, N'Trắng mịn', N'Đang bán', 'L001', 'TH004'),
('SP026', N'Viên uống Blackmores Vit C', N'Hộp', 350000, 5, N'500mg', N'Đang bán', 'L005', 'TH005'),
('SP027', N'Dầu cá Blackmores Fish Oil', N'Hộp', 450000, 5, N'Bổ mắt', N'Đang bán', 'L005', 'TH005'),
('SP028', N'Bông tẩy trang Silcot', N'Hộp', 45000, 20, N'82 miếng', N'Đang bán', 'L010', 'TH002'),
('SP029', N'Sữa tắm em bé Johnson', N'Chai', 110000, 10, N'Dịu nhẹ', N'Đang bán', 'L008', 'TH006'),
('SP030', N'Tinh dầu bưởi Cocoon', N'Chai', 125000, 10, N'Mọc tóc', N'Đang bán', 'L004', 'TH011');

--Phiếu nhập
INSERT INTO PHIEUNHAP (MaPhieuNhap, NgayNhap, TongTienNhap, GhiChu, MaNCC, MaNV) VALUES 
('PN001', '2025-10-01', 15000000, N'Nhập L''Oreal', 'NCC01', 'NV04'),
('PN002', '2025-10-02', 20000000, N'Nhập Unilever', 'NCC04', 'NV04'),
('PN003', '2025-10-05', 10000000, N'Nhập Cocoon', 'NCC08', 'NV07'),
('PN004', '2025-10-08', 35000000, N'Nhập TPCN', 'NCC02', 'NV07'),
('PN005', '2025-10-15', 12000000, N'Nhập Rohto', 'NCC03', 'NV04'),
('PN006', '2025-10-18', 18000000, N'Nhập Nivea', 'NCC05', 'NV04'),
('PN007', '2025-10-20', 22000000, N'Nhập Johnson', 'NCC06', 'NV07'),
('PN008', '2025-10-22', 25000000, N'Nhập Shiseido', 'NCC07', 'NV07'),
('PN009', '2025-10-25', 15000000, N'Nhập LG Vina', 'NCC09', 'NV04'),
('PN010', '2025-10-28', 10000000, N'Nhập Mesa', 'NCC10', 'NV04');

--Lô hàng 
INSERT INTO LOHANG (MaLo, NgaySX, HanSD, GiaNhap, SoLuongTon, MaSP, MaPhieuNhap) VALUES 
('L001', '2025-01-01', '2028-01-01', 120000, 50, 'SP001', 'PN001'),
('L002', '2025-02-01', '2028-02-01', 300000, 30, 'SP002', 'PN001'),
('L003', '2025-06-01', '2028-06-01', 130000, 20, 'SP011', 'PN001'),
('L004', '2025-07-01', '2028-07-01', 110000, 50, 'SP017', 'PN002'),
('L005', '2025-08-01', '2028-08-01', 90000, 80, 'SP020', 'PN002'),
('L006', '2025-08-01', '2028-08-01', 100000, 60, 'SP021', 'PN002'),
('L007', '2025-09-01', '2026-09-01', 100000, 100, 'SP006', 'PN003'),
('L008', '2025-01-01', '2028-01-01', 80000, 50, 'SP030', 'PN003'),
('L009', '2025-09-01', '2026-09-01', 75000, 40, 'SP019', 'PN003'), 
('L010', '2025-03-01', '2027-03-01', 250000, 40, 'SP026', 'PN004'),
('L011', '2025-01-15', '2027-01-15', 150000, 60, 'SP027', 'PN004'), 
('L012', '2025-06-01', '2028-06-01', 280000, 20, 'SP003', 'PN005'),
('L013', '2025-05-01', '2028-05-01', 80000, 100, 'SP025', 'PN005'),
('L014', '2025-05-01', '2028-05-01', 45000, 50, 'SP018', 'PN006'),
('L015', '2025-05-01', '2028-05-01', 80000, 40, 'SP023', 'PN006'),
('L016', '2025-05-01', '2028-05-01', 65000, 30, 'SP024', 'PN006'), 
('L017', '2025-01-01', '2028-01-01', 220000, 20, 'SP005', 'PN007'),
('L018', '2025-01-01', '2028-01-01', 70000, 30, 'SP029', 'PN007'), 
('L019', '2025-02-01', '2028-02-01', 550000, 10, 'SP008', 'PN008'),
('L020', '2025-02-01', '2028-02-01', 65000, 50, 'SP009', 'PN008'), 
('L021', '2025-03-01', '2028-03-01', 50000, 100, 'SP013', 'PN009'),
('L022', '2025-04-01', '2028-04-01', 30000, 200, 'SP028', 'PN010'),
('L023', '2025-04-01', '2028-04-01', 90000, 50, 'SP012', 'PN010'), 
('L024', '2025-01-01', '2028-01-01', 120000, 20, 'SP001', 'PN001'), 
('L026', '2023-12-01', '2025-12-01', 110000, 15, 'SP001', 'PN001'), 
('L027', '2023-11-15', '2025-11-15', 300000, 10, 'SP002', 'PN001'), 
('L028', '2023-12-20', '2025-12-20', 280000, 25, 'SP003', 'PN002'), 
('L029', '2023-10-30', '2025-10-30', 200000, 5,  'SP004', 'PN004'), 
('L030', '2023-12-31', '2025-12-31', 300000, 50, 'SP005', 'PN003'); 


-- BẢNG GIAO DỊCH - BÁN HÀNG 
INSERT INTO HOADON (MaHD, NgayLap, GioLap, TongTienHang, TienGiamGia, ThanhTien, PhuongThucTT, MaNV, MaKH) VALUES 
('HD001', '2025-11-01', '09:00:00', 10530000, 63900, 10466100, N'Tiền mặt', 'NV02', 'KH001'), 
('HD002', '2025-11-01', '10:00:00', 10375000, 20750, 10354250, N'Thẻ', 'NV02', 'KH002'),      
('HD003', '2025-11-02', '14:30:00', 109000, 0, 109000, N'Momo', 'NV03', 'KH003'),
('HD004', '2025-11-02', '16:00:00', 10500000, 35000, 10465000, N'Tiền mặt', 'NV02', 'KH001'),  
('HD005', '2025-11-03', '11:00:00', 135000, 0, 135000, N'Thẻ', 'NV03', 'KH005'),
('HD006', '2025-11-04', '09:30:00', 17250000, 40000, 17210000, N'Tiền mặt', 'NV02', 'KH002'),  
('HD007', '2025-11-05', '18:00:00', 2455000, 0, 2455000, N'Momo', 'NV08', 'KH007'),           
('HD008', '2025-11-06', '12:00:00', 7350000, 225000, 7125000, N'Thẻ', 'NV08', 'KH004'),    
('HD009', '2025-11-07', '15:45:00', 99000, 0, 99000, N'Tiền mặt', 'NV03', 'KH003'),
('HD010', '2025-11-08', '19:20:00', 270000, 27000, 243000, N'Thẻ', 'NV10', 'KH006'),
('HD011', '2025-11-09', '08:15:00', 2200000, 0, 2200000, N'Tiền mặt', 'NV02', 'KH005'),        
('HD012', '2025-11-10', '13:00:00', 450000, 67500, 382500, N'Momo', 'NV10', 'KH019'),
('HD013', '2025-11-11', '20:00:00', 120000, 0, 120000, N'Tiền mặt', 'NV08', 'KH017'),
('HD014', '2025-11-12', '10:10:00', 12575000, 105000, 12470000, N'Thẻ', 'NV03', 'KH010'),   
('HD015', '2025-11-13', '17:30:00', 65000, 0, 65000, N'Tiền mặt', 'NV02', 'KH003'),
('HD016', '2025-11-14', '09:00:00', 300000, 15000, 285000, N'Momo', 'NV10', 'KH011'),
('HD017', '2025-11-15', '11:30:00', 3780000, 0, 3780000, N'Thẻ', 'NV03', 'KH013'),             
('HD018', '2025-11-16', '14:45:00', 16750000, 85000, 16665000, N'Tiền mặt', 'NV08', 'KH014'),  
('HD019', '2025-11-17', '16:20:00', 250000, 12500, 237500, N'Thẻ', 'NV02', 'KH015'),
('HD020', '2025-11-18', '21:00:00', 6128000, 25000, 6103000, N'Tiền mặt', 'NV10', 'KH016'), 
('HD021', '2025-11-19', '09:00:00', 175000, 0, 175000, N'Tiền mặt', 'NV06', 'KH008'),
('HD022', '2025-11-20', '10:30:00', 238000, 0, 238000, N'Thẻ', 'NV06', 'KH009'),
('HD023', '2025-11-21', '14:00:00', 98000, 0, 98000, N'Momo', 'NV06', 'KH012'),
('HD024', '2025-11-22', '16:45:00', 125000, 0, 125000, N'Tiền mặt', 'NV06', 'KH018'),
('HD025', '2025-11-23', '19:00:00', 330000, 0, 330000, N'Thẻ', 'NV06', 'KH020');

-- CHI TIẾT HÓA ĐƠN
INSERT INTO CHITIETHOADON (MaHD, MaSP, SoLuongBan, DonGiaBan) VALUES 
('HD001', 'SP001', 20, 189000), 
('HD001', 'SP008', 15, 450000), 
('HD002', 'SP003', 25, 415000), 
('HD003', 'SP025', 1, 109000), 
('HD004', 'SP026', 30, 350000),
('HD005', 'SP016', 1, 135000), 
('HD006', 'SP008', 15, 450000), 
('HD006', 'SP026', 30, 350000), 
('HD007', 'SP011', 1, 205000), 
('HD007', 'SP028', 50, 45000),  
('HD008', 'SP008', 15, 450000), 
('HD008', 'SP027', 1, 450000), 
('HD008', 'SP017', 1, 150000),
('HD009', 'SP009', 1, 99000),
('HD010', 'SP023', 1, 120000), 
('HD010', 'SP024', 1, 150000),
('HD011', 'SP028', 50, 44000),  
('HD012', 'SP027', 1, 450000),
('HD013', 'SP023', 1, 120000),
('HD014', 'SP003', 25, 415000), 
('HD014', 'SP028', 50, 44000),  
('HD015', 'SP015', 1, 65000),
('HD016', 'SP011', 1, 205000), 
('HD016', 'SP022', 1, 95000),
('HD017', 'SP001', 20, 189000), 
('HD018', 'SP008', 15, 450000), 
('HD018', 'SP003', 25, 400000), 
('HD019', 'SP030', 2, 125000),
('HD020', 'SP001', 20, 189000), 
('HD020', 'SP024', 1, 98000), 
('HD020', 'SP028', 50, 45000),  
('HD021', 'SP006', 1, 175000), 
('HD022', 'SP013', 1, 238000), 
('HD023', 'SP024', 1, 98000), 
('HD024', 'SP030', 1, 125000), 
('HD025', 'SP005', 1, 330000);


SELECT * FROM LOAISANPHAM;
SELECT * FROM THUONGHIEU;
SELECT * FROM NHACUNGCAP;
SELECT * FROM CHUCVU;
SELECT * FROM HANGTHANHVIEN;
SELECT * FROM NHANVIEN;
SELECT * FROM TAIKHOAN;
SELECT * FROM KHACHHANG;
SELECT * FROM SANPHAM;
SELECT * FROM PHIEUNHAP;
SELECT * FROM LOHANG;
SELECT * FROM HOADON;
SELECT * FROM CHITIETHOADON;

---------SYNONYM-------------
--Synonym 1
Create synonym SP
For dbo.SANPHAM;

--Kiểm thử
Select top 5 MaSP, TenSP, GiaBan 
From SP;

--Synonym 2
Create synonym KH 
For dbo.KHACHHANG;

--Kiểm thử
Select MaKH, HoTen, SDT 
From KH 
Where HoTen like N'% Hà%';

--Synonym 3
Create synonym HD 
For dbo.HOADON;

--Kiểm thử
Select MaHD, NgayLap, TongTienHang 
From HD 
Where NgayLap = '2025-11-01';

--Synonym 4
Create synonym NV 
For dbo.NHANVIEN;

--Kiểm thử
Select MaNV, TenNV, TrangThaiLamViec 
From NV 
Where TrangThaiLamViec = N'Đang làm';

--Synonym 5
Create synonym LH 
For dbo.LOHANG;

--Kiểm thử
Select * From LH 
Where SoLuongTon > 50;

-----------INDEX------------------


--Index 1: Tạo chỉ mục tìm kiếm theo tên sản phẩm
Create index IX_SANPHAM_TenSP 
On dbo.SANPHAM(TenSP);

--Kiểm thử
Select MaSP, TenSP, GiaBan 
From SANPHAM 
Where TenSP like N'%Sữa%';


--Index 2: Tạo chỉ mục tìm kiếm theo số điện thoại
Create index IX_KHACHHANG_SDT 
On dbo.KHACHHANG(SDT);

--Kiểm thử
Select * From KHACHHANG 
Where SDT = '0987137263';

--Index 3:Tạo chỉ mục cho ngày lập hóa đơn
Create index IX_HOADON_NgayLap 
On dbo.HOADON(NgayLap);

--Kiểm thử
Select MaHD, TongTienHang, PhuongThucTT 
From HOADON 
Where NgayLap = '2025-11-01';

--Index 4: Tạo chỉ mục trên khóa ngoại MaLoai
Create index IX_SANPHAM_MaLoai 
On dbo.SANPHAM(MaLoai);

--Kiểm thử
Select TenSP, GiaBan 
From SANPHAM 
Where MaLoai = 'L001';


--Index 5: Tạo chỉ mục trên hạn sử dụng
Create index IX_LOHANG_HanSD 
On dbo.LOHANG(HanSD);

--Kiểm thử
Select MaLo, MaSP, HanSD 
From LOHANG 
Where HanSD < '2026-01-01';


--------------VIEW------------------

-- View 1: Tạo view hiển thị sản phẩm kèm tên loại và thương hiệu
Create view v_Sanpham_Chitiet
As
Select sp.MaSP, sp.TenSP, l.TenLoai, th.TenThuongHieu, sp.GiaBan, sp.DonViTinh, sp.TrangThai
From SANPHAM sp
Join LOAISANPHAM l On sp.MaLoai = l.MaLoai
Join THUONGHIEU th On sp.MaThuongHieu = th.MaThuongHieu;

-- Kiểm thử
Select * From v_Sanpham_Chitiet;


-- View 2: Tạo view chi tiết phiếu nhập hàng kèm tên NCC và NV
Create view v_Phieunhap_Chitiet
As
Select pn.MaPhieuNhap, pn.NgayNhap, ncc.TenNCC, nv.TenNV as NguoiNhap, pn.TongTienNhap
From PHIEUNHAP pn
Join NHACUNGCAP ncc On pn.MaNCC = ncc.MaNCC
Join NHANVIEN nv On pn.MaNV = nv.MaNV;

-- Kiểm thử 
Select * From v_Phieunhap_Chitiet
Where TongTienNhap > 20000000;

-- View 3: Thống kê tổng doanh thu và số hóa đơn của từng nhân viên
Create view v_Thongke_Doanhso_Nhanvien
As
Select nv.MaNV, nv.TenNV, Count(hd.MaHD) as SoLuongHoaDon, Sum(hd.TongTienHang) as TongDoanhThu
From NHANVIEN nv
Join HOADON hd On nv.MaNV = hd.MaNV
Group by nv.MaNV, nv.TenNV;

-- Kiểm thử 
Select * From v_Thongke_Doanhso_Nhanvien 
Order by TongDoanhThu Desc;

-- View 4: Thống kê tổng số lượng bán ra của từng sản phẩm
Create view v_Sanpham_Banchay
As
Select sp.MaSP, sp.TenSP, Sum(ct.SoLuongBan) as TongDaBan
From SANPHAM sp
Join CHITIETHOADON ct On sp.MaSP = ct.MaSP
Group by sp.MaSP, sp.TenSP;

-- Kiểm thử
Select top 5 * From v_Sanpham_Banchay
Order by TongDaBan Desc;

-- View 5: Lọc các sản phẩm có giá bán cao hơn mức giá trung bình
Create view v_Sanpham_GiaCao
As
Select MaSP, TenSP, GiaBan, DonViTinh
From SANPHAM
Where GiaBan > (Select Avg(GiaBan) From SANPHAM);

-- Kiểm thử
Select * From v_Sanpham_GiaCao 
Order by GiaBan Desc;

-- View 6: Tìm các sản phẩm chưa từng được bán (không có trong chi tiết hóa đơn)
Create view v_Sanpham_ChuaBanDuoc
As
Select MaSP, TenSP, GiaBan, TrangThai
From SANPHAM
Where MaSP Not In (Select Distinct MaSP From CHITIETHOADON);

-- Kiểm thử
Select * From v_Sanpham_ChuaBanDuoc;

-------------FUNCTION-------------------

--Function 1: Tạo hàm tính tổng số lượng tồn kho của một sản phẩm dựa vào mã SP
Create function f_TinhTongTonKho (@MaSP char(10))
Returns int
As
Begin
    -- Khai báo biến để lưu tổng số lượng
    Declare @TongTon int;
    
    -- Tính tổng số lượng tồn từ bảng LOHANG theo mã sản phẩm
    Select @TongTon = Sum(SoLuongTon) 
    From LOHANG 
    Where MaSP = @MaSP;
    
    -- Trả về kết quả (Nếu không có dữ liệu thì trả về 0)
    Return Isnull(@TongTon, 0);
End;

-- Kiểm thử hàm tính tổng tồn kho
Select MaSP, TenSP, dbo.f_TinhTongTonKho(MaSP) as TongTonKhoThucTe
From SANPHAM
Where MaSP = 'SP001';

--Function 2: Tạo hàm trả về bảng danh sách sản phẩm nằm trong khoảng giá
Create function f_TimSanPhamTheoGia (@GiaMin decimal(18,0), @GiaMax decimal(18,0))
Returns Table
As
Return
(
    -- Lọc danh sách sản phẩm có giá bán nằm trong khoảng từ Min đến Max
    Select MaSP, TenSP, DonViTinh, GiaBan, TrangThai
    From SANPHAM
    Where GiaBan Between @GiaMin And @GiaMax
);

-- Kiểm thử tìm kiếm sản phẩm theo giá
Select * From dbo.f_TimSanPhamTheoGia(100000, 200000)
Order by GiaBan Asc;


--Function 3: Tạo hàm tính tổng doanh thu của một tháng cụ thể trong năm
Create function f_TinhDoanhThuThang (@Thang int, @Nam int)
Returns decimal(18,0)
As
Begin
    -- Khai báo biến lưu doanh thu
    Declare @DoanhThu decimal(18,0);
    
    -- Tính tổng cột Thành tiền của các hóa đơn trong tháng/năm tương ứng
    Select @DoanhThu = Sum(ThanhTien) 
    From HOADON
    Where Month(NgayLap) = @Thang And Year(NgayLap) = @Nam;
    
    -- Trả về kết quả (nếu không có doanh thu thì trả về 0)
    Return Isnull(@DoanhThu, 0);
End;

-- Kiểm thử tính doanh thu tháng 11/2025
Select dbo.f_TinhDoanhThuThang(11, 2025) as DoanhThuThang11;


------------------PROCEDURE-------------------

--Procedure 1: Tạo thủ tục tìm kiếm sản phẩm
Create Proc sp_TimKiemSanPham
    @TuKhoa nvarchar(100)
As
Begin
    Select sp.MaSP, sp.TenSP, sp.DonViTinh, sp.GiaBan, lh.SoLuongTon
    From SANPHAM sp
    Left Join LOHANG lh On sp.MaSP = lh.MaSP
    Where sp.TenSP Like N'%' + @TuKhoa + N'%';
End;

--Kiểm thử
Exec sp_TimKiemSanPham N'sữa';


--Procedure 2: Tạo thủ tục xem doanh thu nhân viên
Create Proc sp_XemDoanhThuNhanVien
    @MaNV char(10),
    @Thang int,
    @Nam int
As
Begin
    Select MaNV, Sum(ThanhTien) as TongDoanhThu
    From HOADON
    Where MaNV = @MaNV 
      And Month(NgayLap) = @Thang 
      And Year(NgayLap) = @Nam
    Group by MaNV;
End;

--Kiểm thử
Exec sp_XemDoanhThuNhanVien 'NV02', 11, 2025;

--Procedure 3: Tạo thủ tục thêm khách hàng
Create Proc sp_ThemKhachHang
    @MaKH char(10),
    @HoTen nvarchar(100),
    @SDT varchar(15),
    @NgaySinh date,
    @GioiTinh nvarchar(10)
As
Begin
    -- Kiểm tra SĐT đã tồn tại chưa
    If Exists (Select 1 From KHACHHANG Where SDT = @SDT)
    Begin
        Print N'Lỗi: Số điện thoại này đã được đăng ký!';
        Return;
    End

    -- Thêm mới
    Insert Into KHACHHANG(MaKH, HoTen, SDT, NgaySinh, GioiTinh, DiemTichLuy, MaHang)
    Values (@MaKH, @HoTen, @SDT, @NgaySinh, @GioiTinh, 0, 'H01'); 
    
    Print N'Thêm khách hàng thành công!';
End;

--Kiểm thử
Exec sp_ThemKhachHang 'KH021', N'Nguyễn Văn Mới', '0999888777', '2000-01-01', N'Nam';

Select * From KHACHHANG Where MaKH = 'KH021'; -- Xem lại bảng Khách hàng 

-- Xóa khách hàng KH021 để test lại
Delete From KHACHHANG Where MaKH = 'KH021';

--Procedure 4: Tạo thủ tục tính tổng tiền có tham số Output
Create Proc sp_TinhTongTienHoaDon
    @MaHD char(10),
    @TongTien decimal(18,0) Output
As
Begin
    Select @TongTien = Sum(SoLuongBan * DonGiaBan)
    From CHITIETHOADON
    Where MaHD = @MaHD;
    
    If @TongTien Is Null Set @TongTien = 0;
End;

--Kiểm thử
Declare @Tien decimal(18,0);
Exec sp_TinhTongTienHoaDon 'HD001', @Tien Output;
Print N'Tổng tiền hóa đơn HD001 là: ' + Cast(@Tien as nvarchar(20));


--Procedure 5: Tạo thủ tục thanh toán có Transaction
Create Proc sp_ThanhToanHoaDon
    @MaHD char(10),
    @PhuongThucTT nvarchar(50)
As
Begin
    Begin Transaction; -- Bắt đầu giao dịch
    Begin Try
        -- 1. Cập nhật phương thức thanh toán
        Update HOADON
        Set PhuongThucTT = @PhuongThucTT
        Where MaHD = @MaHD;

        -- 2. Cộng điểm tích lũy (10.000đ = 1 điểm)
        Declare @MaKH char(10), @ThanhTien decimal(18,0);
        Select @MaKH = MaKH, @ThanhTien = ThanhTien From HOADON Where MaHD = @MaHD;
        
        If @MaKH Is Not Null
        Begin
            Update KHACHHANG
            Set DiemTichLuy = DiemTichLuy + Cast((@ThanhTien / 10000) as int)
            Where MaKH = @MaKH;
        End

        Commit Transaction; -- Xác nhận thành công
        Print N'Thanh toán và tích điểm thành công!';
    End Try
    Begin Catch
        Rollback Transaction; -- Hoàn tác nếu lỗi
        Print N'Lỗi: Giao dịch thất bại!';
		Print Error_message(); -- In ra lỗi cụ thể
    End Catch
End;

--Kiểm thử
Exec sp_ThanhToanHoaDon 'HD001', N'Thẻ';

-- 1. Xem lại Hóa đơn HD001 để thấy Phương thức thanh toán đã đổi thành 'Thẻ'
Select MaHD, ThanhTien, PhuongThucTT, MaKH 
From HOADON 
Where MaHD = 'HD001';

-- 2. Xem lại Khách hàng (của hóa đơn đó) để thấy Điểm tích lũy đã tăng lên
-- (Lấy MaKH từ hóa đơn HD001 để tìm)
Select MaKH, HoTen, DiemTichLuy 
From KHACHHANG 
Where MaKH = (Select MaKH From HOADON Where MaHD = 'HD001');


--Procedure 6: Tạo thủ tục nhập hàng có Transaction
Create Proc sp_NhapHangMoi
    @MaPhieuNhap char(10),
    @MaSP char(10),
    @SoLuong int,
    @GiaNhap decimal(18,0)
As
Begin
    Begin Transaction;
    Begin Try
        -- 1. Thêm lô hàng mới (Tạo mã lô tự động ngẫu nhiên)
        Declare @MaLo char(10) = 'L' + Cast(ABS(Checksum(NewId())) % 10000 as varchar);
        
        Insert Into LOHANG(MaLo, NgaySX, HanSD, GiaNhap, SoLuongTon, MaSP, MaPhieuNhap)
        Values (@MaLo, GetDate(), DateAdd(year, 3, GetDate()), @GiaNhap, @SoLuong, @MaSP, @MaPhieuNhap);

        -- 2. Cập nhật tổng tiền phiếu nhập
        Update PHIEUNHAP
        Set TongTienNhap = TongTienNhap + (@SoLuong * @GiaNhap)
        Where MaPhieuNhap = @MaPhieuNhap;

        Commit Transaction;
        Print N'Nhập hàng thành công!';
    End Try
    Begin Catch
        Rollback Transaction;
        Print N'Lỗi nhập hàng!';
    End Catch
End;

--Kiểm thử
-- 1. Xem tổng tiền trước khi nhập (để so sánh)
Select TongTienNhap From PHIEUNHAP Where MaPhieuNhap = 'PN001';

-- 2. Thực thi thủ tục nhập hàng
Exec sp_NhapHangMoi 'PN001', 'SP001', 50, 120000;

-- 3. Xem lại bảng Lô hàng và Phiếu nhập sau khi nhập
Select * From LOHANG Where MaPhieuNhap = 'PN001' And MaSP = 'SP001';
Select * From PHIEUNHAP Where MaPhieuNhap = 'PN001';


--Procedure 7: Tạo thủ tục xóa nhân viên an toàn
Create Proc sp_XoaNhanVien
    @MaNV char(10)
As
Begin
    Begin Transaction;
    Begin Try
        -- 1. Xóa tài khoản trước
        Delete From TAIKHOAN Where MaNV = @MaNV;
        
        -- 2. Xóa nhân viên sau
        Delete From NHANVIEN Where MaNV = @MaNV;

        Commit Transaction;
        Print N'Xóa nhân viên thành công!';
    End Try
    Begin Catch
        Rollback Transaction;
        Print N'Lỗi: Không thể xóa nhân viên này (do ràng buộc dữ liệu)!';
    End Catch
End;

--Kiểm thử
-- Bước 1: Tạo dữ liệu giả định (Nhân viên mới chưa bán hàng)
Insert Into NHANVIEN(MaNV, TenNV, MaCV) Values ('NV_Test', N'Nhân viên Test', 'CV02');
Insert Into TAIKHOAN(TenDangNhap, MatKhau, MaNV) Values ('testuser', '123', 'NV_Test');

-- Bước 2: Kiểm tra sự tồn tại trước khi xóa (Chứng minh đã thêm thành công)
Select * From NHANVIEN Where MaNV = 'NV_Test';

-- Bước 3: Thực thi thủ tục xóa (Kiểm tra Transaction hoạt động)
Exec sp_XoaNhanVien 'NV_Test';

-- Bước 4: Kiểm tra lại sau khi xóa (Kết quả phải RỖNG)
Select * From NHANVIEN Where MaNV = 'NV_Test';
Select * From TAIKHOAN Where MaNV = 'NV_Test';

/*
--Kiểm thử bị lỗi do ràng buộc dữ liệu
-- 1. Xem thông tin NV10 trước khi xóa (Để chứng minh đang tồn tại)
Select * From NHANVIEN Where MaNV = 'NV10';
Select * From TAIKHOAN Where MaNV = 'NV10';

-- 2. Thực thi lệnh xóa
Exec sp_XoaNhanVien 'NV10';
	
-- 3. Xem lại thông tin NV10 sau khi xóa (Kết quả rỗng)
Select * From NHANVIEN Where MaNV = 'NV10';
Select * From TAIKHOAN Where MaNV = 'NV10';
*/


--Procedure 8: Tạo thủ tục cập nhật giá có Transaction
Create Proc sp_CapNhatGiaTheoThuongHieu
    @MaThuongHieu char(10),
    @PhanTramTang float
As
Begin
    Begin Transaction;
    Begin Try
        Update SANPHAM
        Set GiaBan = GiaBan * (1 + @PhanTramTang / 100)
        Where MaThuongHieu = @MaThuongHieu;
        
        Commit Transaction;
        Print N'Đã cập nhật giá bán thành công!';
    End Try
    Begin Catch
        Rollback Transaction;
        Print N'Lỗi cập nhật giá!';
    End Catch
End;

--Kiểm thử
-- Bước 1. Xem giá các sản phẩm L'Oreal (TH001) trước khi tăng
Select TenSP, GiaBan From SANPHAM Where MaThuongHieu = 'TH001';

-- Bước 2. Thực thi thủ tục tăng giá 10%
Exec sp_CapNhatGiaTheoThuongHieu 'TH001', 10;

-- Bước 3. Xem lại giá mới (Phải cao hơn giá cũ)
Select TenSP, GiaBan From SANPHAM Where MaThuongHieu = 'TH001';

--Procedure 9: Tạo thủ tục cảnh báo tồn kho
Create Proc sp_CanhBaoTonKho
    @MucToiThieu int
As
Begin
    Select sp.MaSP, sp.TenSP, Sum(lh.SoLuongTon) as TongTon
    From SANPHAM sp
    Join LOHANG lh On sp.MaSP = lh.MaSP
    Group by sp.MaSP, sp.TenSP
    Having Sum(lh.SoLuongTon) < @MucToiThieu;
End;

--Kiểm thử
Exec sp_CanhBaoTonKho 20;

---------------TRIGGER----------------

--Trigger 1: Tạo trigger kiểm tra giá bán > giá nhập
Create trigger tg_KiemTraGiaBan
On SANPHAM
For Insert, Update
As
Begin
    -- Kiểm tra nếu có sản phẩm nào có Giá bán < Giá nhập gần nhất
    If Exists (
        Select * From inserted i
        Join LOHANG l On i.MaSP = l.MaSP
        Where i.GiaBan < l.GiaNhap
    )
    Begin
        Print N'Lỗi: Giá bán không được thấp hơn giá nhập của lô hàng!';
        Rollback transaction;
    End
End;

-- Kiểm thử
-- Test sai: Giá bán thấp hơn giá nhập
Update SANPHAM 
Set GiaBan = 50000 
Where MaSP = 'SP001';

-- Test đúng: Giá bán cao hơn giá nhập
/*
-- Đưa giá về lại trạng thái ban đầu để test lại
Update SANPHAM 
Set GiaBan = 189000 
Where MaSP = 'SP001';
*/

-- Test đúng: Giá bán cao hơn giá nhập
-- Bước 1: Xem giá cũ 
Select MaSP, TenSP, GiaBan 
From SANPHAM 
Where MaSP = 'SP001';

-- Bước 2: Thực hiện sửa giá hợp lệ (200.000 > 120.000)
Update SANPHAM 
Set GiaBan = 200000 
Where MaSP = 'SP001';

-- Bước 3: Xem lại giá mới (để chứng minh đã cập nhật thành công)
Select MaSP, TenSP, GiaBan From SANPHAM Where MaSP = 'SP001';


-- Trigger 2: Tạo trigger không cho phép hạ cấp thành viên
Create trigger tg_ChanHaCapThanhVien
On KHACHHANG
For Update
As
Begin
    -- Chỉ kiểm tra khi có cập nhật cột MaHang
    If Update(MaHang)
    Begin
        If Exists (
            Select * From inserted i
            Join deleted d On i.MaKH = d.MaKH
            Join HANGTHANHVIEN h_moi On i.MaHang = h_moi.MaHang
            Join HANGTHANHVIEN h_cu On d.MaHang = h_cu.MaHang
            Where h_moi.DiemToiThieu < h_cu.DiemToiThieu -- Điều kiện: Hạng mới thấp hơn hạng cũ
        )
        Begin
            Print N'Lỗi: Không được phép hạ cấp hạng thành viên của khách hàng!';
            Rollback transaction;
        End
    End
End;

-- Kiểm thử
-- Test sai: Cố tình hạ cấp khách hàng
Update KHACHHANG 
Set MaHang = 'H02' 
Where MaKH = 'KH017';

--Test đúng
-- Bước 1: Xem hạng cũ của KH003 (Đang là H01 - Thân thiết)
Select MaKH, HoTen, MaHang From KHACHHANG Where MaKH = 'KH003';

-- Bước 2: Thực hiện nâng cấp lên H02 (Hợp lệ vì H02 cao hơn H01)
Update KHACHHANG 
Set MaHang = 'H02' 
Where MaKH = 'KH003';

-- Bước 3: Xem lại hạng mới (Sẽ thấy thay đổi thành H02)
Select MaKH, HoTen, MaHang From KHACHHANG Where MaKH = 'KH003';

-- Trigger 3: Tạo trigger chặn xóa sản phẩm đang kinh doanh
Create trigger tg_KiemTraXoaSanPham
On SANPHAM
Instead of Delete --Sử dụng Instead of để chặn trước khi lỗi khóa ngoại xảy ra
As
Begin
    -- Kiểm tra nếu sản phẩm đã bán (trong Chi tiết hóa đơn) hoặc đã nhập (trong Lô hàng)
    If Exists (Select * From deleted d Join CHITIETHOADON c On d.MaSP = c.MaSP)
       Or Exists (Select * From deleted d Join LOHANG l On d.MaSP = l.MaSP)
    Begin
        -- Nếu có dữ liệu liên quan -> Báo lỗi và không thực hiện xóa
        Print N'Lỗi: Sản phẩm này đã có giao dịch, không thể xóa! Hãy chuyển trạng thái sang Ngưng bán.';
    End
    Else
    Begin
        -- Nếu sản phẩm chưa có giao dịch nào -> Cho phép xóa thật sự
        Delete From SANPHAM 
        Where MaSP In (Select MaSP From deleted);
        
        Print N'Xóa sản phẩm thành công!';
    End
End;

-- Kiểm thử
-- Test sai: Xóa sản phẩm đang kinh doanh
Delete From SANPHAM 
Where MaSP = 'SP001';

-- Test đúng
-- 1. Tạo một sản phẩm nháp 
Insert Into SANPHAM(MaSP, TenSP, MaLoai, MaThuongHieu, GiaBan) 
Values ('SP_Test', N'Sản phẩm Test', 'L001', 'TH001', 0);

-- 2. Xem lại để chắc chắn sản phẩm này đang tồn tại
Select * From SANPHAM 
Where MaSP = 'SP_Test';

-- 3. Thực hiện lệnh xóa 
Delete From SANPHAM 
Where MaSP = 'SP_Test';

-- 4. Xem lại kết quả sau khi xóa 
Select * From SANPHAM 
Where MaSP = 'SP_Test';


-- Trigger 4: Tạo trigger kiểm tra ngày nhập hàng
Create trigger tg_KiemTraNgayNhap
On PHIEUNHAP
For Insert, Update
As
Begin
    -- Kiểm tra nếu có phiếu nhập nào có Ngày nhập lớn hơn Ngày hiện tại
    If Exists (Select * From inserted Where NgayNhap > Getdate())
    Begin
        Print N'Lỗi: Ngày nhập hàng không được lớn hơn ngày hiện tại!';
        Rollback transaction;
    End
End;

-- Kiểm thử
-- Test sai: Nhập ngày tương lai 
Insert Into PHIEUNHAP(MaPhieuNhap, NgayNhap, MaNCC, MaNV) 
Values ('PN026', '2026-01-01', 'NCC01', 'NV01');


-- Test đúng: Nhập ngày hôm nay
Insert Into PHIEUNHAP(MaPhieuNhap, NgayNhap, MaNCC, MaNV) 
Values ('PN012', Getdate(), 'NCC01', 'NV01');
-- Xem lại kết quả sau khi thêm 
Select * From PHIEUNHAP Where MaPhieuNhap = 'PN012';


----------USER--------------

-- User 1: Nhóm quyền Quản lý

-- Tạo tài khoản đăng nhập
Create login QUANLY with password = '123456';
-- Tạo user kết nối vào cơ sở dữ liệu
Create user QUANLY for login QUANLY;

-- Cấp quyền 
Grant select, insert, update, delete on LOAISANPHAM to QUANLY;
Grant select, insert, update, delete on THUONGHIEU to QUANLY;
Grant select, insert, update, delete on CHUCVU to QUANLY;
Grant select, insert, update, delete on HANGTHANHVIEN to QUANLY;
Grant select, insert, update, delete on NHACUNGCAP to QUANLY;
Grant select, insert, update, delete on SANPHAM to QUANLY;
Grant select, insert, update, delete on NHANVIEN to QUANLY;
Grant select, insert, update, delete on KHACHHANG to QUANLY;
Grant select, insert, update, delete on TAIKHOAN to QUANLY;
Grant select, insert, update, delete on PHIEUNHAP to QUANLY;
Grant select, insert, update, delete on LOHANG to QUANLY;
Grant select, insert, update, delete on HOADON to QUANLY;
Grant select, insert, update, delete on CHITIETHOADON to QUANLY;


-- User 2: Nhân viên bán hàng
-- Tạo tài khoản đăng nhập
Create login NHANVIEN with password = '2324085';

-- Tạo user kết nối vào cơ sở dữ liệu
Create user NHANVIEN for login NHANVIEN;

-- Cấp quyền xem thông tin 
Grant select on LOAISANPHAM to NHANVIEN;
Grant select on THUONGHIEU to NHANVIEN;
Grant select on SANPHAM to NHANVIEN;
Grant select on HANGTHANHVIEN to NHANVIEN;
Grant select on KHACHHANG to NHANVIEN;
Grant select on HOADON to NHANVIEN;
Grant select on CHITIETHOADON to NHANVIEN;
Grant select on LOHANG to NHANVIEN;

-- Cấp quyền nghiệp vụ bán hàng 
Grant insert, update on HOADON to NHANVIEN;
Grant insert, update on CHITIETHOADON to NHANVIEN;
Grant insert on KHACHHANG to NHANVIEN;
Grant update (DiemTichLuy) on KHACHHANG to NHANVIEN; -- Chỉ cho sửa điểm tích lũy

-- Từ chối quyền xóa để bảo vệ toàn vẹn dữ liệu
Deny delete on SANPHAM to NHANVIEN;
Deny delete on HOADON to NHANVIEN;
Deny delete on KHACHHANG to NHANVIEN;

