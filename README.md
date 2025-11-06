# Web_Bai3_NguyenThiKimHue  

### BÀI TẬP 3 - PHÁT TRIỂN ỨNG DỤNG TRÊN NỀN WEB  
--------------------------------------------------
Giảng viên: Đỗ Duy Cốp   
Lớp học phần: 58KTP  
Sinh viên thực hiện: Nguyễn Thị Kim Huệ   
Chủ đề: Lập trình ứng dụng web thương mại điện tử trên nền Linux (Docker + Hyper-V + Ubuntu)  

**## YÊU CẦU BÀI TOÁN**
1. Cài đặt môi trường linux
 - enable wsl: cài đặt docker desktop
 - enable wsl: cài đặt ubuntu
2. Cài đặt Docker (nếu dùng docker desktop trên windows thì nó có ngay)
3. Sử dụng 1 file docker-compose.yml để cài đặt các docker container sau: 
   mariadb (3306), phpmyadmin (8080), nodered/node-red (1880), influxdb (8086), grafana/grafana (3000), nginx (80,443)
4. Lập trình web frontend+backend:
 4.1 Web thương mại điện tử
 - Tạo web dạng Single Page Application (SPA), chỉ gồm 1 file index.html, toàn bộ giao diện do javascript sinh động.
 - Có tính năng login, lưu phiên đăng nhập vào cookie và session
   Thông tin login lưu trong cơ sở dữ liệu của mariadb, được dev quản trị bằng phpmyadmin, yêu cầu sử dụng mã hoá khi gửi login.
   Chỉ cần login 1 lần, bao giờ logout thì mới phải login lại.
 - Có tính năng liệt kê các sản phẩm bán chạy ra trang chủ
 - Có tính năng liệt kê các nhóm sản phẩm
 - Có tính năng liệt kê sản phẩm theo nhóm
 - Có tính năng tìm kiếm sản phẩm
 - Có tính năng chọn sản phẩm (đưa sản phẩm vào giỏ hàng, thay đổi số lượng sản phẩm trong giỏ, cập nhật tổng tiền)
 - Có tính năng đặt hàng, nhập thông tin giao hàng => được 1 đơn hàng.
 - Có tính năng dành cho admin: Thống kê xem có bao nhiêu đơn hàng, call để xác nhận và cập nhật thông tin đơn hàng. chuyển cho bộ phận đóng gói, gửi bưu điện, cập nhật mã COD, tình trạng giao hàng, huỷ hàng,...
 - Có tính năng dành cho admin: biểu đồ thống kê số lượng mặt hàng bán được trong từng ngày. (sử dụng grafana)
 - backend: sử dụng nodered xử lý request gửi lên từ javascript, phản hồi về json.
5. Nginx làm web-server
 - Cấu hình nginx để chạy được website qua url http://fullname.com  (thay fullname bằng chuỗi ko dấu viết liền tên của bạn)
 - Cấu hình nginx để http://fullname.com/nodered truy cập vào nodered qua cổng 80, (dù nodered đang chạy ở port 1880)
 - Cấu hình nginx để http://fullname.com/grafana truy cập vào grafana qua cổng 80, (dù grafana đang chạy ở port 3000)

**### BÀI LÀM**    
**BƯỚC 1: LỰA CHỌN & CÀI ĐẶT MÔI TRƯỜNG LINUX**  
Dùng máy ảo Ubuntu với Docker cài trực tiếp.  

**BƯỚC 2: CÀI ĐẶT DOCKER & DOCKER COMPOSE**  
**Kiểm tra Docker Desktop đã cài và đang chạy**
Mở Docker Desktop:
Nhấn Windows → nhập “Docker Desktop” → Nhấn Enter mở ứng dụng.  
**Kiểm tra Docker trong Ubuntu WSL**
Mở Ubuntu (WSL):
  Nhấn Windows → nhập “Ubuntu” → Nhấn Enter.
Kiểm tra phiên bản Docker:
Gõ lệnh trong cửa sổ Ubuntu:docker --version  
Kiểm tra docker compose  
Gõ lệnh: docker compose version  
Kiểm tra thử Docker bằng ví dụ Hello World   
Trong Ubuntu gõ:docker run --rm hello-world  





<img width="1473" height="760" alt="image" src="https://github.com/user-attachments/assets/61054318-98be-4b48-99ea-ff7ead152bf3" />   

TRUY CẬP VÀ KIỂM TRA  
phpMyAdmin (quản trị CSDL):
Truy cập http://localhost:8080
User: root
Password: yourpassword
<img width="1907" height="1029" alt="image" src="https://github.com/user-attachments/assets/2a627661-a607-4b16-9111-91e4612af414" />   

<img width="1911" height="952" alt="image" src="https://github.com/user-attachments/assets/ddb4bddc-4bb2-4ad4-b374-1e03b654bb2b" />  

<img width="1226" height="762" alt="image" src="https://github.com/user-attachments/assets/a39fdfa5-9fb5-45d7-a6f2-7355dc8010ce" />  
Tạo data iotweb 
<img width="1902" height="964" alt="image" src="https://github.com/user-attachments/assets/18730e72-e115-46b1-bcbb-938295ca959e" />  

<img width="1912" height="951" alt="image" src="https://github.com/user-attachments/assets/9b8e5e34-3a78-4426-b5e6-5c5ce6445a43" />  






