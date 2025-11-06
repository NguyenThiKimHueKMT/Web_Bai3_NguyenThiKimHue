// web/js/app.js
let cart = JSON.parse(localStorage.getItem('cart')) || [];

const token = getCookie('token');

async function api(url, method = 'GET', body = null) {
  const headers = { 'Authorization': `Bearer ${token}` };
  if (body) headers['Content-Type'] = 'application/json';
  const res = await fetch(url, { method, headers, body: body ? JSON.stringify(body) : null });
  return await res.json();
}

async function initApp() {
  const user = await api('/api/me');
  if (!user.id) return logout();

  document.getElementById('app').innerHTML = `
    <h1>Xin chào, ${user.username}!</h1>
    <button onclick="logout()">Đăng xuất</button>
    <button onclick="showHome()">Trang chủ</button>
    <button onclick="showCart()">Giỏ hàng (${cart.length})</button>
    ${user.role === 'admin' ? '<button onclick="showAdmin()">Admin</button>' : ''}
    <div id="content"></div>
  `;
  showHome();
}

async function showHome() {
  const products = await api('/api/products');
  const cats = await api('/api/categories');
  document.getElementById('content').innerHTML = `
    <h2>Sản phẩm bán chạy</h2>
    <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:15px;">
      ${products.map(p => `
        <div style="border:1px solid #ddd;padding:15px;border-radius:8px;background:white;">
          <h3>${p.name}</h3>
          <p><strong>${p.price.toLocaleString()}đ</strong></p>
          <button onclick="addToCart(${p.id}, '${p.name}', ${p.price})">Thêm vào giỏ</button>
        </div>
      `).join('')}
    </div>
    <h2 class="mt-20">Danh mục</h2>
    ${cats.map(c => `<button onclick="loadByCat(${c.id})">${c.name}</button>`).join(' ')}
  `;
}

async function loadByCat(catId) {
  const products = await api(`/api/products?cat=${catId}`);
  // Render tương tự showHome
  alert('Sản phẩm theo danh mục: ' + catId);
}

function addToCart(id, name, price) {
  const item = cart.find(i => i.id === id);
  if (item) item.qty++;
  else cart.push({ id, name, price, qty: 1 });
  localStorage.setItem('cart', JSON.stringify(cart));
  alert('Đã thêm: ' + name);
}

function showCart() {
  const total = cart.reduce((s, i) => s + i.price * i.qty, 0);
  document.getElementById('content').innerHTML = `
    <h2>Giỏ hàng</h2>
    ${cart.length === 0 ? '<p>Trống</p>' : `
      ${cart.map(item => `
        <div style="border-bottom:1px solid #eee;padding:10px;">
          ${item.name} x ${item.qty} = ${(item.price * item.qty).toLocaleString()}đ
          <button onclick="removeFromCart(${item.id})">Xóa</button>
        </div>
      `).join('')}
      <h3>Tổng: ${total.toLocaleString()}đ</h3>
      <button onclick="placeOrder()">Đặt hàng</button>
    `}
  `;
}

function removeFromCart(id) {
  cart = cart.filter(i => i.id !== id);
  localStorage.setItem('cart', JSON.stringify(cart));
  showCart();
}

async function placeOrder() {
  const info = prompt('Thông tin giao hàng (Tên, Địa chỉ, SĐT):');
  if (!info || cart.length === 0) return alert('Không hợp lệ!');
  const res = await api('/api/order', 'POST', { info, items: cart });
  if (res.success) {
    cart = []; localStorage.setItem('cart', '[]');
    alert('Đặt hàng thành công! ID: ' + res.orderId);
    showHome();
  }
}

async function showAdmin() {
  const orders = await api('/api/admin/orders');
  document.getElementById('content').innerHTML = `
    <h2>Quản lý đơn hàng</h2>
    <table border="1" width="100%">
      <tr><th>ID</th><th>Khách</th><th>Tổng</th><th>Trạng thái</th><th>Hành động</th></tr>
      ${orders.map(o => `
        <tr>
          <td>${o.id}</td>
          <td>${o.shipping_info}</td>
          <td>${o.total_price}</td>
          <td>${o.status}</td>
          <td>
            <button onclick="updateStatus(${o.id}, 'confirmed')">Xác nhận</button>
            <button onclick="updateStatus(${o.id}, 'shipped')">Gửi hàng</button>
          </td>
        </tr>
      `).join('')}
    </table>
    <h2>Xem thống kê: <a href="/grafana" target="_blank">Grafana</a></h2>
  `;
}

async function updateStatus(id, status) {
  await api(`/api/admin/order/${id}`, 'PUT', { status });
  showAdmin();
}

// Khởi động
if (token) initApp();
else showLogin();