using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class Domain
    {
        public string redemption_active { get; set; }
        public string account_name { get; set; }
        public Sockets sockets { get; set; }
        public string account_description { get; set; }
        public string domain_name { get; set; }
    }
}
