using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class OrderSummary
    {
        public string order_number { get; set; }
        public string date_placed { get; set; }
    }

    public class Orders
    {
        public List<OrderSummary> OrderSummary { get; set; }
    }

    public class OrderListResult
    {
        public Credentials credentials { get; set; }
        public Pager pager { get; set; }
        public Orders orders { get; set; }
    }

    public class OrderListResponse
    {
        public OrderListResult order_list_result { get; set; }
    }
}
