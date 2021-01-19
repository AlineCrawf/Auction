<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Customer_shop.aspx.cs" Inherits="Auction.Customer" MasterPageFile="~/Account.master"%>


<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div>
        <asp:Label ID="Label2" runat="server" Text="Новые товары"></asp:Label>
        <asp:GridView ID="GridView1" runat="server" CssClass="Grid" DataKeyNames="idpokupka" AutoGenerateColumns="False" DataSourceID="SqlDataSource1" AllowSorting="True" OnSelectedIndexChanged="GridView1_SelectedIndexChanged">
            <Columns>
                <asp:CommandField SelectText="Доставка" ShowSelectButton="True" />
                <asp:BoundField DataField="idpokupka" HeaderText="Номер покупки" SortExpression="idpokupka" />
                <asp:BoundField DataField="phone" HeaderText="Номер телефона" SortExpression="phone" />
                
                <asp:BoundField DataField="datapokupki" HeaderText="Дата покупки" SortExpression="datapokupki" />
                <asp:BoundField DataField="itogstoimosty" HeaderText="Цена" SortExpression="itogstoimosty" />
                <asp:BoundField DataField="tovar" HeaderText="Товар" SortExpression="tovar" />
                <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                <asp:BoundField DataField="name" HeaderText="Тип" SortExpression="name" />
                <asp:BoundField DataField="prodavec" HeaderText="Продавец" SortExpression="prodavec" />
            </Columns>
            <EmptyDataTemplate>
                Список новых товаров пуст. Примите участие в торгах.
            </EmptyDataTemplate>
        </asp:GridView>

        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()].ConnectionString %>' ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT * FROM pokupki
LEFT JOIN dostavka d on pokupki.idpokupka = d.idpokupka
WHERE dostavka IS NULL and phone = @phone">
            <SelectParameters>
                <asp:SessionParameter Name="phone" SessionField="user_phone" />
            </SelectParameters>
        </asp:SqlDataSource>

        <asp:RadioButtonList ID="RadioButtonList1" runat="server" Visible="false">
             <asp:ListItem Selected="True" Value="Pochta">Почта</asp:ListItem>
        <asp:ListItem Value="Samovivoz">Самовывоз</asp:ListItem>
        <asp:ListItem Value="Kuryerskaya">Курьером</asp:ListItem>
        </asp:RadioButtonList>

        <br />

    </div>
    <asp:TextBox ID="TextBox1" runat="server" Visible="False" Width="209px">Адрес</asp:TextBox>
    <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Подтвердить" Visible="False" />

    <br/><br />
    <asp:Label ID="Label1" runat="server" Text="Доставка"></asp:Label>

    <asp:GridView ID="GridView2" runat="server" CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="iddostavka" DataSourceID="SqlDataSource2">
        <Columns>
            <asp:BoundField DataField="idpokupka" HeaderText="Номер покупки" SortExpression="idpokupka" />
                <asp:BoundField DataField="phone" HeaderText="Номер телефона" SortExpression="phone" />                
                <asp:BoundField DataField="datapokupki" HeaderText="Дата покупки" SortExpression="datapokupki" />
                <asp:BoundField DataField="itogstoimosty" HeaderText="Цена" SortExpression="itogstoimosty" />
                <asp:BoundField DataField="tovar" HeaderText="Товар" SortExpression="tovar" />
                <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                <asp:BoundField DataField="name" HeaderText="Тип" SortExpression="name" />
                <asp:BoundField DataField="prodavec" HeaderText="Продавец" SortExpression="prodavec" />
                <asp:BoundField DataField="dostavka" HeaderText="Тип доставки" SortExpression="prodavec" />
                <asp:BoundField DataField="adress" HeaderText="Адрес доставки" SortExpression="prodavec" />
                <asp:BoundField DataField="registgration_date" HeaderText="Дата создания доставки" SortExpression="prodavec" />
        </Columns>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource2" runat="server" ConnectionString="<%$ ConnectionStrings:customerConnectionString %>" ProviderName="<%$ ConnectionStrings:customerConnectionString.ProviderName %>" SelectCommand="SELECT * FROM pokupki
INNER JOIN dostavka d on pokupki.idpokupka = d.idpokupka"></asp:SqlDataSource>
</asp:Content>