<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- ====================== CSS CHO LOGIN DARK THEME ====================== -->
<style>
.modal.login-modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0; top: 0; width: 100%; height: 100%;
    backdrop-filter: blur(10px);
    background: rgba(0,0,0,0.9);
}
.modal.login-modal.show {
    display: flex; justify-content: center; align-items: center;
}
.modal-content-login {
    background: #252525;
    padding: 35px 40px; border-radius: 18px; width: 400px;
    color: #fff; backdrop-filter: blur(25px);
    box-shadow: 0 20px 60px rgba(0,0,0,0.9);
    border: 1px solid #333;
    animation: fadeIn 0.3s ease-out;
}
@keyframes fadeIn { from {opacity: 0; transform: scale(0.95);} to {opacity: 1; transform: scale(1);} }

.modal-content-login input {
    width: 100%; padding: 14px; margin: 10px 0 18px 0;
    border-radius: 8px; border: 1px solid #333;
    background: #1a1a1a;
    color: #fff; font-size: 15px;
    transition: all 0.3s;
}
.modal-content-login input:focus {
    outline: none;
    border-color: #ff6b35;
    box-shadow: 0 0 10px rgba(255, 107, 53, 0.3);
}
.modal-content-login input::placeholder { color: #666; }

.btn-group-login { display: flex; justify-content: space-between; margin-top: 5px; }
.btn-group-login button {
    width: 48%; padding: 14px; border: none; border-radius: 8px; cursor: pointer;
    font-weight: 600; transition: all 0.3s;
}
.btn-login {
    background: linear-gradient(135deg, #00d4ff, #0099cc);
    color: #fff;
    box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3);
}
.btn-login:hover {
    background: linear-gradient(135deg, #0099cc, #00d4ff);
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 212, 255, 0.5);
}
.btn-to-signup {
    background: #333;
    color: #b0b0b0;
}
.btn-to-signup:hover {
    background: #444;
    color: #ffffff;
}

.close-login {
    float: right; font-size: 28px; color: #888; cursor: pointer;
    transition: all 0.3s;
}
.close-login:hover {
    color: #ff6b35;
    transform: rotate(90deg);
}
</style>


<!-- ====================== LOGIN MODAL ====================== -->
<div class="modal login-modal">
  <div class="modal-content-login">
    <span class="close-login close">×</span>
    <h1 class="title">LOGIN</h1>

    <form action="login" method="POST" name="formLogin">
      <input type="hidden" name="action" value="check-login" />

      <%
        String username = (String) session.getAttribute("username");
      %>

      <input type="text" name="username" placeholder="Username"
             value="<%=username == null ? "" : username%>" required />

      <input type="password" name="password" placeholder="Password" required />

      <div class="btn-group-login">
        <button type="submit" class="btn-login">Login</button>

        <button type="button" class="btn-to-signup"
          onclick="
            document.querySelector('.signup-modal').classList.add('show');
            document.querySelector('.login-modal').classList.remove('show');
          ">
          Sign up
        </button>
      </div>
    </form>
  </div>
</div>
