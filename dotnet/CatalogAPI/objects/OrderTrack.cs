using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class Meta
    {
        public string key { get; set; }
        public string uri { get; set; }
        public string value { get; set; }
    }

    public class FulfillmentItem
    {
        public string order_item_id { get; set; }
    }

    public class Fulfillment
    {
        public string fulfillment_date { get; set; }


        /// <summary>
        /// The following metadata keys will be seen on physical items that are shipped.
        /// 
        /// SHIPPER - The name of the shipper that was used to send your item. (e.g., UPS)
        /// TRACKING - The tracking number of the shipment.
        /// 
        /// </summary>
        public List<Meta> metadata { get; set; }
        
        public FulfillmentItems items { get; set; }
    }

    public class Fulfillments
    {
        public List<Fulfillment> Fulfillment { get; set; }
    }

    public class FulfillmentItems
    {
        public List<FulfillmentItem> FulfillmentItem { get; set; }
    }

    public class OrderItems
    {
        public List<OrderItem> OrderItem { get; set; }
    }


    public class OrderItem
    {
        public string catalog_price { get; set; }
        public string name { get; set; }
        
        /// <summary>
        /// Processing - We are processing the order.
        /// Fulfilled - The item has been received by the participant. (i.e., the item Shipped)
        /// Backordered - The item is on backorder and we do not know when it will be Fullfilled.
        /// Pended - The item was pended because you do not have sufficient funds in your pool account. Once you make a payment this item will be processed if it is still available.
        /// Canceled - The item was canceled. Your pool account was refunded.
        /// </summary>
        public string order_item_status { get; set; }
        public string catalog_item_id { get; set; }
        public string currency { get; set; }
        public string order_item_id { get; set; }
        public string points { get; set; }
        public List<Meta> metadata { get; set; }
        public string order_item_status_id { get; set; }
        public string option { get; set; }
    }
    
    /// <summary>
    /// All details of a order when useing <see cref="OrderTrack"/>
    /// see catalogapi.com/docs/methods/order_track/ for full details
    /// </summary>
    public class Order
    {
        public string last_name { get; set; }
        public string external_user_id { get; set; }
        public string external_order_number { get; set; }
        public string date_placed { get; set; }
        public string is_test { get; set; }
        public string postal_code { get; set; }
        public string city { get; set; }
        public string first_name { get; set; }
        public Fulfillments fulfillments { get; set; }
        public string company_name { get; set; }
        public string name_prefix { get; set; }
        public string email { get; set; }
        public List<Meta> metadata { get; set; }
        public string phone_number { get; set; }
        public OrderItems items { get; set; }
        public string state_province { get; set; }
        public int gender { get; set; }
        public string name_suffix { get; set; }
        public string address_1 { get; set; }
        public string address_2 { get; set; }
        public string address_3 { get; set; }
        public string birth_date { get; set; }
        public string country { get; set; }
        public string order_number { get; set; }
    }

    public class OrderTrackResult
    {
        public Credentials credentials { get; set; }
        public Order order { get; set; }
    }

    public class OrderTrackResponse
    {
        public OrderTrackResult order_track_result { get; set; }
    }


    
}
