<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="Auction.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <title>Login Form</title>
  <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <form  runat="server">
      <section class="container">
        <div class="login" runat="server">
          <h1>Register to Web App</h1>
            <p><asp:TextBox ID="Name" runat="server"  name="Name" placeholder="Name"></asp:TextBox></p>
            <p><asp:TextBox ID="Surname" runat="server"  name="Surname" placeholder="Surname"></asp:TextBox></p>
            <p><asp:TextBox ID="Udoslich" runat="server" name="Udoslich" placeholder="Udoslich"></asp:TextBox></p>
            <p><asp:TextBox ID="Email" runat="server" name="Email" placeholder="Email"></asp:TextBox></p>
            <p><asp:TextBox ID="Phone" runat="server" name="Phone" placeholder="Phone" ></asp:TextBox></p>

            <p><asp:TextBox ID="passwordBox" runat="server" name="password" value="" placeholder="Password"></asp:TextBox></p>          
            <p class="submit">
                <asp:Button ID="sign_up" runat="server" Text="Sign up" OnClick="sign_up_Click" /></p>
        </div>
          <asp:GridView ID="GridView1" runat="server" DataSourceID="SqlDataSource1">
          </asp:GridView>
          <asp:SqlDataSource ID="SqlDataSource1" runat="server"></asp:SqlDataSource>
      </section>
  </form>
</body>
</html>
