<%@ Page Title="" Language="C#" MasterPageFile="~/Expert.Master" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="Auction.Report1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div>
        
        <asp:Label ID="Label1" runat="server" Text="Новый отчет" Font-Bold="true" Font-Size="Large"></asp:Label>
        <br />
        <asp:Label ID="Label2" runat="server" Text="Товар "></asp:Label>
        
        <asp:DropDownList ID="DropDownList1" runat="server" DataSourceID="TovarSqlDataSource" DataTextField="name" DataValueField="idtovar" Height="67px" Width="165px">
        <asp:ListItem></asp:ListItem>
    </asp:DropDownList>
    <asp:CheckBoxList ID="CheckBoxList1" runat="server" Width="141px">
        <asp:ListItem Value="podlinosty">Подлинный</asp:ListItem>
        <asp:ListItem Value="propaja">Пропажа</asp:ListItem>
    </asp:CheckBoxList>
         <asp:TextBox ID="TextBox2" runat="server" TextMode="MultiLine" Width="25%">Отчет продавцу</asp:TextBox>
         <asp:TextBox ID="TextBox3" runat="server" TextMode="MultiLine" Width="25%">Отчет администратору</asp:TextBox>
        <asp:TextBox ID="TextBox1" runat="server" TextMode="MultiLine" Width="25%">Описание</asp:TextBox>
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Отправить" />
    <asp:SqlDataSource ID="TovarSqlDataSource" runat="server" ConnectionString="<%$ ConnectionStrings:expertConnectionString %>" ProviderName="<%$ ConnectionStrings:expertConnectionString.ProviderName %>" SelectCommand="SELECT idtovar, name FROM tovar LEFT JOIN expertiza ex USING(idtovar) WHERE idexpertiza IS NULL"></asp:SqlDataSource>
        
        <hr />
        <asp:Label ID="Label3" runat="server" Text="Все отчеты" Font-Bold="true" Font-Size="Large"></asp:Label>
        <asp:GridView ID="GridView1" runat="server" CssClass="Grid" AutoGenerateColumns="False" DataKeyNames="idtovar,idexpertiza" DataSourceID="SqlDataSource1" AllowPaging="True" AllowSorting="True">
            <Columns>
                <asp:BoundField DataField="idtovar" HeaderText="Код товара" InsertVisible="False" ReadOnly="True" SortExpression="idtovar" />
                <asp:BoundField DataField="idprodavec" HeaderText="idprodavec" SortExpression="idprodavec" Visible="False" />
                <asp:BoundField DataField="idtypetovara" HeaderText="idtypetovara" SortExpression="idtypetovara" Visible="False" />
                <asp:BoundField DataField="document" HeaderText="Документ" SortExpression="document" />
                <asp:BoundField DataField="name" HeaderText="Название товара" SortExpression="name" />
                <asp:BoundField DataField="fullname" HeaderText="Продавец" SortExpression="fullname" />
                <asp:BoundField DataField="sostoyanie" HeaderText="Состояние" SortExpression="sostoyanie" />
                <asp:BoundField DataField="stoimosty" HeaderText="Стоимость" SortExpression="stoimosty" />
                <asp:BoundField DataField="registration_date" HeaderText="Дата регистрации" SortExpression="registration_date" />
                <asp:BoundField DataField="idparenttype" HeaderText="idparenttype" SortExpression="idparenttype" Visible="False" />
                <asp:BoundField DataField="name1" HeaderText="Тип" SortExpression="name1" />
                <asp:BoundField DataField="idpolzovately" HeaderText="idpolzovately" SortExpression="idpolzovately" Visible="False" />
                <asp:BoundField DataField="idexpertiza" HeaderText="Номер экспертизы" InsertVisible="False" ReadOnly="True" SortExpression="idexpertiza" />
                <asp:BoundField DataField="idexpert" HeaderText="idexpert" SortExpression="idexpert" Visible="False" />
                <asp:CheckBoxField DataField="podlinosty" HeaderText="Подлиность" SortExpression="podlinosty" />
                <asp:CheckBoxField DataField="propaja" HeaderText="Пропажа" SortExpression="propaja" />
                <asp:BoundField DataField="opisanie" HeaderText="Описание" SortExpression="opisanie" />

            </Columns>
        </asp:GridView>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:expertConnectionString %>" ProviderName="<%$ ConnectionStrings:expertConnectionString.ProviderName %>" SelectCommand="SELECT *, pz.name || ' '|| pz.surname as fullname
            FROM tovar
            INNER JOIN typetovara t USING (idtypetovara)
            INNER JOIN prodavec p USING (idprodavec)
            INNER JOIN polzovately pz ON p.idpolzovately = pz.id
            LEFT JOIN expertiza ex USING(idtovar)
            WHERE idexpert= @idexpert;">
             <SelectParameters>  
            <asp:SessionParameter
                Name="idexpert"
                SessionField="idexpert"                
                Type="Int32"/> 
        </SelectParameters> 
        </asp:SqlDataSource>
    </div>
    
</asp:Content>
