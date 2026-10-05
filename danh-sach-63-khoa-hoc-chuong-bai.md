# Danh sách khóa học, chương và bài học của Meduc PHP cũ

Nguồn: [full_database.sql](./full_database.sql), dump hoàn tất **2026-09-20 21:28:40**.

## Tổng quan

| Trạng thái | Khóa học | Chương | Bài học |
|---|---:|---:|---:|
| Đang bật | 33 | 218 | 1064 |
| Đã tắt | 30 | 161 | 754 |
| **Tổng** | **63** | **379** | **1818** |

Các khóa học là sản phẩm thuộc danh mục **Khóa Học** (ID 50) hoặc danh mục con, chưa bị xóa. Trạng thái lấy từ trường `products.status`. Trong danh sách tiết học, mục có `chapter_vi = y` là chương; mọi mục còn lại có tên là bài học. Giữ nguyên thứ tự trong dữ liệu gốc.

Có **31** bài thiếu cờ phân loại nhưng có tên (đều thuộc khóa đã tắt); chúng được tính là bài. **17** mục không có tên được bỏ qua. Đây là số liệu của bản dump, không phải truy vấn cơ sở dữ liệu trực tiếp hôm nay.

## Danh mục khóa học

| STT | ID | Khóa học | Trạng thái | Chương | Bài |
|---:|---:|---|---|---:|---:|
| 1 | 48 | [\[Sinh Lý 1, 2\] Cơ Bản -&gt; Chuyên Sâu](#khoa-48) | Đang bật | 13 | 44 |
| 2 | 49 | [Hoá Sinh Kèm Riêng](#khoa-49) | Đã tắt | 3 | 32 |
| 3 | 50 | [Giải Phẫu Kèm Riêng](#khoa-50) | Đã tắt | 9 | 53 |
| 4 | 51 | [\[Lâm Sàng - Nội Khoa\] Cơ Bản -&gt; Chuyên Sâu](#khoa-51) | Đang bật | 7 | 30 |
| 5 | 52 | [\[Lâm Sàng - Ngoại Khoa\] Cơ Bản -&gt; Chuyên Sâu](#khoa-52) | Đang bật | 4 | 37 |
| 6 | 53 | [\[Lâm Sàng Sản Khoa\] Cơ Bản -&gt; Chuyên Sâu](#khoa-53) | Đang bật | 8 | 30 |
| 7 | 54 | [LS Nhi Khoa Cơ Bản (25 bài, 30 Case LS)](#khoa-54) | Đã tắt | 14 | 31 |
| 8 | 56 | [Tiếng Anh Y Khoa Kèm Riêng](#khoa-56) | Đã tắt | 2 | 32 |
| 9 | 96 | [\[Nội Khoa Cô Ý Nhi\] Cơ Bản -&gt; Chuyên Sâu](#khoa-96) | Đang bật | 8 | 34 |
| 10 | 99 | [\[Giải Phẫu 1, 2\] Cơ Bản -&gt; Chuyên Sâu](#khoa-99) | Đang bật | 9 | 47 |
| 11 | 100 | [Sinh Lý Cơ Bản (14 buổi, 140 sơ đồ ghi nhớ)](#khoa-100) | Đã tắt | 6 | 15 |
| 12 | 101 | [\[Tiếng Anh Y Khoa 1,2\] Cơ Bản -&gt; Chuyên Sâu](#khoa-101) | Đang bật | 12 | 40 |
| 13 | 103 | [\[Xét Nghiệm\] Cơ Bản -&gt; Chuyên Sâu](#khoa-103) | Đang bật | 3 | 28 |
| 14 | 104 | [LS Nội Khoa Cơ Bản (22 bài, 30 case LS)](#khoa-104) | Đã tắt | 2 | 27 |
| 15 | 105 | [LS Ngoại Khoa Cơ Bản (22 bài, 30 Case LS)](#khoa-105) | Đã tắt | 0 | 22 |
| 16 | 106 | [\[Sản Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-106) | Đang bật | 2 | 22 |
| 17 | 107 | [\[Lâm Sàng Nhi Khoa\] Cơ Bản -&gt; Chuyên Sâu](#khoa-107) | Đang bật | 11 | 42 |
| 18 | 109 | [Khoá học Sinh Lý Kèm Riêng](#khoa-109) | Đã tắt | 5 | 38 |
| 19 | 112 | [\[Lý Thuyết + Lâm Sàng ECG\] Cơ Bản -&gt; Chuyên Sâu](#khoa-112) | Đang bật | 6 | 35 |
| 20 | 155 | [\[Sinh Lý SĐH - Y Hà Nội\] Cơ Bản -&gt; Chuyên Sâu](#khoa-155) | Đã tắt | 10 | 40 |
| 21 | 156 | [\[Ngoại Khoa SĐH - Y Hà Nội\] Cơ Bản -&gt; Chuyên Sâu](#khoa-156) | Đã tắt | 6 | 44 |
| 22 | 157 | [\[Nội Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-157) | Đang bật | 9 | 64 |
| 23 | 158 | [\[Nhi Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-158) | Đang bật | 7 | 55 |
| 24 | 160 | [\[Hóa Sinh SĐH - Y Hà Nội\] Cơ Bản -&gt; Chuyên Sâu](#khoa-160) | Đã tắt | 2 | 45 |
| 25 | 161 | [Sinh Học \[ Cơ Bản -&gt; Chuyên Sâu\]](#khoa-161) | Đang bật | 4 | 12 |
| 26 | 162 | [Nội Khoa SĐH - Y Hà Nội (Cơ Bản 30 bài)](#khoa-162) | Đã tắt | 9 | 30 |
| 27 | 163 | [Sinh Lý SĐH - Y Hà Nội (Cơ Bản: 25 Bài)](#khoa-163) | Đã tắt | 10 | 25 |
| 28 | 164 | [Hóa Sinh SĐH - Y Hà Nội (Cơ Bản: 30 Bài)](#khoa-164) | Đã tắt | 2 | 30 |
| 29 | 165 | [Ngoại Khoa SĐH - Y Hà Nội (Cơ Bản 25 Bài)](#khoa-165) | Đã tắt | 6 | 25 |
| 30 | 166 | [Nhi Khoa SĐH - Y Hà Nội (Cơ Bản 30 Bài)](#khoa-166) | Đã tắt | 7 | 30 |
| 31 | 167 | [Nội Khoa SĐH - Y Huế (Cơ Bản 22 Bài)](#khoa-167) | Đã tắt | 0 | 0 |
| 32 | 168 | [Sinh Lý SĐH - Y Huế (Cơ Bản: 30 buổi)](#khoa-168) | Đã tắt | 0 | 0 |
| 33 | 169 | [Sinh Lý SĐH - Y Huế (Cơ Bản -&gt; Chuyên Sâu)](#khoa-169) | Đã tắt | 0 | 0 |
| 34 | 170 | [ECG Cơ Bản - 16 bài](#khoa-170) | Đã tắt | 0 | 0 |
| 35 | 171 | [Nội Cơ Bản SĐH - Y HCM: 30 bài, 10 Bộ Đề](#khoa-171) | Đã tắt | 10 | 29 |
| 36 | 172 | [Nội Chuyên Sâu SĐH - Y HCM: 65 bài, 19 Bộ Đề](#khoa-172) | Đã tắt | 19 | 54 |
| 37 | 173 | [Ngoại Cơ Bản SĐH - Y HCM: 25 Bài, 10 Bộ Đề](#khoa-173) | Đã tắt | 10 | 21 |
| 38 | 174 | [\[Ngoại Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-174) | Đang bật | 19 | 31 |
| 39 | 175 | [\[Sinh Lý SĐH - Y HCM\] Cơ Bản](#khoa-175) | Đã tắt | 10 | 25 |
| 40 | 176 | [\[Sinh Lý - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-176) | Đang bật | 18 | 32 |
| 41 | 177 | [\[Mô Phôi\] Cơ Bản -&gt; Chuyên Sâu](#khoa-177) | Đang bật | 3 | 33 |
| 42 | 178 | [Mô Phôi Cơ Bản (25 Bài + 250 sơ đồ ghi nhớ)](#khoa-178) | Đã tắt | 0 | 0 |
| 43 | 179 | [Hóa Sinh SĐH - Y HCM (Cơ Bản -&gt; Chuyên Sâu)](#khoa-179) | Đã tắt | 19 | 28 |
| 44 | 180 | [\[Hóa Sinh - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-180) | Đang bật | 13 | 19 |
| 45 | 181 | [Da Liễu Cơ Bản Đến Chuyên Sâu](#khoa-181) | Đã tắt | 0 | 24 |
| 46 | 191 | [\[Dược Lý Lý Thuyết\] Cơ Bản -&gt; Chuyên Sâu](#khoa-191) | Đang bật | 9 | 37 |
| 47 | 192 | [Tiếng Anh Giao Tiếp Y Khoa Trong Bệnh Viện (cơ bản -&gt; chuyên sâu)](#khoa-192) | Đang bật | 0 | 25 |
| 48 | 193 | [\[Sinh Lý Bệnh MD\] Cơ Bản -&gt; Chuyên Sâu](#khoa-193) | Đang bật | 4 | 37 |
| 49 | 194 | [\[Ký Sinh Trùng Y Học\] Cơ Bản -&gt; Chuyên Sâu](#khoa-194) | Đang bật | 3 | 32 |
| 50 | 195 | [\[Hóa Sinh\] Cơ Bản -&gt; Chuyên Sâu](#khoa-195) | Đang bật | 10 | 45 |
| 51 | 196 | [Thống Kê Y Học \[Cơ Bản -&gt; Chuyên Sâu\]](#khoa-196) | Đang bật | 0 | 16 |
| 52 | 197 | [\[Sinh Lý - Nội Trú\] Cơ Bản -&gt; sâu](#khoa-197) | Đã tắt | 0 | 29 |
| 53 | 198 | [\[Nội Khoa - Nội Trú\] Cơ Bản -&gt; Sâu](#khoa-198) | Đã tắt | 0 | 25 |
| 54 | 199 | [\[Lý Sinh\] Cơ Bản -&gt; Chuyên Sâu](#khoa-199) | Đang bật | 9 | 40 |
| 55 | 200 | [\[Dược Lý Lâm Sàng\] Cơ Bản -&gt; Chuyên Sâu](#khoa-200) | Đang bật | 11 | 41 |
| 56 | 201 | [\[Giải Phẫu - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu](#khoa-201) | Đang bật | 0 | 0 |
| 57 | 202 | [\[Nhi Khoa Bệnh Lý\] Cơ Bản -&gt; Chuyên Sâu](#khoa-202) | Đã tắt | 0 | 0 |
| 58 | 203 | [Giải Phẫu Bệnh(Cơ Bản -&gt; Chuyên Sâu)](#khoa-203) | Đang bật | 2 | 25 |
| 59 | 204 | [Vi Sinh (Cơ Bản -&gt; Chuyên Sâu)](#khoa-204) | Đang bật | 3 | 20 |
| 60 | 206 | [\[Nội Cơ Sở\] Cơ Bản -&gt; Chuyên Sâu](#khoa-206) | Đang bật | 6 | 38 |
| 61 | 215 | [Hoá Học \[Cơ Bản -&gt; Chuyên Sâu\]](#khoa-215) | Đang bật | 0 | 24 |
| 62 | 219 | [Tiền Lâm Sàng \[ Cơ Bản -&gt; Chuyên Sâu\]](#khoa-219) | Đang bật | 0 | 24 |
| 63 | 220 | [Ngoại Cơ Sở - Ngoại Triệu Chứng \[Cơ Bản -&gt; Chuyên Sâu\]](#khoa-220) | Đang bật | 5 | 25 |

## Chi tiết từng khóa học

<a id="khoa-48"></a>

### 1. \[Sinh Lý 1, 2\] Cơ Bản -&gt; Chuyên Sâu (ID 48)

**Trạng thái:** Đang bật · **Chương:** 13 · **Bài học:** 44

#### MODULE 1: SINH LÝ ĐẠI CƯƠNG (12 bài)

- Bài 1: Nhập môn sinh lý học, khái niệm nội môi, hằng tính nội môi
- Bài 2: Sinh lý tế bào, trao đổi chất qua màng tế bào
- Bài 3: Sinh lý điện thế màng, điện thế nghỉ và điện thế hoạt động
- Bài 4: : Sinh lý chuyển hoá chất và chuyển hoá năng lượng
- Bài 5: Sinh lý Điều nhiệt

#### Module Sinh Lý Máu

- Bài 6: Sinh lý Máu - Hồng Cầu
- Bài 7: Sinh lý Máu - Bạch cầu
- Bài 8: Sinh lý Máu - Tiểu cầu
- Bài 9: Sinh lý Máu - Huyết tương
- Bài 10: Sinh lý Máu - Nhóm máu
- Bài 11: Sinh lý Máu - Xét nghiệm công thức máu
- Bài 12: Sinh lý dịch cơ thể
- ÔN TẬP SINH LÝ ĐẠI CƯƠNG

#### MODULE 2: CƠ XƯƠNG KHỚP (2 bài)

- Bài 13: Sinh lý cơ p1
- Bài 14: Sinh lý cơ P2

#### MODULE 3: SINH LÝ HÔ HẤP (2 bài)

- Bài 15: Trao đổi khí tại phổi
- Bài 16: Chuyên chở khí trong máu

#### MODULE 4: TIM MẠCH (2 bài)

- Bài 17: Tuần hoàn Tim
- Bài 18: Tuần hoàn Hệ mạch

#### MODULE 5: TIÊU HÓA (2 bài)

- Bài 19: Sinh lý tiêu hóa - dạ dày
- Bài 20: Sinh lý tiêu hoá - ruột non - ruột già

#### MODULE 6: GAN - MẬT (1 bài)

- Bài 21: Sinh lý Gan - Mật

#### ÔN TẬP GIỮA KÌ

#### MODULE 7: TIẾT NIỆU (2 bài)

- Bài 22: Qúa trình lọc tại cầu thận
- Bài 23: Qúa trình trao đổi tại ống thận

#### MODULE 8: NỘI TIẾT (2 bài)

- Bài 24: Tổng quan sinh lý nội tiết
- Bài 25: Sinh lý nội tiết (tiếp theo)

#### MODULE 9: SINH SẢN (3 bài)

- Bài 26: Sinh sản nam
- Bài 27: Sinh sản nữ
- Bài 28: Sự thụ tinh

#### MODULE 10: THẦN KINH (5 bài)

- Bài 29: Sinh lý thần kinh Nơron - Synap (P1)
- Bài 30-1: Sinh lý thần kinh nơ ron -synap (P2)
- Bài 30-2: Sinh lý hệ thần kinh (cảm giác P3)
- Bài 30-3: Sinh lý hệ thần kinh (vận động P4)
- Bài 30-4: Sinh lý hệ thần kinh (tự chủ P5)

#### Bài 31: Ôn tập Cuối Khoá P1 + P2

- TRẮC NGHIỆM TIM MẠCH (WEBSITE)
- TRẮC NGHIỆM TIÊU HÓA (WEBSITE)
- TRẮC NGHIỆM HÔ HẤP (WEBSITE)
- TRẮC NGHIỆM TIM MẠCH (WEBSITE)
- TRẮC NGHIỆM THẦN KINH (WEBSITE)
- TRẮC NGHIỆM THẦN KINH (WEBSITE)
- TRẮC NGHIỆM GIỮA KÌ (WEBSITE)
- TRẮC NGHIỆM SINH SẢN (WEBSITE)
- TRẮC NGHIỆM LUYỆN ĐỀ (WEBSITE)
- TRẮC NGHIỆM LUYỆN ĐỀ tiếp theo(WEBSITE)

<a id="khoa-49"></a>

### 2. Hoá Sinh Kèm Riêng (ID 49)

**Trạng thái:** Đã tắt · **Chương:** 3 · **Bài học:** 32

#### Hóa Sinh Lý Thuyết

- Bài 1: Hóa Sinh Glucid
- Bài 2: Hóa Sinh Protid
- Bài 3: Hóa Sinh Lipid
- Bài 4: Hóa Sinh enzym

#### Chuyên Ngành Hoá Sinh Lâm Sàng

- Bài 5: Các Xét Nghiệm Thăm Dò Chức Năng Thận
- Bài 6: Rối Loạn Chuyển Hoá Cacbonhydrat Và Xét Nghiệm Liên Quan
- Bài 7: Xét Nghiệm Đánh Giá Chức Năng Gan
- Bài 8: Các Xét Nghiệm Trong Bệnh Lý Tim Mạch
- Bài 9: Chỉ Dấu Ung Thư
- Bài 10: Rối Loạn Chuyển Hoá Lipid Máu Và Xét Nghiệm Lipid, Máu
- Bài 11: Các Xét Nghiệm Đánh Giá Chức Năng Tuyến Giáp
- Bài 12: Nguyên Lý Đo Quang
- Bài 13: Các Phương Pháp Xét Nghiệm Miễn Dịch
- Bài 14: Các Yếu Tố Gây Nhiễu Giai Đoạn Tiền Phân Tích Ảnh Hưởng Sinh Hoá - Miễn Dịch
- Ôn Tập - Thực Hành Biện Luận Một Số Kết Quả Xét Nghiệm Hoá Sinh

#### Chuyên Ngành Huyết Học

- Bài 15: Sinh Lý Hồng Cầu Và Các Rối Loạn Dòng Hồng Cầu
- Bài 16: Sinh Lý Bạch Cầu Và Các Rối Loạn Dòng Bạch Cầu
- Bài 17: Kỹ Thuật Xét Nghiệm Huyết Học Tế Bào - Biện Luận Công Thức Máu
- Bài 18: Sinh Lý Đông Cầm Máu
- Bài 19: Kỹ Thuật Xét Nghiệm Khảo Sát Đông Cầm Máu
- Bài 20: Tổng Quan Các Bệnh Lý Liên Quan Đến Rối Loạn Đông máu
- Bài 21: Tổng Quan Hện Thống Nhóm Máu - Hệ Nhóm Máu ABO Và Hệ Nhóm Máu RHESUS
- Bài 22: Kỹ Thuật Định Nhóm Máu Hệ ABO Và RHESUS
- Bài 23: Kỹ Thuật Xét Nghiệm Coombs
- Bài 24: Phản Ứng Hoà Hợp Trong Truyền Máu
- Ôn Tập
- Kiểm Tra Cuối Kỳ
- Luyện Đề 1
- Luyện Đề 2
- Luyện Đề 3
- Luyện Đề 4
- Luyện Đề 5

<a id="khoa-50"></a>

### 3. Giải Phẫu Kèm Riêng (ID 50)

**Trạng thái:** Đã tắt · **Chương:** 9 · **Bài học:** 53

#### Giải Phẫu 1 : Chi Trên (5 Buổi)

- Bài 1: Module Cơ Xương Khớp: Các Mặt Phẳng Giải Phẫu
- Bài 2: Module Cơ Xương Khớp: Xương Khớp Chi Trên P1
- Bài 3: Module Cơ Xương Khớp: Xương Khớp Chi Trên P2
- Bài 4: Module Cơ xương Khớp: Cơ Chi Trên
- Bài 5: Ôn Luyện Đề Chương Xương Khớp Cơ Chi Trên

#### Giải Phẫu 1: Chi Dưới (5 Buổi)

- Bài 6: Module Cơ Xương Khớp: Xương Khớp Chi Dưới P1
- Bài 7: Module Cơ Xương Khớp: Xương Khớp Chi Dưới P2
- Bài 8: Module Cơ Xương Khớp: Cơ Chi Dưới P1
- Bài 9: Module Cơ Xương Khớp: Cơ Chi Dưới P2
- Bài 10: Ôn Luyện Đề Chương Xương Khớp Cơ Chi Dưới

#### Giải Phẫu 1: Thân Mình (3 buổi)

- Bài 11: Module Cơ Xương Khớp: Xương Thân Mình
- Bài 12: Module Cơ Xương Khớp: Cơ Thân Mình
- Bài 13: Ôn Luyện Đề Xương, Khớp, Cơ Thân Mình

#### Giải Phẫu 1: Đầu Mặt Cổ (5 Buổi)

- Bài 14: Module Cơ Xương Khớp: Xương Khớp Đầu Mặt Cổ P1
- Bài 15: Module Cơ Xương Khớp: Xương Khớp Đầu Mặt Cổ P2
- Bài 16: Module Cơ Xương Khớp: Cơ Đầu Mặt Cổ P1
- Bài 17: Module Cơ Xương Khớp: Cơ Đầu Mặt Cổ P2
- Bài 18: Ôn Luyện Đề Xương Khớp Cơ Đầu Mặt Cổ
- Bài 19: Ôn Luyện Giải Phẫu 1

#### Giải Phẫu 2: Tim Mạch (8 buổi)

- Bài 20: Module Tim Mạch: Giải Phẫu Hình Thể Ngoài Của Tim
- Bài 21: Module Tim Mạch: Giải Phẫu Hình Thể Trong Của Tim
- Bài 22: Module Tim Mạch: Động Mạch Chủ - Tĩnh Mạch Chủ
- Bài 23: Module Tim Mạch: Mạch Máu Chi Trên
- Bài 24: Module Tim Mạch: Mạch Máu Chi Dưới
- Bài 25: Ôn Luyện Đề Tim, Mạch máu Chi Trên Dưới
- Bài 26: Module Tim Mạch: Mạch Máu Đầu Mặt Cổ
- Bài 27: Ôn Luyện Đề Mạch Máu Đầu Mặt Cổ

#### Giải Phẫu 2: Hô Hấp (4 buổi)

- Bài 28: Module Hô Hấp: Giải Phẫu Mũi
- Bài 29: Module Hô Hấp: Giải Phẫu Thanh Quản - Khí Phế Quản
- Bài 30: Module Hô Hấp: Giải Phẫu Phổi
- Bài 31: Ôn Luyện Đề Hệ Hô Hấp

#### Giải Phẫu 2: Tiêu Hoá (6 buổi)

- Bài 32: Module Tiêu Hóa: Giải Phẫu Ổ Miệng- Thực Quản- Dạ Dày
- Bài 33: Ôn Luyện Đề: Ổ Miệng, Thực Quản, Dạ Dày
- Bài 34: Module Tiêu Hóa: Giải Phẫu Gan - Đường Mật- Lách
- Bài 35: Ôn Luyện Đề Giải Phẫu Gan Mật Lách
- Bài 36: Module Tiêu Hóa: Giải Phẫu Ruột Non- Ruột Già
- Bài 37: Ôn Luyện Đề Ruột Non, Ruột Già

#### Giải Phẫu 2: Tiết Niệu, Sinh Dục (4 buổi)

- Bài 38: Module Hệ Tiết Niệu: Giải Phẫu Thận, Niệu Quản, Bàng Quang, Niệu Đạo
- Bài 39: Ôn Luyện Đề Hệ Tiết Niệu
- Bài 40: Module Hệ Sinh Dục: Giải Phẫu Cơ Quan Sinh Dục Nam - Nữ
- Bài 41: Ôn Luyện Đề Cơ Quan Sinh Dục Nam, Cơ Quan Sinh Dục Nữ

#### Giải Phẫu 2: Ngũ Quan, Thần Kinh (8 Buổi)

- Bài 42: Module Ngũ Quan: Cơ Quan Thị Giác - Tiền Đình Ốc Tai
- Bài 43: BTVN: Cơ Quan Tiền Đình Ốc Tai, Cơ Quan Thị Giác
- Bài 44: Module Thần Kinh: Thần Kinh Tủy Sống: Tủy Gai - Thân Não - Tiểu Não
- Bài 45: Module Thần Kinh: Gian Não- Đoan Não
- Bài 46: Module Thần Kinh: Hệ Thần Kinh Tự Chủ- 12 Đôi dây TK
- Bài 47: Module Thần Kinh: TK Chi Trên- TK Chi Dưới
- Bài 48: Ôn Luyện Giải phẫu 2
- Luyện Đề 1
- Luyện Đề 2
- Luyện Đề 3
- Luyện Đề 4
- Luyện Đề 5

<a id="khoa-51"></a>

### 4. \[Lâm Sàng - Nội Khoa\] Cơ Bản -&gt; Chuyên Sâu (ID 51)

**Trạng thái:** Đang bật · **Chương:** 7 · **Bài học:** 30

#### Phần 1: Tiêu hóa ( Chào mừng bạn đến với khoá học tại Meduc.vn)

- Buổi 1: Xuất huyết tiêu hóa
- Buổi 2: Viêm gan B
- Buổi 3: Viêm tuỵ cấp
- Buổi 4: Xơ gan và biến chứng

#### Phần 2: Nội tiết (wow, bạn đã vượt qua 4 buổi đầu tiên một cách thật xuất sắc)

- Buổi 5: Đái tháo đường và biến chứng cấp mạn
- Buổi 6: Cường giáp
- Buổi 7: Suy giáp

#### Phần 3: Hô hấp ( Hít thở nào, bạn đang làm rất tốt, tiếp tục tiến lên nha )

- Buổi 8 : Khí máu động mạch và hô hấp ký
- Buổi 9: COPD
- Buổi 10: Hen
- Buổi 11: Viêm phổi
- Buổi 12: Ôn Tập Giữa Kì
- Buổi 13: Kiểm Tra Giữa Kì ( Vấn Đáp )

#### Phần 4: Tim mạch ( Tim bạn đập nhanh không ? chúng ta đã vượt qua 1/2 chặng đường rồi đấy)

- Buổi 14: Tăng huyết áp
- Buổi 15: Bệnh lý van tim
- Buổi 16: Nhồi máu cơ tim cấp
- Buổi 17: Suy tim cấp - mạn

#### Phần 5: Thận nội ( Thận trọng với những quyết định của bạn, đây không phải lúc bỏ cuộc đâu)

- Buổi 18: Tổn Thương Thận Cấp
- Buổi 19: Bệnh Thận Mạn
- Buổi 20: Nhiễm trùng tiểu
- Buổi 21: Bệnh cầu thận

#### Phần 6: Cơ xương khớp (Còn 1 tháng nữa là những kết quả của chúng ta sẽ '' Khớp '' với cố gắng ta đã bỏ ra)

- Buổi 22: Viêm khớp dạng thấp
- Buổi 23: Thoái hóa khớp
- Buổi 24: Loãng xương
- Buổi 25: Gout

#### Phần 7: Hồi sức tích cực và Máu ( Bạn Hãy Nghỉ Ngơi Một Chút Đi, Rồi Quay Lại Và Mạnh Mẽ Hơn Nhé )

- Buổi 26: Hồi sức ngưng tim ngưng thở cơ bản
- Buổi 27: Các rối loạn đông máu, và thuốc
- Buổi 28: Thiếu máu và tiếp cận thiếu máu
- Buổi 29: Ôn tập cuối kì
- Buổi 30: Kiểm Tra Cuối Kì ( Trắc Nghiệm ) (Chúc Mừng Bạn Đã Hoàn Thành Khoá Học Tại Meduc.vn)

<a id="khoa-52"></a>

### 5. \[Lâm Sàng - Ngoại Khoa\] Cơ Bản -&gt; Chuyên Sâu (ID 52)

**Trạng thái:** Đang bật · **Chương:** 4 · **Bài học:** 37

#### PHẦN 1: TIÊU HÓA – BỤNG CẤP

- Buổi 1: Viêm ruột thừa cấp
- Buổi 2: Thủng ổ loét dạ dày tá tràng
- Buổi 3: Tắc ruột
- Buổi 4: Hội Chứng Hẹp Môn Vị
- Buổi 5: Lồng Ruột Trẻ Em
- Buổi 6: Chấn thương bụng, Hội Chứng Chảy Máu Trong
- Buổi 7: Viêm Túi Mật Cấp
- Buổi 8: Sỏi Ống Mật Chủ
- Buổi 9: Viêm phúc mạc và các ổ áp xe trong ổ bụng
- Buổi 10: Ung thư dạ dày ( Chẩn Đoán - Phân Loại )
- Buổi 11: Ung Thư Dạ Dày ( Điều Trị )
- Buổi 12: Ung thư đại tràng ( Chẩn Đoán )
- Buổi 13: Điều Trị Ung Thư Đại Tràng
- Buổi 14: Trĩ ( Phẫu Thuật )
- Buổi 15: Thoát Vị Bẹn

#### PHẦN 2: CHẤN THƯƠNG – XƯƠNG

- Buổi 16: Khám Gãy Xương
- Buổi 17: Gãy xương hở
- Buổi 18: Gãy trên lồi cầu xương cánh tay
- Buổi 19: Gãy Thân Xương Cánh Tay
- Buổi 20: Gãy hai xương cẳng tay
- Buổi 21: Gãy thân xương đùi
- Buổi 22: Gãy Cổ Xương Đùi
- Buổi 23: Gãy hai xương cẳng chân
- Buổi 24: Tổng Quan Gãy Xương Chày
- Buổi 25: Thoát Vị Đĩa Đệm - Thắt Lưng
- Buổi 26: Sơ Lược Về Tạo Hình
- Buổi 27: Ôn Tập

#### PHẦN 3: CHẤN THƯƠNG – NIỆU / BỎNG / MỀM

- Buổi 28: Chấn Thuơng Niệu Đạo
- Buổi 29: Chấn thương thận
- Buổi 30: Chấn Thương Bìu - Dương Vật
- Buổi 31: U Xơ tiền Lịệt Tuyến
- Buổi 32: Bỏng + Điều trị khuyết hông phần mềm
- Buổi 33: Nhiễm Trùng Và Vết Thương Bàn Tay
- Buổi 34: Sỏi tiết niệu
- Buổi 35: Chấn Thương Ngực
- Bài 36: Chấn Thương Sọ Não
- Buổi 37: Ôn Tập Chấn Thương

#### Bài 38: Ôn Tập Cuối Kì


<a id="khoa-53"></a>

### 6. \[Lâm Sàng Sản Khoa\] Cơ Bản -&gt; Chuyên Sâu (ID 53)

**Trạng thái:** Đang bật · **Chương:** 8 · **Bài học:** 30

#### Chương 1. Sản Khoa

- Buổi 1: Thay đổi giải phẫu và sinh lý ở phụ nữ mang thai.
- 1.2. Sự phát triển của phôi và thai – Tính chất thai nhi của phần phụ đủ tháng.
- 1.3. Chẩn đoán có thai.
- 1.4. Sinh lý chuyển dạ.
- 1.5. Biểu đồ tim thai và cơn co tử cung.
- 1.6. Hậu sản thường.

#### Ôn Tập

- 1.7. Chảy máu âm đạo 3 tháng đầu thai kỳ.
- 1.8. Thai lạc chỗ.
- 1.9. Thai trứng.
- 1.10. Thai chết trong tử cung.
- 1.11. Nhau tiền đạo.
- 1.12. Nhau bong non.
- 1.13. Vỡ tử cung
- 1.14. Sinh non.

#### Ôn Tập

#### Kiểm Tra giữa Kì

- 1.15. Đái tháo đường thai kỳ.
- 1.16. Tăng huyết áp thai kỳ.
- 1.17. Đa ối – Thiểu ối
- 1.18. Thai chậm tăng trưởng trong tử cung.
- 1.19. Thai suy trong chuyển dạ
- 1.20. Chảy máu sau sinh

#### Ôn Tập

#### Chương 2. Phụ Khoa

- 2.1. Sinh lý phụ khoa.
- 2.2. Các biện pháp tránh thai.
- 2.3. Các phương pháp đình chỉ thai.
- 2.4. Bệnh lý lành tính âm hộ - âm đạo.
- 2.5. Bệnh lây truyền qua đường tình dục.
- 2.6. Vai trò của siêu âm trong sản khoa.
- 2.7. U xơ tử cung.
- 2.8. Khối u buồng trứng.
- 2.9. Bệnh lý cổ tử cung, lành tính và ác tính.
- 2.10. Khối u vú

#### Ôn Tập

#### Kiểm Tra Cuối Kì


<a id="khoa-54"></a>

### 7. LS Nhi Khoa Cơ Bản (25 bài, 30 Case LS) (ID 54)

**Trạng thái:** Đã tắt · **Chương:** 14 · **Bài học:** 31

#### Chương I: Nhi Khoa Đại Cương

- Buổi 1: Các thời kỳ của trẻ em &amp; Quá trình phát triển thể chất trẻ em
- Buổi 2: Tiêm chủng

#### Chương II: Sơ Sinh

- Buổi 3: Đặc điểm của trẻ bình thường và trẻ đẻ non &amp; Chăm sóc trẻ sơ sinh.
- Buổi 4: Hội chứng hô hấp nguy kịch ở trẻ sơ sinh/ Bệnh màng trong
- Buổi 5: Vàng da ở trẻ sơ sinh
- Buổi 6: Nhiễm khuẩn sơ sinh

#### Ôn Tập

#### Chương 3: Tiêu Hoá, Hô Hấp

- Buổi 7: Tiêu chảy cấp
- Buổi 8: Viêm thanh khí phế quản
- Buổi 9: Viêm tiểu phế quản
- Buổi 10: Viêm phổi
- Buổi 11: Hen phế quản

#### Chương 4: Tim mạch

- Buổi 12: Bệnh tim bẩm sinh 1 (Sinh lý, giải phẫu hệ tuần hoàn trẻ em, thông liên nhĩ, thông liên thất)
- Buổi 13: Bệnh tim bẩm sinh 2 (PDA, Tứ chứng Fallot)

#### Chương 5: Tiết niệu

- Buổi 14: Viêm cầu thận cấp
- Buổi 15: Hội chứng thận hư
- Buổi 16: Nhiễm trùng đường tiểu
- Ôn Tập

#### Kiểm tra Giữa Kì

#### Chương 6: Dinh Dưỡng và Huyết Học

- Buổi 17: Nhu cầu dinh dưỡng trẻ em và các bệnh liên quan.
- Buổi 18: Thiếu máu do dinh dưỡng
- Buổi 19: Thiếu máu do tán huyết
- Buổi 20: Bạch cầu cấp
- Buổi 21: Xuất huyết giảm tiểu cầu miễn dịch

#### Chương 7: Thần Kinh

- Buổi 22: Hội chứng co giật
- Buổi 23: Động Kinh
- Buổi 24: Viêm màng não mủ

#### Ôn Tập

#### Chương 8: Truyền nhiễm, Miễn Dịch

- Buổi 26: Sốt xuất huyết
- Buổi 27: Nhiễm trùng huyết &amp; Sốc nhiễm trùng
- Buổi 28: Kawasaki

#### Chương 9: Cấp cứu

- Buổi 29: Sốc trẻ em, tiếp cận chẩn đoán sử trí
- Buổi 30: Cấp cứu ngừng thở ngừng tim
- Buổi 31: Rối loạn nước điện giải

#### Ôn Tập

#### Kiểm tra cuối kỳ


<a id="khoa-56"></a>

### 8. Tiếng Anh Y Khoa Kèm Riêng (ID 56)

**Trạng thái:** Đã tắt · **Chương:** 2 · **Bài học:** 32

#### Phần 1: Nền Tảng

- Buổi 1: Key Concepts Of Medical Terminology
- Buổi 2: Body Structure

#### Phần 2: Các Hệ Cơ Quan

- Buổi 3: Skeletal System P1
- Buổi 4: Skeletal System P2
- Buổi 5: Muscular System P1
- Buổi 6: Muscular System P2
- Buổi 7: Buổi Ôn Tập Hệ Cơ Xương Khớp
- Buổi 8: Integumentary System – Da Liễu P1
- Buổi 9: Integumentary System – Da Liễu P2
- Buổi 10: Cardiovascular System P1
- Buổi 11: Cardiovascular System P2
- Buổi 12: Cardiovascular System P3
- Buổi 13: Respiratory System P1
- Buổi 14: Respiratory System P2
- Buổi 15: Respiratory System P3
- Buổi 16: Gastrointestinal System P1
- Buổi 17: Gastrointestinal System P2
- Buổi 18: Gastrointestinal System P3
- Buổi 19: Kiểm Tra Giữa Kỳ
- Buổi 20: Urinary System P1
- Buổi 21: Urinary System P2
- Buổi 22: Reproductive System (Nam + Nữ) P1
- Buổi 23: Reproductive System (Nam + Nữ) P2
- Buổi 24: Maternal Health P1
- Buổi 25: Maternal Health P2
- Buổi 26: Neurologic System P1
- Buổi 27: Neurologic System P2
- Buổi 28: Endocrine System P1
- Buổi 29: Endocrine System P2
- Buổi 30: Blood And Lymphatic System P1
- Buổi 31: Blood And Lymphatic System P2
- Buổi 32: Kiểm Tra Cuối Kỳ

<a id="khoa-96"></a>

### 9. \[Nội Khoa Cô Ý Nhi\] Cơ Bản -&gt; Chuyên Sâu (ID 96)

**Trạng thái:** Đang bật · **Chương:** 8 · **Bài học:** 34

#### Chương 1: Hô Hấp

- Buổi 1: Bệnh phổi tắc nghẽn mạn tính
- Buổi 2. Hen phế quản
- Buổi 3. Viêm phổi cộng đồng
- Buổi 4. Ung thư phổi nguyên phát
- Buổi 5. Suy hô hấp

#### Chương 2: Tiêu Hóa

- Buổi 6. Viêm gan mạn
- Buổi 7. Loét dạ dày tá tràng
- Buổi 8. Xơ gan- ung thư gan
- Buổi 9. Viêm ruột mạn
- Buổi 10. Viêm tụy cấp
- Buổi 11. Hội chứng thận hư
- Buổi 12. Viêm cầu thận cấp sau nhiễm liên cầu
- Buổi 13. Suy thận mạn
- Buổi 14. Suy thận cấp
- Buổi 15. Bệnh cầu thận IgA

#### Chương 3: Tim Mạch

- Buổi 16. Tăng huyết áp
- Buổi 17. Nhồi máu cơ tim
- Buổi 18. Suy tim
- Buổi 19. Thấp tim
- Buổi 20. Ngưng thở tắc nghẽn khi ngủ

#### Chương 4: Thần Kinh

- Buổi 21. Parkinson
- Buổi 22. Tai biến mạch máu não
- Buổi 23. Động kinh
- Buổi 24. Tăng áp lực nội sọ
- Buổi 25. Guillain Barre

#### Chương 5: Cơ Xương Khớp

- Buổi 26. Nhược cơ
- Buổi 27. Viêm khớp dạng thấp
- Buổi 28. Thoái khớp
- Buổi 29. Gout
- Buổi 30. Lupus ban đỏ hệ thống

#### Chương 6: Nội Tiết

- Buổi 31. Đái tháo đường
- Buổi 32. Basedow
- Buổi 33. Suy giáp
- Buổi 34. Suy thượng thận

#### Buổi 35. Ôn tập cuối kì

#### Buổi 36. Kiểm Tra


<a id="khoa-99"></a>

### 10. \[Giải Phẫu 1, 2\] Cơ Bản -&gt; Chuyên Sâu (ID 99)

**Trạng thái:** Đang bật · **Chương:** 9 · **Bài học:** 47

#### Đại Cương Giải Phẫu (2 Bài)

- Bài 1: Nhập Môn Giải Phẫu - Thuật Ngữ Giải Phẫu
- Bài 2: Đại Cương Về Xương, Khớp, Cơ

#### MODULE 1: CƠ XƯƠNG KHỚP ( 10 Bài)

- Bài 3: Xương Khớp Chi Trên P1
- Bài 4: Xương Khớp Chi Trên P2
- Bài 5: Cơ Chi Trên
- Bài 6.1: Xương Khớp Chi Dưới P1
- Bài 6.2: Xương Khớp Chi Dưới P2
- Bài 7.1: Cơ Chi Dưới P1
- Bài 7.2: Cơ Chi Dưới P2
- Bài 8: Xương - Khớp Thân Mình
- Bài 9: Cơ Thân Mình
- Bài 10.1: Xương Khớp Đầu Mặt Cổ P1
- Bài 10.2: Xương Khớp Đầu Mặt Cổ P2
- Bài 11.1: Cơ Đầu Mặt Cổ P1
- Bài 11.2: Cơ Đầu Mặt Cổ P2
- Bài 12.1: Ôn Tập Hệ Vận Động (Xương Khớp Cơ Chi Trên)
- Bài 12.2 : Ôn Tập Hệ Vận Động (Xương Khớp Cơ Chi Dưới)
- Bài 12.3: Ôn Tập Hệ Vận Động (Xương, Khớp, Cơ Thân Mình)
- Bài 12.4: Ôn Tập Hệ Vận Động (Xương, Khớp, Đầu Mặt Cổ)

#### MODULE 2: TIM MẠCH (6 Bài)

- Bài 13: Trung Thất
- Bài 14.1 : Giải Phẫu Hình Thể Ngoài Của Tim
- Bài 14.2: Giải Phẫu Hình Thể Trong Của Tim
- Bài 15: Động Mạch Chủ - Tĩnh Mạch Chủ
- Bài 16: Mạch Máu Chi Trên
- Bài 17: Mạch Máu Chi Dưới
- Bài 18: Mạch Máu Đầu Mặt Cổ

#### MODULE 3: HÔ HẤP (4 Bài)

- Bài 19: Giải Phẫu Thành Ngực
- Bài 20: Giải Phẫu Mũi
- Bài 21: Hầu - Thanh Quản
- Bài 22: Khí Quản - Phế Quản - Phổi

#### MODULE 4: TIÊU HÓA (5 Bài)

- Bài 23: GP Ổ Bụng - Thành Bụng - Phúc Mạc - Ống Bẹn
- Bài 24: Ổ Miệng- Thực Quản
- Bài 25: Dạ Dày - Ruột Non - Ruột Già
- Bài 26: Gan - Đường Mật - Lách
- Bài 27: Ôn Luyện Đề Hệ Tiêu Hoá

#### MODULE 5: THẬN - TIẾT NIỆU (1 Bài)

- Bài 28: Thận, Niệu Quản, Bàng Quang, Niệu Đạo

#### MODULE 6: SINH DỤC - SINH SẢN (1 Bài)

- Bài 29: Cơ Quan Sinh Dục Nam - Nữ

#### MODULE 7: GIÁC QUAN (2 Bài)

- Bài 30: Cơ Quan Thị Giác - Tiền Đình Ốc Tai
- Bài 31: Ôn Tập Các Hệ Đã Học
- Ôn Luyện Hệ Tim Mạch
- Ôn Luyện Hệ Hô Hấp
- Ôn Luyện Hệ Tiết Niệu - Sinh Dục

#### MODULE 8: THẦN KINH (5 Bài)

- Bài 32: Thân Não - Tiểu Não - Tủy Gai
- Bài 33: Gian Não- Đoan Não
- Bài 34: Hệ Thần Kinh Tự Chủ- 12 Đôi dây TK Sọ
- Bài 35: TK Chi Trên - TK Chi Dưới
- Bài 36: Ôn Luyện Cuối Khoá

<a id="khoa-100"></a>

### 11. Sinh Lý Cơ Bản (14 buổi, 140 sơ đồ ghi nhớ) (ID 100)

**Trạng thái:** Đã tắt · **Chương:** 6 · **Bài học:** 15

#### Phần 1: Sinh Lý Máu

- Buổi 1: Cấu tạo và chức năng hồng cầu, quá trình tạo máu
- Buổi 2: Phân loại nhóm máu, nguyên tắc định nhóm máu và truyền máu

#### Phần 2: Sinh Lý Hô Hấp

- Buổi 3: Sinh lý hô hấp: Trao đổi khí tại phổi
- Buổi 4: Sinh lý hô hấp: Chuyên chở khí trong máu

#### Phần 4: Sinh Lý Tiêu Hoá

- Buổi 5: Tim (cấu trúc và chức năng của tim)
- Buổi 6: Hệ mạch (các chức năng của hệ mạch)
- Buổi 7: Tiêu hóa ở ruột non và ruột già (hoạt động cơ học và bài tiết)
- Buổi 8: Tiêu hóa ở ruột non và ruột già (hoạt động cơ học và bài tiết)

#### Phần 5: Sinh Lý Tiết Niệu

- Buổi 9: Các thành phần của hệ tiết niệu, chức năng của thận
- Buổi 10: Sinh lý hệ tiết niệu: Quá trình tạo ra nước tiểu ở thận

#### Phần 6: Sinh Lý Nội Tiết

- Buổi 11: Vai trò một số tuyến nội tiết trong cơ thể
- Phần 7: Sinh Lý Sinh Sản
- Buổi 12: Quá trình thụ tinh

#### Phần 8: Sinh Lý Hệ Thần Kinh

- Buổi 13: Sinh lý hệ thần kinh: Hệ thần kinh tự chủ
- Buổi 14: Thần kinh tủy gai

<a id="khoa-101"></a>

### 12. \[Tiếng Anh Y Khoa 1,2\] Cơ Bản -&gt; Chuyên Sâu (ID 101)

**Trạng thái:** Đang bật · **Chương:** 12 · **Bài học:** 40

#### Chương 1: Nền Tảng Tiếng Anh Chuyên Ngành

- Buổi 1: Key concepts: cấu trúc từ, root, suffix, prefix
- Buổi 2: Body structure: thuật ngữ cơ thể, ứng dụng phân tích thuật ngữ

#### Chương 2: Hệ Cơ Xương Khớp

- Buổi 3: Skeletal system – cấu trúc xương, thuật ngữ
- Buổi 4: Skeletal system – bệnh lý xương, ứng dụng thuật ngữ
- Buổi 5: Muscular system – cấu trúc cơ, thuật ngữ
- Buổi 6: Muscular system – bệnh lý cơ, ứng dụng thuật ngữ
- Buổi 7: Buổi Ôn Tập Hệ Cơ Xương Khớp

#### Chương 3: Da liễu / Integumentary

- Buổi 8: Integumentary System – Cấu trúc da, thuật ngữ da liễu
- Buổi 9: Integumentary System – Bệnh lý da liễu, ứng dụng thuật ngữ

#### Chương 4: Tim mạch (Cardiovascular)

- Buổi 10: Cardiovascular System: Cấu trúc tim, mạch máu, thuật ngữ cơ bản
- Buổi 11: Cardiovascular System: Bệnh lý tim mạch, thuật ngữ chuyên môn
- Buổi 12: Cardiovascular System: Ứng dụng thuật ngữ tim mạch
- Buổi 13: Ôn Tập Da Liễu - Tim Mạch

#### Chương 5: Hô hấp (Respiratory)

- Buổi 14: Respiratory System: Cấu trúc hệ hô hấp, thuật ngữ
- Buổi 15: Respiratory System: Bệnh lý hô hấp, thuật ngữ chuyên môn
- Buổi 16: Respiratory System: Ứng dụng thuật ngữ hô hấp

#### Chương 6: Tiêu hóa (Gastrointestinal)

- Buổi 17: Gastrointestinal System P1: Cấu trúc hệ tiêu hóa, thuật ngữ
- Buổi 18: Gastrointestinal System P2: Bệnh lý tiêu hóa, thuật ngữ
- Buổi 19: Ôn Tập Lại Các Hệ Cơ Quan Đã Học - Thi Giữa Kì
- Buổi 20: Thi Giữa Kì: Nói, Viết, Đọc

#### Chương 7: Hệ Tiết Niệu (Urinary)

- Buổi 21: Urinary System P1: Cấu trúc &amp; thuật ngữ hệ tiết niệu
- Buổi 22: Urinary System P2: Bệnh lý tiết niệu, ứng dụng thuật ngữ

#### Chương 8: Sinh dục – sức khỏe mẹ &amp; con (Reproductive / Maternal Health)

- Buổi 23: Reproductive System: Cấu trúc, thuật ngữ, Sinh Dục nam
- Buổi 24: Reproductive System: Cấu trúc, thuật ngữ, Sinh Dục nữ
- Buổi 25: Maternal Health: Sức khỏe bà mẹ, chăm sóc thai kỳ
- Buổi 26: Maternal Health P2: Bệnh lý sản khoa, ứng dụng thuật ngữ
- Buổi 27: Ôn Tập Tiết Niệu - Sinh Dục

#### Chương 9: Hệ thần kinh (Neurologic)

- Buổi 28: Neurologic System P1: Hệ thần kinh: cấu trúc, thuật ngữ
- Buổi 29: Neurologic System P2: Bệnh lý thần kinh
- Buổi 30: Neurologic System P3: Ứng dụng thuật ngữ thần kinh

#### Chương 10: Nội tiết (Endocrine)

- Buổi 31: Endocrine System P1: Cấu trúc, chức năng, thuật ngữ tuyến nội tiết
- Buổi 32: Endocrine System P2: Bệnh lý nội tiết
- Buổi 33: Ôn Tập: Thần Kinh - Nội Tiết

#### Chương 11: Máu &amp; bạch huyết (Blood &amp; Lymphatic)

- Buổi 34: Blood And Lymphatic System P1: Cấu trúc, thuật ngữ máu và hệ bạch huyết
- Buổi 35: Blood And Lymphatic System P2: Bệnh lý máu/bạch huyết, ứng dụng thuật ngữ

#### Chương 12: Răng – Hàm – Mặt

- Buổi 36: Răng Hàm Mặt P1: Cấu trúc &amp; thuật ngữ giải phẫu RHM
- Buổi 37: Răng Hàm Mặt P2: Một số bệnh lý &amp; ứng dụng thuật ngữ
- Buổi 38: Răng Hàm Mặt P3
- Buổi 39: Ôn tập Máu/bạch huyết + RHM
- Buổi 40: Kiểm Tra Cuối Kỳ

<a id="khoa-103"></a>

### 13. \[Xét Nghiệm\] Cơ Bản -&gt; Chuyên Sâu (ID 103)

**Trạng thái:** Đang bật · **Chương:** 3 · **Bài học:** 28

#### Chuyên Ngành Hoá Sinh Lâm Sàng

- Bài 1: Các Xét Nghiệm Thăm Dò Chức Năng Thận
- Bài 2: Rối Loạn Chuyển Hoá Cacbonhydrat Và Xét Nghiệm Liên Quan
- Bài 3: Xét Nghiệm Đánh Giá Chức Năng Gan
- Bài 4: Các Xét Nghiệm Trong Bệnh Lý Tim Mạch
- Bài 5: Chỉ Dấu Ung Thư
- Bài 10: Rối Loạn Chuyển Hoá Lipid Máu Và Xét Nghiệm Lipid, Máu
- Bài 11: Các Xét Nghiệm Đánh Giá Chức Năng Tuyến Giáp
- Bài 12: Nguyên Lý Đo Quang
- Bài 13: Các Phương Pháp Xét Nghiệm Miễn Dịch
- Bài 14: Các Yếu Tố Gây Nhiễu Giai Đoạn Tiền Phân Tích Ảnh Hưởng Sinh Hoá - Miễn Dịch
- Ôn Tập - Thực Hành Biện Luận Một Số Kết Quả Xét Nghiệm Hoá Sinh

#### Chuyên Ngành Huyết Học

- Bài 15: Sinh Lý Hồng Cầu Và Các Rối Loạn Dòng Hồng Cầu
- Bài 15: Sinh Lý Hồng Cầu Và Các Rối Loạn Dòng Hồng Cầu
- Bài 16: Sinh Lý Bạch Cầu Và Các Rối Loạn Dòng Bạch Cầu
- Bài 17: Kỹ Thuật Xét Nghiệm Huyết Học Tế Bào - Biện Luận Công Thức Máu
- Bài 18: Sinh Lý Đông Cầm Máu
- Bài 19: Kỹ Thuật Xét Nghiệm Khảo Sát Đông Cầm Máu
- Bài 20: Tổng Quan Các Bệnh Lý Liên Quan Đến Rối Loạn Đông máu
- Bài 21: Tổng Quan Hện Thống Nhóm Máu - Hệ Nhóm Máu ABO Và Hệ Nhóm Máu RHESUS
- Bài 22: Kỹ Thuật Định Nhóm Máu Hệ ABO Và RHESUS
- Bài 23: Kỹ Thuật Xét Nghiệm Coombs
- Bài 24: Phản Ứng Hoà Hợp Trong Truyền Máu
- Ôn Tập
- Kiểm Tra Cuối Kỳ

#### Hóa Sinh Lý Thuyết

- Bài 1: Hóa Sinh Glucid
- Bài 2: Hóa Sinh Protid
- Bài 3: Hóa Sinh Lipid
- Bài 4: Hóa Sinh enzym

<a id="khoa-104"></a>

### 14. LS Nội Khoa Cơ Bản (22 bài, 30 case LS) (ID 104)

**Trạng thái:** Đã tắt · **Chương:** 2 · **Bài học:** 27

#### Phần 1: Tiêu Hóa

- Buổi 1: Xuất huyết tiêu hóa
- Buổi 2: Viêm gan B
- Buổi 3: Viêm tuỵ cấp

#### Phần 2: Nội Tiết

- Buổi 4: Đái tháo đường và biến chứng cấp mạn
- Buổi 5: Cường giáp
- Buổi 6: Suy giáp
- Phần 3: Hô hấp
- Buổi 7 : Khí máu động mạch và hô hấp ký
- Buổi 8: COPD
- Buổi 9: Viêm phổi
- Buổi 10: Ôn Tập Giữa Kì
- Phần 4: Tim mạch
- Buổi 11: Tăng huyết áp
- Buổi 12: Bệnh lý van tim
- Buổi 13: Nhồi máu cơ tim cấp
- Buổi 14: Suy tim cấp - mạn
- Phần 5: Thận nội
- Buổi 15: Tổn Thương Thận Cấp
- Buổi 16: Bệnh Thận Mạn
- Buổi 17: Bệnh cầu thận
- Phần 6: Cơ xương khớp
- Buổi 18: Viêm khớp dạng thấp
- Buổi 19: Gout
- Phần 7: Hồi sức tích cực và Máu
- Buổi 20: Các rối loạn đông máu, và thuốc
- Buổi 21: Thiếu máu và tiếp cận thiếu máu
- Buổi 22: Ôn Tập Cuối Kì

<a id="khoa-105"></a>

### 15. LS Ngoại Khoa Cơ Bản (22 bài, 30 Case LS) (ID 105)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 22

**Bài chưa xếp chương:**

- Buổi 1: Viêm ruột thừa cấp
- Buổi 2: Thủng ổ loét dạ dày tá tràng
- Buổi 3: Ung thư dạ dày ( Chẩn Đoán - Phân Loại )
- Buổi 4: Ung Thư Dạ Dày ( Điều Trị )
- Buổi 5: Chấn thương bụng, Hội Chứng Chảy Máu Trong
- Buổi 6: Viêm Túi Mật Cấp ( Cơ Bản )
- Buổi 7: Sỏi Ống Mật Chủ
- Buổi 8: Ung thư đại tràng ( Chẩn Đoán - Điều Trị )
- Buổi 9: Trĩ ( Phẫu Thuật )
- Buổi 10: Ôn Tập Giữ Khóa
- Buổi 11: Khám Gãy Xương
- Buổi 12: Gãy xương hở
- Buổi 13: Gãy hai xương cẳng tay
- Buổi 14: Gãy Thân Xương Cánh Tay
- Buổi 15: Gãy thân xương đùi
- Buổi 16: Gãy Cổ Xương Đùi
- Buổi 17: Gãy hai xương cẳng chân
- Buổi 18: Bỏng + Điều trị khuyết hông phần mềm
- Buổi 19: Chấn Thương Bìu - Dương Vật
- Buổi 20: U Xơ tiền Lịệt Tuyến
- Buổi 21: Chấn Thương Ngực
- Buổi 22: Ôn Tập Cuối Khóa

<a id="khoa-106"></a>

### 16. \[Sản Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 106)

**Trạng thái:** Đang bật · **Chương:** 2 · **Bài học:** 22

#### Phần 1: Sản Khoa

- 1.2. Sự phát triển của phôi và thai – Tính chất thai nhi của phần phụ đủ tháng.
- 1.3. Chẩn đoán có thai.
- 1.4. Sinh lý chuyển dạ.
- 1.6. Hậu sản thường.
- 1.7. Chảy máu âm đạo 3 tháng đầu thai kỳ.
- 1.8. Thai lạc chỗ.
- 1.10. Thai chết trong tử cung.
- 1.11. Nhau tiền đạo.
- 1.13. Vỡ tử cung
- Ôn Tập Giữa Kì
- 1.15. Đái tháo đường thai kỳ.
- 1.16. Tăng huyết áp thai kỳ.
- 1.17. Đa ối – Thiểu ối
- 1.20. Chảy máu sau sinh

#### Phần 2: Phụ Khoa

- 2.1. Sinh lý phụ khoa.
- 2.2. Các biện pháp tránh thai.
- 2.3. Các phương pháp đình chỉ thai.
- 2.5. Bệnh lây truyền qua đường tình dục.
- 2.6. Vai trò của siêu âm trong sản khoa.
- 2.9. Bệnh lý cổ tử cung, lành tính và ác tính.
- 2.10. Khối u vú
- Ôn Tập Cuối Kì

<a id="khoa-107"></a>

### 17. \[Lâm Sàng Nhi Khoa\] Cơ Bản -&gt; Chuyên Sâu (ID 107)

**Trạng thái:** Đang bật · **Chương:** 11 · **Bài học:** 42

#### Phần 1: ĐẠI CƯƠNG

- Buổi 1. Đặc điểm các thời kỳ của trẻ em
- Buổi 2. Quá trình phát triển thể chất – vận động – tinh thần

#### Phần 2: SƠ SINH

- Buổi 3. Đặc điểm và cách chăm sóc trẻ sơ sinh đủ tháng và non tháng
- Buổi 4. Vàng da sơ sinh
- Buổi 5. Nhiễm trùng sơ sinh sớm
- Buổi 6. Hội chứng suy hô hấp ở trẻ sơ sinh

#### Phần 3: TIÊU HÓA – DINH DƯỠNG

- Buổi 7. Đau bụng cấp ở trẻ em
- Buổi 8. Tiêu chảy cấp ở trẻ em
- Buổi 9. Viêm loét dạ dày do HP
- Buổi 10. XHTH ở trẻ em
- Buổi 11. Vàng da ứ mật trẻ em

#### Phần 4: HÔ HẤP

- Buổi 12. Viêm tiểu phế quản cấp ở trẻ em
- Buổi 13. Viêm phổi
- Buổi 14. Hen phế quản

#### Phần 5: TRUYỀN NHIỄM

- Buổi 15. Sốt xuất huyết Dengue
- Buổi 16. Tay chân miệng
- Buổi 17. Bạch hầu – Sởi (đang hot)
- Buổi 18. Viêm màng não mủ
- Buổi 19. Viêm não nhật bản

#### Phần 6: TIM MẠCH

- Buổi 20. Đặc điểm hệ tuần hoàn trẻ em
- Buổi 21. Khái quát bệnh tim bẩm sinh ở trẻ em
- Buổi 22. Kawasaki

#### Phần 7: THẬN - NỘI TIẾT

- Buổi 23. Viêm cầu thận cấp
- Buổi 24. Hội chứng thận hư
- Buổi 25. Nhiễm trùng đường tiểu
- Buổi 26. Suy giáp bẩm sinh trẻ em
- Buổi 27. Cường giáp trẻ em

#### Phần 8: HUYẾT HỌC

- Buổi 28. Thiếu máu trẻ em
- Buổi 29. Thalassemia
- Buổi 30. Xuất huyết giảm tiểu cầu miễn dịch
- Buổi 31. Bệnh Hemophilia

#### Phần 9: THẦN KINH

- Buổi 32. Hội chứng co giật
- Buổi 33. Động kinh

#### Phần 10: CẤP CỨU

- Buổi 34. Dấu hiệu nhận biết trẻ bị bệnh nặng
- Buổi 35. Suy hô hấp cấp trẻ em
- Buổi 36. Sốc trẻ em, tiếp cận chẩn đoán và xử trí

#### Chương 11: Chữa Case Lâm Sàng

- Chữa Case Lâm Sàng P1
- Chữa Case Lâm Sàng P2
- Chữa Case Lâm Sàng P3
- Chữa Case Lâm Sàng P4
- Chữa Case Lâm Sàng P5
- Chữa Case Lâm Sàng P6

<a id="khoa-109"></a>

### 18. Khoá học Sinh Lý Kèm Riêng (ID 109)

**Trạng thái:** Đã tắt · **Chương:** 5 · **Bài học:** 38

#### PHẦN 1: ĐẠI CƯƠNG – MÀNG TẾ BÀO – MÁU – DỊCH THỂ (7 buổi)

- Sinh lý đại cương, hằng định nội môi
- Màng tế bào &amp; kênh ion
- Máu – thành phần, hồng cầu, bạch cầu – miễn dịch
- Tiểu cầu – đông – cầm máu
- Nhóm máu ABO, Rh – ý nghĩa lâm sàng
- Dịch thể cơ thể (dịch mô, dịch não tủy…)
- Ôn Tập

#### PHẦN 2: HỆ TUẦN HOÀN (6 buổi)

- Cấu trúc tim &amp; chu kỳ tim
- Điện tâm đồ – dẫn truyền – điều hòa nhịp
- Huyết áp – lưu lượng – điều hòa
- Vi tuần hoàn – dịch mô – hệ bạch huyết
- Điều hòa cảm nhận &amp; nội tiết tim mạch
- Ứng dụng lâm sàng + quiz &amp; case

#### PHẦN 3: HỆ HÔ HẤP (4 buổi)

- Cơ học hô hấp &amp; thông khí
- Thể tích phổi – trao đổi khí
- Thông khí phế nang &amp; vận chuyển khí
- Điều hòa hệ hô hấp + tình huống lâm sàng

#### PHẦN 4: HỆ TIÊU HÓA (4 buổi)

- Hoạt động tiêu hóa miệng – dạ dày
- Enzyme/ ruột non/ hấp thu
- Gan – dịch mật – chuyển hóa
- Điều hòa hoạt động tiêu hóa
- PHẦN 5: THẬN – NỘI MÔI – NỘI TIẾT (5 buổi)
- Cấu trúc nephron – lọc
- Tái hấp thu – bài tiết – hormon thận
- Điều hòa nước – điện giải – pH
- Nội tiết: yên, giáp, tụy
- Nội tiết: thượng thận – sinh dục

#### PHẦN 6: CƠ – THẦN KINH – CẢM GIÁC (6 buổi)

- Co cơ cơ vân – cơ tim – cơ trơn
- Khớp thần kinh – synapse – dẫn truyền
- Phản xạ tủy sống &amp; thần kinh thực vật
- Giác giác – thị giác – thính giác
- Vỏ não: vận động cao cấp, trí nhớ, giấc ngủ
- Ôn tập + case lâm sàng hệ cơ &amp; thần kinh
- Luyện Đề 1
- Luyện Đề 2
- Luyện Đề 3
- Luyện Đề 4
- Luyện Đề 5

<a id="khoa-112"></a>

### 19. \[Lý Thuyết + Lâm Sàng ECG\] Cơ Bản -&gt; Chuyên Sâu (ID 112)

**Trạng thái:** Đang bật · **Chương:** 6 · **Bài học:** 35

#### PHẦN 1 – NỀN TẢNG ECG VÀ NHỊP TIM

- Buổi 1: Giới Thiệu Về Ecg: Nguyên Lý Ghi, Điện Cực, Các Chuyển Đạo
- Buổi 2: Nhịp Xoang Bình Thường – Tiêu Chuẩn Ecg Bình Thường
- Buổi 3: Ngoại Tâm Thu Nhĩ (Pac) – Ngoại Tâm Thu Thất (Pvc)
- Buổi 4: Nhịp Nhanh Trên Thất (Svt)
- Buổi 5: Rung Nhĩ (Af)
- Buổi 6: Cuồng Nhĩ (Atrial Flutter)
- Buổi 7: Ôn Tập Nền Tảng ECG Và Nhịp Tim

#### PHẦN 2 – RỐI LOẠN NHỊP NGUY HIỂM: NHỊP THẤT - BLOCK - RL DẪN TRUYỀN

- Buổi 8: Nhịp Nhanh Thất (Vt)
- Buổi 9: Rung Thất (Vf)
- Buổi 10: Block Nhĩ Thất (Av Block I, Ii, Iii)
- Buổi 11: Block Nhánh Phải (Rbbb)
- Buổi 12: Block Nhánh Trái (Lbbb)
- Buổi 13: Hội Chứng Tiền Kích Thích (Wpw)
- Buổi 14: Ôn Tập Rối Loạn Nhịp Nguy Hiểm

#### PHẦN 3 – THIẾU MÁU CƠ TIM – NHỒI MÁU CƠ TIM – BỆNH TIM MẠCH CẤP

- Buổi 15: Thiếu Máu Cơ Tim Cục Bộ – Biến Đổi St Và Sóng T
- Buổi 16: Nhồi Máu Cơ Tim Cấp Có St Chênh Lên (Stemi)
- Buổi 17: Nhồi Máu Cơ Tim Cấp Không St Chênh (Nstemi, Ua)
- Buổi 18: Nhồi Máu Cơ Tim Thành Đặc Biệt
- Buổi 19: Viêm Màng Ngoài Tim, Viêm Cơ Tim
- Buổi 20: Ôn Tập Thiếu Máu Cơ Tim - Nhồi Máu Cơ Tim

#### PHẦN 4 – BỆNH LÝ MẠN – ĐIỆN GIẢI – VAN TIM – TIM BẨM SINH

- Buổi 21: Dày Thất Trái (Lvh) Và Dày Thất Phải (Rvh)
- Buổi 22: Rối Loạn Điện Giải (K+, Ca++, Digoxin)
- Buổi 23: Bệnh Tim Phổi Mạn Và Suy Tim
- Buổi 24: Bệnh Tim Bẩm Sinh &amp; Bệnh Van Tim Cơ Bản
- Buổi 25: Thực Hành Tổng Hợp Bệnh Lý Tim Mạch Cơ Bản
- Buổi 26: Ôn Tập Bệnh Lý Mạn - Điện Giải - Van Tim - Tim Bẩm Sinh

#### PHẦN 5 – CẤP CỨU TIM MẠCH – ECG TRONG HỒI SỨC

- Buổi 27: Ngừng Tuần Hoàn – Các Thể Ecg Trong Ngừng Tim
- Buổi 28: Rung Thất (Vf) &amp; Nhịp Nhanh Thất Vô Mạch
- Buổi 29: Nhịp Nhanh Thất Có Mạch
- Buổi 30: Nhịp Chậm Nguy Hiểm – Block Nhĩ Thất Hoàn Toàn
- Buổi 31: Hội Chứng Brugada &amp; Qt Dài
- Buổi 32: Thuyên Tắc Phổi Cấp &amp; Tăng Áp Phổi Cấp
- Buổi 33: Chèn Ép Tim Cấp (Cardiac Tamponade)
- Buổi 34: Tổng Hợp Cấp Cứu Tim Mạch – Case Lâm Sàng Tích Hợp
- Buổi 35: Ôn Tập Cấp Cứu Tim Mạch - ECG Trong Hồi Sức

#### Buổi 36: Ôn Kết Thúc Khoá Học


<a id="khoa-155"></a>

### 20. \[Sinh Lý SĐH - Y Hà Nội\] Cơ Bản -&gt; Chuyên Sâu (ID 155)

**Trạng thái:** Đã tắt · **Chương:** 10 · **Bài học:** 40

#### Chương I: SL Đại Cương Chuyển Hóa - Điều Nhiệt

- Bài 1: Đại Cương Cơ Thể Sống
- Bài 2: Chuyển Hóa Năng Lượng
- Bài 3: Sinh Lý Điều Nhiệt
- Bài 4: Chữa Chuyên Sâu Bộ Đề 1
- Bài 5: Chữa Chuyên Sâu Bộ Đề 2

#### Chương II: Sinh Lý Tế Bào

- Bài 6: Sinh Lý Trao Đổi Chất Qua Màn
- Bài 7: Điện Thế Màn
- Bài 8: Chữa Chuyên Sâu Bộ Đề 3
- Bài 9: Chữa Chuyên Sâu Bộ Đề 4

#### Chương III: Sinh Lý Máu Và Dịch Cơ Thể

- Bài 10: Sinh Lý Máu - Dịch Cơ Thể
- Bài 11: Chữa Chuyên Sâu Bộ Đề 5
- Bài 12: Chữa Chuyên Sâu Bộ Đề 6

#### Chương IV: Sinh Lý Tuần Hoàn

- Bài 13: Sinh Lý Tim
- Buổi 14: Sinh Lý Mạch Máu
- Bài 15: Chữa Chuyên Sâu Bộ Đề 7

#### Chương V: Sinh Lý Hô Hấp

- Bài 16: Sinh Lý Hô Hấp P1
- Bài 17: Sinh Lý Hô Hấp P2
- Bài 18: Chữa Chuyên Sâu Bộ Đề 8
- Bài 19: Chữa Chuyên Sâu Bộ Đề 9

#### Chương VI: Sinh Lý Thận - Tiết Niệu

- Bài 20: Sinh Lý Thận - Tiết Niệu
- Bài 21: Chữa Chuyên Sâu Bộ Đề 10

#### Chương VII: Sinh Lý Nội Tiết

- Bài 22: Sinh Lý Nội Tiết
- Bài 23: Ứng Dụng Lâm Sàng
- Bài 24: Chữa Chuyên Sâu Bộ Đề 11
- Bài 25: Chữa Chuyên Sâu Bộ Đề 12
- Bài 26: Chữa Chuyên Sâu Bộ Đề 13

#### Chương VIII: Sinh Lý Sinh Sản

- Bài 27: Sinh Lý Sinh Sản Nam
- Bài 28: Sinh Lý Sinh Sản Nữ
- Bài 29: Chữa Chuyên Sâu Bộ Đề 14

#### Chương IX: Sinh Lý Tiêu Hóa

- Bài 30: Đường Tiêu Hóa Trên
- Bài 31: Đường Tiêu Hóa Dưới
- Bài 32: Chữa Chuyên Sâu Bộ Đề 15
- Bài 33: Chữa Chuyên Sâu Bộ Đề 16

#### Chương X: Sinh Lý Thần Kinh - Cơ

- Bài 34: Thần Kinh Cơ P1
- Bài 35: Thần Kinh Cơ P2
- Bài 36: Sinh Lý Cảm Giác Tự Chủ
- Bài 37: Sinh Lý Thần Kinh Vận Động
- Bài 38: Sinh Lý Thần Kinh Cấp Cao
- Bài 39: Chữa Chuyên Sâu Bộ Đề 17
- Bài 40: Chữa Chuyên Sâu Bộ Đề 18

<a id="khoa-156"></a>

### 21. \[Ngoại Khoa SĐH - Y Hà Nội\] Cơ Bản -&gt; Chuyên Sâu (ID 156)

**Trạng thái:** Đã tắt · **Chương:** 6 · **Bài học:** 44

#### Chương I: Tiêu Hóa

- Bài 1: Tắc Ruột
- Bài 2: Tắc Ruột Ở Trẻ Em
- Bài 3: MEGACOLON: Giãn Đại Tràng Bẩm Sinh
- Bài 4: Ung Thư Dạ Dày
- Bài 5: Ung Thư Thực Quản
- Bài 6: Sỏi Mật
- Bài 7: Ung Thư Đại Trực Tràng
- Bài 8: Trĩ
- Bài 9: Chấn Thương Bụng
- Bài 10: Vết Thương Bụng
- Bài 11: Viêm Ruột Thừa Cấp
- Bài 12: Chữa Chuyên Sâu Bộ Đề 1
- Bài 13: Chữa Chuyên Sâu Bộ Đề 2
- Bài 14: Chữa Chuyên Sâu Bộ Đề 3
- Bài 15: Chữa Chuyên Sâu Bộ Đề 4
- Bài 16: Chữa Chuyên Sâu Bộ Đề 5
- Bài 17: Chữa Chuyên Sâu Bộ Đề 6
- Bài 18: Chữa Chuyên Sâu Bộ Đề 7
- Bài 19: Chữa Chuyên Sâu Bộ Đề 8

#### Chương II: Tiết Niệu

- Bài 20: Thoát Vị Bẹn Đùi
- Bài 21: Bệnh Lý Còn Ống Phúc Tinh Mạc Ở Trẻ Em
- Bài 22: Chấn Thương Thận
- Bài 23: Sỏi Tiết Niệu
- Bài 24: Chữa Chuyên Sâu Bộ Đề 9
- Bài 25: Chữa Chuyên Sâu Bộ Đề 10

#### Chương III: Thần Kinh

- Bài 26: U Não
- Bài 27: Chữa Chuyên Sâu Bộ Đề 11

#### Chương IV: Lồng Ngực - Mạch Máu

- Bài 28: Chấn Thương - Vết Thương Ngực
- Bài 29: Chấn Thương Vết Thương Động Mạch
- Bài 30: Chữa Chuyên Sâu Bộ Đề 12
- Bài 31: Chữa Chuyên Sâu Bộ Đề 13

#### Chương V: Chấn Thương Chi Trên

- Bài 32: Vết Thương Bàn Tay
- Bài 33: Nhiễm Khuẩn Tay
- Bài 34: Trật Khớp
- Bài 35: Gãy Xương
- Bài 36: Chữa Chuyên Sâu Bộ Đề 14
- Bài 37: Chữa Chuyên Sâu Bộ Đề 15

#### Chương VI : Chấn Thương Chi Dưới

- Bài 38: Bỏng
- Bài 39: Chèn Ép Khoang - Gãy Xương Hở
- Bài 40: Hoại Thư Sinh Hơi - Gãy Xương Chậu
- Bài 41: Chữa Chuyên Sâu Bộ Đề 16
- Bài 42: Chữa Chuyên Sâu Bộ Đề 17
- Bài 43: Chữa Chuyên Sâu Bộ Đề 18
- Bài 44: Chữa Chuyên Sâu Bộ Đề 19

<a id="khoa-157"></a>

### 22. \[Nội Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 157)

**Trạng thái:** Đang bật · **Chương:** 9 · **Bài học:** 64

#### Chương I: Hô Hấp

- Bài 1: Viêm Phổi
- Bài 2: Áp xe Phổi
- Bài 3: Ung Thư Phổi
- Bài 4: COPD
- Bài 5: Giãn Phế Quản - Hen Phế Quản
- Bài 6: Tràn Dịch, Tràn Khí Màng Phổi
- Bài 7: Tâm Phế Mạn
- Bài 8: Chữa Chuyên Sâu Bộ Đề 1
- Bài 9: Chữa Chuyên Sâu Bộ Đề 2

#### Chương II: Tim Mạch

- Bài 10: Tăng Huyết Áp
- Bài 11: Suy Tim
- Bài 12: Hẹp Van Hai Lá
- Bài 13: Hội Chứng Vành Cấp
- Bài 14: Viêm Màng Ngoài Tim
- Bài 15: Viêm Nội Tâm Mạc
- Bài 16: Rối Loạn Nhịp Tim
- Bài 17: Chữa Chuyên Sâu Bộ Đề 3
- Bài 18: Chữa Chuyên Sâu Bộ Đề 4
- Bài 19: Chữa Chuyên Sâu Bộ Đề 5

#### Chương III: Tiết Niệu

- Bài 20: Nhiễm Khuẩn Tiết Niệu
- Bài 21: Phì Đại Tiền Liệt Tuyến
- Bài 22: Viêm Cầu Cấp Thận
- Bài 23: Hội Chứng Thận Hư
- Bài 24: Tổn Thương Thận Cấp
- Bài 25: Bệnh Thận Mạn
- Bài 26: Chữa Chuyên Sâu Bộ Đề 6
- Bài 27: Chữa Chuyên Sâu Bộ Đề 7
- Bài 28: Chữa Chuyên Sâu Bộ Đề 8

#### Chương IV: Tiêu Hóa

- Bài 29: Viêm Gan
- Bài 30: Xơ Gan
- Bài 31: Ung Thư Gan
- Bài 32: Viêm Loét Dạ Dày Tá Tràng
- Bài 33: Viêm Tụy
- Bài 34: Xuất Huyết Tiêu Hóa
- Bài 35: Viêm Đại Tràng
- Bài 36: Chữa Chuyên Sâu Bộ Đề 9
- Bài 37: Chữa Chuyên Sâu Bộ Đề 10
- Bài 38: Chữa Chuyên Sâu Bộ Đề 11

#### Chương V: Nội Tiết

- Bài 39: Đái Tháo Đường
- Bài 40: Basedow
- Bài 41: Hội Chứng Cushing - Addison - Rối Loạn Mỡ Máu.
- Bài 42: Lubus Ban Đỏ Hệ Thống
- Bài 43: Chữa Chuyên Sâu Bộ Đề 12

#### Chương VI: Cơ Xương Khớp

- Bài 44: Viêm Khớp Dạng Thấp
- Bài 46: Gout
- Bài 47: Loãng Xương
- Bài 48: Thoái Hóa Khớp
- Bài 49: Đau Cột Sống Thắt Lưng
- Bài 50: Chữa Chuyên Sâu Bộ Đề 13
- Bài 51: Chữa Chuyên Sâu Bộ Đề 14

#### Chương VII: Huyết Học

- Bài 52: Hội Chứng Thiếu Máu
- Bài 53: Hội Chứng Xuất Huyết
- Bài 54: An Toàn Truyền Máu
- Bài 55: Ung Thư Huyết Học p1
- Bài 56: Ung Thư Huyết Học p2
- Bài 57: Chữa Chuyên Sâu Bộ Đề 15
- Bài 58: Chữa Chuyên Sâu Bộ Đề 16

#### Chương VIII: Hồi Sức

- Bài 59: Shock
- Bài 60: Rối Loạn Kiềm Toan
- Bài 61: Chữa Chuyên Sâu Bộ Đề 17
- Bài 62: Chữa Chuyên Sâu Bộ Đề 18

#### Chương IX: Thần Kinh

- Bài 63: Đau Đầu
- Bài 64: Lão Khoa
- Bài 65: Chữa Chuyên Sâu Bộ Đề 19

<a id="khoa-158"></a>

### 23. \[Nhi Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 158)

**Trạng thái:** Đang bật · **Chương:** 7 · **Bài học:** 55

#### Chương I: Đại Cương - Các Bệnh Học Sơ Sinh

- Bài 1: Bệnh Vàng Da
- Bài 2: Nhiễm Khuẩn Sơ Sinh
- Bài 3: Suy Hô Hấp Sơ Sinh
- Bài 4: Thời Kì Tăng Trưởng - Phát Triển Thể Chất
- Bài 5: Phát Triển Tâm Thần Vận Động
- Bài 6: Chữa Chuyên Sâu Bộ Đề 1
- Bài 7: Chữa Chuyên Sâu Bộ Đề 2
- Bài 8: Chữa Chuyên Sâu Bộ Đề 3

#### Chương II: Hồi Sức - Huyết Học

- Bài 9: Tiếp Cận Trẻ Em Bệnh Nặng
- Bài 10: Ngộ Độc Cấp
- Bài 11: Huyết Học Trẻ Em
- Bài 12: Thiếu Máu - Thiếu Sắt
- Bài 13: Hội Chứng Xuất Huyết
- Bài 14: Bạch Cầu Cấp Trẻ Em
- Bài 15: Chữa Chuyên Sâu Bộ Đề 4
- Bài 16: Chữa Chuyên Sâu Bộ Đề 5
- Bài 17: Chữa Chuyên Sâu Bộ Đề 6

#### Chương III: Hô Hấp

- Bài 18: Giải Phẫu - Sinh Lý Hô Hấp
- Bài 19: Nhiễm Khuẩn - Hô Hấp Cấp Tính Ở Trẻ Em
- Bài 20: Viêm Phế Quản Phổi
- Bài 21: Viêm Tiểu Phế Quản Phổi
- Bài 22: Hen Phế Quản Trẻ Em
- Bài 23: Chữa Chuyên Sâu Bộ Đề 7
- Bài 24: Chữa Chuyên Sâu Bộ Đề 8
- Bài 25: Chữa Chuyên Sâu Bộ Đề 9

#### Chương IV: Thận - Tiết Niệu

- Bài 26: Nhiễm Khuẩn Tiết Niệu
- Bài 27: Viêm Cầu Thận Cấp Sau Nhiễm Liên Cầu
- Bài 28: Hội Chứng Thận Hư
- Bài 29: Chữa Chuyên Sâu Bộ Đề 10
- Bài 30: Chữa Chuyên Sâu Bộ Đề 11

#### Chương V: Tuần Hoàn - Tim Mạch

- Bài 31: Đặc Điểm Hệ Tuần Hoàn Trẻ Em p1
- Bài 32: Đặc Điểm Hệ Tuần Hoàn Trẻ Em p2
- Bài 33: Suy Tim
- Bài 34: Thấp Tim
- Bài 35: Chữa Chuyên Sâu Bộ Đề 12
- Bài 36: Chữa Chuyên Sâu Bộ Đề 13
- Bài 37: Chữa Chuyên Sâu Bộ Đề 14

#### Chương VI: Nội Tiết - Thần Kinh - Truyền Nhiễm

- Bài 38: Suy Giáp Bẩm Sinh Trẻ Em
- Bài 39: Tăng Sản Thượng Thận Bẩm Sinh
- Bài 40: Viêm Màng Não Trẻ Em
- Bài 41: Viêm Não
- Bài 42: Chữa Chuyên Sâu Bộ Đề 15
- Bài 43: Chữa Chuyên Sâu Bộ Đề 16
- Bài 44: Chữa Chuyên Sâu Bộ Đề 17
- Bài 45: Chữa Chuyên Sâu Bộ Đề 18

#### Chương VII: Tiêu Hóa - Dinh Dưỡng

- Bài 46: Đặc Điểm Hệ Tiêu Hóa Trẻ Em
- Bài 47: Thiếu Vitamin D
- Bài 48: Thiếu Vitamin A
- Bài 49: Đau Bụng Trẻ Em
- Bài 50: Hội Chứng Nôn Trớ Táo Bón
- Bài 51: Tiêu Chảy Cấp
- Bài 52: Tiêu Chảy Kéo Dài
- Bài 53: Chữa Chuyên Sâu Bộ Đề 19
- Bài 54: Chữa Chuyên Sâu Bộ Đề 20
- Bài 55: Chữa Chuyên Sâu Bộ Đề 21

<a id="khoa-160"></a>

### 24. \[Hóa Sinh SĐH - Y Hà Nội\] Cơ Bản -&gt; Chuyên Sâu (ID 160)

**Trạng thái:** Đã tắt · **Chương:** 2 · **Bài học:** 45

#### Chương I: Cấu Tạo Và Chuyển Hóa Chất

- Bài 1: Chuyển Hóa Acid amin
- Bài 2: Chữa Chuyên Sâu Bộ Đề 1
- Bài 3: Thoái Hóa Acid Nucleic
- Bài 4: Tổng Hợp Acid Nucleic
- Bài 5: Chữa Chuyên Sâu Bộ Đề 2
- Bài 6: Chuyển Hóa Glucid p1
- Bài 7: Chuyển Hóa Glucid p2
- Bài 8: Chữa Chuyên Sâu Bộ Đề 3
- Bài 9: Thoái Hóa Lipid
- Bài 10: Sinh Tổng Hợp Lipid
- Bài 11: Chữa Chuyên Sâu Bộ Đề 4
- Bài 12: Enzyme p1
- Bài 13: Enzyme p2
- Bài 14: Enzyme p3
- Bài 15: Chữa Chuyên Sâu Bộ Đề 5
- Bài 16: Hóa Học Acid Amin
- Bài 17: Chữa Chuyên Sâu Bộ Đề 6
- Bài 18: Hóa Học Glucid
- Bài 19: Chữa Chuyên Sâu Bộ Đề 7
- Bài 20: Hóa Học Acid Nucleic p1
- Bài 21: Hóa Học Acid Nucleic p2
- Bài 22: Chữa Chuyên Sâu Bộ Đề 8
- Bài 23: Hóa Học Lipid
- Bài 24: Chữa Chuyên Sâu Bộ Đề 9

#### Chương II: Hóa Sinh Tế Bào, Mô, Cơ Quan

- Bài 25: Hóa Sinh Thần Kinh
- Bài 26: Hóa Sinh Cơ
- Bài 27: Hóa Sinh Dịch Cơ Thể
- Bài 28: Hóa Sinh Gan
- Bài 29: Chữa Chuyên Sâu Bộ Đề 10
- Bài 30: Hóa Sinh Hormon p1
- Bài 31: Hóa Sinh Hormon p2
- Bài 32: Chữa Chuyên Sâu Bộ Đề 11
- Bài 33: Hóa Sinh Máu
- Bài 34: Hóa Sinh Khí Máu Động Mạch
- Bài 35: Chữa Chuyên Sâu Bộ Đề 12
- Bài 36: Hóa Sinh Thận Và Nước Tiểu
- Bài 37: Hóa Sinh Thận - Muối Nước
- Bài 38: Chữa Chuyên Sâu Bộ Đề 13
- Bài 39: Hóa Sinh Năng Lượng
- Bài 40: Chữa Chuyên Sâu Bộ Đề 14
- Bài 41: Sinh Tổng Hợp Protein
- Bài 42: Chuyển Hóa Hemoglobin
- Bài 43: Chữa Chuyên Sâu Bộ Đề 15
- Bài 44: Ôn Tập Và Chữa Test B1
- Bài 45: Ôn Tập Và Chữa Test B2

<a id="khoa-161"></a>

### 25. Sinh Học \[ Cơ Bản -&gt; Chuyên Sâu\] (ID 161)

**Trạng thái:** Đang bật · **Chương:** 4 · **Bài học:** 12

#### Chương I: Sinh Học Di Truyền

- Bài 1: Đại Cương Di Truyền
- Bài 2: Axit Nucleic
- Bài 3: Di Truyền - Dịch Mã
- Bài 4: Điều Hòa Gen
- Bài 5: Di Truyền Đột Biến
- Bài 6: Chữa Chuyên Sâu Bộ Đề 1

#### Chương II: Sinh Học Phát Triển

- Bài 7: Sinh Học Phát Triển phần 1
- Bài 8: Sinh Học Phát Triển Phần 2

#### Chương III: Sinh Học Tế Bào

- Bài 9: Màng Tế Bào và Các Bào Quan
- Bài 10: Nhân Tế Bào
- Bài 11: Chữa Chuyên Sâu Bộ Đề 2

#### Chương IV: Sinh Thái - Tiến Hóa

- Bài 12: Sinh Thái - Tiến Hóa

<a id="khoa-162"></a>

### 26. Nội Khoa SĐH - Y Hà Nội (Cơ Bản 30 bài) (ID 162)

**Trạng thái:** Đã tắt · **Chương:** 9 · **Bài học:** 30

#### Chương I: Hô Hấp

- Bài 1: Viêm Phổi
- Bài 2: COPD
- Bài 3: Giãn Phế Quản - Hen Phế Quản
- Bài 4: Tràn Dịch, Tràn Khí Màng Phổi
- Bài 5: Chữa Chuyên Sâu Bộ Đề 1
- Bài 6: Chữa Chuyên Sâu Bộ Đề 2

#### Chương II: Tim Mạch

- Bài 7: Tăng Huyết Áp
- Bài 8: Suy Tim
- Bài 9: Hội Chứng Vành Cấp
- Bài 10: Rối Loạn Nhịp Tim
- Bài 11: Chữa Chuyên Sâu Bộ Đề 3

#### Chương III: Tiết Niệu

- Bài 12: Tổn Thương Thận Cấp
- Bài 13: Bệnh Thận Mạn
- Bài 14: Chữa Chuyên Sâu Bộ Đề 6

#### Chương IV: Tiêu Hóa

- Bài 15: Xơ Gan
- Bài 16: Viêm Tụy
- Bài 17: Xuất Huyết Tiêu Hóa
- Bài 18: Chữa Chuyên Sâu Bộ Đề 7

#### Chương V: Nội Tiết

- Bài 19: Đái Tháo Đường
- Bài 20: Basedow
- Bài 21: Chữa Chuyên Sâu Bộ Đề 8

#### Chương VI: Cơ Xương Khớp

- Bài 22: Viêm Khớp Dạng Thấp
- Bài 23: Gout
- Bài 24: Chữa Chuyên Sâu Bộ Đề 9

#### Chương VII: Huyết Học

- Bài 25: Hội Chứng Thiếu Máu
- Bài 26: Chữa Chuyên Sâu Bộ Đề 10

#### Chương VIII: Hồi Sức

- Bài 27: Shock
- Bài 28: Chữa Chuyên Sâu Bộ Đề 11

#### Chương IX: Thần Kinh

- Bài 29: Đau Đầu
- Bài 30: Chữa Chuyên Sâu Bộ Đề 12

<a id="khoa-163"></a>

### 27. Sinh Lý SĐH - Y Hà Nội (Cơ Bản: 25 Bài) (ID 163)

**Trạng thái:** Đã tắt · **Chương:** 10 · **Bài học:** 25

#### Chương I: SL Đại Cương Chuyển Hóa - Điều Nhiệt

- Bài 1: Đại Cương Cơ Thể Sống
- Bài 2: Chuyển Hóa Năng Lượng
- Bài 3: Chữa Chuyên Sâu Bộ Đề 1

#### Chương II: Sinh Lý Tế Bào

- Bài 4: Sinh Lý Trao Đổi Chất Qua Màng
- Bài 5: Chữa Chuyên Sâu Bộ Đề 2

#### Chương III: Sinh Lý Máu Và Dịch Cơ Thể

- Bài 6: Sinh Lý Máu - Dịch Cơ Thể
- Bài 7: Chữa Chuyên Sâu Bộ Đề 3

#### Chương IV: Sinh Lý Tuần Hoàn

- Bài 8: Sinh Lý Tim
- Bài 9: Chữa Chuyên Sâu Bộ Đề 4

#### Chương V: Sinh Lý Hô Hấp

- Bài 10: Sinh Lý Hô Hấp P1
- Bài 11: Sinh Lý Hô Hấp P2
- Bài 12: Chữa Chuyên Sâu Bộ Đề 5

#### Chương VI: Sinh Lý Thận - Tiết Niệu

- Bài 13: Sinh Lý Thận - Tiết Niệu
- Bài 14: Chữa Chuyên Sâu Bộ Đề 6

#### Chương VII: Sinh Lý Nội Tiết

- Bài 15: Sinh Lý Nội Tiết
- Bài 16: Chữa Chuyên Sâu Bộ Đề 7

#### Chương VIII: Sinh Lý Sinh Sản

- Bài 17: Sinh Lý Sinh Sản Nam
- Bài 18: Sinh Lý Sinh Sản Nữ
- Bài 19: Chữa Chuyên Sâu Bộ Đề 8

#### Chương IX: Sinh Lý Tiêu Hóa

- Bài 20: Đường Tiêu Hóa Trên
- Bài 21: Đường Tiêu Hóa Dưới
- Bài 22: Chữa Chuyên Sâu Bộ Đề 9

#### Chương X: Sinh Lý Thần Kinh - Cơ

- Bài 23: Thần Kinh Cơ P1
- Bài 24: Thần Kinh Cơ P2
- Bài 25: Chữa Chuyên Sâu Bộ Đề 10

<a id="khoa-164"></a>

### 28. Hóa Sinh SĐH - Y Hà Nội (Cơ Bản: 30 Bài) (ID 164)

**Trạng thái:** Đã tắt · **Chương:** 2 · **Bài học:** 30

#### Chương I: Cấu Tạo Và Chuyển Hóa Chất

- Bài 1: Chuyển Hóa Acid amin
- Bài 2: Chữa Chuyên Sâu Bộ Đề 1
- Bài 3: Chuyển Hóa Glucid p1
- Bài 4: Chuyển Hóa Glucid p2
- Bài 5: Chữa Chuyên Sâu Bộ Đề 2
- Bài 6: Thoái Hóa Lipid
- Bài 7: Sinh Tổng Hợp Lipid
- Bài 8: Chữa Chuyên Sâu Bộ Đề 3
- Bài 9: Enzyme p1
- Bài 10: Enzyme p2
- Bài 11: Enzyme p3
- Bài 12: Chữa Chuyên Sâu Bộ Đề 4
- Bài 13: Hóa Học Acid Amin
- Bài 14: Chữa Chuyên Sâu Bộ Đề 5
- Bài 15: Hóa Học Glucid
- Bài 16: Chữa Chuyên Sâu Bộ Đề 6
- Bài 17: Hóa Học Lipid
- Bài 18: Chữa Chuyên Sâu Bộ Đề 7

#### Chương II: Hóa Sinh Tế Bào, Mô, Cơ Quan

- Bài 19: Hóa Sinh Thần Kinh
- Bài 20: Hóa Sinh Cơ
- Bài 21: Hóa Sinh Dịch Cơ Thể
- Bài 22: Hóa Sinh Gan
- Bài 23: Hóa Sinh Hormon p1
- Bài 24: Chữa Chuyên Sâu Bộ Đề 8
- Bài 25: Hóa Sinh Máu
- Bài 26: Chữa Chuyên Sâu Bộ Đề 9
- Bài 27: Hóa Sinh Thận - Muối Nước
- Bài 28: Chữa Chuyên Sâu Bộ Đề 10
- Bài 29: Hóa Sinh Năng Lượng
- Bài 30: Chữa Chuyên Sâu Bộ Đề 11

<a id="khoa-165"></a>

### 29. Ngoại Khoa SĐH - Y Hà Nội (Cơ Bản 25 Bài) (ID 165)

**Trạng thái:** Đã tắt · **Chương:** 6 · **Bài học:** 25

#### Chương I: Tiêu Hóa

- Bài 1: Tắc Ruột
- Bài 2: Tắc Ruột Ở Trẻ Em
- Bài 3: MEGACOLON: Giãn Đại Tràng Bẩm Sinh
- Bài 4: Ung Thư Dạ Dày
- Bài 5: Ung Thư Thực Quản
- Bài 6: Sỏi Mật
- Bài 7: Chữa Chuyên Sâu Bộ Đề 1
- Bài 8: Chữa Chuyên Sâu Bộ Đề 2
- Bài 9: Chữa Chuyên Sâu Bộ Đề 3
- Bài 10: Chữa Chuyên Sâu Bộ Đề 4

#### Chương II: Tiết Niệu

- Bài 11: Thoát Vị Bẹn Đùi
- Bài 12: Bệnh Lý Còn Ống Phúc Tinh Mạc Ở Trẻ Em
- Bài 13: Chữa Chuyên Sâu Bộ Đề 5

#### Chương III: Thần Kinh

- Bài 14: U Não
- Bài 15: Chữa Chuyên Sâu Bộ Đề 6

#### Chương IV: Lồng Ngực - Mạch Máu

- Bài 16: Chấn Thương - Vết Thương Ngực
- Bài 17: Chấn Thương - Vết Thương Động Mạch
- Bài 18: Chữa Chuyên Sâu Bộ Đề 7

#### Chương V: Chấn Thương Chi Trên

- Bài 19: Vết Thương Bàn Tay
- Bài 20: Nhiễm Khuẩn Tay
- Bài 21: Chữa Chuyên Sâu Bộ Đề 8

#### Chương VI : Chấn Thương Chi Dưới

- Bài 22: Bỏng
- Bài 23: Chèn Ép Khoang - Gãy Xương Hở
- Bài 24: Chữa Chuyên Sâu Bộ Đề 9
- Bài 25: Chữa Chuyên Sâu Bộ Đề 10

<a id="khoa-166"></a>

### 30. Nhi Khoa SĐH - Y Hà Nội (Cơ Bản 30 Bài) (ID 166)

**Trạng thái:** Đã tắt · **Chương:** 7 · **Bài học:** 30

#### Chương I: Đại Cương - Các Bệnh Học Sơ Sinh

- Bài 1: Thời Kì Tăng Trưởng - Phát Triển Thể Chất
- Bài 2: Phát Triển Tâm Thần Vận Động
- Bài 3: Chữa Chuyên Sâu Bộ Đề 1

#### Chương II: Hồi Sức - Huyết Học

- Bài 4: Thiếu Máu - Thiếu Sắt
- Bài 5: Hội Chứng Xuất Huyết
- Bài 6: Bạch Cầu Cấp Trẻ Em
- Bài 7: Chữa Chuyên Sâu Bộ Đề 2
- Bài 8: Chữa Chuyên Sâu Bộ Đề 3

#### Chương III: Hô Hấp

- Bài 9: Nhiễm Khuẩn - Hô Hấp Cấp Tính Ở Trẻ Em
- Bài 10: Viêm Phế Quản Phổi
- Bài 11: Viêm Tiểu Phế Quản Phổi
- Bài 12: Hen Phế Quản Trẻ Em
- Bài 13: Chữa Chuyên Sâu Bộ Đề 4
- Bài 14: Chữa Chuyên Sâu Bộ Đề 5

#### Chương IV: Thận - Tiết Niệu

- Bài 15: Nhiễm Khuẩn Tiết Niệu
- Bài 16: Viêm Cầu Thận Cấp Sau Nhiễm Liên Cầu
- Bài 17: Hội Chứng Thận Hư
- Bài 18: Chữa Chuyên Sâu Bộ Đề 6

#### Chương V: Tuần Hoàn - Tim Mạch

- Bài 19: Đặc Điểm Hệ Tuần Hoàn Trẻ Em p1
- Bài 20: Đặc Điểm Hệ Tuần Hoàn Trẻ Em p2
- Bài 21: Suy Tim
- Bài 22: Chữa Chuyên Sâu Bộ Đề 7

#### Chương VI: Nội Tiết - Thần Kinh - Truyền Nhiễm

- Bài 23: Viêm Màng Não Trẻ Em
- Bài 24: Chữa Chuyên Sâu Bộ Đề 8
- Bài 25: Chữa Chuyên Sâu Bộ Đề 9

#### Chương VII: Tiêu Hóa - Dinh Dưỡng

- Bài 26: Thiếu Vitamin D
- Bài 27: Thiếu Vitamin A
- Bài 28: Tiêu Chảy Cấp
- Bài 29: Tiêu Chảy Kéo Dài
- Bài 30: Chữa Chuyên Sâu Bộ Đề 10

<a id="khoa-167"></a>

### 31. Nội Khoa SĐH - Y Huế (Cơ Bản 22 Bài) (ID 167)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-168"></a>

### 32. Sinh Lý SĐH - Y Huế (Cơ Bản: 30 buổi) (ID 168)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-169"></a>

### 33. Sinh Lý SĐH - Y Huế (Cơ Bản -&gt; Chuyên Sâu) (ID 169)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-170"></a>

### 34. ECG Cơ Bản - 16 bài (ID 170)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-171"></a>

### 35. Nội Cơ Bản SĐH - Y HCM: 30 bài, 10 Bộ Đề (ID 171)

**Trạng thái:** Đã tắt · **Chương:** 10 · **Bài học:** 29

**Bài chưa xếp chương:**

- Chương I: Hô Hấp
- Bài 1: Viêm Phổi
- Bài 2: COPD
- Bài 3: Giãn Phế Quản - Hen Phế Quản
- Bài 4: Tràn Dịch, Tràn Khí Màng Phổi

#### Bài 5: Chữa Chuyên Sâu Bộ Đề 1

#### Bài 6: Chữa Chuyên Sâu Bộ Đề 2

- Chương II: Tim Mạch
- Bài 7: Tăng Huyết Áp
- Bài 8: Suy Tim
- Bài 9: Hội Chứng Vành Cấp
- Bài 10: Rối Loạn Nhịp Tim

#### Bài 11: Chữa Chuyên Sâu Bộ Đề 3

- Chương III: Tiết Niệu
- Bài 12: Tổn Thương Thận Cấp
- Bài 13: Bệnh Thận Mạn

#### Bài 14: Chữa Chuyên Sâu Bộ Đề 4

- Chương IV: Tiêu Hóa
- Bài 15: Xơ Gan
- Bài 16: Viêm Tụy
- Bài 17: Xuất Huyết Tiêu Hóa

#### Bài 18: Chữa Chuyên Sâu Bộ Đề 5

- Chương V: Nội Tiết
- Bài 19: Đái Tháo Đường
- Bài 20: Basedow

#### Bài 21: Chữa Chuyên Sâu Bộ Đề 6

- Chương VI: Cơ Xương Khớp
- Bài 22: Viêm Khớp Dạng Thấp
- Bài 23: Gout

#### Bài 24: Chữa Chuyên Sâu Bộ Đề 7

- Chương VII: Huyết Học
- Bài 25: Hội Chứng Thiếu Máu

#### Bài 26: Chữa Chuyên Sâu Bộ Đề 8

- Chương VIII: Hồi Sức
- Bài 27: Shock

#### Bài 28: Chữa Chuyên Sâu Bộ Đề 9

- Chương IX: Thần Kinh
- Bài 29: Đau Đầu

#### Bài 30: Chữa Chuyên Sâu Bộ Đề 10


<a id="khoa-172"></a>

### 36. Nội Chuyên Sâu SĐH - Y HCM: 65 bài, 19 Bộ Đề (ID 172)

**Trạng thái:** Đã tắt · **Chương:** 19 · **Bài học:** 54

**Bài chưa xếp chương:**

- Chương I: Hô Hấp
- Bài 1: Viêm Phổi
- Bài 2: Áp xe Phổi
- Bài 3: Ung Thư Phổi
- Bài 4: COPD
- Bài 5: Giãn Phế Quản - Hen Phế Quản
- Bài 6: Tràn Dịch, Tràn Khí Màng Phổi
- Bài 7: Tâm Phế Mạn

#### Bài 8: Chữa Chuyên Sâu Bộ Đề 1

#### Bài 9: Chữa Chuyên Sâu Bộ Đề 2

- Chương II: Tim Mạch
- Bài 10: Tăng Huyết Áp
- Bài 11: Suy Tim
- Bài 12: Hẹp Van Hai Lá
- Bài 13: Hội Chứng Vành Cấp
- Bài 14: Viêm Màng Ngoài Tim
- Bài 15: Viêm Nội Tâm Mạc
- Bài 16: Rối Loạn Nhịp Tim

#### Bài 17: Chữa Chuyên Sâu Bộ Đề 3

#### Bài 18: Chữa Chuyên Sâu Bộ Đề 4

#### Bài 19: Chữa Chuyên Sâu Bộ Đề 5

- Chương III: Tiết Niệu
- Bài 20: Nhiễm Khuẩn Tiết Niệu
- Bài 21: Phì Đại Tiền Liệt Tuyến
- Bài 22: Viêm Cầu Cấp Thận
- Bài 23: Hội Chứng Thận Hư
- Bài 24: Tổn Thương Thận Cấp
- Bài 25: Bệnh Thận Mạn

#### Bài 26: Chữa Chuyên Sâu Bộ Đề 6

#### Bài 27: Chữa Chuyên Sâu Bộ Đề 7

#### Bài 28: Chữa Chuyên Sâu Bộ Đề 8

- Chương IV: Tiêu Hóa
- Bài 29: Viêm Gan
- Bài 30: Xơ Gan
- Bài 31: Ung Thư Gan
- Bài 32: Viêm Loét Dạ Dày Tá Tràng
- Bài 33: Viêm Tụy
- Bài 34: Xuất Huyết Tiêu Hóa
- Bài 35: Viêm Đại Tràng

#### Bài 36: Chữa Chuyên Sâu Bộ Đề 9

#### Bài 37: Chữa Chuyên Sâu Bộ Đề 10

#### Bài 38: Chữa Chuyên Sâu Bộ Đề 11

- Chương V: Nội Tiết
- Bài 39: Đái Tháo Đường
- Bài 40: Basedow
- Bài 41: Hội Chứng Cushing - Addison - Rối Loạn Mỡ Máu.
- Bài 42: Lubus Ban Đỏ Hệ Thống

#### Bài 43: Chữa Chuyên Sâu Bộ Đề 12

- Chương VI: Cơ Xương Khớp
- Bài 44: Viêm Khớp Dạng Thấp
- Bài 46: Gout
- Bài 47: Loãng Xương
- Bài 48: Thoái Hóa Khớp
- Bài 49: Đau Cột Sống Thắt Lưng

#### Bài 50: Chữa Chuyên Sâu Bộ Đề 13

#### Bài 51: Chữa Chuyên Sâu Bộ Đề 14

- Chương VII: Huyết Học
- Bài 52: Hội Chứng Thiếu Máu
- Bài 53: Hội Chứng Xuất Huyết
- Bài 54: An Toàn Truyền Máu
- Bài 55: Ung Thư Huyết Học p1
- Bài 56: Ung Thư Huyết Học p2

#### Bài 57: Chữa Chuyên Sâu Bộ Đề 15

#### Bài 58: Chữa Chuyên Sâu Bộ Đề 16

- Chương VIII: Hồi Sức
- Bài 59: Shock
- Bài 60: Rối Loạn Kiềm Toan

#### Bài 61: Chữa Chuyên Sâu Bộ Đề 17

#### Bài 62: Chữa Chuyên Sâu Bộ Đề 18

- Chương IX: Thần Kinh
- Bài 63: Đau Đầu
- Bài 64: Lão Khoa

#### Bài 65: Chữa Chuyên Sâu Bộ Đề 19


<a id="khoa-173"></a>

### 37. Ngoại Cơ Bản SĐH - Y HCM: 25 Bài, 10 Bộ Đề (ID 173)

**Trạng thái:** Đã tắt · **Chương:** 10 · **Bài học:** 21

**Bài chưa xếp chương:**

- Chương I: Tiêu Hóa
- Bài 1: Tắc Ruột
- Bài 2: Tắc Ruột Ở Trẻ Em
- Bài 3: MEGACOLON: Giãn Đại Tràng Bẩm Sinh

#### Bài 7: Chữa Chuyên Sâu Bộ Đề 1

#### Bài 8: Chữa Chuyên Sâu Bộ Đề 2

- Bài 4: Ung Thư Dạ Dày
- Bài 5: Ung Thư Thực Quản
- Bài 6: Sỏi Mật

#### Bài 9: Chữa Chuyên Sâu Bộ Đề 3

#### Bài 10: Chữa Chuyên Sâu Bộ Đề 4

- Chương II: Tiết Niệu
- Bài 11: Thoát Vị Bẹn Đùi
- Bài 12: Bệnh Lý Còn Ống Phúc Tinh Mạc Ở Trẻ Em

#### Bài 13: Chữa Chuyên Sâu Bộ Đề 5

- Chương III: Thần Kinh
- Bài 14: U Não

#### Bài 15: Chữa Chuyên Sâu Bộ Đề 6

- Chương IV: Lồng Ngực - Mạch Máu
- Bài 16: Chấn Thương - Vết Thương Ngực
- Bài 17: Chấn Thương - Vết Thương Động Mạch

#### Bài 18: Chữa Chuyên Sâu Bộ Đề 7

- Chương V: Chấn Thương Chi Trên
- Bài 19: Vết Thương Bàn Tay
- Bài 20: Nhiễm Khuẩn Tay

#### Bài 21: Chữa Chuyên Sâu Bộ Đề 8

- Chương VI : Chấn Thương Chi Dưới
- Bài 22: Bỏng
- Bài 23: Chèn Ép Khoang - Gãy Xương Hở

#### Bài 24: Chữa Chuyên Sâu Bộ Đề 9

#### Bài 25: Chữa Chuyên Sâu Bộ Đề 10


<a id="khoa-174"></a>

### 38. \[Ngoại Khoa - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 174)

**Trạng thái:** Đang bật · **Chương:** 19 · **Bài học:** 31

**Bài chưa xếp chương:**

- Chương I: Tiêu Hóa
- Bài 1: Tắc Ruột
- Bài 2: Tắc Ruột Ở Trẻ Em

#### Bài 3: Chữa Chuyên Sâu Bộ Đề 1

#### Bài 4: Chữa Chuyên Sâu Bộ Đề 2

- Bài 5: MEGACOLON: Giãn Đại Tràng Bẩm Sinh
- Bài 6: Ung Thư Dạ Dày

#### Bài 7: Chữa Chuyên Sâu Bộ Đề 3

#### Bài 8: Chữa Chuyên Sâu Bộ Đề 4

- Bài 9: Ung Thư Thực Quản
- Bài 10: Sỏi Mật
- Bài 11: Ung Thư Đại Trực Tràng

#### Bài 12: Chữa Chuyên Sâu Bộ Đề 5

#### Bài 13: Chữa Chuyên Sâu Bộ Đề 6

- Bài 14: Trĩ
- Bài 15: Chấn Thương Bụng
- Bài 16: Vết Thương Bụng
- Bài 17: Viêm Ruột Thừa Cấp

#### Bài 18: Chữa Chuyên Sâu Bộ Đề 7

#### Bài 19: Chữa Chuyên Sâu Bộ Đề 8

- Chương II: Tiết Niệu
- Bài 20: Thoát Vị Bẹn Đùi
- Bài 21: Bệnh Lý Còn Ống Phúc Tinh Mạc Ở Trẻ Em
- Bài 22: Chấn Thương Thận
- Bài 23: Sỏi Tiết Niệu

#### Bài 24: Chữa Chuyên Sâu Bộ Đề 9

#### Bài 25: Chữa Chuyên Sâu Bộ Đề 10

- Chương III: Thần Kinh
- Bài 26: U Não

#### Bài 27: Chữa Chuyên Sâu Bộ Đề 11

- Chương IV: Lồng Ngực - Mạch Máu
- Bài 28: Chấn Thương - Vết Thương Ngực
- Bài 29: Chấn Thương Vết Thương Động Mạch

#### Bài 30: Chữa Chuyên Sâu Bộ Đề 12

#### Bài 31: Chữa Chuyên Sâu Bộ Đề 13

- Chương V: Chấn Thương Chi Trên
- Bài 32: Vết Thương Bàn Tay
- Bài 33: Nhiễm Khuẩn Tay
- Bài 34: Trật Khớp
- Bài 35: Gãy Xương

#### Bài 36: Chữa Chuyên Sâu Bộ Đề 14

#### Bài 37: Chữa Chuyên Sâu Bộ Đề 15

- Chương VI : Chấn Thương Chi Dưới
- Bài 38: Bỏng

#### Bài 39: Chữa Chuyên Sâu Bộ Đề 16

#### Bài 40: Chữa Chuyên Sâu Bộ Đề 17

- Bài 41: Chèn Ép Khoang - Gãy Xương Hở
- Bài 42: Hoại Thư Sinh Hơi - Gãy Xương Chậu

#### Bài 43: Chữa Chuyên Sâu Bộ Đề 18

#### Bài 44: Chữa Chuyên Sâu Bộ Đề 19


<a id="khoa-175"></a>

### 39. \[Sinh Lý SĐH - Y HCM\] Cơ Bản (ID 175)

**Trạng thái:** Đã tắt · **Chương:** 10 · **Bài học:** 25

#### Chương I: SL Đại Cương Chuyển Hóa - Điều Nhiệt

- Bài 1: Đại Cương Cơ Thể Sống
- Bài 2: Chuyển Hóa Năng Lượng
- Bài 3: Chữa Chuyên Sâu Bộ Đề 1

#### Chương II: Sinh Lý Tế Bào

- Bài 4: Sinh Lý Trao Đổi Chất Qua Màn
- Bài 5: Chữa Chuyên Sâu Bộ Đề 2

#### Chương III: Sinh Lý Máu Và Dịch Cơ Thể

- Bài 6: Sinh Lý Máu - Dịch Cơ Thể
- Bài 7: Chữa Chuyên Sâu Bộ Đề 3

#### Chương IV: Sinh Lý Tuần Hoàn

- Bài 8: Sinh Lý Tim
- Bài 9: Chữa Chuyên Sâu Bộ Đề 4

#### Chương V: Sinh Lý Hô Hấp

- Bài 10: Sinh Lý Hô Hấp P1
- Bài 11: Sinh Lý Hô Hấp P2
- Bài 12: Chữa Chuyên Sâu Bộ Đề 5

#### Chương VI: Sinh Lý Thận - Tiết Niệu

- Bài 13: Sinh Lý Thận - Tiết Niệu
- Bài 14: Chữa Chuyên Sâu Bộ Đề 6

#### Chương VII: Sinh Lý Nội Tiết

- Bài 15: Sinh Lý Nội Tiết
- Bài 16: Chữa Chuyên Sâu Bộ Đề 7

#### Chương VIII: Sinh Lý Sinh Sản

- Bài 17: Sinh Lý Sinh Sản Nam
- Bài 18: Sinh Lý Sinh Sản Nữ
- Bài 19: Chữa Chuyên Sâu Bộ Đề 8

#### Chương IX: Sinh Lý Tiêu Hóa

- Bài 20: Đường Tiêu Hóa Trên
- Bài 21: Đường Tiêu Hóa Dưới
- Bài 22: Chữa Chuyên Sâu Bộ Đề 9

#### Chương X: Sinh Lý Thần Kinh - Cơ

- Bài 23: Thần Kinh Cơ P1
- Bài 24: Thần Kinh Cơ P2
- Bài 25: Chữa Chuyên Sâu Bộ Đề 10

<a id="khoa-176"></a>

### 40. \[Sinh Lý - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 176)

**Trạng thái:** Đang bật · **Chương:** 18 · **Bài học:** 32

**Bài chưa xếp chương:**

- Chương I: SL Đại Cương Chuyển Hóa - Điều Nhiệt
- Bài 1: Đại Cương Cơ Thể Sống
- Bài 2: Chuyển Hóa Năng Lượng
- Bài 3: Sinh Lý Điều Nhiệt

#### Bài 4: Chữa Chuyên Sâu Bộ Đề 1

#### Bài 5: Chữa Chuyên Sâu Bộ Đề 2

- Chương II: Sinh Lý Tế Bào
- Bài 6: Sinh Lý Trao Đổi Chất Qua Màng
- Bài 7: Điện Thế Màn

#### Bài 8: Chữa Chuyên Sâu Bộ Đề 3

#### Bài 9: Chữa Chuyên Sâu Bộ Đề 4

- Chương III: Sinh Lý Máu Và Dịch Cơ Thể
- Bài 10: Sinh Lý Máu - Dịch Cơ Thể

#### Bài 11: Chữa Chuyên Sâu Bộ Đề 5

#### Bài 12: Chữa Chuyên Sâu Bộ Đề 6

- Chương IV: Sinh Lý Tuần Hoàn
- Bài 13: Sinh Lý Tim
- Bài 14: Sinh Lý Mạch Máu

#### Bài 15: Chữa Chuyên Sâu Bộ Đề 7

- Chương V: Sinh Lý Hô Hấp
- Bài 16: Sinh Lý Hô Hấp P1
- Bài 17: Sinh Lý Hô Hấp P2

#### Bài 18: Chữa Chuyên Sâu Bộ Đề 8

#### Bài 19: Chữa Chuyên Sâu Bộ Đề 9

- Chương VI: Sinh Lý Thận - Tiết Niệu
- Bài 20: Sinh Lý Thận - Tiết Niệu

#### Bài 21: Chữa Chuyên Sâu Bộ Đề 10

- Chương VII: Sinh Lý Nội Tiết
- Bài 22: Sinh Lý Nội Tiết
- Bài 23: Ứng Dụng Lâm Sàng

#### Bài 24: Chữa Chuyên Sâu Bộ Đề 11

#### Bài 25: Chữa Chuyên Sâu Bộ Đề 12

#### Bài 26: Chữa Chuyên Sâu Bộ Đề 13

- Chương VIII: Sinh Lý Sinh Sản
- Bài 27: Sinh Lý Sinh Sản Nam
- Bài 28: Sinh Lý Sinh Sản Nữ

#### Bài 29: Chữa Chuyên Sâu Bộ Đề 14

- Chương IX: Sinh Lý Tiêu Hóa
- Bài 30: Đường Tiêu Hóa Trên
- Bài 31: Đường Tiêu Hóa Dưới

#### Bài 32: Chữa Chuyên Sâu Bộ Đề 15

#### Bài 33: Chữa Chuyên Sâu Bộ Đề 16

- Chương X: Sinh Lý Thần Kinh - Cơ
- Bài 34: Thần Kinh Cơ P1
- Bài 35: Thần Kinh Cơ P2
- Bài 36: Sinh Lý Cảm Giác Tự Chủ
- Bài 37: Sinh Lý Thần Kinh Vận Động
- Bài 38: Sinh Lý Thần Kinh Cấp Cao

#### Bài 39: Chữa Chuyên Sâu Bộ Đề 17

#### Bài 40: Chữa Chuyên Sâu Bộ Đề 18


<a id="khoa-177"></a>

### 41. \[Mô Phôi\] Cơ Bản -&gt; Chuyên Sâu (ID 177)

**Trạng thái:** Đang bật · **Chương:** 3 · **Bài học:** 33

#### PHẦN 1 – MÔ HỌC CƠ BẢN (11 bài)

- Bài 1: Biểu Mô
- Bài 2: Mô Liên Kết P1
- Bài 3: Mô Liên Kết P2
- Bài 4: Mô Cơ
- Bài 5: Mô Thần Kinh Và Hệ Thần Kinh

#### PHẦN 2 – MÔ HỌC CÁC HỆ CƠ QUAN (17 bài)

- Bài 14: Hệ Hô Hấp P1
- Bài 15: Hệ Hô Hấp P2
- Bài 8: Hệ Tiêu Hóa P1
- Bài 9: Hệ Tiêu Hóa P2
- Bài 18: Hệ Tiết Niệu P1
- Bài 16: Da Và Cấu Trúc Phụ P1
- Bài 17: Da Và Cấu Trúc Phụ P2
- Bài 20: Hệ Sinh Dục P1
- Bài 21: Hệ Sinh Dục P2
- Bài 22: Hệ Nội Tiết P1
- Bài 23: Hệ Nội Tiết P2
- Bài 24: Hệ Tim Mạch P1
- Bài 25: Hệ Tim Mạch P2
- Bài 26: Cơ Quan Tạo Máu Và Miễn Dịch P1
- Bài 27: Cơ Quan Tạo Máu Và Miễn Dịch P2

#### PHẦN 3 – PHÔI THAI HỌC CƠ BẢN &amp; PHÁT TRIỂN HỆ CƠ QUAN (17 bài)

- Bài 28: Sự Tạo Và Phát Triển Của Phôi 3 Lá P1
- Bài 29: Sự Tạo Và Phát Triển Của Phôi 3 Lá P2
- Bài 30: Sự Tạo Nhanh Và Phát Triển Của Phần Phụ Phôi Thai
- Bài 31: Sự Phát Triển Của Hệ Hô Hấp P1
- Bài 32: Sự Phát Triển Của Hệ Hô Hấp P2
- Bài 33: Sự Tạo Và Phát Triển Của Hệ Tiêu Hóa P1
- Bài 34: Sự Tạo Và Phát Triển Của Hệ Tiêu Hóa P2
- Bài 35: Sự Tạo Và Phát Triển Của Hệ Tiết Niệu Sinh Dục P1
- Bài 36: Sự Tạo Và Phát Triển Của Hệ Tiết Niệu Sinh Dục P2
- Bài 37: Ôn Luyện Đề Mô Phôi Cuối Kì
- Bài 38: Ôn Luyện Đề Mô Phôi Cuối Kì P2
- Bài 5: Mô Sụn Và Mô Xương P1
- Bài 6: Mô Sụn Và Mô Xương P2

<a id="khoa-178"></a>

### 42. Mô Phôi Cơ Bản (25 Bài + 250 sơ đồ ghi nhớ) (ID 178)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-179"></a>

### 43. Hóa Sinh SĐH - Y HCM (Cơ Bản -&gt; Chuyên Sâu) (ID 179)

**Trạng thái:** Đã tắt · **Chương:** 19 · **Bài học:** 28

#### Chương I: Cấu Tạo Và Chuyển Hóa Chất

- Bài 1: Chuyển Hóa Acid amin

#### Bài 2: Chữa Chuyên Sâu Bộ Đề 1

- Bài 3: Thoái Hóa Acid Nucleic
- Bài 4: Tổng Hợp Acid Nucleic

#### Bài 5: Chữa Chuyên Sâu Bộ Đề 2

- Bài 6: Chuyển Hóa Glucid p1
- Bài 7: Chuyển Hóa Glucid p2

#### Bài 8: Chữa Chuyên Sâu Bộ Đề 3

- Bài 9: Thoái Hóa Lipid
- Bài 10: Sinh Tổng Hợp Lipid

#### Bài 11: Chữa Chuyên Sâu Bộ Đề 4

- Bài 12: Enzyme p1
- Bài 13: Enzyme p2
- Bài 14: Enzyme p3

#### Bài 15: Chữa Chuyên Sâu Bộ Đề 5

- Bài 16: Hóa Học Acid Amin

#### Bài 17: Chữa Chuyên Sâu Bộ Đề 6

- Bài 18: Hóa Học Glucid

#### Bài 19: Chữa Chuyên Sâu Bộ Đề 7

- Bài 20: Hóa Học Acid Nucleic p1
- Bài 21: Hóa Học Acid Nucleic p2

#### Bài 22: Chữa Chuyên Sâu Bộ Đề 8

- Bài 23: Hóa Học Lipid

#### Bài 24: Chữa Chuyên Sâu Bộ Đề 9

#### Chương II: Hóa Sinh Tế Bào, Mô, Cơ Quan

- Bài 25: Hóa Sinh Thần Kinh
- Bài 26: Hóa Sinh Cơ
- Bài 27: Hóa Sinh Dịch Cơ Thể
- Bài 28: Hóa Sinh Gan

#### Bài 29: Chữa Chuyên Sâu Bộ Đề 10

- Bài 30: Hóa Sinh Hormon p1
- Bài 31: Hóa Sinh Hormon p2

#### Bài 32: Chữa Chuyên Sâu Bộ Đề 11

- Bài 33: Hóa Sinh Máu
- Bài 34: Hóa Sinh Khí Máu Động Mạch

#### Bài 35: Chữa Chuyên Sâu Bộ Đề 12

- Bài 36: Hóa Sinh Thận Và Nước Tiểu
- Bài 37: Hóa Sinh Thận - Muối Nước

#### Bài 38: Chữa Chuyên Sâu Bộ Đề 13

- Bài 39: Hóa Sinh Năng Lượng

#### Bài 40: Chữa Chuyên Sâu Bộ Đề 14

- Bài 41: Sinh Tổng Hợp Protein
- Bài 42: Chuyển Hóa Hemoglobin

#### Bài 43: Chữa Chuyên Sâu Bộ Đề 15

#### Bài 44: Ôn Tập Và Chữa Test B1

#### Bài 45: Ôn Tập Và Chữa Test B2


<a id="khoa-180"></a>

### 44. \[Hóa Sinh - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 180)

**Trạng thái:** Đang bật · **Chương:** 13 · **Bài học:** 19

#### Chương I: Cấu Tạo Và Chuyển Hóa Chất

- Bài 1: Chuyển Hóa Acid amin

#### Bài 2: Chữa Chuyên Sâu Bộ Đề 1

- Bài 3: Chuyển Hóa Glucid p1
- Bài 4: Chuyển Hóa Glucid p2

#### Bài 5: Chữa Chuyên Sâu Bộ Đề 2

- Bài 6: Thoái Hóa Lipid
- Bài 7: Sinh Tổng Hợp Lipid

#### Bài 8: Chữa Chuyên Sâu Bộ Đề 3

- Bài 9: Enzyme p1
- Bài 10: Enzyme p2
- Bài 11: Enzyme p3

#### Bài 12: Chữa Chuyên Sâu Bộ Đề 4

- Bài 13: Hóa Học Acid Amin

#### Bài 14: Chữa Chuyên Sâu Bộ Đề 5

- Bài 15: Hóa Học Glucid

#### Bài 16: Chữa Chuyên Sâu Bộ Đề 6

- Bài 17: Hóa Học Lipid

#### Bài 18: Chữa Chuyên Sâu Bộ Đề 7

#### Chương II: Hóa Sinh Tế Bào, Mô, Cơ Quan

- Bài 19: Hóa Sinh Thần Kinh
- Bài 20: Hóa Sinh Cơ
- Bài 21: Hóa Sinh Dịch Cơ Thể
- Bài 22: Hóa Sinh Gan
- Bài 23: Hóa Sinh Hormon p1

#### Bài 24: Chữa Chuyên Sâu Bộ Đề 8

- Bài 25: Hóa Sinh Máu

#### Bài 26: Chữa Chuyên Sâu Bộ Đề 9

- Bài 27: Hóa Sinh Thận - Muối Nước

#### Bài 28: Chữa Chuyên Sâu Bộ Đề 10

- Bài 29: Hóa Sinh Năng Lượng

#### Bài 30: Chữa Chuyên Sâu Bộ Đề 11


<a id="khoa-181"></a>

### 45. Da Liễu Cơ Bản Đến Chuyên Sâu (ID 181)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 24

**Bài chưa xếp chương:**

- Buổi 1: Mô Học Da Thường
- Buổi 2: Sinh Lý Da
- Buổi 3: Các Dạng Thuốc Bôi Ngoài Da
- Buổi 4: Thương Tổn Cơ Bản
- Buổi 5: Cách Làm Bệnh Án Da Liễu
- Buổi 6: Viêm Da Cơ Địa
- Buổi 7: Dị Ứng Thuốc
- Buổi 8: Bệnh Vảy Nến
- Buổi 9: Bệnh Lupus Ban Đỏ
- Buổi 10: Bệnh Chốc
- Buổi 11: Bệnh Duhring - Brocq
- Buổi 12: Bệnh Pemphigus
- Buổi 13: Bệnh Lang Ben
- Buổi 14: Các Bệnh Nấm Thông Thường
- Buổi 15: Bệnh Ghẻ
- Buổi 16: Bệnh Phong
- Buổi 17: Bệnh Lậu
- Buổi 18: Bệnh Giang Mai
- Buổi 19: Bệnh Viêm Âm Đạo Do Nấm Candida
- Buổi 20: Viêm Âm Đạo Do Trùng Roi
- Buổi 21: Các Biểu Hiện Da Niêm Mạc, Ở Bệnh Nhân HIV
- Buổi 22: Ôn Tập Lại Buổi 1 -12
- Buổi 23: Ôn Tập Lại Buổi 12-22
- Buổi 24: Kiểm Tra Cuối Kì - Kết Thúc Khóa Học

<a id="khoa-191"></a>

### 46. \[Dược Lý Lý Thuyết\] Cơ Bản -&gt; Chuyên Sâu (ID 191)

**Trạng thái:** Đang bật · **Chương:** 9 · **Bài học:** 37

#### PHẦN I: ĐẠI CƯƠNG DƯỢC LÝ

- Buổi 1: Dược động học
- Buổi 2: Dược lực học, Tương tác thuốc
- Buổi 3: Bài tập chuyên đề 1: Dược lý đại cương
- Buổi 4: BTCĐ 1: Dược Lý Đại Cương

#### PHẦN II: THUỐC TÁC ĐỘNG TRÊN HỆ TKTW

- Buổi 5: Các Chất Dẫn Truyền Thần Kinh, Thuốc An Thần Gây Ngủ
- Buổi 6: Thuốc gây mê, Thuốc gây tê
- Buổi 7: Thuốc giảm đau TKTW
- Buổi 8: Thuốc chống động kinh, Thuốc chống trầm cảm
- Buổi 9: Bài tập chuyên đề 2: Thuốc tác động trên hệ TKTW

#### PHẦN III: THUỐC TÁC ĐỘNG TRÊN HỆ MIỄN DỊCH

- Buổi 10: Thuốc kháng viêm không steroid (NSAID)
- Buổi 11: Thuốc kháng histamine H1, Thuốc điều trị gout
- Buổi 12: Bài tập chuyên đề 3: Thuốc tác động trên hệ miễn dịch

#### PHẦN IV: ĐẠI CƯƠNG KHÁNG SINH

- Buổi 13: Beta-lactam
- Buổi 14: Kháng Sinh Beta-Lactam
- Buổi 15: Sulfamide kháng khuẩn, Quinolon
- Buổi 16: Thuốc điều trị lao, Thuốc điều trị phong
- Buổi 17: BTCĐ 4: Kháng Sinh

#### PHẦN V: KHÁNG SINH

- Buổi 18: Aminoglycoside, Cycline
- Buổi 19: Macrolide và lincosamide, Phenicol
- Buổi 20: Kháng sinh peptid, Thuốc kháng nấm
- Buổi 21: Thuốc kháng virus, Thuốc kháng ký sinh trùng P1
- Buổi 22: Thuốc kháng virus, Thuốc kháng ký sinh trùng P2
- Buổi 23: Bài tập chuyên đề 5: Kháng sinh (tiếp theo)

#### PHẦN VI: TÁC ĐỘNG TRÊN HỆ TIM MẠCH

- Buổi 24: Thuốc điều trị tăng huyết áp, Thuốc lợi tiểu
- Buổi 25: Thuốc làm tăng sức co bóp cơ tim, Thuốc điều trị rối loạn nhịp tim, Thuốc chống đau thắt ngực
- Buổi 26: Thuốc Hạ Lipid Máu, Tác Động Qúa Trình Đông Máu
- Buổi 27: Bài tập chuyên đề 6: Thuốc tác động trên hệ tim mạch

#### PHẦN VII: THUỐC TÁC ĐỘNG TRÊN HỆ TIÊU HÓA

- Buổi 28: Thuốc điều trị loét đường tiêu hoá
- Buổi 29: Thuốc điều trị tiêu chảy, Thuốc điều trị táo bón
- Buổi 30: Thuốc Chống Nôn, ĐTrị Thừa Cân - Béo Phì
- Buổi 31: Bài tập chuyên đề 7: Thuốc tác động trên hệ tiêu hóa

#### PHẦN VIII: THUỐC TÁC ĐỘNG TRÊN HỆ HÔ HẤP

- Buổi 32: Thuốc điều trị hen phế quản
- Buổi 33: Thuốc giảm ho, Thuốc điều chỉnh dịch tiết phế quản
- Buổi 34: Bài tập chuyên đề 8: Thuốc tác động trên hệ hô hấp

#### PHẦN IX: THUỐC TÁC ĐỘNG TRÊN HỆ THỐNG HORMONE

- Buổi 35: Insulin và thuốc điều trị đái tháo đường, Thuốc điều trị bệnh lý tuyến giáp
- Buổi 36: Hormone vỏ thượng thận và các thuốc corticoid, Hormone sinh dục và các thuốc liên quan
- Buổi 37: Bài tập chuyên đề 9: Thuốc tác động trên hệ thống hormone

<a id="khoa-192"></a>

### 47. Tiếng Anh Giao Tiếp Y Khoa Trong Bệnh Viện (cơ bản -&gt; chuyên sâu) (ID 192)

**Trạng thái:** Đang bật · **Chương:** 0 · **Bài học:** 25

**Bài chưa xếp chương:**

- Phần 1: Kiến Thức Nền Tảng và Chào Hỏi
- Buổi 1: Giới Thiệu Chung Về Bệnh Viện Và Các Khoa
- Buổi 2: Chào Hỏi Và Giới Thiệu Bản Thân
- Buổi 3: Hỏi Thông Tin Cá Nhân Cơ Bản
- Buổi 4: Lịch Sử Y Tế Cơ Bản
- Buổi 5: Mô Tả Đau
- Buổi 6: Các Triệu Chứng Thường Gặp Khác
- Buổi 7: Hỏi Về Các Hệ Cơ Quan
- Buổi 8: Giải Thích Quy Trình Khám Bệnh
- Buổi 9: Thông Báo Chẩn Đoán Đơn Giản
- Buổi 10: Giải Thích Các Phương Pháp Điều Trị
- Buổi 11: Kê Đơn Thuốc và Hướng Dẫn Sử Dụng
- Buổi 12: Thảo Luận Về Kết Quả Xét Nghiệm
- Buổi 13: Giao Tiếp Trong Tình Huống Cấp Cứu
- Buổi 14: Tại Khoa Cấp Cứu
- Buổi 15: Chăm Sóc Trước và Sau Phẫu Thuật
- Buổi 16: Giao Tiếp Tại Phòng Sinh/Sản Khoa
- Buổi 17: Giải Thích Thủ Thuật Y Tế
- Buổi 18: Giao Tiếp Với Người Nhà Bệnh Nhân
- Buổi 19: Xử Lý Tình Huống Khó Khăn
- Buổi 20: Thông Báo Tin Xấu
- Buổi 21: Hướng Dẫn Ra Viện
- Buổi 22: Chăm Sóc Tại Nhà và Phục Hồi
- Buổi 23: Giao Tiếp Giữa Các Đồng Nghiệp và Chuyển Giao Ca
- Buổi 24: Tổng Kết &amp; Thực Hành Tổng Hợp

<a id="khoa-193"></a>

### 48. \[Sinh Lý Bệnh MD\] Cơ Bản -&gt; Chuyên Sâu (ID 193)

**Trạng thái:** Đang bật · **Chương:** 4 · **Bài học:** 37

#### Phần 1: Đại Cương Sinh Lý Bệnh

- Bài 1: Đại Cương Sinh Lý Bệnh
- Bài 2: Các Khái Niệm Cơ Bản Sinh Lý Bệnh
- Bài 3: Rối Loạn Chuyển Hóa Glucid P1
- Bài 4: Rối Loạn Chuyển Hóa Glucid P2
- Bài 5: Rối Loạn Chuyển Hóa Lipid
- Bài 6: Rối Loạn Chuyển Hóa Protid
- Bài 7: Rối Loạn Thân Nhiệt - Sốt
- Bài 8: Sinh Lý Bệnh Hệ Nội Tiết
- Bài 9: Ôn Tập

#### Phần 2: Rối Loạn Chuyển Hóa

- Bài 10: Viêm
- Bài 11: Rối Loạn Chuyển Hóa Nước Và Điện Giải P1
- Bài 12: Rối Loạn Chuyển Hóa Nước Và Điện Giải P2
- Bài 13: Rối Loạn Chuyển Hóa Nước Và Điện Giải P3
- Bài 14: Rối Loạn Cân Bằng Acid - Base P1
- Bài 15: Rối Loạn Cân Bằng Acid - Base P2
- Bài 16: Rối Loạn Cấu Tạo Máu P1
- Bài 17: Rối Loạn Cấu Tạo Máu P2
- Bài 18: Rối Loạn Cấu Tạo Máu P3
- Bài 19: Ôn Tập

#### Phần 3: Sinh Lý Bệnh Chức Năng

- Bài 20: Sinh Lý Bệnh Chức Năng Tuần Hoàn P1
- Bài 21: Sinh Lý Bệnh Chức Năng Tuần Hoàn P2
- Bài 22: Sinh Lý Bệnh Chức Năng Hô Hấp P1
- Bài 23: Sinh Lý Bệnh Chức Năng Hô Hấp P2
- Bài 24: Sinh Lý Bệnh Chức Năng Tiêu Hóa
- Bài 25: Sinh Lý Bệnh Chức Năng Gan P1
- Bài 26: Sinh Lý Bệnh Chức Năng Gan P2
- Bài 27: Sinh Lý Bệnh Chức Năng Tiết Niệu P1
- Bài 28: Sinh Lý Bệnh Chức Năng Tiết Niệu P2
- Bài 29: Ôn Tập

#### Phần 4: Miễn Dịch

- Bài 30: Đại Cương Về Miễn Dịch Học
- Bài 31: Hệ Thống Tổ Chức Các Cơ Quan Miễn Dịch
- Bài 32: Kháng Nguyên
- Bài 33: Kháng Thể
- Bài 34: Bổ Thể
- Bài 35: Sự kết hợp kháng nguyên-kháng thể và ứng dụng
- Bài 36: Ôn Tập
- Bài 37: Thi Thử

<a id="khoa-194"></a>

### 49. \[Ký Sinh Trùng Y Học\] Cơ Bản -&gt; Chuyên Sâu (ID 194)

**Trạng thái:** Đang bật · **Chương:** 3 · **Bài học:** 32

#### PHẦN 1 – ĐẠI CƯƠNG &amp; GIUN SÁN

- Bài 1: Đại Cương Về Ký Sinh Trùng Y Học
- Bài 2: Đại Cương Về Giun Sán
- Bài 3: Đại Cương Về Đơn Bào Ký Sinh
- Bài 4: Giun Đũa Người
- Bài 5: Giun Móc
- Bài 6: Giun Tóc
- Bài 7: Giun Kim
- Bài 8: Giun Đũa Chó Mèo
- Bài 9: Giun Lươn
- Bài 10: Giun Xoắn
- Bài 11: Giun Chỉ
- Bài 12: Ôn Tập &amp; Kiểm Tra Giữa Phần Giun
- Bài 13: Sán Lá Gan Lớn, Nhỏ, Sán Lá Ruột
- Bài 14: Sán Lá Phổi
- Bài 15: Sán Máng
- Bài 16: Sán Dây Lợn
- Bài 17: Sán Dây Bò
- Bài 18: Ôn Tập &amp; Kiểm Tra Giữa Phần Sán

#### PHẦN 2 – ĐƠN BÀO &amp; SỐT RÉT

- Bài 19: Amip Ký Sinh Ở Người
- Bài 20: Trùng Roi
- Bài 21: Trùng Lông
- Bài 22: Ký Sinh Trùng Sốt Rét – Phần 1
- Bài 23: Ký Sinh Trùng Sốt Rét – Phần 2
- Bài 24: Dịch Tễ Học Sốt Rét
- Bài 25: Phòng Chống Bệnh Sốt Rét
- Bài 26: Ôn Tập &amp; KT Giữa Phần Đơn Bào &amp; Sốt Rét

#### PHẦN 3 – TIẾT TÚC Y HỌC - VI NẤM

- Bài 27: Tiết Túc Y Học – Đại Cương
- Bài 28: Tiết Túc Thuộc Lớp Nhện
- Bài 29: Tiết Túc Thuộc Lớp Côn Trùng
- Bài 30: Vi Nấm Ký Sinh Y Học
- Bài 31: Ôn Tập Cuối Kỳ + Kiểm Tra Tổng Hợp
- Bài 32: Luyện Thi Cuối Kì

<a id="khoa-195"></a>

### 50. \[Hóa Sinh\] Cơ Bản -&gt; Chuyên Sâu (ID 195)

**Trạng thái:** Đang bật · **Chương:** 10 · **Bài học:** 45

#### PHẦN A: NỀN TẢNG HÓA SINH

#### CHƯƠNG 1: ENZYME

- Buổi 1: Đại Cương Enzyme
- Buổi 2: Cách Gọi Tên, Phân Loại, Cơ Chế Xúc Tác
- Buổi 3: Coenzym
- Buổi 4: Đề Thi, Chữa Đề Thi Enzym

#### CHƯƠNG 2: ACID AMIN

- Bài 5: Hóa Học Acid Amin
- Bài 6: Đề Thi, Chữa Đề Hóa Học Acid Amin
- Bài 7: Chuyển Hóa Acid Amin, Chu Trình Ure
- Bài 8: Đề Thi, Chữa Chuyển Hóa Acid Amin

#### CHƯƠNG 3: PROTEIN

- Bài 9: Hóa Học Protein Phân Loại, Cấu Tạo
- Bài 10: Chuyển Hóa Hemoglobin
- Bài 11: Đề, Chữa Đề Chuyển Hóa Hemoglobin

#### CHƯƠNG 4: GLUCID

- Bài 12: Hóa Học Glucid
- Bài 13: Đề, Chữa Đề Hóa Học Glucid
- Bài 14.1: Chuyển Hóa Glucid p1
- Bài 14.3: Đề, Chữa Đề Chuyển Hóa Glucid
- Bài 14.2: Chuyển Hóa Glucid p2

#### CHƯƠNG 5: LIPID

- Bài 15: Hóa Học Lipid Phân Loại, Cấu Tạo
- Bài 16: Đề, Chữa Đề Hóa Học Lipid
- Bài 17.1: Chuyển Hóa Lipid
- Bài 17.2: Sinh Tổng Hợp Lipid
- Bài 17.3: Thoái Hóa Lipid
- Bài 18: Đề, Chữa Đề Chuyển Hóa Lipid

#### CHƯƠNG 6: ACID NUCLEIC

- Bài 19.1: Hóa Học Acid Nucleic p1
- BàI 19.2: Hóa Học Acid Nucleic p2
- Bài 20: Đề, Chữa Đề Acid Nucleic
- Bài 21.1: Chuyển Hóa Acid Nucleic
- Bài 21.2: Thoái Hóa Acid Nucleic
- Bài 21.3: Tổng Hợp Acid Nucleic

#### PHẦN B: NĂNG LƯỢNG SINH HỌC

- Bài 22: Hóa Sinh Năng Lượng
- Bài 23: Đề, Chữa Đề Hóa Sinh Năng Lượng

#### PHẦN C: HÓA SINH TẠNG VÀ LÂM SÀNG

- Bài 24.1: Hóa Sinh Hormon p1
- Bài 24.2: Hóa Sinh Hormon p2
- Bài 25: Đề, Chữa Đề Hóa Sinh Hormon
- Bài 26: Hóa Sinh Máu
- Bài 27: Hóa Sinh Khí Máu Động Mạch
- Bài 28: Đề, Chữa Đề Hóa Sinh Máu - Khí Máu ĐM
- Bài 29: Hóa Sinh Muối Nước
- Bài 30: Đề, Chữa Đề Hóa Sinh Muối Nước
- Bài 31: Hóa Sinh Gan
- Bài 32: Hóa Sinh Thận Và Nước Tiểu
- Bài 33.1: Hóa Sinh Dịch Cơ Thể
- Bài 33.2: Hóa Sinh Thần Kinh
- Bài 33.3: Hóa Sinh Cơ

#### CHƯƠNG 7: SINH TỔNG HỢP PROTEIN (DỊCH MÃ)

- Bài 34: Sinh Tổng Hợp Protein
- Làm Đề Hóa Sinh số 1 (bài tập làm thêm website)

<a id="khoa-196"></a>

### 51. Thống Kê Y Học \[Cơ Bản -&gt; Chuyên Sâu\] (ID 196)

**Trạng thái:** Đang bật · **Chương:** 0 · **Bài học:** 16

**Bài chưa xếp chương:**

- Bài 1. Lý Thuyết Giới Thiệu Chung SPSS - Biến Dữ Liệu Trên SPSS
- Bài 2. Thực Hành Giới Thiệu Chung SPSS - Biến Dữ Liệu Trên SPSS
- Bài 3. Lý Thuyết Quản Lý Và Biên Tập Dữ Liệu
- Bài 4. Thực Hành Quản Lý Và Biên Tập Dữ Liệu
- Bài 5. Lý Thuyết Tổ Chức Và Tạo Biến Mới - Thống Kê Mô Tả
- Bài 6. Thực Hành Tổ Chức Và Tạo Biến Mới - Thống Kê Mô Tả
- Bài 7. Lý Thuyết Thống Kê Mô Tả: Phân Phối Chuẩn Và Các Loại Biểu Đồ
- Bài 8. Thực Hành Thống Kê Mô Tả: Phân Phối Chuẩn Và Các Loại Biểu Đồ
- Bài 9. Lý Thuyết Thống Kê Suy Diễn: Kiểm Định Giả Thuyết Và Phân Tích Biến Liên Tục
- Bài 10. Thực Hành Thống Kê Suy Diễn: Kiểm Định Giả Thuyết Và Phân Tích Biến Liên Tục
- Bài 11. Lý Thuyết Phân Tích Biến Phân Loại
- Bài 12. Thực Hành Phân Tích Biến Phân Loại
- Bài 13. Lý Thuyết Phân Tích Phương Sai ANOVA
- Bài 14. Thực Hành Phân Tích Phương Sai ANOVA
- Bài 15. Lý Thuyết Tương Quan Và Hồi Quy
- Bài 16. Thực Hành Tương Quan Và Hồi Quy

<a id="khoa-197"></a>

### 52. \[Sinh Lý - Nội Trú\] Cơ Bản -&gt; sâu (ID 197)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 29

**Bài chưa xếp chương:**

- Bài 1: Sinh Lý Hồng Cầu
- Bài 2: Sinh Lý Tiểu Cầu - Cầm Máu
- Bài 3: Nhóm Máu
- Bài 4: Ôn Tập Trắc Nghiệm Phần Máu
- Bài 5: Hoạt Động Điện Của Tim
- Bài 6: Chức Năng Bơm Máu Của Tim
- Bài 7: Điều Hoà Hoạt Động Điện Của Tim
- Bài 8: Ôn Tập Trắc Nghiệm Phần Tuần Hoàn
- Bài 9: Cơ Học Hô Hấp
- Bài 10: Trao Đổi Khí Tại Phổi
- Bài 11: Chuyển Chở Khí Trong Máu
- Bài 12: Ôn Tập Trắc Nghiệm Phần Hô Hấp
- Bài 13: Chức Năng Tạo Nước Tiểu Và Bài Xuất Các Sản Phẩm Chuyển Hoá
- Bài 14: Chức Năng Nội Tiết Của Thận
- Bài 15: Ôn Tập Trắc Nghiệm Phần Tiết Niệu
- Bài 16: Tiêu Hoá Ở Dạ Dày
- Bài 17: Tiêu Hoá Ở Ruột Non
- Bài 18: Ôn Tập Trắc Nghiệm Phần Tiêu Hoá
- Bài 19: Khái Quát Về Hoạt Động Hệ Nội Tiết
- Bài 20: Sinh Lý Tuyến Giáp
- Bài 21: Sinh Lý Tuyến Tuỵ Nội Tiết
- Bài 22: Ôn Tập Trắc Nghiệm Phần Nội Tiết
- Bài 23: Sinh Lý Tuỷ Gai
- Bài 24: Sinh Lý Hệ Thần Kinh Tự Chủ
- Bài 25: Ôn Tập Trắc Nghiệm Phần Thần Kinh
- Bài 26: Làm Thử Đề Sinh Lý 120 Câu
- Bài 27: Sửa Đề Sinh Lý
- Bài 28: Làm Thử Đề Sinh Lý 120 Câu
- Bài 29: Sửa Đề Sinh Lý

<a id="khoa-198"></a>

### 53. \[Nội Khoa - Nội Trú\] Cơ Bản -&gt; Sâu (ID 198)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 25

**Bài chưa xếp chương:**

- Bài 1: Tim Mạch : Hội Chứng Vành Cấp
- Bài 2: Ôn Tập Câu Hỏi Lâm Sàng Hội Chứng Vành Cấp
- Bài 3: Hô Hấp: Nhiễm Khuẩn Hô Hấp Dưới
- Bài 4: Ôn Tập Câu Hỏi Lâm Sàng Nhiễm Khuẩn Hô Hấp Dưới
- Bài 5: Thận: Tổn Thương Thận Cấp
- Bài 6: Ôn Tập Câu Hỏi Lâm Sàng Tổn Thương Thận Cấp
- Bài 7: Tiêu Hoá: Xuất Huyết Tiêu Hoá
- Bài 8: Ôn Tập Câu Hỏi Lâm Sàng Xuất Huyết Tiêu Hoá
- Bài 9: Lão Khoa: Loãng Xương Người Cao Tuổi
- Bài 10: Ôn Tập Câu Hỏi Lâm Sàng Loãng Xương
- Bài 11: Huyết Học: Thiểu Máu
- Bài 12: Ôn Tập Câu Hỏi Tình Huống Thiếu Máu
- Bài 13: Nội Tiết: Đái Tháo Đường P1
- Bài 14: Nội Tiết: Đái Tháo Đường P2
- Bài 15: Ôn Tập Câu Hỏi Lâm Sàng Đái Tháo Đường
- Bài 16: Thần Kinh: Hôn Mê
- Bài 17: Ôn Tập Câu Hỏi Lâm Sàng Hôn Mê
- Bài 18: Da Liễu: Bệnh Bóng Nước Tự Miễn
- Bài 19: Ôn Tập Câu Hỏi Lâm Sàng Bệnh Bóng Nước Tự Miễn
- Bài 20: Tâm Thần : Rối Loạn Trầm Cảm Chủ Yếu
- Bài 21: Ôn Tập Câu Hỏi Lâm Sàng Rối Loạn Trầm Cảm Chủ Yếu
- Bài 22: Làm Thử Đề Nội Khoa 120 Câu
- Bài 23: Sửa Đề Nội Khoa
- Bài 24: Làm Thử Đề Nội Khoa 120 Câu
- Bài 25: Sửa Đề Nội Khoa

<a id="khoa-199"></a>

### 54. \[Lý Sinh\] Cơ Bản -&gt; Chuyên Sâu (ID 199)

**Trạng thái:** Đang bật · **Chương:** 9 · **Bài học:** 40

#### Chương 1: Đơn Vị Đo Lường

- Bài 1: Các Hệ Thống Đơn Vị Đo Lường
- Bài 2: MQH Giữa Đại Lượng Và Đơn Vị Đo
- Bài 3: Cách Biểu Diễn Và Đọc Kết Quả Đo
- Bài 4: Bài Tập Áp Dụng

#### Chương 2: Vận Động Cơ Học

- Bài 5: Chuyển Động Của Chất Điểm
- Bài 6: Chuyển Động Của Vật Rắn
- Bài 7: Công Và Năng Lượng Trong Cơ Thể Sống
- Bài 8: Bài Tập Áp Dụng

#### Chương 3: Dao Động Và Sóng Cơ Sóng Âm Và Siêu Âm

- Bài 9: Dao Động Cơ Học
- Bài 10: Sóng Cơ
- Bài 11: Sóng Âm
- Bài 12: Bài Tập Áp Dụng

#### Chương 4: Cơ Học Chất Lưu

- Bài 13: Các Khái Niệm Cơ Bản
- Bài 14: Tĩnh Học Chất Lưu
- Bài 15: Động Học Chất Lưu
- Bài 16: Chuyển Động Của Máu Trong HTH
- Bài 17: Bài Tập Áp Dụng

#### Chương 5: Thuyết Động Học Phân Từ - Hiện Tượng Vận Chuyển Trao Đổi Chất

- Bài 18: Một Số Khái Niệm Về Khí Lý Tưởng
- Bài 19: Thuyết Động Học Phân Từ Các Chất Khí
- Bài 20: Các Hiện Tượng VCVC Cơ Bản Trong CT
- Bài 21: Vận Chuyển Vật Chất Qua Màng Tế Bào
- Bài 22: Bài Tập Áp Dụng

#### Chương 6: NĐLH Và Hệ Thống Sống

- Bài 23: Phát Biểu NL, BD Đại Lượng Đặc Trưng
- Bài 24: Áp Dụng NL I, Ii Cho Hệ Thống Sống
- Bài 25: Bài Tập Áp Dụng

#### Chương 7: Điện Sinh Học

- Bài 26: Các Loại Điện Thế Sinh Vật
- Bài 27: Các Loại Điện Thế Sinh Vật
- Bài 28: Các Hiện Tượng Điện Động
- Bài 29: Tác Dụng Của DĐ Lên Cơ Thể Sống
- Bài 30: Bài Tập Áp Dụng

#### Chương 8: Quang Sinh Học

- Bài 31: Các Định Luật Quang Hình Cơ Bản
- Bài 32: TD Của Ánh Sáng Lên Cơ Thể Sống
- Bài 33: Thấu Kính Mắt
- Bài 34: Bài Tập Áp Dụng

#### Chương 9: Thần Kinh - Cấp Cứu

- Bài 35: KN Và Nguồn Gốc Của Bức Xạ Ion Hoá
- Bài 36: Tương Tác Của Bức Xạ Ion Với Vật Chất
- Bài 37: Sự Hấp Thụ NL Bức Xạ. Liều Lượng BX
- Bài 38: TD Của BX Ion Hoá Lên Vật Chất Sống
- Bài 39: Các Phương Áp Y Học Hạt Nhân
- Bài 40: Bài Tập Áp Dụng

<a id="khoa-200"></a>

### 55. \[Dược Lý Lâm Sàng\] Cơ Bản -&gt; Chuyên Sâu (ID 200)

**Trạng thái:** Đang bật · **Chương:** 11 · **Bài học:** 41

#### Phần 1: DƯỢC LÂM SÀNG ĐẠI CƯƠNG

- Bài 1: Giới thiệu về dược lâm sàng - Số phận của thuốc trong cơ thể
- Bài 2: Các đường đưa thuốc và cách sử dụng
- Bài 3: Thông tin thuốc
- Bài 4: Phản ứng có hại của thuốc
- Bài 5: Dị ứng thuốc
- Bài 6: Tương tác thuốc
- Bài 7: Tương tác thuốc (tiếp theo) + Tương kỵ thuốc
- Bài 8: Độc chất học lâm sàng
- Bài 9: Sử thuốc trên đối tượng đặc biệt: Sử dụng thuốc cho phụ nữ có thai, cho con bú, trẻ em
- Bài 10: Sử thuốc trên đối tượng đặc biệt: Sử dụng thuốc cho người cao tuổi, suy gan, suy thận

#### Phần 2: DƯỢC LÂM SÀNG VÀ ĐIỀU TRỊ

#### Sử dụng thuốc trong điều trị bệnh tiêu hoá (4 bài)

- Bài 11: Sử dụng thuốc trong điều trị loét dạ dày tá tràng
- Bài 12: Sử dụng thuốc trong điều trị loét dạ dày tá tràng (tiếp theo)
- Bài 13: Sử dụng thuốc trong điều trị táo bón
- Bài 14: Sử dụng thuốc trong điều trị tiêu chảy

#### Sử dụng thuốc trong điều trị các bệnh lý tim mạch (6 bài)

- Bài 15: Sử dụng thuốc trong điều trị tăng huyết áp
- Bài 16: Sử dụng thuốc trong điều trị tăng huyết áp (tiếp theo)
- Bài 17: Sử dụng thuốc trong điều trị rối loạn lipid huyết
- Bài 18: Sử dụng thuốc trong điều trị rối loạn lipid huyết (tiếp theo)
- Bài 19: Sử dụng thuốc trong điều trị suy tim mạn tính
- Bài 20: Sử dụng thuốc trong điều trị suy tim mạn tính (tiếp theo)

#### Sử dụng thuốc trong điều trị các bệnh huyết học (2 bài)

- Bài 21: Xét nghiệm huyết học
- Bài 22: Sử dụng thuốc trong điều trị thiếu máu

#### Sử dụng thuốc trong điều trị bệnh lý nội tiết (4 bài)

- Bài 23: Sử dụng thuốc trong điều trị đái tháo đường
- Bài 24: Sử dụng thuốc trong điều trị đái tháo đường (tiếp theo)
- Bài 25: Sử dụng thuốc trong điều trị đái tháo đường (tiếp theo)
- Bài 26: Sử dụng thuốc trong điều trị bệnh thận mạn

#### Sử dụng thuốc trong điều trị bệnh lý hô hấp (2 bài)

- Bài 27: Sử dụng thuốc trong điều trị hen phế quản
- Bài 28: Sử dụng thuốc trong điều trị COPD

#### Sử dụng thuốc trong điều trị bệnh lý thần kinh – tâm thần (4 bài)

- Bài 29: Sử dụng thuốc trong điều trị Parkinson
- Bài 30: Sử dụng thuốc trong điều trị Parkinson (tiếp theo)
- Bài 31: Sử dụng thuốc trong điều trị trầm cảm
- Bài 32: Sử dụng thuốc trong điều trị mất ngủ

#### Sử dụng thuốc trong điều trị bệnh lý xương khớp (2 bài)

- Bài 33: Sử dụng thuốc trong điều trị gout và tăng acid uric máu
- Bài 34: Sử dụng thuốc trong điều trị loãng xương

#### Sử dụng thuốc trong quản lý đau

- Bài 35: Sử dụng thuốc trong điều trị đau

#### Sử dụng thuốc trong điều trị các bệnh lý nhiễm khuẩn (6 bài)

- Bài 36: Nguyên tắc SD KS hợp lý - Tối ưu hoá thông số PK/PD trong điều trị KS
- Bài 37: Sử dụng kháng sinh trong điều trị viêm phổi
- Bài 38: Sử dụng kháng sinh trong điều trị nhiễm khuẩn tiết niệu
- Bài 39: Sử dụng KS trong điều trị các chủng vi khuẩn kháng thuốc
- Bài 40: Sử dụng KS trong điều trị các chủng vi khuẩn kháng thuốc (tiếp theo)
- Bài 41: Thi thử

<a id="khoa-201"></a>

### 56. \[Giải Phẫu - Nội Trú\] Cơ Bản -&gt; Chuyên Sâu (ID 201)

**Trạng thái:** Đang bật · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-202"></a>

### 57. \[Nhi Khoa Bệnh Lý\] Cơ Bản -&gt; Chuyên Sâu (ID 202)

**Trạng thái:** Đã tắt · **Chương:** 0 · **Bài học:** 0

_Chưa có chương hoặc bài học có tên trong bản dump._

<a id="khoa-203"></a>

### 58. Giải Phẫu Bệnh(Cơ Bản -&gt; Chuyên Sâu) (ID 203)

**Trạng thái:** Đang bật · **Chương:** 2 · **Bài học:** 25

#### Chương 1: Bệnh Học Đại Cương

- Bài 1: Giới Thiệu Môn Học Giải Phẫu Bệnh
- Bài 2: Tổn Thương Cơ Bản Của Tế Bào - Mô
- Bài 3: Giải Phẫu Bệnh Về Viêm Và Sửa Chữa
- Bài 4: Tổn thương do rối loạn tuần hoàn (Huyết Quản - Huyết)
- Bài 5: Bệnh Lý U
- Bài 6: Ung Thư

#### Chương 2: Bệnh Học Tạng Và Hệ Thống

- Bài 7: Bệnh Lý Phổi - Màng Phổi P1
- Bài 8: Bệnh Lý Phổi - Màng Phổi P2
- Bài 9: Bệnh Lý Ống Tiêu Hóa P1
- Bài 10 : Bệnh Lý Ống Tiêu Hóa P2
- Bài 11: Bệnh Lý Gan
- Bài 12: Bệnh Lý Thận P1
- Bài 13: Bệnh Lý Thận P2
- Bài 14: Bệnh Lý Tuyến Vú
- Bài 15: Bệnh Lý Hệ Sinh Dục Nữ - Khoang P1
- Bài 16: Bệnh Lý Hệ Sinh Dục Nữ - Khoang P2
- Bài 17: Bệnh Lý Xương Và Mô Mềm P1
- Bài 18: Bệnh Lý Xương Và Mô Mềm P2
- BT Bệnh Hạch Và Lympho website
- BT Bệnh Hệ Thần Kinh website
- BT Viêm website
- BT Bệnh Mật website
- BT Bệnh Bàng Quang website
- BT Bệnh Tuyến Giáp website
- BT Ôn Tập Cuối Khoá website

<a id="khoa-204"></a>

### 59. Vi Sinh (Cơ Bản -&gt; Chuyên Sâu) (ID 204)

**Trạng thái:** Đang bật · **Chương:** 3 · **Bài học:** 20

#### CHƯƠNG 1 — Đại cương Vi sinh &amp; Nền tảng

- Bài 1: Lịch sử ngành Vi sinh
- Bài 2: Di truyền vi khuẩn, Kháng sinh và đề kháng kháng sinh
- Bài 3: Đại Cương virus
- Bài 4: Đại Cương Vi Khuẩn

#### CHƯƠNG 2 — Vi khuẩn điển hình gây bệnh (Gram +, Gram −, không điển hình)

- Bài 5: Các cầu khuẩn gây bệnh
- Bài 6: Vi khuẩn đường ruột
- Bài 7: Vi khuẩn dịch hạch
- Bài 8: Bạch hầu
- Bài 9: Trực Khuẩn
- Bài 10: Xoắn khuẩn
- Bài 11: Rickettsia – Mycoplasma – Chlamydia

#### CHƯƠNG 3 — Virus

- Bài 12: Enterovirus – Cúm
- Bài 13: Dengue, Zika, viêm não Nhật Bản
- Bài 14: Các virus viêm gan– huyết thanh học chẩn đoán
- Bài 15: SARS-CoV-2 và các coronavirus khác
- Bài 16: Các nhiễm trùng mới nổi và tái nổi
- Bài 17: Virus HIV/AIDS và các retrovirus khác
- Bài 18: Tổng ôn tập đại cương
- Bài 19: Tổng ôn tập các khuẩn
- Bài 20: Ôn Tập Cuối Khoá

<a id="khoa-206"></a>

### 60. \[Nội Cơ Sở\] Cơ Bản -&gt; Chuyên Sâu (ID 206)

**Trạng thái:** Đang bật · **Chương:** 6 · **Bài học:** 38

#### CHƯƠNG I: TIM MẠCH (8 Buổi)

- Bài 1: Bệnh án nội khoa
- Bài 2: Triệu chứng cơ năng tim mạch 1
- Bài 3: Triệu chứng cơ năng tim mạch 2
- Bài 4: Khám tim 1
- Bài 5: Khám tim 2
- Bài 6: Hội chứng suy tim
- Bài 7: Cận lâm sàng tim mạch
- Bài 8: Ôn tập chương tim mạch

#### CHƯƠNG II: HÔ HẤP (7 buổi)

- Bài 9: Triệu chứng cơ năng hô hấp 1
- Bài 10: Triệu chứng cơ năng hô hấp 2
- Bài 11: Khám phổi 1
- Bài 12: Khám phổi 2
- Bài 13: Các hội chứng lâm sàng hô hấp
- Bài 14: Xét nghiệm cận lâm sàng hô hấp
- Bài 15: Ôn tập chương hô hấp

#### CHƯƠNG III: TIÊU HOÁ (8 buổi)

- Bài 16: Triệu chứng cơ năng tiêu hoá 1
- Bài 17: Triệu chứng cơ năng tiêu hoá 2
- Bài 18: Khám bụng
- Bài 19: Hội chứng vàng da
- Bài 20: Cổ trướng
- Bài 21: Xuất huyết tiêu hoá
- Bài 22: Xét nghiệm chức năng gan
- Bài 23: Ôn tập chương tiêu hoá

#### CHƯƠNG IV: TIẾT NIỆU (5 buổi)

- Bài 24: Triệu chứng cơ năng tiết niệu
- Bài 25: Khám thận tiết niệu
- Bài 26: Một số hội chứng trong bệnh thận
- Bài 27: Các xét nghiệm chẩn đoán bệnh thận
- Bài 28: Ôn tập chương tiết niệu

#### CHƯƠNG V: THẦN KINH HỌC (5 buổi)

- Bài 29: Khám các dây thần kinh sọ não
- Bài 30: Khám chức năng vận động
- Bài 31: Khám cảm giác, phản xạ
- Bài 32: Một số hội chứng thần kinh thường gặp
- Bài 33: Ôn tập chương thần kinh

#### CHƯƠNG VI: MÁU VÀ CƠ QUAN TẠO MÁU (5 buổi)

- Bài 34: Triệu chứng cơ năng bệnh máu và cơ quan tạo máu
- Bài 35: Hội chứng thiếu máu, xuất huyết
- Bài 36: Hội chứng lách to, hạch to
- Bài 37: Các xét nghiệm thường dùng trong huyết học
- Bài 38: Ôn tập chương máu và cơ quan tạo máu

<a id="khoa-215"></a>

### 61. Hoá Học \[Cơ Bản -&gt; Chuyên Sâu\] (ID 215)

**Trạng thái:** Đang bật · **Chương:** 0 · **Bài học:** 24

**Bài chưa xếp chương:**

- Bài 1: Cấu Tạo Nguyên Tử Và Liên Kết hoá Học
- Bài 2: Chữa Đề Trắc Nghiệm Cấu Tạo - Liên Kết
- Bài 3: Protid
- Bài 4: Chữa Đề Trắc Nghiệm Protid
- Bài 5: Lipid
- Bài 6: Chữa Đề Trắc Nghiệm Lipid
- Bài 7: Glucid
- Bài 8: Chữa Đề Trắc Nghiệm Glucid
- Bài 9: Ôn Tập Cấu Tạo - P - L - G
- Bài 10: Đại cương dung dịch và dung dịch keo
- Bài 11: Chữa Đề Trắc Nghiệm Dung Dịch
- Bài 12: Dị Vòng Và Vitamin
- Bài 13: Chữa Đề Trắc Nghiệm Dị Vòng - Vitamin
- Bài 14: Dung dịch chất điện ly và dung dịch đệm
- Bài 15: Chữa Đề Trắc Nghiệm Dung Dịch Chất Điện Ly - Đệm
- Bài 16: Ôn Tập Giữa Kì
- Bài 17: Nhiệt động học và động hoá học
- Bài 18: Chữa Đề Trắc Nghiệm Nhiệt Động Học và Động Hóa Học
- Bài 19: Điện Hoá Học
- Bài 20: Chữa Đề Trắc Nghiệm Điện Hoá Học
- Bài 21: Chữa Đề Trắc Nghiệm Điện Hoá Học
- Bài 22: Nguyên Tố Vi Lượng - Kim Loại Nặng
- Bài 23: Chữa Đề Trắc Nghiệm Nguyên Tố Vi Lượng - Kim Loại Nặng
- Bài 24: Ôn Tập Cuối kì

<a id="khoa-219"></a>

### 62. Tiền Lâm Sàng \[ Cơ Bản -&gt; Chuyên Sâu\] (ID 219)

**Trạng thái:** Đang bật · **Chương:** 0 · **Bài học:** 24

**Bài chưa xếp chương:**

- Kỹ năng giao tiếp giữa thầy thuốc và người bệnh
- Khai thác tiền sử và bệnh sử
- Khám tổng quát
- Kỹ thuật trình bày bệnh án cơ bản và bệnh án điện tử
- Kỹ năng làm việc nhóm
- Khám phổi
- Khám tim
- Khám bụng tổng quát, khám gan, khám lách, khám thận
- Khám hạch và tuyến giáp
- Khám mạch máu ngoại biên
- Thăm khám hậu môn - trực tràng
- Khám thận tiết niệu - dục nam
- Khám sọ não trong chấn thương sọ não
- Khám trương lực cơ và phản xạ gân xương và khám cột sống
- Khám vận động khớp gối
- Khám vận động khớp vai
- Kỹ thuật đo dấu hiệu sinh tồn
- Kỹ thuật tiêm
- Kỹ thuật đặt ống thông dạ dày
- Kỹ thuật đặt ống thông tiểu
- Kỹ thuật thay băng rửa vết thương
- Kỹ thuật truyền dịch
- Hồi sức tim phổi cơ bản
- Chọc dịch màng phổi - màng bụng

<a id="khoa-220"></a>

### 63. Ngoại Cơ Sở - Ngoại Triệu Chứng \[Cơ Bản -&gt; Chuyên Sâu\] (ID 220)

**Trạng thái:** Đang bật · **Chương:** 5 · **Bài học:** 25

#### Chương 1: Ngoại tiêu hóa

- Khám bụng ngoại khoa
- Hội chứng tắc ruột
- Hội chứng viêm phúc mạc
- Khám hậu môn trực tràng
- Hội chứng vàng da tắc mật
- Hội chứng chảy máu trong

#### Chương 2: Ngoại thần kinh

- Hội chứng chèn ép tủy
- Khám dây thần kinh ngoại biên
- Hội chứng chèn ép rễ thần kinh thắt lưng cùng
- Khám bệnh nhân chấn thương sọ não
- Hội chứng tăng áp lực nội sọ
- Khám cột sống

#### chương 3: Ngoại chấn thương chỉnh hình

- Triệu chứng học nhọt, áp xe, hậu bối, chín mé
- Triệu chứng học về bỏng
- Triệu chứng trật khớp
- Biến chứng của gãy xương
- Triệu chứng gãy xương

#### Chương 4: Ngoại lồng ngực mạch máu

- Thăm khám triệu chứng học chấn thương vết thương ngực
- Thăm khám triệu chứng học chấn thương mạch máu ngoại biên
- Khám tuyến giáp
- Hội chứng tắc mạch chi

#### Chương 5: Ngoại tiết niệu

- Triệu chứng lâm sàng hệ tiết niệu
- Khám lâm sàng hệ tiết niệu sinh dục
- Hội chứng đường tiểu dưới
- Ôn Tâp Cuối Kì
