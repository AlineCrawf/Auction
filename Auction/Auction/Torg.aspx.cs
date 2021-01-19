using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Drawing;
using System.Web.UI.WebControls;
using Npgsql;
using System.Configuration;
using System.Threading;

using System.Runtime;

namespace Auction
{
    public partial class torg : System.Web.UI.Page
    {
        private int idtorg;
        //static System.Threading.Timer timer;
        int time = 30;

        protected void Page_PreInit(object sender, EventArgs e)
        {
            MasterPageFile = Application["masterPage"].ToString();
            //idtorg = (int) Session["idtorg"];
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            SqlDataSource1.ConnectionString = ConfigurationManager.ConnectionStrings[Application["ConnectionString"].ToString()].ConnectionString;

            Label1.Visible = false;
            TextBox1.BorderColor = Color.Black;
            Label1.Visible = true;
            //Label1.Text = "SSS" + Session["idtorg"];//idtorg.ToString();
            GridView1.DataBind();

             idtorg = Convert.ToInt32(Session["idtorg"]);//GridView1.Rows[1].Cells[1].Text);
            //timer = new System.Threading.Timer( new TimerCallback(Close_torg), null, 0, 30000);
           // Label1.Text = Application["user_phone"].ToString();
        }

        public void Close_torg()
        {
            Label1.Text = "Торг окончен";

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {

                connection.Open();
                NpgsqlCommand command = new
                NpgsqlCommand("Close_torg", connection);
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("p_idtorg", idtorg);

                command.ExecuteNonQuery();
            }
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            Label1.Visible = false;

            if (TextBox1.Text == "")
            {
                TextBox1.BorderColor = Color.Red;
                return;
            }
           // TextBox1.BorderColor = Color.Black;

          //  timer.Change(0,30000);

            using (NpgsqlConnection connection = new NpgsqlConnection(ConfigurationManager.ConnectionStrings["AuctionConnectionString"].ToString()))
            {

                connection.Open();
                // ID покупателя по номеру
                NpgsqlCommand idpokupatel_command = new NpgsqlCommand("user_id", connection);
                idpokupatel_command.CommandType = System.Data.CommandType.StoredProcedure;

                idpokupatel_command.Parameters.AddWithValue("p_phone", Application["user_phone"].ToString());
                int idpokupatel = (int) idpokupatel_command.ExecuteScalar();
                //Label1.Text = idpokupatel.ToString()";
               
                NpgsqlCommand command = new NpgsqlCommand("Insert into torg_history (idpokupatel, idtorg, stavka) " +
                    " values (@idpokupatel, @idtorg, @stavka)", connection);

                command.Parameters.AddWithValue("idtorg", idtorg);
                command.Parameters.AddWithValue("idpokupatel", idpokupatel);
                command.Parameters.AddWithValue("stavka", Convert.ToInt32(TextBox1.Text));

                //Label1.Text = idtorg.ToString();
                try
                {
                    command.ExecuteNonQuery();
                }
                catch
                {
                    TextBox1.BorderColor = Color.Red;
                    Label1.Text = "Ставка меньше последней";
                    Label1.Visible = true;                   
                }
            }

            GridView1.DataBind(); 
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            Close_torg();
        }

        protected void Timer1_Tick(object sender, EventArgs e)
        {
            time--;

            Label1.Text = time.ToString();

        }
    }
}