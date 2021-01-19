using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Npgsql;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Drawing;

namespace Auction
{
    public partial class Sign_In : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Application.Clear();
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            string role = "";
            string master = "", conn = "";

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["UsersConnectionString"].ToString()))
            {

                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("authentication", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_number", this.login.Text);
                command.Parameters.AddWithValue("p_password", this.password.Text);//GetMD5HashData(this.passwordBox.Text));
                

                try
                {
                    role = command.ExecuteScalar().ToString();
                }

                catch (Exception ex)
                {
                    login.BorderColor = password.BorderColor = Color.DarkRed;
                    return;
                }

                // Response.Cookies.Add( new HttpCookie("user_phone", this.login.Text));
                //Response.Cookies.Add(new HttpCookie("user_role", role));
                Application.Add("user_phone", this.login.Text);
                Application.Add("user_role", role);
                
            }
            switch (role)
                {
                    case "Customer": master = "Account.Master"; conn = "customerConnectionString"; break;
                    case "Seller": master = "Seller.Master"; conn = "sellerConnectionString";
                    using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
                    {
                        connection.Open();
                        NpgsqlCommand command1 = new NpgsqlCommand("SELECT idprodavec FROM prodavec INNER JOIN polzovately ON id = idpolzovately WHERE telefon = @p_phone", connection);
                        command1.Parameters.AddWithValue("p_phone", Application["user_phone"].ToString());
                        Session["idprodavec"] = command1.ExecuteScalar();
                    }
                                break;
                    case "Admin": master = "Admin.Master"; conn = "adminConnectionString"; break;
                }

                Application.Add("MasterPage", master);
                Application.Add("ConnectionString", conn);

            //login.Text =;

            
                // login.Text = Response.Cookies["user_phone"].Value.ToString() + " " + Response.Cookies["user_role"].Value.ToString();
            Response.Redirect("MainPage", false);
                // this.login.Text = Application.Get("user_phone").ToString();
            
        }
    }
}