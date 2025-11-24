<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.BEAN.User"%>
<%
User user = (User) request.getAttribute("user");
Boolean success = (Boolean) request.getAttribute("success");
Boolean error = (Boolean) request.getAttribute("error");
String message = (String) request.getAttribute("message");

String passwordSuccess = (String) session.getAttribute("password-success");
String passwordError = (String) session.getAttribute("password-error");
session.removeAttribute("password-success");
session.removeAttribute("password-error");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Profile - PDF Converter</title>
<link rel="stylesheet" href="./css/common.css" />
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
  body { background: #1a1a1a; font-family: 'Inter', sans-serif; color: #ffffff; min-height: 100vh; padding-top: 100px; }
  .container { max-width: 900px; margin: 0 auto; padding: 40px 20px; }
  .page-title { font-size: 42px; font-weight: 700; background: linear-gradient(135deg, #ffffff 0%, #ff6b35 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text; margin-bottom: 40px; text-align: center; }
  .card { background: rgba(26, 26, 26, 0.6); backdrop-filter: blur(20px); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 20px; padding: 40px; margin-bottom: 30px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5); }
  .card-title { font-size: 24px; font-weight: 600; color: #ff6b35; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 1px solid rgba(255, 255, 255, 0.1); }
  .form-group { margin-bottom: 25px; }
  .form-group label { display: block; margin-bottom: 8px; color: #b0b0b0; font-size: 14px; font-weight: 500; }
  .form-group input, .form-group select { width: 100%; padding: 14px 18px; background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 10px; color: #ffffff; font-size: 15px; transition: all 0.3s; }
  .form-group input:focus, .form-group select:focus { outline: none; border-color: #ff6b35; background: rgba(255, 255, 255, 0.08); }
  .form-group input:disabled, .form-group select:disabled { opacity: 0.5; cursor: not-allowed; }
  .btn { padding: 14px 30px; border-radius: 10px; font-weight: 600; font-size: 15px; cursor: pointer; transition: all 0.3s; border: none; }
  .btn-primary { background: linear-gradient(135deg, #ff6b35, #f27b44); color: white; box-shadow: 0 10px 30px rgba(255, 107, 53, 0.4); }
  .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 15px 40px rgba(255, 107, 53, 0.6); }
  .btn-secondary { background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); color: white; margin-left: 10px; }
  .btn-secondary:hover { background: rgba(255, 255, 255, 0.1); }
  .btn-back { padding: 10px 20px; background: linear-gradient(135deg, #00d4ff, #0099cc); color: white; border-radius: 8px; display: inline-block; transition: all 0.3s; box-shadow: 0 4px 15px rgba(0, 212, 255, 0.3); }
  .btn-back:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0, 212, 255, 0.5); }
  .alert { padding: 15px 20px; border-radius: 10px; margin-bottom: 25px; font-size: 14px; }
  .alert-success { background: rgba(46, 204, 113, 0.15); border: 1px solid rgba(46, 204, 113, 0.3); color: #2ecc71; }
  .alert-error { background: rgba(231, 76, 60, 0.15); border: 1px solid rgba(231, 76, 60, 0.3); color: #e74c3c; }
  .row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
  @media (max-width: 768px) { .row { grid-template-columns: 1fr; } .page-title { font-size: 32px; } .card { padding: 30px 20px; } }
</style>
</head>
<body>
  <%@include file="header.jsp"%>

  <div class="container">
    <a href="index.jsp" class="btn-back" style="text-decoration: none; display: inline-block; margin-bottom: 30px;">← Back to Home</a>
    <h1 class="page-title">👤 My Profile</h1>

    <div class="card">
      <h2 class="card-title">Personal Information</h2>
      
      <% if (success != null && success) { %>
      <div class="alert alert-success">✓ <%= message %></div>
      <% } else if (error != null && error) { %>
      <div class="alert alert-error">✗ <%= message %></div>
      <% } %>

      <form method="post" action="profile" id="profileForm">
        <div class="form-group">
          <label>Username</label>
          <input type="text" value="<%= user != null ? user.getUsername() : "" %>" disabled>
        </div>

        <div class="row">
          <div class="form-group">
            <label>Email *</label>
            <input type="email" name="email" id="email" value="<%= user != null && user.getEmail() != null ? user.getEmail() : "" %>" required disabled>
          </div>
          <div class="form-group">
            <label>Full Name</label>
            <input type="text" name="fullName" id="fullName" value="<%= user != null && user.getFullName() != null ? user.getFullName() : "" %>" disabled>
          </div>
        </div>

        <div class="row">
          <div class="form-group">
            <label>Phone</label>
            <input type="text" name="phone" id="phone" value="<%= user != null && user.getPhone() != null ? user.getPhone() : "" %>" disabled>
          </div>
          <div class="form-group">
            <label>Date of Birth</label>
            <input type="date" name="dateOfBirth" id="dateOfBirth" value="<%= user != null && user.getDateOfBirth() != null ? user.getDateOfBirth() : "" %>" disabled>
          </div>
        </div>

        <div class="form-group">
          <label>Address</label>
          <input type="text" name="address" id="address" value="<%= user != null && user.getAddress() != null ? user.getAddress() : "" %>" disabled>
        </div>

        <div class="form-group">
          <label>Gender</label>
          <select name="gender" id="gender" disabled>
            <option value="">-- Select Gender --</option>
            <option value="Male" <%= user != null && "Male".equals(user.getGender()) ? "selected" : "" %>>Male</option>
            <option value="Female" <%= user != null && "Female".equals(user.getGender()) ? "selected" : "" %>>Female</option>
            <option value="Other" <%= user != null && "Other".equals(user.getGender()) ? "selected" : "" %>>Other</option>
          </select>
        </div>

        <button type="button" class="btn btn-primary" id="editBtn" onclick="enableEdit()">✏️ Edit Information</button>
        <button type="submit" class="btn btn-primary" id="updateBtn" style="display: none;">💾 Update Profile</button>
        <button type="button" class="btn btn-secondary" id="cancelBtn" style="display: none;" onclick="cancelEdit()">✖️ Cancel</button>
      </form>
    </div>

    <div class="card">
      <h2 class="card-title">Change Password</h2>

      <% if (passwordSuccess != null) { %>
      <div class="alert alert-success">✓ <%= passwordSuccess %></div>
      <% } else if (passwordError != null) { %>
      <div class="alert alert-error">✗ <%= passwordError %></div>
      <% } %>

      <form method="post" action="changePassword">
        <div class="form-group">
          <label>Current Password *</label>
          <input type="password" name="oldPassword" required>
        </div>

        <div class="row">
          <div class="form-group">
            <label>New Password *</label>
            <input type="password" name="newPassword" required>
          </div>
          <div class="form-group">
            <label>Confirm New Password *</label>
            <input type="password" name="confirmPassword" required>
          </div>
        </div>

        <button type="submit" class="btn btn-primary">🔐 Change Password</button>
      </form>
    </div>
  </div>

  <script>
    const fields = ['email', 'fullName', 'phone', 'dateOfBirth', 'address', 'gender'];
    const originalValues = {};
    fields.forEach(f => { originalValues[f] = document.getElementById(f).value; });

    function enableEdit() {
      fields.forEach(f => document.getElementById(f).disabled = false);
      document.getElementById('editBtn').style.display = 'none';
      document.getElementById('updateBtn').style.display = 'inline-block';
      document.getElementById('cancelBtn').style.display = 'inline-block';
    }

    function cancelEdit() {
      fields.forEach(f => {
        document.getElementById(f).value = originalValues[f];
        document.getElementById(f).disabled = true;
      });
      document.getElementById('editBtn').style.display = 'inline-block';
      document.getElementById('updateBtn').style.display = 'none';
      document.getElementById('cancelBtn').style.display = 'none';
    }
  </script>
</body>
</html>
