<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- ====================== CSS CHO SIGNUP DARK THEME ====================== -->
<style>
.modal.signup-modal {
    display: none; position: fixed; z-index: 1000;
    left: 0; top: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.9);
    backdrop-filter: blur(10px);
}
.modal.signup-modal.show {
    display: flex; justify-content: center; align-items: center;
}
.modal-content-signup {
    background: #252525;
    padding: 35px 40px; border-radius: 18px; width: 500px;
    max-width: 95%;
    color: #fff; backdrop-filter: blur(25px);
    box-shadow: 0 20px 60px rgba(0,0,0,0.9);
    border: 1px solid #333;
    animation: fadeIn 0.3s ease-out;
    max-height: 90vh;
    overflow-y: auto;
}

.modal-content-signup input,
.modal-content-signup select {
    width: 100%; padding: 12px; margin: 8px 0 12px 0;
    border-radius: 8px; border: 1px solid #333;
    background: #1a1a1a;
    color: #fff; font-size: 14px;
    transition: all 0.3s;
}

.modal-content-signup input:focus,
.modal-content-signup select:focus {
    outline: none;
    border-color: #ff6b35;
    box-shadow: 0 0 10px rgba(255, 107, 53, 0.3);
}

.modal-content-signup input::placeholder { color: #666; }

.modal-content-signup label {
    display: block;
    margin-top: 12px;
    margin-bottom: 4px;
    color: #b0b0b0;
    font-size: 13px;
    font-weight: 500;
}

.modal-content-signup label.required::after {
    content: " *";
    color: #ff6b35;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

.form-field {
    display: flex;
    flex-direction: column;
}

.btn-group-signup {
    display: flex; justify-content: space-between; margin-top: 20px;
}
.btn-create {
    width: 48%; padding: 14px; border-radius: 8px; border: none;
    background: linear-gradient(135deg, #ff6b35, #f27b44);
    color: #fff; cursor: pointer; transition: all 0.3s;
    font-weight: 600;
    box-shadow: 0 4px 15px rgba(255, 107, 53, 0.3);
}
.btn-create:hover {
    background: linear-gradient(135deg, #f27b44, #ff6b35);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(255, 107, 53, 0.5);
}

.btn-to-login {
    width: 48%; padding: 14px; border-radius: 8px; border: none;
    background: #333; color: #b0b0b0; cursor: pointer; transition: all 0.3s;
    font-weight: 600;
}
.btn-to-login:hover {
    background: #444;
    color: #ffffff;
}

.close-signup {
    float: right; font-size: 28px; color: #888; cursor: pointer;
    transition: all 0.3s;
}
.close-signup:hover {
    color: #ff6b35;
    transform: rotate(90deg);
}

@media (max-width: 600px) {
    .form-row {
        grid-template-columns: 1fr;
    }
}
</style>


<!-- ====================== SIGNUP MODAL ====================== -->
<div class="modal signup-modal">
  <div class="modal-content-signup">
    <span class="close-signup close">×</span>
    <h1 class="title">SIGN UP</h1>

    <form action="login" method="POST" name="formSignup">
      <input type="hidden" name="action" value="sign-up" />

      <!-- Thông tin đăng nhập -->
      <label class="required">Username</label>
      <input type="text" name="username" placeholder="Tên đăng nhập" required />

      <div class="form-row">
        <div class="form-field">
          <label class="required">Password</label>
          <input type="password" name="password" placeholder="Mật khẩu" required />
        </div>
        <div class="form-field">
          <label class="required">Confirm Password</label>
          <input type="password" name="confirmPassword" placeholder="Xác nhận mật khẩu" required />
        </div>
      </div>

      <!-- Thông tin cá nhân -->
      <label class="required">Email</label>
      <input type="email" name="email" placeholder="Email của bạn" required />

      <label>Họ và tên</label>
      <input type="text" name="fullName" placeholder="Họ và tên đầy đủ" />

      <div class="form-row">
        <div class="form-field">
          <label>Số điện thoại</label>
          <input type="tel" name="phone" placeholder="Số điện thoại" />
        </div>
        <div class="form-field">
          <label>Ngày sinh</label>
          <input type="date" name="dateOfBirth" />
        </div>
      </div>

      <label>Địa chỉ</label>
      <input type="text" name="address" placeholder="Địa chỉ của bạn" />

      <label>Giới tính</label>
      <select name="gender">
        <option value="">Chọn giới tính</option>
        <option value="Nam">Nam</option>
        <option value="Nữ">Nữ</option>
        <option value="Khác">Khác</option>
      </select>

      <div class="btn-group-signup">
        <button type="button" class="btn-create" onclick="validatePassword()">Create</button>

        <button type="button" class="btn-to-login"
          onclick="
            document.querySelector('.signup-modal').classList.remove('show');
            document.querySelector('.login-modal').classList.add('show');
          ">
          Login
        </button>
      </div>
    </form>
  </div>
</div>

<!-- ====================== JS CHECK PASSWORD & EMAIL ====================== -->
<script>
function validatePassword() {
  const form = document.forms["formSignup"];
  const pw = form["password"].value;
  const cpw = form["confirmPassword"].value;
  const email = form["email"].value;

  if (pw !== cpw) {
    alert("Mật khẩu không khớp!");
    return;
  }

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    alert("Email không hợp lệ!");
    return;
  }

  form.submit();
}
</script>
