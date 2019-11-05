using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class SearchCatalogResult
    {
        public Items items { get; set; }
        public Pager pager { get; set; }
        public Credentials credentials { get; set; }
    }

    public class SearchCatalogResponse
    {
        public SearchCatalogResult search_catalog_result { get; set; }
    }


    public class Items
    {
        public List<CatalogItem> CatalogItem { get; set; }
    }

}
