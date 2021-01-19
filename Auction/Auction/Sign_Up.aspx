<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Sign_Up.aspx.cs" Inherits="Auction.Sign_Up" %>

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
	<div class="limiter">
		<div class="container-login100">
			<div class="wrap-login100">
				<form class="login100-form validate-form" runat="server" >
					<span class="login100-form-title p-b-26">
						Регистрация
					</span>
					<span class="login100-form-title p-b-48">
						<i class="zmdi zmdi-font"></i>
					</span>

					<div class="wrap-input100 validate-input">
						<asp:TextBox ID="Name" runat="server"  name="Name" placeholder="Имя" ValidateRequestMode="Enabled"></asp:TextBox> </div>
					<div class="wrap-input100 validate-input">	
						<asp:TextBox ID="Surname" runat="server"  name="Surname" placeholder="Фамилия" ValidateRequestMode="Enabled"></asp:TextBox>
					</div>
					<div class="wrap-input100 validate-input">
						<asp:TextBox ID="Udoslich" runat="server" name="Udoslich" placeholder="Номер паспорта" ValidateRequestMode="Enabled"></asp:TextBox>
					</div>
					<div class="wrap-input100 validate-input">
						<asp:TextBox ID="Email" runat="server" name="Email" placeholder="Email" TextMode="Email" ValidateRequestMode="Enabled"></asp:TextBox>
					</div>
					<div class="wrap-input100 validate-input">	
						<asp:TextBox ID="Phone" runat="server" name="Phone" placeholder="Номер телефона" TextMode="Phone" ValidateRequestMode="Enabled" ></asp:TextBox>
					</div>
					<div class="wrap-input100 validate-input">
						<asp:TextBox ID="passwordBox" type="password" runat="server" name="password" value="" placeholder="Пароль" OnTextChanged="passwordBox_TextChanged" ValidateRequestMode="Enabled"></asp:TextBox>
					</div>


					<div class="container-login100-form-btn">
						<div class="wrap-login100-form-btn">
							<div class="login100-form-bgbtn"></div>
							<button  ID="Button1" runat="server" class="login100-form-btn" onServerClick="Button1_Click">
								Регистрация</button>
							
						</div>
					</div>

					<div class="text-center p-t-115">
						<span class="txt1">
							Есть аккаунт?
						</span>

						<a class="txt2" href="Sign_In">
							Войти
						</a>
					</div>
				</form>
			</div>
		</div>
	</div>
	
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