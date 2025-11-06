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
<img width="1087" height="498" alt="image" src="https://github.com/user-attachments/assets/a9a1a164-a3cd-46cb-8f40-bb94539b4a69" />  
**CẤU HÌNH DOCKER-COMPOSE**   
Tạo file docker-compose.yml:  
version: '3.8'

services:
  mariadb:
    image: mariadb:10.11
    container_name: mariadb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: BanHang
      MYSQL_USER: khiem
      MYSQL_PASSWORD: khiem123
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
      --functionGlobalContext.mysql=require('mysql').createPool({host:'mariadb',user:'khiem',password:'khiem123',database:'BanHang',port:3306,charset:'utf8mb4',connectionLimit:10})
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
      - GF_SERVER_ROOT_URL=http://nguyennhukhiem.com/grafana
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






