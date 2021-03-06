﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Sign_In.aspx.cs" Inherits="Auction.Sign_In" %>

<!DOCTYPE html>
<html lang="en">
<head>
	<title>Login V2</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<!--===============================================================================================-->	
	<link rel="icon" type="image/png" href="images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/bootstrap/css/bootstrap.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="fonts/font-awesome-4.7.0/css/font-awesome.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="fonts/iconic/css/material-design-iconic-font.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animate/animate.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="vendor/css-hamburgers/hamburgers.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animsition/css/animsition.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/select2/select2.min.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="vendor/daterangepicker/daterangepicker.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="css/util.css">
	<link rel="stylesheet" type="text/css" href="css/main.css">
<!--===============================================================================================-->
</head>
<body>
<form runat="server">
	<div class="limiter">
		<div class="container-login100">
			<div class="wrap-login100">
				<form class="login100-form validate-form">
					<span class="login100-form-title p-b-26">
						Добро пожаловать
					</span>
					<span class="login100-form-title p-b-48">
						<i class="zmdi zmdi-font"></i>
					</span>
					 
					<div class="wrap-input100 validate-input" data-validate = "Valid email is: a@b.c">
						<asp:RequiredFieldValidator ID="rfv1" ControlToValidate="login" runat="server" 
            EnableClientScript="true" ErrorMessage="Обязательно" SetFocusOnError="true">
					 </asp:RequiredFieldValidator>
						<asp:TextBox ID="login" runat="server" class="input100"  type="text" name="Номер"/>
						<span class="focus-input100" data-placeholder="Номер"></span>
					</div>

					<div class="wrap-input100 validate-input" data-validate="Введите пароль">
						<asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="password" runat="server" 
            EnableClientScript="true" ErrorMessage="Обязательно" SetFocusOnError="true">
						</asp:RequiredFieldValidator>
						<span class="btn-show-pass">
							<i class="zmdi zmdi-eye"></i>
						</span>					
					
						<asp:TextBox runat="server" ID="password"  class="input100" type="password" name="pass"/>
						<span class="focus-input100" data-placeholder="Пароль"></span>
					</div>

					<div class="container-login100-form-btn">
						<div class="wrap-login100-form-btn">
							<div class="login100-form-bgbtn"></div>
							<button  ID="Button1" runat="server" class="login100-form-btn" onServerClick="Button1_Click">
								Вход
							</button>
							
						</div>
					</div>

					<div class="text-center p-t-115">
						<span class="txt1">
							Нет аккаунта?
						</span>

						<a class="txt2" href="Sign_Up">
							Зарегестрироваться
						</a>
					</div>
				</form>
			</div>
		</div>
	</div>
	
</form>	
	<div id="dropDownSelect1"></div>
	
<!--===============================================================================================-->
	<script src="vendor/jquery/jquery-3.2.1.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/animsition/js/animsition.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/bootstrap/js/popper.js"></script>
	<script src="vendor/bootstrap/js/bootstrap.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/select2/select2.min.js"></script>
<!--===============================================================================================-->
	<script src="vendor/daterangepicker/moment.min.js"></script>
	<script src="vendor/daterangepicker/daterangepicker.js"></script>
<!--===============================================================================================-->
	<script src="vendor/countdowntime/countdowntime.js"></script>
<!--===============================================================================================-->
	<script src="js/main.js"></script>

</body>
</html>
