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
    public partial class Customer1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Label1.Text += Application["user_phone"].ToString();
            
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {

                connection.Open();
                NpgsqlCommand idpokupatel_command = new NpgsqlCommand("user_id", connection);
                idpokupatel_command.CommandType = System.Data.CommandType.StoredProcedure;

                idpokupatel_command.Parameters.AddWithValue("p_phone", Application["user_phone"].ToString());
                int idpokupatel = (int)idpokupatel_command.ExecuteScalar();
                Label1.Text = idpokupatel.ToString();


                NpgsqlCommand command = new
                NpgsqlCommand("UPDATE pokupatel SET prodavec_request = true WHERE idpokupatel = @idpokupatel", connection);
               // command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("idpokupatel", idpokupatel);

                command.ExecuteNonQuery();
            }
        }
    }
}