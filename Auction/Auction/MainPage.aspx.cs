using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Auction
{
    public partial class MainPage : System.Web.UI.Page
    {
        protected void Page_PreInit(object sender, EventArgs e)
        {
            MasterPageFile = Application["masterPage"].ToString();
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            Label1.Text = Application["user_phone"].ToString();
        }



        protected void GridView2_SelectedIndexChanged(object sender, EventArgs e)
        {
           // Label1.Text = GridView2.SelectedDataKey.Values["idtorg"].ToString();

            string idtorg = GridView2.SelectedDataKey.Values["idtorg"].ToString();

            Response.Cookies.Add(new HttpCookie("idtorg", idtorg));
            

            Response.Redirect("torg", false);
            
        }

    }
}