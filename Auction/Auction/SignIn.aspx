<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignIn.aspx.cs" Inherits="Auction.SignIn" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <title>Login Form</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <form  runat="server">
  <section class="container">
    <div class="login" runat="server">
      <h1>Login to Web App</h1>
        <p><asp:TextBox ID="login" runat="server" name="login" value="" placeholder="Phone number"></asp:TextBox></p>
        <p><asp:TextBox ID="passwordBox" runat="server" type="password" name="password" value="" placeholder="Password"></asp:TextBox></p>          
        <p class="submit"><asp:Button ID="sign_in" runat="server" Text="Sign in" OnClick="sign_in_Click" /></p>
        <a  href="SignUp"> Регистрация </a>
    </div>
  </section>
  </form>
</body>
</html>
