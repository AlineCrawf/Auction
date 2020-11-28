<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Customer_shop.aspx.cs" Inherits="Auction.Customer" MasterPageFile="~/Account.master"%>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div>

        <asp:GridView ID="GridView1" runat="server" CssClass="Grid" AutoGenerateColumns="False" DataSourceID="SqlDataSource1">
            <Columns>
                <asp:BoundField DataField="idtovar" HeaderText="idtovar" Visible="false" SortExpression="idtovar" />
                <asp:BoundField DataField="idpokupka" HeaderText="Номер покупки" SortExpression="idpokupka" />
                <asp:BoundField DataField="phone" HeaderText="Номер телефона" SortExpression="phone" />
                
                <asp:BoundField DataField="datapokupki" HeaderText="Дата покупки" SortExpression="datapokupki" />
                <asp:BoundField DataField="itogstoimosty" HeaderText="Цена" SortExpression="itogstoimosty" />
                <asp:BoundField DataField="tovar" HeaderText="Товар" SortExpression="tovar" />
                <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                <asp:BoundField DataField="name" HeaderText="Тип" SortExpression="name" />
                <asp:BoundField DataField="prodavec" HeaderText="Продавец" SortExpression="prodavec" />
            </Columns>
        </asp:GridView>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()] %>' ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT *
FROM pokupki WHERE phone = @phone">
            <SelectParameters>
                <asp:SessionParameter Name="phone" SessionField="user_phone" />
            </SelectParameters>
        </asp:SqlDataSource>

    </div>
</asp:Content>