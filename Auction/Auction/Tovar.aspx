<%@ Page Title="" Language="C#" MasterPageFile="~/Seller.Master" AutoEventWireup="true" CodeBehind="Tovar.aspx.cs" Inherits="Auction.Tovar" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:Label ID="lb" runat="server"></asp:Label>
 
    <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/Tovar_stat.aspx">Статистика</asp:HyperLink>
 
    <asp:GridView ID="GridView1" runat="server" CssClass="Grid" AllowSorting="True" AutoGenerateColumns="False" DataKeyNames="idtovar" DataSourceID="SqlDataSource1" ShowFooter="True" OnSelectedIndexChanged="GridView1_SelectedIndexChanged" >
        <Columns>
            <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" ShowHeader="True" />
            <asp:BoundField DataField="idtovar" HeaderText="idtovar" InsertVisible="False" ReadOnly="True" Visible="false" SortExpression="idtovar" />
           <asp:BoundField DataField="name" HeaderText="Название" SortExpression="name" />
            <asp:BoundField DataField="document" HeaderText="Документ" SortExpression="document" />
            <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                           
            
            <asp:BoundField DataField="idtypetovara" Visible="false" HeaderText="idtypetovara" SortExpression="idtypetovara" />
            <asp:BoundField DataField="type" HeaderText="Тип" InsertVisible="False" />
            <asp:TemplateField HeaderText="Тип" Visible="False">
            </asp:TemplateField>
            <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" Visible="false"/>
            <asp:BoundField DataField="stoimosty" HeaderText="Стоимость" SortExpression="stoimosty" />
            <asp:BoundField DataField="torg" HeaderText="Создан торг" />
            <asp:BoundField DataField="purchase" HeaderText="Продано" />
            <asp:TemplateField >
                <FooterTemplate>
                    <asp:Button ID="Button1" runat="server" Text="Добавить" OnClick="Button1_Click" />
                </FooterTemplate>               
            </asp:TemplateField>
        </Columns>
        <EmptyDataTemplate>
            У Вас нет товаров.
            <br />
            <asp:LinkButton ID="LinkButton1" runat="server"  OnClick="Button1_Click">Добавить товар</asp:LinkButton>
        </EmptyDataTemplate>
    </asp:GridView>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()] %>' DeleteCommand="DELETE FROM tovar WHERE (idtovar = @idtovar)" InsertCommand="INSERT INTO tovar(idtovar, document, name, sostoyanie, idtypetovara, idprodavec, stoimosty) VALUES (@idtovar, @document, @name, @sostoyanie ::sostoyanie_t, @idtypetovara, @idprodavec, @stoimosty)" ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="sELECT tovar.*, t.name as type, CASE when t2.idtovar IS NULL THEN 'Нет' ELSE 'Да'  END as torg,
       CASE when p.idtovar IS NULL THEN 'Нет' ELSE 'Да' END as purchase
FROM tovar
         INNER JOIN typetovara t USING (idtypetovara)
         LEFT JOIN pokupka p USING (idtovar)
         LEFT JOIN torg t2 USING (idtovar) WHERE idprodavec = @idprodavec" UpdateCommand="UPDATE tovar SET document = @document, name = @name, sostoyanie = @sostoyanie :: sostoyanie_t,  idprodavec = @idprodavec, stoimosty = @stoimosty WHERE (idtovar = @idtovar)">
        <SelectParameters>  
            <asp:SessionParameter
                Name="idprodavec"
                SessionField="idprodavec"
                
                Type="Int32"/> 
        </SelectParameters> 

        <DeleteParameters>
            <asp:Parameter Name="idtovar" Type="int32" />
        </DeleteParameters>
        <InsertParameters>
            <asp:Parameter Name="idtovar" Type="int32" />
            <asp:Parameter Name="document" Type="String" />
            <asp:Parameter Name="name" Type="String" />
            <asp:Parameter Name="sostoyanie" Type="String" />
            <asp:SessionParameter Name="idprodavec" SessionField="idprodavec"  Type="Int32"/>
            <asp:Parameter Name="stoimosty" Type="Decimal" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="document" Type="String" />
            <asp:Parameter Name="name" Type="String" />
            <asp:Parameter Name="sostoyanie" Type="String" />
            <asp:SessionParameter Name="idprodavec" SessionField="idprodavec"  Type="Int32"/>
            <asp:Parameter Name="stoimosty" Type="Decimal" />
            <asp:Parameter Name="idtovar" Type="int32" />
        </UpdateParameters>
    </asp:SqlDataSource>
    <asp:SqlDataSource ID="SqlDataSource3" runat="server" ConnectionString='<%# ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()] %>' ProviderName="<%$ ConnectionStrings:AuctionConnectionString.ProviderName %>" SelectCommand="SELECT * FROM &quot;typetovara&quot;"></asp:SqlDataSource>
      

    <asp:textbox
           id="idprodavec"
           runat="server" Visible="false" />

    <asp:TextBox ID="name" runat="server" PlaceHolder="Название" Visible="false"></asp:TextBox>
    <asp:TextBox ID="doc" runat="server" PlaceHolder="Документ" Visible="false"></asp:TextBox>
    <asp:DropDownList id="sostoyanieList"
                    runat="server" Visible="false">
                    
                  <asp:ListItem Selected="True" Value="novoe"> New </asp:ListItem>
                  <asp:ListItem  Value="B/U"> B/U </asp:ListItem>
    </asp:DropDownList>
    
    <asp:DropDownList id="typeList"
                    runat="server" Visible="False" DataSourceID="SqlDataSource3" DataTextField="name" DataValueField="idtypetovara" >                    
            
    </asp:DropDownList>
    <asp:TextBox ID="stoimosty" runat="server" PlaceHolder="Стоимость" Visible="false"  TextMode="Number"></asp:TextBox>

      
    <asp:Button ID="Button2" runat="server" Text="Подтвердить" Visible="false" OnClick="Button2_Click"/>

      
</asp:Content>
