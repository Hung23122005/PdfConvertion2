<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
Boolean loginStatus = (Boolean) session.getAttribute("login-status");
Boolean signUpStatus = (Boolean) session.getAttribute("signup-status");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>PDF to Word Converter</title>
<link rel="stylesheet" href="./css/common.css" />
<link rel="stylesheet" href="./css/convertion/convertion.css" />
<link rel="stylesheet" type="text/css" href="css/login/login.css">
</head>
<body>
  <%@include file="header.jsp"%>

  <div class="content">
    <div class="content-header">
      <h1 class="content-title">PDF to WORD Conversion</h1>
      <h2 class="content-subtitle">Converting pdf documents to word is very convenient</h2>
    </div>
    <div class="content-uploader">
      <a href="#!" class="btn-upload" id="uploadLink">Choose PDF file</a>
    </div>

    <% if (loginStatus != null && loginStatus) { %>
    <div class="content-uploader">
        <a href="list" class="btn-upload">View converted files</a>
    </div>
    <% } %>
  </div>

  <%@include file="login-modal.jsp"%>
  <%@include file="signup-modal.jsp"%>

  <!-- PDF Preview Modal -->
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

  <!-- THÊM DÒNG NÀY – TRUYỀN CONTEXT PATH CHO JS -->
  <script>
    const contextPath = '<%= request.getContextPath() %>';  // → /PDFConverterPro
  </script>

  <!-- PDF.js Library -->
  <script type="module">
    import * as pdfjsLib from '<%= request.getContextPath() %>/pdfjs/build/pdf.mjs';
    window.pdfjsLib = pdfjsLib;
    pdfjsLib.GlobalWorkerOptions.workerSrc = '<%= request.getContextPath() %>/pdfjs/build/pdf.worker.mjs';
  </script>

  <script src="./js/main.js"></script>

  <script>
    if (<%= (loginStatus != null && !loginStatus) %>) {
      document.querySelector('.login-modal').classList.add('show');
    }

    // Show success message after signup
    if (<%= (signUpStatus != null && signUpStatus) %>) {
      alert('Account created successfully! Please login to continue.');
      <% session.removeAttribute("signup-status"); %>
    }
    
    // Show error message if signup failed
    if (<%= (signUpStatus != null && !signUpStatus) %>) {
      alert('Signup failed! Username might already exist.');
      <% session.removeAttribute("signup-status"); %>
    }

    document.addEventListener('DOMContentLoaded', function() {
      document.querySelector('.text-login')?.addEventListener('click', () => {
        document.querySelector('.login-modal').classList.add('show');
      });

      document.querySelector('.btn-signup')?.addEventListener('click', () => {
        document.querySelector('.signup-modal').classList.add('show');
      });

      document.querySelectorAll('.close').forEach(btn => {
        btn.addEventListener('click', () => {
          document.querySelectorAll('.modal').forEach(m => m.classList.remove('show'));
        });
      });

      document.querySelectorAll('.modal').forEach(modal => {
        modal.addEventListener('click', e => {
          if (e.target === modal) modal.classList.remove('show');
        });
      });
    });
  </script>
</body>
</html>