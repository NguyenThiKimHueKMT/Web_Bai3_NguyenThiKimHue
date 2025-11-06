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

**## BÀI LÀM**    
**LỰA CHỌN & CÀI ĐẶT MÔI TRƯỜNG LINUX**  
Dùng máy ảo Ubuntu với Docker cài trực tiếp.  

**CÀI ĐẶT DOCKER & DOCKER COMPOSE**  
**Kiểm tra Docker Desktop đã cài và đang chạy**
Mở Docker Desktop:
Nhấn Windows → nhập “Docker Desktop” → Nhấn Enter mở ứng dụng.  
**Kiểm tra Docker trong Ubuntu WSL**
Mở Ubuntu (WSL):
  Nhấn Windows → nhập “Ubuntu” → Nhấn Enter.
Kiểm tra phiên bản Docker:
Gõ lệnh trong cửa sổ Ubuntu:`docker --version ` 
Kiểm tra docker compose  
Gõ lệnh:` docker compose version`  
Kiểm tra thử Docker bằng ví dụ Hello World   
Trong Ubuntu gõ:`docker run --rm hello-world `  
<img width="1087" height="498" alt="image" src="https://github.com/user-attachments/assets/a9a1a164-a3cd-46cb-8f40-bb94539b4a69" />  
**CẤU HÌNH DOCKER-COMPOSE**   
Tạo file docker-compose.yml:  
```
version: '3.8'

services:  
  mariadb: 
    image: mariadb:10.11  
    container_name: mariadb  
    restart: always  
    environment: 
      MYSQL_ROOT_PASSWORD: root123`  
      MYSQL_DATABASE: ShopSach 
      MYSQL_USER: hue  
     MYSQL_PASSWORD: hue123  
    ports:  
     - "3306:3306" 
    volumes:  
      - ./mariadb/data:/var/lib/mysql  
    networks:  
      - ecommerce-network  
  
  phpmyadmin:  
    image: phpmyadmin:latest   
    container_name: phpmyadmin  
    restart: always  
    environment:  
      PMA_HOST: mariadb  
      PMA_PORT: 3306  
      MYSQL_ROOT_PASSWORD: root123  
    ports:  
      - "8080:80" 
    depends_on:  
      - mariadb  
    networks: 
      - ecommerce-network 
  
  nodered:  
    image: nodered/node-red:latest 
    container_name: nodered 
    restart: always  
    environment: 
      - TZ=Asia/Ho_Chi_Minh  
    ports:  
      - "1880:1880" 
    volumes:  
      - ./node-red/data:/data  
    user: "1000:1000"  
   depends_on:  
      - mariadb  
      - influxdb  
    networks:  
      - ecommerce-network  
    command: >  
      sh -c "  
      npm install -g node-red-node-mysql &&  
      node-red  
      --httpNodeRoot=/api 
      --httpAdminRoot=/nodered  
      --functionGlobalContext.mysql=require('mysql').createPool({host:'mariadb',user:'hue',password:'hue123',database:'ShopSach',port:3306,charset:'utf8mb4',connectionLimit:10}) 
      --functionGlobalContext.crypto=require('crypto') 
      "

  influxdb:  
    image: influxdb:2.7  
    container_name: influxdb  
    restart: always  
    environment:  
      - DOCKER_INFLUXDB_INIT_MODE=setup  
      - DOCKER_INFLUXDB_INIT_USERNAME=admin  
      - DOCKER_INFLUXDB_INIT_PASSWORD=admin123  
      - DOCKER_INFLUXDB_INIT_ORG=ecommerce  
      - DOCKER_INFLUXDB_INIT_BUCKET=statistics  
      - DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-super-secret-auth-token  
    ports:  
      - "8086:8086" 
    volumes:  
      - ./influxdb/data:/var/lib/influxdb2  
    networks:  
      - ecommerce-network  

  grafana:  
      image: grafana/grafana:latest  
      container_name: grafana  
      restart: always  
      environment:  
        - GF_SERVER_HTTP_PORT=3000  
        - GF_SERVER_ROOT_URL=http://nguyenthikimhue.com/grafana  
        - GF_SERVER_SERVE_FROM_SUB_PATH=true  
        - GF_SECURITY_ADMIN_USER=admin  
        - GF_SECURITY_ADMIN_PASSWORD=admin123  
      ports:  
        - "3000:3000"  
      volumes:  
       - ./grafana/data:/var/lib/grafana  
      depends_on:  
        - influxdb  
      networks:  
        - ecommerce-network  
  
  nginx:  
   image: nginx:latest  
    container_name: nginx  
    restart: always  
    ports:  
      - "80:80"  
      - "443:443"  
    volumes:  
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro  
      - ./nginx/certs:/etc/nginx/certs:ro  
      - ./web:/usr/share/nginx/html:ro  
    depends_on:  
      - nodered  
      - grafana  
    networks:  
      - ecommerce-network  
  
networks:  
  ecommerce-network:  
  driver: bridge
```

*Chạy  container*
docker compose up -d~





**CẤU HÌNH NGINX**
File nginx/default.conf:
```
erver {  
    listen 80;  
    server_name nguyenthikimhue.com www.nguyenthikimhue.com;  
    
    # === Gốc: SPA Frontend ===  
    location / {  
        root /usr/share/nginx/html;  
        index index.html;  
        try_files $uri $uri/ /index.html;  
  
        # Cache static assets  
        location ~* \.(js|css|png|jpg|jpeg|gif|svg|ico|woff2?|ttf|eot)$ {  
            expires 1y;  
            add_header Cache-Control "public, immutable";  
        }  
    }  

    # === API Backend (Node-RED) ===  
    location /api/ {  
        proxy_pass http://nodered:1880/;  
        proxy_http_version 1.1;  
        proxy_set_header Host $host;  
        proxy_set_header X-Real-IP $remote_addr;  
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        proxy_set_header X-Forwarded-Proto $scheme;  
    }  
  
        # === API User Orders (Node-RED) ===  
    location /user/ {  
        proxy_pass http://nodered:1880/;  
        proxy_http_version 1.1;  
        proxy_set_header Host $host;  
        proxy_set_header X-Real-IP $remote_addr;  
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        proxy_set_header X-Forwarded-Proto $scheme;  
    }  
  
    # === Node-RED UI (Subpath) ===  
    location ^~ /nodered/ {  
        proxy_pass http://nodered:1880/;  
        proxy_http_version 1.1;  
        proxy_set_header Upgrade $http_upgrade;  
        proxy_set_header Connection "upgrade";  
        proxy_set_header Host $host;  
        proxy_set_header X-Real-IP $remote_addr;  
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        proxy_set_header X-Forwarded-Proto $scheme;  
  
        # Fix tài nguyên tĩnh (CSS/JS) cho subpath  
        sub_filter_once off;  
        sub_filter 'href="/'  'href="/nodered/';  
        sub_filter 'src="/'   'src="/nodered/';  
        sub_filter 'action="/' 'action="/nodered/';  
        sub_filter_types text/css text/javascript text/xml application/javascript;  
        proxy_set_header Accept-Encoding "";  
    }  
  
    # === Grafana (Subpath) ===  
    location ^~ /grafana/ {  
        proxy_pass http://grafana:3000;  
        proxy_http_version 1.1;  
          
        proxy_set_header Host $host;  
        proxy_set_header X-Real-IP $remote_addr;  
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        proxy_set_header X-Forwarded-Proto $scheme;  
        
        proxy_set_header Upgrade $http_upgrade;  
        proxy_set_header Connection "upgrade";  
    }  
   
    # === Bảo mật Header ===  
    add_header X-Frame-Options "SAMEORIGIN" always;  
    add_header X-Content-Type-Options "nosniff" always;  
    add_header X-XSS-Protection "1; mode=block" always;  
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;  
   
    # === 404 Fallback cho SPA ===  
    error_page 404 /index.html;  
}
```

**Website chính:**  http://nguyenthikimhue.com  
**Node-RED:**  http://nguyenthikimhue.com/nodered    
**Grafana:**  http://nguyenthikimhue.com/grafana  


**FRONTEND (index.html + script.js)**  
**Các chức năng:**
Login (mã hóa mật khẩu bằng SHA-256)  
Hiển thị danh sách sản phẩm bán chạy  
Thêm sản phẩm vào giỏ hàng  
Thanh toán, lưu đơn hàng vào MariaDB  
**Trang Admin:**
Xem danh sách đơn hàng  
Thống kê doanh thu (iframe Grafana)  

TRUY CẬP VÀ KIỂM TRA  
phpMyAdmin (quản trị CSDL):
Truy cập http://192.168.2.34:8080
<img width="1907" height="1029" alt="image" src="https://github.com/user-attachments/assets/2a627661-a607-4b16-9111-91e4612af414" />  

PhpMyAdmin chạy tại http://172.25.128.100:8080/  
<img width="1914" height="1029" alt="Ảnh chụp màn hình 2025-11-06 085945" src="https://github.com/user-attachments/assets/417b1123-4bca-4833-b577-9d02cda7e95d" />  

  InfluxDB chạy tại http://172.25.128.100:8086/   
  <img width="1903" height="1026" alt="Ảnh chụp màn hình 2025-11-06 085925" src="https://github.com/user-attachments/assets/1f00bcfe-9939-40e5-8f3f-76189a95b669" />   

  Website chính: http://nguyenthikimhue.com  
<img width="1851" height="979" alt="image" src="https://github.com/user-attachments/assets/07d80b06-a147-43d4-9bea-817002390a93" />   

  Node-RED: http://nguyenthikimhue.com/nodered  
Cấu hình file settings.js để nodered yêu cầu đăng nhập  
 Tiếp theo chạy Node_RED  
 <img width="606" height="335" alt="Ảnh chụp màn hình 2025-10-25 125027" src="https://github.com/user-attachments/assets/92589ea2-44e4-4da5-bd14-efc8254dfbc7" />   

 **MariaDB**  
 <img width="1910" height="973" alt="image" src="https://github.com/user-attachments/assets/5448789f-a98a-48cd-9efe-4900b66663e5" />   

 **Cơ sở dữ liệu: ShopSach**  
 Danh sách bảng và vai trò  
1. NguoiDung  
Vai trò: Lưu thông tin người dùng của hệ thống (bao gồm cả admin và khách hàng).  
Các cột chính:  
ten_dang_nhap: Tên đăng nhập 
mat_khau: Mật khẩu đã mã hóa  
ho_ten, email, dien_thoai  
la_admin: Xác định người quản trị (1) hay khách hàng (0)  
 
2. DonHang  
Vai trò: Lưu thông tin các đơn hàng của người dùng.  
Các cột chính:  
nguoi_dung_id: Khách hàng đặt hàng    
tong_tien: Tổng giá trị đơn hàng
trang_thai: Trạng thái đơn (chờ, đang giao, đã giao, huỷ, …)  
ten_nguoi_nhan, dia_chi_giao, dien_thoai_nguoi_nhan  
ngay_tao, ngay_cap_nhat  

3. ChiTietDonHang  
Vai trò: Lưu chi tiết từng sản phẩm trong đơn hàng (liên kết nhiều–nhiều giữa DonHang và SanPham).  
Các cột chính:  
don_hang_id: Đơn hàng chứa sản phẩm  
san_pham_id: Sản phẩm trong đơn  
so_luong: Số lượng mua  
gia_luc_mua: Giá tại thời điểm đặt hàng  

4.  SanPham  
Vai trò: Lưu thông tin chi tiết về sản phẩm.  
Các cột chính:  
ten_san_pham, nhom_id, gia_ban, gia_cu, ton_kho, mo_ta, anh  
la_ban_chay, so_luot_mua, diem_trung_binh  

5.  NhomSanPham  
Vai trò: Quản lý phân loại sản phẩm (nhóm danh mục).  
Các cột chính:  
ten_nhom, mo_ta, id

**NODE-RED BACKEND**  
Các flow chính:  
1. Đăng Nhập : API /login – Xác thực người dùng  
curl -X POST http://nguyenthikimhue.com/api/login
<img width="1565" height="278" alt="image" src="https://github.com/user-attachments/assets/fc92ff81-d6ef-4067-b267-56aa8d45e116" />

**NODE-RED BACKEND**  
Các flow chính:  
1. Đăng Nhập : API /login – Xác thực người dùng  
curl -X POST http://nguyenthikimhue.com/api/login
<img width="1218" height="172" alt="image" src="https://github.com/user-attachments/assets/b98c51da-4a23-49a5-920e-a12a8ece998b" />
 
 Sản phẩm bán chạy  
curl http://nguyenthikimhue.com/api/san-pham-ban-chay  
<img width="887" height="94" alt="image" src="https://github.com/user-attachments/assets/5a0b8d72-0c03-4fff-9f06-fa3d895ac917" /> 
**Test APT**  
<img width="1162" height="817" alt="image" src="https://github.com/user-attachments/assets/f32be120-a040-4af7-a790-e133d167d788" />

Nhóm sản phẩm  
curl http://nguyenthikimhue.com/api/nhom-san-pham   
<img width="868" height="113" alt="image" src="https://github.com/user-attachments/assets/ca668743-4967-4fe8-8184-301f7ab79fca" />   
**Test API**  
<img width="976" height="787" alt="image" src="https://github.com/user-attachments/assets/c5df18b7-4d1a-4347-b2f4-dd827f33be69" />  

 Sản phẩm theo nhóm   
curl http://nguyenthikimhue.com/api/san-pham?nhom=1  
<img width="887" height="151" alt="image" src="https://github.com/user-attachments/assets/6b43a6f7-8510-4e13-9d74-9e383cc0e836" /> 
**Test API**  
<img width="970" height="486" alt="image" src="https://github.com/user-attachments/assets/db7f3301-372d-4dd9-9ee1-c1c8fe4c1239" />  

Tìm kiếm  
curl http://nguyenthikimhue.com/api/tim-kiem?q=sach  
<img width="847" height="153" alt="image" src="https://github.com/user-attachments/assets/954dca6f-f755-4710-ab90-9530366d9b13" />   
**Test API**  
<img width="890" height="702" alt="image" src="https://github.com/user-attachments/assets/edc1b0b2-a9cc-40a2-8cd7-32602e892e42" />








  








