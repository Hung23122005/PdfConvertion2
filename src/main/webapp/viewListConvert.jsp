<%@page import="model.BEAN.Upload"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>View list convert</title>
<link rel="stylesheet" href="./css/common.css" />
<link rel="stylesheet" href="./css/convertion/convertion.css" />
<style>
    .list-convert {
        background: #1a1a1a;
        min-height: 100vh;
        color: #ffffff;
    }
    .header-text {
        color: #ffffff !important;
        margin: 20px 0;
    }
    .styled-table tbody td {
        color: #ffffff !important;
    }
    .styled-table tbody a {
        color: #ff6b35 !important;
        font-weight: bold;
    }
</style>
</head>
<body>

  <%@include file="header.jsp"%>

  <%
  @SuppressWarnings("unchecked")
  ArrayList<Upload> uploads = (ArrayList<Upload>) session.getAttribute("uploads");
  %>

  <div class="content-downloader list-convert">
    <div class="table-container scrollbar">
      <div class="header-content">
        <a class="btn btn-back" href="index.jsp">Back to home</a>
        <h1 class="text-center header-text fs-20px">List file converted</h1>
      </div>

      <% if (uploads != null && !uploads.isEmpty()) { %>
      <table class="styled-table">
        <thead class="thead-dark">
          <tr>
            <th class="text-center">No</th>
            <th class="text-center">File upload</th>
            <th class="text-center">File converted</th>
            <th class="text-center">Date</th>
          </tr>
        </thead>
        <tbody>
          <% 
          int i = 1;
          for (Upload upload : uploads) { 
          %>
          <tr class="active-row">
            <td class="text-center"><%= i %></td>
            <td class="text-center"><%= upload.getFileNameUpload() %></td>
            <td class="text-center">
              <a href="download?file=<%= upload.getFileNameOutputInServer() %>"
                 target="_blank">
                <%= upload.getFileNameOutput() %>
              </a>
            </td>
            <td class="text-center"><%= upload.getDate() %></td>
          </tr>
          <% 
          i++; 
          } %>
        </tbody>
      </table>
      <% } else { %>
      <h3 style="text-align:center; margin-top:50px; color:#ffffff;">
        You haven't converted any files yet.
      </h3>
      <% } %>

    </div>
  </div>

</body>
</html>