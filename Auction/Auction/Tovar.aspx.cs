using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Npgsql;
using System.Configuration;

namespace Auction
{
    public partial class Tovar : System.Web.UI.Page
    {
        private int v_idprodavec = 0;
        protected void Page_PreInit(object sender, EventArgs e)
        {
            MasterPageFile = Application["masterPage"].ToString();

                      
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            //GridView1.EmptyDataText = "У Вас нет товаров";
            //this.idprodavec.Text = v_idprodavec.ToString();
            // lb.Text = Session["idprodavec"].ToString();
            //GridView1.DataBind();
            SqlDataSource3.ConnectionString = SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()].ConnectionString;

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            name.Visible = doc.Visible = sostoyanieList.Visible = stoimosty.Visible = typeList.Visible = Button2.Visible = true;


        }

        protected object select_idprodavec()
        {
            return v_idprodavec;
        }
        protected void Button2_Click(object sender, EventArgs e)
        {
            
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {

                connection.Open();
                NpgsqlCommand command = new NpgsqlCommand(
                    "INSERT INTO tovar(document, name, sostoyanie, idtypetovara, idprodavec, stoimosty) " +
                    "VALUES (@document, @name, @sostoyanie::sostoyanie_t, @idtypetovara, @idprodavec, @stoimosty )"
                    , connection);

                 command.Parameters.AddWithValue("document", doc.Text);
                command.Parameters.AddWithValue("name", name.Text);                                                                                                                                                                                                                                                         
                command.Parameters.AddWithValue("sostoyanie", sostoyanieList.SelectedValue);
                command.Parameters.AddWithValue("idtypetovara", Convert.ToInt32(typeList.SelectedValue));
                command.Parameters.AddWithValue("idprodavec", Session["idprodavec"]);
                command.Parameters.AddWithValue("stoimosty", Convert.ToInt32(stoimosty.Text));

                command.ExecuteNonQuery();
            }

                GridView1.DataBind();

            name.Visible = doc.Visible = sostoyanieList.Visible = stoimosty.Visible = typeList.Visible = Button2.Visible = false;

        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

       
        protected void Button3_Click(object sender, EventArgs e)
        {
            name.Text = GridView1.SelectedIndex.ToString();
            name.Visible = true;
        }
    }
}

///<!--asp:CookieParameter CookieName="idprodavec" Name="idprodavec" Type="Int32" /-->
