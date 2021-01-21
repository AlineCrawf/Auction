<%@ Page Title="" Language="C#" MasterPageFile="~/Account.Master" AutoEventWireup="true" CodeBehind="TovarWithoutTorg.aspx.cs" Inherits="Auction.TovarWithoutTorg" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:GridView ID="GridView1" CssClass="Grid" runat="server" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="idtovar,idtorg,idexpertiza" DataSourceID="SqlDataSource1" OnSelectedIndexChanged="GridView1_SelectedIndexChanged" EmptyDataText="Все товары выставленны. Добавьте новый товар">
        <Columns>
            <asp:BoundField DataField="idtovar" HeaderText="Код товара" InsertVisible="False" ReadOnly="True" SortExpression="idtovar" />
            <asp:BoundField DataField="document" HeaderText="Документ" SortExpression="document" />
            <asp:BoundField DataField="name" HeaderText="Название" SortExpression="name" />
            <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
            <asp:BoundField DataField="idtypetovara" HeaderText="idtypetovara" SortExpression="idtypetovara" Visible="False" />
            <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" Visible="False" />
            <asp:BoundField DataField="stoimosty" HeaderText="Стоимость" SortExpression="stoimosty" />
            <asp:BoundField DataField="registration_date" HeaderText="Дата регистрации" SortExpression="registration_date" />
            <asp:BoundField DataField="idtorg" HeaderText="idtorg" InsertVisible="False" ReadOnly="True" SortExpression="idtorg" Visible="False" />
            <asp:BoundField DataField="data_open" HeaderText="data_open" SortExpression="data_open" Visible="False" />
            <asp:BoundField DataField="data_close" HeaderText="data_close" SortExpression="data_close" Visible="False" />
            <asp:BoundField DataField="max_stavka" HeaderText="max_stavka" SortExpression="max_stavka" Visible="False" />
            <asp:BoundField DataField="min_stavka" HeaderText="min_stavka" SortExpression="min_stavka" Visible="False" />
            <asp:BoundField DataField="idexpertiza" HeaderText="Номер экспертизы" InsertVisible="False" ReadOnly="True" SortExpression="idexpertiza" Visible="False" />
            <asp:BoundField DataField="idexpert" HeaderText="idexpert" SortExpression="idexpert" Visible="False" />
            <asp:BoundField DataField="opisanie" HeaderText="opisanie" SortExpression="opisanie" Visible="False" />
            <asp:CheckBoxField DataField="podlinosty" HeaderText="Подлиность" SortExpression="podlinosty" />
            <asp:CheckBoxField DataField="propaja" HeaderText="Пропажа" SortExpression="propaja" />
            <asp:BoundField DataField="otchetadmin" HeaderText="otchetadmin" SortExpression="otchetadmin" Visible="False" />
            <asp:BoundField DataField="otchetprodavca" HeaderText="otchetprodavca" SortExpression="otchetprodavca" Visible="False" />
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()] %>' ProviderName="<%$ ConnectionStrings:sellerConnectionString.ProviderName %>" SelectCommand="SELECT *   FROM Tovar LEFT JOIN torg USING (idtovar) LEFT JOIN expertiza ex USING(idtovar) WHERE idtorg IS NULL AND idprodavec = @idprodavec AND podlinosty IS True AND propaja IS false">
    </asp:SqlDataSource>
</asp:Content>
