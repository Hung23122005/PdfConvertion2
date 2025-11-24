<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div class="header" style="background: rgba(15, 15, 15, 0.9) !important; backdrop-filter: blur(20px); border-bottom: 1px solid rgba(255, 107, 53, 0.2) !important;">
  <div class="navbar">
    <div class="menu">
      <!-- Logo removed -->
    </div>

    <div class="actions">

      <%
        Boolean headerLoginStatus = (Boolean) session.getAttribute("login-status");
        boolean headerIsLoggedIn = (headerLoginStatus != null && headerLoginStatus);
      %>

      <% if (headerIsLoggedIn) { %>

        <label style="margin-right: 10px; color: #ffffff;">
          <span>Hello</span>
          <b><%= session.getAttribute("username") %></b>
        </label>

        <a href="profile" style="margin-right: 10px; color: #ff6b35; text-decoration: none; font-weight: 600; transition: all 0.3s;">👤 Profile</a>

        <a class="btn btn-logout" href="login?action=logout" style="background: linear-gradient(135deg, #00d4ff, #0099cc) !important; box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3) !important;">Logout</a>

      <% } else { %>

        <label class="text-login" style="color: #ffffff !important; font-weight: 700 !important; font-size: 16px !important; opacity: 1 !important; cursor: pointer;">Login</label>
        <button class="btn btn-signup">Sign up</button>

      <% } %>

    </div>
  </div>
</div>
