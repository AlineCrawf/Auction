<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Account.Master" CodeBehind="MainPage.aspx.cs" Inherits="Auction.MainPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
   
</asp:Content>

 <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">   
        <div>
            <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="False" SelectedRowStyle-BackColor="#99ccff" DataKeyNames="idtorg,idtovar" DataSourceID="SqlDataSource2" AllowSorting="True" OnSelectedIndexChanged="GridView2_SelectedIndexChanged">
                <Columns>
                    <asp:CommandField ShowSelectButton="True" />
                    <asp:BoundField DataField="idtorg" HeaderText="idtorg" InsertVisible="False" ReadOnly="True" SortExpression="idtorg" />
                    <asp:BoundField DataField="idtovar" HeaderText="idtovar" SortExpression="idtovar" />
                    <asp:BoundField DataField="data_open" HeaderText="data_open" SortExpression="data_open" />
                    <asp:BoundField DataField="data_close" HeaderText="data_close" SortExpression="data_close" />
                    <asp:BoundField DataField="max_stavka" HeaderText="max_stavka" SortExpression="max_stavka" />
                    <asp:BoundField DataField="min_stavka" HeaderText="min_stavka" SortExpression="min_stavka" />
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:AuctionConnectionString %>" ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT * FROM torg WHERE data_close IS NULL"></asp:SqlDataSource>
            <asp:Label ID="Label1" runat="server" Text="Label" Visible="false" ></asp:Label >
        </div>
</asp:Content>
