<%@ Page Title="" Language="C#" MasterPageFile="~/Account.Master" AutoEventWireup="true" CodeBehind="TovarWithoutTorg.aspx.cs" Inherits="Auction.TovarWithoutTorg" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:GridView ID="GridView1" CssClass="Grid" runat="server" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="idtovar, stoimosty" DataSourceID="SqlDataSource1" OnSelectedIndexChanged="GridView1_SelectedIndexChanged" EmptyDataText="Все товары выставленны. Добавьте новый товар">
        <Columns>
            <asp:CommandField SelectText="Создать торг" ShowSelectButton="True" />
            <asp:BoundField DataField="idtovar" HeaderText="idtovar" InsertVisible="False" ReadOnly="True" SortExpression="idtovar" />
            <asp:BoundField DataField="document" HeaderText="document" SortExpression="document" />
            <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" />
            <asp:BoundField DataField="sostoyanie" HeaderText="sostoyanie" SortExpression="sostoyanie" />
            <asp:BoundField DataField="idtypetovara" HeaderText="idtypetovara" SortExpression="idtypetovara" />
            <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" />
            <asp:BoundField DataField="stoimosty" HeaderText="stoimosty" SortExpression="stoimosty" />
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()] %>' ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT Tovar.*  FROM Tovar LEFT JOIN torg USING (idtovar) WHERE idtorg IS NULL AND idprodavec = @idprodavec">
        <SelectParameters>
            <asp:SessionParameter Name="idprodavec" SessionField="idprodavec" Type="Int32" />
        </SelectParameters>
    </asp:SqlDataSource>
</asp:Content>
