<%@ Page Title="" Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="Request.aspx.cs" Inherits="Auction.Request" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
   
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">   
    <div>
            
    <asp:GridView ID="GridView1" runat="server"  CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="idpolzovately, telefon" DataSourceID="SqlDataSource1" OnSelectedIndexChanged="Unnamed1_SelectedIndexChanged">
                 <Columns>
                     <asp:CommandField ShowSelectButton="True" />
                     <asp:BoundField DataField="idpokupatel" HeaderText="idpokupatel" InsertVisible="False" ReadOnly="True" SortExpression="idpokupatel" />
                     <asp:BoundField DataField="idpolzovately" HeaderText="idpolzovately" SortExpression="idpolzovately" />
                     <asp:CheckBoxField DataField="prodavec_request" HeaderText="prodavec_request" SortExpression="prodavec_request" />
                     <asp:BoundField DataField="telefon" HeaderText="telefon" SortExpression="telefon" />
                 </Columns>
             </asp:GridView>
             <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:AuctionConnectionString %>" ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT  pk.*, pz.telefon
FROM pokupatel pk 
inner join polzovately pz on pz.id = pk.idpolzovately
 WHERE prodavec_request = true"></asp:SqlDataSource>
    </div>
</asp:Content>

