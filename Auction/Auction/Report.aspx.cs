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
    public partial class Report1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button1_Click(object sender, EventArgs e)
        {
           //TextBox1.Text = this.DropDownList1.SelectedValue + " | " + CheckBoxList1.Items[0].Selected + " | "
             //   + CheckBoxList1.Items[1].Selected +  " | " + TextBox1.Text;

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {

                connection.Open();
                NpgsqlCommand command = new NpgsqlCommand("INSERT INTO expertiza(idtovar, idexpert, opisanie, podlinosty, propaja,otchetprodavca, otchetadmin )  VALUES(@tovar, @idexpert, @opisanie, @podlinosty, @propaja,@otchetprodavca, @otchetadmin)", connection);
                command.Parameters.AddWithValue("tovar", Convert.ToInt32(DropDownList1.SelectedValue));
                command.Parameters.AddWithValue("idexpert", Convert.ToInt32(1));
                command.Parameters.AddWithValue("opisanie", TextBox1.Text);
                command.Parameters.AddWithValue("podlinosty", CheckBoxList1.Items[0].Selected);
                command.Parameters.AddWithValue("propaja", CheckBoxList1.Items[1].Selected);
                command.Parameters.AddWithValue("otchetprodavca", TextBox2.Text);
                command.Parameters.AddWithValue("otchetadmin", TextBox3.Text); 
                command.ExecuteNonQuery();
            }

            GridView1.DataBind();            
        }
    }
}