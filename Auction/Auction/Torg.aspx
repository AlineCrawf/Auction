<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Account.Master" CodeBehind="Torg.aspx.cs" Inherits="Auction.torg" %>


 <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">   
        <div>
            <asp:GridView ID="GridView1" runat="server" CssClass="Grid" AutoGenerateColumns="False" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="user" HeaderText="Покупатель" SortExpression="user" />
                    <asp:BoundField DataField="time_stavka" HeaderText="Время ставки" SortExpression="time_stavka" />
                    <asp:BoundField DataField="idtorg" HeaderText="idtorg" SortExpression="idtorg" Visible="false" />
                    <asp:BoundField DataField="stavka" HeaderText="Ставка" SortExpression="stavka" />
                </Columns>
            </asp:GridView>
           
            <br />

            <asp:TextBox ID="TextBox1" runat="server" Height="16px" TextMode="Number" placeholder="Введите ставку" Width="199px"></asp:TextBox>

            <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Ставка" />
             <asp:Button ID="Button2" runat="server" OnClick="Button2_Click" Text="Закрыть торг" style="float:right"/>

            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()] %>' ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>"
                SelectCommand="Select pl.name ||' ' ||pl.surname as user, tg.time_stavka, tg.idtorg, tg.stavka
                                from torg_history tg
                                inner join pokupatel p on tg.idpokupatel = p.idpokupatel
                                inner join polzovately pl on p.idpolzovately = pl.id
                                WHERE idtorg = @idtorg">
                <SelectParameters>
                    <asp:CookieParameter CookieName="idtorg"  Name="idtorg" Type="Int32" />
                </SelectParameters>
            </asp:SqlDataSource>
            <asp:Label ID="Label1" runat="server" Visible="false"></asp:Label>
        </div>
</asp:Content>
