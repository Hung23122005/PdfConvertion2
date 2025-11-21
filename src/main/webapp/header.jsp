<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="header">
  <div class="navbar">
    <div class="menu">
      <img class="logo-header" src="./img/Logo.png" alt="PDF Convertion" />
    </div>
    <div class="actions">
      <%
      // ĐỔI TÊN BIẾN ĐỂ TRÁNH TRÙNG 100%!!!
      Boolean headerLoginStatus = (Boolean) session.getAttribute("login-status");
      Boolean headerSignUpStatus = (Boolean) session.getAttribute("signup-status");
      boolean headerIsLoggedIn = (headerLoginStatus != null && headerLoginStatus) || 
                                 (headerSignUpStatus != null && headerSignUpStatus);
      %>
      <% if (headerIsLoggedIn) { %>
        <label style="margin-right: 10px;">
          <span>Hello</span>
          <b><%= session.getAttribute("username") %></b>
        </label>
        <a class="btn btn-logout" href="login?action=logout">Logout</a>
      <% } else { %>
        <label class="text-login">Login</label>
        <button class="btn btn-signup">Sign up</button>
      <% } %>
    </div>
  </div>
</div>