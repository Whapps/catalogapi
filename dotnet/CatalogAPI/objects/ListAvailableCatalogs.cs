using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class ListAvailableCatalogsResult
    {
        public Credentials credentials { get; set; }
        public Domain domain { get; set; }
    }

    public class ListAvailableCatalogsResponse
    {
        public ListAvailableCatalogsResult list_available_catalogs_result { get; set; }
    }
}
