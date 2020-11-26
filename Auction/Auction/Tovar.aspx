<%@ Page Title="" Language="C#" MasterPageFile="~/Seller.Master" AutoEventWireup="true" CodeBehind="Tovar.aspx.cs" Inherits="Auction.Tovar" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:GridView ID="GridView1" runat="server" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="idtovar" DataSourceID="SqlDataSource1" ShowFooter="True">
        <Columns>
            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" ShowInsertButton="True" />
            <asp:BoundField DataField="idtovar" HeaderText="idtovar" InsertVisible="False" ReadOnly="True" SortExpression="idtovar" />
            <asp:BoundField DataField="document" HeaderText="document" SortExpression="document" />
            <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" />
            <asp:BoundField DataField="sostoyanie" HeaderText="sostoyanie" SortExpression="sostoyanie" />
            <asp:BoundField DataField="idtypetovara" HeaderText="idtypetovara" SortExpression="idtypetovara" />
            <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" />
            <asp:BoundField DataField="stoimosty" HeaderText="stoimosty" SortExpression="stoimosty" />
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource2" runat="server"></asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:AuctionConnectionString %>" DeleteCommand="DELETE FROM tovar WHERE (idtovar = @idtovar)" InsertCommand="INSERT INTO tovar(idtovar, document, name, sostoyanie, idtypetovara, idprodavec, stoimosty) VALUES (@idtovar, @document, @name, @sostoyanie ::sostoyanie_t, @idtypetovara, @idprodavec, @stoimosty)" ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT * FROM &quot;tovar&quot;" UpdateCommand="UPDATE tovar SET document = @document, name = @name, sostoyanie = @sostoyanie :: sostoyanie_t, idtypetovara = @idtypetovara, idprodavec = @idprodavec, stoimosty = @stoimosty WHERE (idtovar = @idtovar)">
        <DeleteParameters>
            <asp:Parameter Name="idtovar" Type="int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="idtovar" Type="int32" />
            <asp:Parameter Name="document" Type="String" />
            <asp:Parameter Name="name" Type="String" />
            <asp:Parameter Name="sostoyanie" Type="String" />
            <asp:Parameter Name="idtypetovara" Type="int32" />
            <asp:Parameter Name="idprodavec" Type="int32" />
            <asp:Parameter Name="stoimosty" Type="Decimal" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="document" Type="String" />
            <asp:Parameter Name="name" Type="String" />
            <asp:Parameter Name="sostoyanie" Type="String" />
            <asp:Parameter Name="idtypetovara" Type="int32" />
            <asp:Parameter Name="idprodavec" Type="int32" />
            <asp:Parameter Name="stoimosty" Type="Decimal" />
            <asp:Parameter Name="idtovar" Type="int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
</asp:Content>
