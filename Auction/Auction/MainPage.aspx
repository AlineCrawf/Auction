<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Account.Master" CodeBehind="MainPage.aspx.cs" Inherits="Auction.MainPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
   
</asp:Content>

 <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">   
        <div style="margin:auto">
            <asp:GridView ID="GridView2" runat="server" CssClass="Grid" DataKeyNames="idtorg" AlternatingRowStyle-CssClass="alt" PagerStyle-CssClass="pgr"  AutoGenerateColumns="False" SelectedRowStyle-BackColor="#99ccff" DataSourceID="SqlDataSource1" AllowSorting="True" OnSelectedIndexChanged="GridView2_SelectedIndexChanged">
<AlternatingRowStyle CssClass="alt"></AlternatingRowStyle>
                <Columns>
                     <asp:CommandField ShowSelectButton="True" >
                    <ItemStyle BackColor="#F5F6F6" />
                    </asp:CommandField>                   
                    <asp:BoundField DataField="idtorg" HeaderText="Номер торга" SortExpression="idtorg" />
                    <asp:BoundField DataField="idtovar" HeaderText="Номер товара" SortExpression="idtovar" />
                    <asp:BoundField DataField="data_open" HeaderText="Дата открытия" SortExpression="data_open" />
                    <asp:BoundField DataField="min_stavka" HeaderText="Начальная ставка" SortExpression="min_stavka" />
                    <asp:BoundField DataField="document" HeaderText="Документ" Visible="false" SortExpression="document" />
                    <asp:BoundField DataField="tovar" HeaderText="Название" SortExpression="tovar" />
                    <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                    <asp:BoundField DataField="type" HeaderText="Тип" SortExpression="type" />
                    <asp:BoundField DataField="prodavec" HeaderText="Продавец" SortExpression="prodavec" />
                    <asp:BoundField DataField="stoimosty" HeaderText="Стоимость" Visible="false" SortExpression="stoimosty" />
                </Columns>

<PagerStyle CssClass="pgr"></PagerStyle>

<SelectedRowStyle BackColor="#99CCFF"></SelectedRowStyle>
            </asp:GridView>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%#  ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()].ConnectionString %>' ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT * FROM open_torg"></asp:SqlDataSource>
            <asp:Label ID="Label1" runat="server" Text="Label" Visible="false" ></asp:Label >
        </div>
</asp:Content>
