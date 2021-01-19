<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="UserActivityAnalytics.aspx.cs" Inherits="Auction.UserActivityAnalytics" %>
<%@ Register assembly="System.Web.DataVisualization, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" namespace="System.Web.UI.DataVisualization.Charting" tagprefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:Chart ID="Chart1" runat="server" DataSourceID="UsersSqlDataSource">
        <Titles>
            <asp:Title Text="Зарегестрированные пользователи">
            </asp:Title>
        </Titles>
        <series>
            <asp:Series Name="Series1" XValueMember="month" YValueMembers="count" IsValueShownAsLabel="true">
            </asp:Series>
        </series>
        <chartareas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </chartareas>
    </asp:Chart>
    <asp:SqlDataSource ID="UsersSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:adminConnectionString %>" ProviderName="<%$ ConnectionStrings:adminConnectionString.ProviderName %>" SelectCommand="SELECT to_char(registration_date, 'TMMonth') AS month, count(id) FROM  polzovately group by month"></asp:SqlDataSource>
    <asp:Chart ID="Chart2" runat="server" DataSourceID="NewTovarSqlDataSource">
         <Titles>
            <asp:Title Text="Зарегестрированные товары">
            </asp:Title>
        </Titles>
        <Series>
            <asp:Series Name="Series1" XValueMember="month" YValueMembers="count" IsValueShownAsLabel="true">
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </ChartAreas>
    </asp:Chart>
    <asp:SqlDataSource ID="NewTovarSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:adminConnectionString %>" ProviderName="<%$ ConnectionStrings:adminConnectionString.ProviderName %>" SelectCommand="SELECT  to_char(registration_date, 'TMMonth') AS month,count(idtovar)  from tovar GROUP BY registration_date"></asp:SqlDataSource>
    <asp:Chart ID="Chart3" runat="server" DataSourceID="PurchaseSqlDataSource">
        <Titles>
            <asp:Title Text="Купленые товары">
            </asp:Title>
        </Titles>
        <Series>
            <asp:Series Name="Series1" XValueMember="month" YValueMembers="count" IsValueShownAsLabel="true">
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </ChartAreas>
    </asp:Chart>
    <asp:SqlDataSource ID="PurchaseSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:adminConnectionString %>" ProviderName="<%$ ConnectionStrings:adminConnectionString.ProviderName %>" SelectCommand="SELECT  to_char(datapokupki, 'TMMonth') AS month, count(idpokupka)  FROM pokupka GROUP BY 1"></asp:SqlDataSource>
    <asp:SqlDataSource ID="UserSqlDataSource" runat="server"></asp:SqlDataSource>
    <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
</asp:Content>
