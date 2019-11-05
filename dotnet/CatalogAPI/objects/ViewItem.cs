using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class ViewItemResult
    {
        public CatalogItem item { get; set; }
        public Credentials credentials { get; set; }
    }

    public class ViewItemResponse
    {
        public ViewItemResult view_item_result { get; set; }
    }
}
