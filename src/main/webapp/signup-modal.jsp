<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- ====================== CSS CHO SIGNUP ====================== -->
<style>
.modal.signup-modal {
    display: none; position: fixed; z-index: 1000;
    left: 0; top: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.35);
    backdrop-filter: blur(6px);
}
.modal.signup-modal.show {
    display: flex; justify-content: center; align-items: center;
}
.modal-content-signup {
    background: rgba(255,255,255,0.15);
    padding: 35px 40px; border-radius: 18px; width: 400px;
    color: #fff; backdrop-filter: blur(25px);
    box-shadow: 0 8px 30px rgba(0,0,0,0.2);
    border: 1px solid rgba(255,255,255,0.25);
    animation: fadeIn 0.25s ease-out;
}

.modal-content-signup input {
    width: 100%; padding: 12px; margin: 10px 0 18px 0;
    border-radius: 8px; border: none;
    background: rgba(255,255,255,0.2);
    color: #fff; font-size: 15px;
}
.modal-content-signup input::placeholder { color: #e4e4e4; }

.btn-group-signup {
    display: flex; justify-content: space-between; margin-top: 5px;
}
.btn-create {
    width: 48%; padding: 12px; border-radius: 8px; border: none;
    background: #4cafef; color: #fff; cursor: pointer; transition: 0.2s;
}
.btn-create:hover { background: #2196f3; }

.btn-to-login {
    width: 48%; padding: 12px; border-radius: 8px; border: none;
    background: rgba(255,255,255,0.3); color: #fff; cursor: pointer; transition: 0.2s;
}
.btn-to-login:hover { background: rgba(255,255,255,0.5); }

.close-signup {
    float: right; font-size: 28px; color: #fff; cursor: pointer;
}
.close-signup:hover { color: #eee; }
</style>


<!-- ====================== SIGNUP MODAL ====================== -->
<div class="modal signup-modal">
  <div class="modal-content-signup">
    <span class="close-signup close">×</span>
    <h1 class="title">SIGN UP</h1>

    <form action="login" method="POST" name="formSignup">
      <input type="hidden" name="action" value="sign-up" />

      <input type="text" name="username" placeholder="Username" required />
      <input type="password" name="password" placeholder="Password" required />
      <input type="password" name="confirmPassword" placeholder="Confirm password" required />

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

<!-- ====================== JS CHECK PASSWORD ====================== -->
<script>
function validatePassword() {
  const form = document.forms["formSignup"];
  const pw = form["password"].value;
  const cpw = form["confirmPassword"].value;

  if (pw !== cpw) {
    alert("Passwords do not match!");
    return;
  }

  form.submit();
}
</script>
