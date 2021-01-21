<%@ Page Title="" Language="C#" MasterPageFile="~/Expert.Master" AutoEventWireup="true" CodeBehind="TovarWithExpertiza.aspx.cs" Inherits="Auction.Report" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:GridView ID="GridView1" runat="server" CssClass="Grid" DataSourceID="SqlDataSource1" AutoGenerateColumns="False" AllowSorting="True" DataKeyNames="idtovar,idexpertiza" AllowPaging="True">
        <Columns>
            <asp:BoundField DataField="idtovar" HeaderText="Код товара" InsertVisible="False" ReadOnly="True" SortExpression="idtovar" />
            <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" Visible="False" />
            <asp:BoundField DataField="idtypetovara" HeaderText="idtypetovara" SortExpression="idtypetovara" Visible="False" />
            <asp:BoundField DataField="document" HeaderText="Документ" SortExpression="document" />
            <asp:BoundField DataField="name" HeaderText="Название товара" SortExpression="name" />
             <asp:BoundField DataField="fullname" HeaderText="Продавец" SortExpression="fullname" />
            <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
            <asp:BoundField DataField="stoimosty" HeaderText="Стоимость" SortExpression="stoimosty" />
            <asp:BoundField DataField="registration_date" HeaderText="Дата регистрации" SortExpression="registration_date" />
            <asp:BoundField DataField="idparenttype" HeaderText="idparenttype" SortExpression="idparenttype" Visible="False" />
            <asp:BoundField DataField="name1" HeaderText="Тип" SortExpression="name1" />
            <asp:BoundField DataField="idpolzovately" HeaderText="idpolzovately" SortExpression="idpolzovately" Visible="False" />
            <asp:BoundField DataField="idexpertiza" HeaderText="Номер экспертизы" InsertVisible="False" ReadOnly="True" SortExpression="idexpertiza" />
            <asp:BoundField DataField="idexpert" HeaderText="idexpert" SortExpression="idexpert" Visible="False" />
            <asp:CheckBoxField DataField="podlinosty" HeaderText="Подлиность" SortExpression="podlinosty" />
            <asp:CheckBoxField DataField="propaja" HeaderText="Пропажа" SortExpression="propaja" />
            <asp:BoundField DataField="opisanie" HeaderText="Описание" SortExpression="opisanie" />
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" SelectCommand="SELECT *, pz.name || ' '|| pz.surname as fullname
FROM tovar
INNER JOIN typetovara t USING (idtypetovara)
INNER JOIN prodavec p USING (idprodavec)
INNER JOIN polzovately pz ON p.idpolzovately = pz.id
LEFT JOIN expertiza ex USING(idtovar);" 
        ConnectionString="<%$ ConnectionStrings:expertConnectionString %>" ProviderName="<%$ ConnectionStrings:expertConnectionString.ProviderName %>"></asp:SqlDataSource>
</asp:Content>
