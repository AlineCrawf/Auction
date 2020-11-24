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
    public partial class Request : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        
        protected void Unnamed1_SelectedIndexChanged(object sender, EventArgs e)
        {
            int idpolzovately = Convert.ToInt32(GridView1.SelectedDataKey.Values["idpolzovately"].ToString());

            
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()].ToString()))
            {

                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("Pokupatel_to_Prodavec", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_idpolzovately", idpolzovately);

                command.ExecuteNonQuery();
            }

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["UsersConnectionString"].ToString()))
            {
                string phone = GridView1.SelectedDataKey.Values["telefon"].ToString();
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("UPDATE login SET role = 3 WHERE phone = @phone", connection);
                command.Parameters.AddWithValue("phone", phone);

                command.ExecuteNonQuery();
            }

            GridView1.DataBind();
        }
    }
}