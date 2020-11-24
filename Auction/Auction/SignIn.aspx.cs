using System;
using System.Web;
using Npgsql;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Drawing;
using System.Web.SessionState;

namespace Auction
{
    public partial class SignIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void sign_in_Click(object sender, EventArgs e)
        {
            MD5 md5 = MD5.Create();
            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["UsersConnectionString"].ToString()))
            {
                
                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("authentication", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_number", this.login.Text);
                command.Parameters.AddWithValue("p_password", this.passwordBox.Text);//GetMD5HashData(this.passwordBox.Text));
                string role = "";

                try
                { 
                    role = command.ExecuteScalar().ToString();
                }

                catch(Exception ex)
                {
                    login.BorderColor = passwordBox.BorderColor = Color.DarkRed;
                    return;
                }

                // Response.Cookies.Add( new HttpCookie("user_phone", this.login.Text));
                //Response.Cookies.Add(new HttpCookie("user_role", role));
                Application.Add("user_phone", this.login.Text);
                Application.Add("user_role", role);
                string master = "", conn="";

                switch(role)
                {
                    case "Customer": master = "Account.Master"; conn = "CustomerConnectionString"; break;
                    case "Seller": master = "Seller.Master"; conn = "SellerConnectionString"; break;
                    case "Admin": master = "Admin.Master"; conn = "AdminConnectionString"; break;
                }

                Application.Add("MasterPage", master);
                Application.Add("ConnectionString", conn);

                login.Text = "";

               // login.Text = Response.Cookies["user_phone"].Value.ToString() + " " + Response.Cookies["user_role"].Value.ToString();
                 Response.Redirect("MainPage", false);
                // this.login.Text = Application.Get("user_phone").ToString();
            }
        }

        private string GetMD5HashData(string data)
        {
            //create new instance of md5
            MD5 md5 = MD5.Create();

            //convert the input text to array of bytes
            byte[] hashData = md5.ComputeHash(Encoding.Default.GetBytes(data));

            //create new instance of StringBuilder to save hashed data
            StringBuilder returnValue = new StringBuilder();

            //loop for each byte and add it to StringBuilder
            for (int i = 0; i < hashData.Length; i++)
            {
                returnValue.Append(hashData[i].ToString());
            }

            // return hexadecimal string
            return returnValue.ToString();

        }
    }


}