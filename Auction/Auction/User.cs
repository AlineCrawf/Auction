using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Auction
{
    public class User
    {
        private string role;
        private string name, surname;


        public string Role { get => role; set => role = value; }
        public string Name { get => name; set => name = value; }
        public string Surname { get => surname; set => surname = value; }
    }
}