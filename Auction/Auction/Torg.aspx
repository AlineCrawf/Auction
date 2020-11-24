<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Account.Master" CodeBehind="Torg.aspx.cs" Inherits="Auction.torg" %>


 <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">   
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="idtorg_history, idtorg" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="idtorg_history" HeaderText="idtorg_history" InsertVisible="False" ReadOnly="True" SortExpression="idtorg_history" />
                    <asp:BoundField DataField="idpokupatel" HeaderText="idpokupatel" SortExpression="idpokupatel" />
                    <asp:BoundField DataField="idtorg" HeaderText="idtorg" SortExpression="idtorg" />
                    <asp:BoundField DataField="stavka" HeaderText="stavka" SortExpression="stavka" />
                </Columns>
            </asp:GridView>
           
            <br />

            <asp:TextBox ID="TextBox1" runat="server" Height="16px" TextMode="Number" placeholder="Введите ставку" Width="199px"></asp:TextBox>

            <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Ставка" />
             <asp:Button ID="Button2" runat="server" OnClick="Button2_Click" Text="Закрыть торг" style="float:right"/>

            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:AuctionConnectionString %>" ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>"
                SelectCommand="SELECT * FROM torg_history where idtorg = @idtorg">
                <SelectParameters>
                    <asp:CookieParameter CookieName="idtorg"  Name="idtorg" Type="Int32" />
                </SelectParameters>
            </asp:SqlDataSource>
            <asp:Label ID="Label1" runat="server" Visible="true"></asp:Label>
        </div>
</asp:Content>
