<%@ Page Title="" Language="C#" MasterPageFile="~/Seller.Master" AutoEventWireup="true" CodeBehind="Tovar_stat.aspx.cs" Inherits="Auction.Tovar_stat" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:Chart ID="Chart1" runat="server" DataSourceID="TovarStatSqlDataSource">
        <Series>
            <asp:Series Name="Series1" XValueMember="name" YValueMembers="customer_count" IsValueShownAsLabel="true">
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </ChartAreas>
        <Titles>
            <asp:Title Text="Количество покупателей сделавших ставки" >
            </asp:Title>
        </Titles>
    </asp:Chart>
    
    <asp:Chart ID="Chart2" runat="server" DataSourceID="TovarStatSqlDataSource">
        <Series>
            <asp:Series Name="Series1" XValueMember="name" YValueMembers="stavka_diff_perc" IsValueShownAsLabel="true">
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </ChartAreas>
        <Titles>
            <asp:Title Text="Разница начальной и конечной цены">
            </asp:Title>
        </Titles>
    </asp:Chart>
    <asp:Chart ID="Chart3" runat="server" DataSourceID="IncomeSqlDataSource">
        <Titles>
            <asp:Title Text="Доход по месецам">
            </asp:Title>
        </Titles>
        <Series>
            <asp:Series Name="Series1" XValueMember="month" YValueMembers="sum" IsValueShownAsLabel="true">
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </ChartAreas>
    </asp:Chart>
   <asp:Chart ID="Chart4" runat="server" DataSourceID="TypeSqlDataSource">
        <Titles>
            <asp:Title Text="Доход по категориям">
            </asp:Title>
        </Titles>
        <Series>
            <asp:Series Name="Series1" XValueMember="typetov" YValueMembers="sum" IsValueShownAsLabel="true">
            </asp:Series>
        </Series>
        <ChartAreas>
            <asp:ChartArea Name="ChartArea1">
            </asp:ChartArea>
        </ChartAreas>
    </asp:Chart>
    
<asp:SqlDataSource ID="TovarStatSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:sellerConnectionString %>" ProviderName="<%$ ConnectionStrings:sellerConnectionString.ProviderName %>" SelectCommand="
SELECT * FROM &quot;toplot_stat&quot; WHERE idprodavec=@idprodavec ">
    <SelectParameters>  
            <asp:SessionParameter
                Name="idprodavec"
                SessionField="idprodavec"
                
                Type="Int32"/> 
        </SelectParameters> 
</asp:SqlDataSource>
<asp:SqlDataSource ID="TypeSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:sellerConnectionString %>" ProviderName="<%$ ConnectionStrings:sellerConnectionString.ProviderName %>" SelectCommand="SELECT typetov, sum(income) from toplot_stat  WHERE idprodavec=@idprodavec GROUP BY typetov ">
    <SelectParameters>  
            <asp:SessionParameter
                Name="idprodavec"
                SessionField="idprodavec"                
                Type="Int32"/> 
        </SelectParameters> 
</asp:SqlDataSource>
 <asp:SqlDataSource ID="IncomeSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:sellerConnectionString %>" ProviderName="<%$ ConnectionStrings:sellerConnectionString.ProviderName %>" SelectCommand="SELECT month, sum(income) FROM &quot;toplot_stat&quot;  WHERE idprodavec=@idprodavec GROUP BY month">
     <SelectParameters>  
            <asp:SessionParameter
                Name="idprodavec"
                SessionField="idprodavec"                
                Type="Int32"/> 
        </SelectParameters> 
 </asp:SqlDataSource>
    

</asp:Content>

