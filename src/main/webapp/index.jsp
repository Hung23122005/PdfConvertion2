<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
Boolean loginStatus = (Boolean) session.getAttribute("login-status");
Boolean signUpStatus = (Boolean) session.getAttribute("signup-status");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>PDF to Word Converter - Professional Tool</title>
<link rel="stylesheet" href="./css/common.css" />
<link rel="stylesheet" href="./css/convertion/convertion.css" />
<link rel="stylesheet" type="text/css" href="css/login/login.css">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }

  html, body {
    background: #1a1a1a;
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
    color: #ffffff;
    overflow-x: hidden;
  }

  .hero-bg {
    position: fixed; top: 0; left: 0; width: 100%; height: 100vh;
    background: linear-gradient(135deg, #1a1a1a 0%, #252525 50%, #1a1a1a 100%);
    z-index: -2;
  }

  .hero-bg::before {
    content: ''; position: absolute; top: -50%; left: -50%; width: 200%; height: 200%;
    background: radial-gradient(circle, rgba(255,107,53,0.12) 0%, transparent 70%);
    animation: rotate 20s linear infinite;
  }

  @keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }

  .particles { position: fixed; top: 0; left: 0; width: 100%; height: 100vh; z-index: -1; overflow: hidden; }
  .particle {
    position: absolute; width: 4px; height: 4px;
    background: rgba(255, 107, 53, 0.4); border-radius: 50%;
    animation: float 15s infinite ease-in-out;
  }

  @keyframes float {
    0%, 100% { transform: translateY(0) translateX(0); opacity: 0; }
    10% { opacity: 1; } 90% { opacity: 1; }
    100% { transform: translateY(-100vh) translateX(100px); opacity: 0; }
  }

  .hero-section {
    min-height: 100vh; display: flex; flex-direction: column;
    justify-content: center; align-items: center; padding: 120px 20px 60px; position: relative;
  }

  .hero-content { max-width: 900px; text-align: center; z-index: 1; }

  .hero-badge {
    display: inline-block; padding: 8px 20px;
    background: rgba(255, 107, 53, 0.1); border: 1px solid rgba(255, 107, 53, 0.3);
    border-radius: 50px; color: #ff6b35; font-size: 13px; font-weight: 600;
    letter-spacing: 0.5px; margin-bottom: 30px; animation: fadeInDown 0.8s ease-out;
  }

  @keyframes fadeInDown { from { opacity: 0; transform: translateY(-20px); } to { opacity: 1; transform: translateY(0); } }

  .hero-title {
    font-size: 72px; font-weight: 800; line-height: 1.1; margin-bottom: 24px;
    background: linear-gradient(135deg, #ffffff 0%, #ff6b35 100%);
    -webkit-background-clip: text; -webkit-text-fill-color: transparent;
    background-clip: text; animation: fadeInUp 0.8s ease-out 0.2s both;
  }

  @keyframes fadeInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }

  .hero-subtitle {
    font-size: 20px; color: #b0b0b0; font-weight: 400; line-height: 1.6;
    margin-bottom: 50px; animation: fadeInUp 0.8s ease-out 0.4s both;
  }

  .upload-card {
    background: rgba(26, 26, 26, 0.6); backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.1); border-radius: 24px;
    padding: 60px; max-width: 600px; margin: 0 auto;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.5);
    animation: fadeInUp 0.8s ease-out 0.6s both; position: relative; overflow: hidden;
  }

  .upload-icon {
    width: 80px; height: 80px; margin: 0 auto 30px;
    background: linear-gradient(135deg, #ff6b35, #f27b44); border-radius: 20px;
    display: flex; align-items: center; justify-content: center; font-size: 40px;
    box-shadow: 0 10px 30px rgba(255, 107, 53, 0.3);
  }

  .btn-upload-new {
    display: inline-flex; align-items: center; justify-content: center; gap: 12px;
    padding: 18px 40px; background: linear-gradient(135deg, #ff6b35, #f27b44);
    color: white; font-size: 18px; font-weight: 600; border-radius: 12px;
    border: none; cursor: pointer; text-decoration: none; transition: all 0.3s;
    box-shadow: 0 10px 30px rgba(255, 107, 53, 0.4); position: relative; overflow: hidden;
  }

  .btn-upload-new:hover { transform: translateY(-3px); box-shadow: 0 15px 40px rgba(255, 107, 53, 0.6); }

  .btn-secondary {
    display: inline-flex; align-items: center; justify-content: center; gap: 12px;
    padding: 18px 40px; background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.1); color: white;
    font-size: 18px; font-weight: 600; border-radius: 12px;
    cursor: pointer; text-decoration: none; transition: all 0.3s; margin-top: 20px;
  }

  .btn-secondary:hover { background: rgba(255, 255, 255, 0.1); transform: translateY(-2px); }

  .content { position: relative; z-index: 5; padding: 15px 20px; text-align: center; }

  .features-section { padding: 80px 20px; max-width: 1200px; margin: 0 auto; }

  .section-title {
    text-align: center; font-size: 42px; font-weight: 700; margin-bottom: 60px;
    background: linear-gradient(135deg, #ffffff 0%, #b0b0b0 100%);
    -webkit-background-clip: text; -webkit-text-fill-color: transparent; background-clip: text;
  }

  .features-grid {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px;
  }

  .feature-card {
    background: rgba(26, 26, 26, 0.4); backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.05); border-radius: 20px;
    padding: 40px; transition: all 0.3s;
  }

  .feature-card:hover {
    transform: translateY(-10px); border-color: rgba(255, 107, 53, 0.3);
    box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
  }

  .feature-icon { font-size: 36px; margin-bottom: 20px; }
  .feature-title { font-size: 22px; font-weight: 600; margin-bottom: 12px; }
  .feature-desc { font-size: 15px; color: #b0b0b0; line-height: 1.6; }

  @media (max-width: 768px) {
    .hero-title { font-size: 42px; }
    .upload-card { padding: 40px 30px; }
    .features-grid { grid-template-columns: 1fr; }
  }

  /* CRITICAL FIX: Force progress bar text to dark color */
  #progressContainer, #progressContainer *, #progFileName, #progMsg { color: #333 !important; }
</style>
</head>
<body>
  <%@include file="header.jsp"%>

  <div class="hero-bg"></div>
  <div class="particles" id="particles"></div>

  <section class="hero-section">
    <div class="hero-content">
      <div class="hero-badge">🚀 Professional PDF Converter</div>
      <h1 class="hero-title">Transform PDF to Word<br/>in Seconds</h1>
      <p class="hero-subtitle">
        Convert your PDF documents to editable Word files with precision.<br/>
        Fast, secure, and completely free.
      </p>

      <div class="upload-card">
        <div class="upload-icon">📄</div>
        <a href="#!" class="btn-upload-new" id="uploadLink">
          <span>Choose PDF File</span>
          <span>→</span>
        </a>

        <% if (loginStatus != null && loginStatus) { %>
        <a href="list" class="btn-secondary">
          <span>📁</span>
          <span>View Conversion History</span>
        </a>
        <% } %>
      </div>
    </div>
  </section>

  <!-- Progress bar sẽ hiển thị ở đây - GIỮA hero và features -->
  <div class="content"></div>

  <section class="features-section">
    <h2 class="section-title">Why Choose Us?</h2>
    <div class="features-grid">
      <div class="feature-card">
        <div class="feature-icon">⚡</div>
        <h3 class="feature-title">Lightning Fast</h3>
        <p class="feature-desc">Convert your PDFs to Word in seconds with our optimized conversion engine.</p>
      </div>

      <div class="feature-card">
        <div class="feature-icon">🔒</div>
        <h3 class="feature-title">100% Secure</h3>
        <p class="feature-desc">Your files are encrypted and automatically deleted after conversion.</p>
      </div>

      <div class="feature-card">
        <div class="feature-icon">🎯</div>
        <h3 class="feature-title">High Accuracy</h3>
        <p class="feature-desc">Preserve formatting, tables, images, and layouts with precision.</p>
      </div>
    </div>
  </section>

  <%@include file="login-modal.jsp"%>
  <%@include file="signup-modal.jsp"%>

  <div id="pdfPreviewModal" class="pdf-preview-modal">
    <div class="pdf-preview-content">
      <div class="pdf-preview-header">
        <h3 id="pdfPreviewTitle">Xem trước PDF</h3>
        <button class="pdf-preview-close" id="pdfPreviewClose">&times;</button>
      </div>
      <div class="pdf-preview-body">
        <div id="pdfPreviewContainer">
          <div id="pdfCanvasContainer"></div>
          <div class="pdf-preview-controls">
            <button id="pdfPrevPage" class="pdf-btn">← Trước</button>
            <span id="pdfPageInfo">Trang 1 / 1</span>
            <button id="pdfNextPage" class="pdf-btn">Sau →</button>
          </div>
        </div>
      </div>
      <div class="pdf-preview-footer">
        <button id="pdfCancelBtn" class="pdf-btn-cancel">Hủy</button>
        <button id="pdfConvertBtn" class="pdf-btn-convert">Chuyển đổi sang Word</button>
      </div>
    </div>
  </div>

  <script>
    var contextPath = '<%= request.getContextPath() %>';
  </script>

  <script type="module">
    import * as pdfjsLib from '<%= request.getContextPath() %>/pdfjs/build/pdf.mjs';
    window.pdfjsLib = pdfjsLib;
    pdfjsLib.GlobalWorkerOptions.workerSrc = '<%= request.getContextPath() %>/pdfjs/build/pdf.worker.mjs';
  </script>

  <script src="./js/main.js"></script>

  <script>
    var particlesContainer = document.getElementById('particles');
    for (var i = 0; i < 30; i++) {
      var particle = document.createElement('div');
      particle.className = 'particle';
      particle.style.left = Math.random() * 100 + '%';
      particle.style.animationDelay = Math.random() * 15 + 's';
      particle.style.animationDuration = (Math.random() * 10 + 10) + 's';
      particlesContainer.appendChild(particle);
    }

    var shouldShowLogin = <%= (loginStatus != null && !loginStatus) %>;
    if (shouldShowLogin) {
      document.querySelector('.login-modal').classList.add('show');
    }

    var signUpSuccess = <%= (signUpStatus != null && signUpStatus) %>;
    if (signUpSuccess) {
      alert('Tạo tài khoản thành công! Vui lòng đăng nhập để tiếp tục.');
      <% session.removeAttribute("signup-status"); %>
    }
    
    var signUpFailed = <%= (signUpStatus != null && !signUpStatus) %>;
    if (signUpFailed) {
      alert('Đăng ký thất bại! Username hoặc email có thể đã tồn tại.');
      <% session.removeAttribute("signup-status"); %>
    }

    document.addEventListener('DOMContentLoaded', function() {
      var loginText = document.querySelector('.text-login');
      if (loginText) {
        loginText.addEventListener('click', function() {
          document.querySelector('.login-modal').classList.add('show');
        });
      }

      var signupBtn = document.querySelector('.btn-signup');
      if (signupBtn) {
        signupBtn.addEventListener('click', function() {
          document.querySelector('.signup-modal').classList.add('show');
        });
      }

      document.querySelectorAll('.close').forEach(function(btn) {
        btn.addEventListener('click', function() {
          document.querySelectorAll('.modal').forEach(function(m) {
            m.classList.remove('show');
          });
        });
      });

      document.querySelectorAll('.modal').forEach(function(modal) {
        modal.addEventListener('click', function(e) {
          if (e.target === modal) modal.classList.remove('show');
        });
      });
    });
  </script>
</body>
</html>