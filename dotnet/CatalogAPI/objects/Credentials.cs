using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    /// <summary>
    /// Credentials returns back with every Catalog API response
    /// </summary>
    public class Credentials
    {
        public string checksum { get; set; }
        public string method { get; set; }
        public string uuid { get; set; }
        public string datetime { get; set; }
    }
}
