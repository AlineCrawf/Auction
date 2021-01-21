<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Request.aspx.cs" Inherits="Auction.Request" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
   
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">   
    <div>
    <asp:Label ID="Label1" runat="server" Text="Подтвердить" Font-Bold="true" Font-Size="Large"></asp:Label>       
    <asp:GridView ID="GridView1" runat="server"  CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="idpokupatel,id" DataSourceID="SqlDataSource1" OnSelectedIndexChanged="Unnamed1_SelectedIndexChanged" AllowSorting="True">
                 <Columns>
                     <asp:CommandField ShowSelectButton="True" />
                     <asp:BoundField DataField="fullname" HeaderText="ФИО" SortExpression="fullname" />
                     <asp:BoundField DataField="idpokupatel" HeaderText="idpokupatel" SortExpression="idpokupatel" InsertVisible="False" ReadOnly="True" Visible="False" />
                     <asp:BoundField DataField="idpolzovately" HeaderText="idpolzovately" SortExpression="idpolzovately" Visible="False" />
                     <asp:CheckBoxField DataField="prodavec_request" HeaderText="prodavec_request" SortExpression="prodavec_request" Visible="False" />
                     <asp:BoundField DataField="id" HeaderText="id" SortExpression="id" InsertVisible="False" ReadOnly="True" Visible="False" />
                     <asp:BoundField DataField="udoslich" HeaderText="udoslich" SortExpression="udoslich" Visible="False" />
                     <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" Visible="False" />
                     <asp:BoundField DataField="surname" HeaderText="surname" SortExpression="surname" Visible="False" />
                     <asp:BoundField DataField="email" HeaderText="Почта" SortExpression="email" />
                     <asp:BoundField DataField="telefon" HeaderText="Номер телефона" SortExpression="telefon" />
                     <asp:BoundField DataField="registration_date" HeaderText="Дата регистрации" SortExpression="registration_date" />
                 </Columns>
             </asp:GridView>
             <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:adminConnectionString %>" ProviderName="<%$ ConnectionStrings:adminConnectionString.ProviderName %>" SelectCommand="SELECT  pz.name || ' '|| pz.surname as fullname, *
FROM pokupatel pk 
inner join polzovately pz on pz.id = pk.idpolzovately
 WHERE prodavec_request = true"></asp:SqlDataSource>
        <br />
        <hr />
         <asp:Label ID="Label3" runat="server" Text="Все товары" Font-Bold="true" Font-Size="Large"></asp:Label>
        <asp:GridView ID="GridView2" runat="server" CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="idtovar,idexpertiza" DataSourceID="SqlDataSource2" AllowPaging="True" AllowSorting="True">
            <Columns>
                <asp:BoundField DataField="idtovar" HeaderText="Номер товара" InsertVisible="False" ReadOnly="True" SortExpression="idtovar" />
                <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" Visible="False" />
                <asp:BoundField DataField="idtypetovara" HeaderText="idtypetovara" SortExpression="idtypetovara" Visible="False" />
                <asp:BoundField DataField="document" HeaderText="Документ" SortExpression="document" />
                <asp:BoundField DataField="name" HeaderText="Название" SortExpression="name" />
                <asp:BoundField DataField="fullname" HeaderText="Продавец" SortExpression="fullname" />
                <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                <asp:BoundField DataField="stoimosty" HeaderText="Стоимость" SortExpression="stoimosty" />
                <asp:BoundField DataField="registration_date" HeaderText="Дата регистрации" SortExpression="registration_date" />
                <asp:BoundField DataField="idparenttype" HeaderText="idparenttype" SortExpression="idparenttype" Visible="False" />
                <asp:BoundField DataField="name1" HeaderText="Тип" SortExpression="name1" />
                <asp:BoundField DataField="idpolzovately" HeaderText="idpolzovately" SortExpression="idpolzovately" Visible="False" />
                <asp:BoundField DataField="idexpertiza" HeaderText="Номер экспертизы" InsertVisible="False" ReadOnly="True" SortExpression="idexpertiza" />
                <asp:BoundField DataField="idexpert" HeaderText="idexpert" SortExpression="idexpert" Visible="False" />
                <asp:BoundField DataField="opisanie" HeaderText="Описание" SortExpression="opisanie" />
                <asp:CheckBoxField DataField="podlinosty" HeaderText="Подлиность" SortExpression="podlinosty" />
                <asp:CheckBoxField DataField="propaja" HeaderText="Пропажа" SortExpression="propaja" />
                <asp:BoundField DataField="otchetadmin" HeaderText="Отчет администратору " SortExpression="otchetadmin" />
                <asp:BoundField DataField="otchetprodavca" HeaderText="otchetprodavca" SortExpression="otchetprodavca" Visible="False" />
            </Columns>
        </asp:GridView>
        <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:expertConnectionString %>" ProviderName="<%$ ConnectionStrings:expertConnectionString.ProviderName %>" SelectCommand="SELECT *, pz.name || ' '|| pz.surname as fullname
    FROM tovar
            INNER JOIN typetovara t USING (idtypetovara)
            INNER JOIN prodavec p USING (idprodavec)
            INNER JOIN polzovately pz ON p.idpolzovately = pz.id
            LEFT JOIN expertiza ex USING(idtovar);"></asp:SqlDataSource>
    </div>
</asp:Content>

