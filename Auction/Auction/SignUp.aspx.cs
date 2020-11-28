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
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void sign_up_Click(object sender, EventArgs e)
        {
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["UsersConnectionString"].ToString()))
            {
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("add_login", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_phone", this.Phone.Text);
                command.Parameters.AddWithValue("p_password", this.passwordBox.Text);//GetMD5HashData(this.passwordBox.Text));

                command.ExecuteNonQuery();

            }

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {
                //add_user(p_name text, p_surname text,  p_udoslich text, p_phone text, p_email text)
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("add_user", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_name", this.Name.Text);
                command.Parameters.AddWithValue("p_surname", this.Surname.Text);
                command.Parameters.AddWithValue("p_udoslich", this.Udoslich.Text);
                command.Parameters.AddWithValue("p_phone", this.Phone.Text);
                command.Parameters.AddWithValue("p_email", this.Email.Text);
                //command.Parameters.AddWithValue("p_password", this.passwordBox.Text);//GetMD5HashData(this.passwordBox.Text));

                command.ExecuteNonQuery();

            }

            
        }
    }
}