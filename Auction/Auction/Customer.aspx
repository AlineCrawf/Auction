<%@ Page Title="" Language="C#" MasterPageFile="~/Account.Master" AutoEventWireup="true" CodeBehind="Customer.aspx.cs" Inherits="Auction.Customer1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
   
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
     <asp:Label ID="Label1" Text="Номер телефона: " runat="server"></asp:Label>
    <br/>
    <asp:Label ID="Label2" Text="Стать продавцом " runat="server"></asp:Label>
    <asp:Button ID="Button1" Text="Подать заявку" runat="server" style="float:right" OnClick="Button1_Click"/>
</asp:Content>
