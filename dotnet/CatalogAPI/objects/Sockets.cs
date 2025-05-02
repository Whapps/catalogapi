using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class Socket
    {
        public string language { get; set; }
        public string socket_name { get; set; }
        public string region { get; set; }
        public string export_uri { get; set; }
        public string socket_id { get; set; }
        public string currency { get; set; }
        public string point_to_currency_ratio { get; set; }
    }

    public class Sockets
    {
        public List<Socket> Socket { get; set; }
    }
}
