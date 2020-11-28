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
    public partial class TovarWithoutTorg : System.Web.UI.Page
    {
        private int v_idprodavec;
        protected void Page_PreInit(object sender, EventArgs e)
        {
            MasterPageFile = Application["masterPage"].ToString();

            HttpCookie cookie = new HttpCookie("idprodavec");

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {

                connection.Open();
                NpgsqlCommand command = new NpgsqlCommand("SELECT idprodavec FROM prodavec INNER JOIN polzovately ON id = idpolzovately WHERE telefon = @p_phone", connection);
                command.Parameters.AddWithValue("p_phone", Application["user_phone"].ToString());

                v_idprodavec = (int)command.ExecuteScalar();
                cookie.Value = v_idprodavec.ToString();
            }

            Response.Cookies.Add(cookie);
        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {
                
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("new_torg", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_idtovar", Convert.ToInt32(GridView1.SelectedRow.Cells[1].Text));
                command.Parameters.AddWithValue("p_min_stavka", Convert.ToInt32(GridView1.SelectedRow.Cells[7].Text));

                command.ExecuteNonQuery();
            }

            GridView1.DataBind();
        }
    }
}