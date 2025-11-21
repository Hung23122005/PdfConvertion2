<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- ====================== CSS CHO LOGIN ====================== -->
<style>
.modal.login-modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0; top: 0; width: 100%; height: 100%;
    backdrop-filter: blur(6px);
    background: rgba(0,0,0,0.35);
}
.modal.login-modal.show {
    display: flex; justify-content: center; align-items: center;
}
.modal-content-login {
    background: rgba(255,255,255,0.15);
    padding: 35px 40px; border-radius: 18px; width: 400px;
    color: #fff; backdrop-filter: blur(25px);
    box-shadow: 0 8px 30px rgba(0,0,0,0.2);
    border: 1px solid rgba(255,255,255,0.25);
    animation: fadeIn 0.25s ease-out;
}
@keyframes fadeIn { from {opacity: 0; transform: scale(0.9);} to {opacity: 1; transform: scale(1);} }

.modal-content-login input {
    width: 100%; padding: 12px; margin: 10px 0 18px 0;
    border-radius: 8px; border: none; background: rgba(255,255,255,0.2);
    color: #fff; font-size: 15px;
}
.modal-content-login input::placeholder { color: #e4e4e4; }

.btn-group-login { display: flex; justify-content: space-between; margin-top: 5px; }
.btn-group-login button {
    width: 48%; padding: 12px; border: none; border-radius: 8px; cursor: pointer;
}
.btn-login {
    background: #4cafef; color: #fff; transition: 0.2s;
}
.btn-login:hover { background: #2196f3; }
.btn-to-signup {
    background: rgba(255,255,255,0.3); color: white; transition: 0.2s;
}
.btn-to-signup:hover { background: rgba(255,255,255,0.5); }

.close-login {
    float: right; font-size: 28px; color: #fff; cursor: pointer;
}
.close-login:hover { color: #eee; }
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
