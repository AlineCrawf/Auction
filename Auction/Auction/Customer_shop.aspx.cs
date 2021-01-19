using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using Npgsql;

namespace Auction
{
    
    public partial class Customer : System.Web.UI.Page
    {
        private int idTovar = 0;

        public int IdTovar { get => idTovar; set => idTovar = value; }

        protected void Page_PreInit(object sender, EventArgs e)
        {
            MasterPageFile = Application["masterPage"].ToString();
        }
        protected void Page_InitComplete(object sender, EventArgs e)
        {
            Session.Add("user_phone", Application["user_phone"].ToString());
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()].ConnectionString;

        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            this.RadioButtonList1.Visible = true;
            this.TextBox1.Visible = true;
            this.Button1.Visible = true;
            Session["idTovar"] = IdTovar = Convert.ToInt32(GridView1.SelectedRow.Cells[1].Text);
            //Label1.Text = GridView1.SelectedRow.Cells[1].Text + IdTovar;
        }


        protected void Button1_Click(object sender, EventArgs e)
        {
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {
                
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("new_dostavka", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("idpokupka",  Convert.ToInt32(Session["idTovar"]));
                command.Parameters.AddWithValue("dostavka_type", RadioButtonList1.SelectedValue);
                command.Parameters.AddWithValue("adres", TextBox1.Text);
                
                command.ExecuteNonQuery();
            }

            GridView1.DataBind();
            GridView2.DataBind();

            this.RadioButtonList1.Visible = false;
            this.TextBox1.Visible = false;
            this.Button1.Visible = false;
        }

     
    }
}