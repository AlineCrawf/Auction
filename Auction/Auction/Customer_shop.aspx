<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Customer_shop.aspx.cs" Inherits="Auction.Customer" MasterPageFile="~/Account.master"%>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div style="text-align:left">
       <h1>Товары</h1>
   </div>
    
    <div>

        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataSourceID="SqlDataSource1">
            <Columns>
                <asp:BoundField DataField="idtovar" HeaderText="idtovar" SortExpression="idtovar" />
                <asp:BoundField DataField="phone" HeaderText="phone" SortExpression="phone" />
                <asp:BoundField DataField="idpokupka" HeaderText="idpokupka" SortExpression="idpokupka" />
                <asp:BoundField DataField="datapokupki" HeaderText="datapokupki" SortExpression="datapokupki" />
                <asp:BoundField DataField="itogstoimosty" HeaderText="itogstoimosty" SortExpression="itogstoimosty" />
                <asp:BoundField DataField="tovar" HeaderText="tovar" SortExpression="tovar" />
                <asp:BoundField DataField="sostoyanie" HeaderText="sostoyanie" SortExpression="sostoyanie" />
                <asp:BoundField DataField="name" HeaderText="name" SortExpression="name" />
                <asp:BoundField DataField="prodavec" HeaderText="prodavec" SortExpression="prodavec" />
            </Columns>
        </asp:GridView>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:AuctionConnectionString %>" ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT *
FROM pokupki WHERE phone = @phone">
            <SelectParameters>
                <asp:SessionParameter Name="phone" SessionField="user_phone" />
            </SelectParameters>
        </asp:SqlDataSource>

    </div>
</asp:Content>