using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class CatalogBreakdownResult
    {
        public Credentials credentials { get; set; }
        public Socket socket { get; set; }
        public Categories categories { get; set; }
    }

    public class CatalogBreakdownResponse
    {
        public CatalogBreakdownResult catalog_breakdown_result { get; set; }
    }
}
