using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Auction
{
    public partial class Customer : System.Web.UI.Page
    {
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
            
        }
    }
}