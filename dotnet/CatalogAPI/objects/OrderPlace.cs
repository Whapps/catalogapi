using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    /// <summary>
    /// For placing order directly, without a cart, using the <see cref="OrderPlace"/> method
    /// </summary>
    public class order_place
    {
        public order_place_request order_place_request { get; set; }
    }

   /// <summary>
   /// Details of placing an order without a cart
   /// </summary>
    public class order_place_request {
        
        /// <summary>
        /// The credentials for the request( don't fill this in, the <see cref="OrderPlace" method will take care of that for you />
        /// </summary>
        public Credentials credentials { get; set; }

        /// <summary>
        /// REQUIRED: This is the socket that the item is in. You can find your available 
        /// sockets by using the list_available_catalogs method.
        /// </summary>
        public string socket_id { get; set; }
        
        /// <summary>
        /// OPTIONAL: This is an id from your system that identifies the user that the order is for. 
        /// It can contain alphanumeric characters, dashes and underscores.
        /// </summary>
        public string external_user_id { get; set; }
        
        
        /// <summary>
        /// OPTIONAL: This is an id from your system that identifies the order. 
        /// It can contain alphanumeric characters, dashes and underscores. 
        /// 
        /// IMPORTANT: If you send this, it must be unique. 
        /// Our system will reject the order if an order was already 
        /// placed with the same external_order_number.
        /// </summary>
        public string external_order_number { get; set; }
        
        
        /// <summary>
        /// REQUIRED: The first name of who you are shipping to, Max length is 40 characters.
        /// </summary>
        public string first_name { get; set; }
        
        /// <summary>
        /// REQUIRED: The last name of who you are shipping to, Max length is 40 characters.
        /// </summary>
        public string last_name { get; set; }
        
        /// <summary>
        /// REQUIRED: 
        /// </summary>
        public string address_1 { get; set; }
        
        /// <summary>
        /// OPTIONAL: 
        /// </summary>
        public string address_2 { get; set; }
        
        /// <summary>
        /// OPTIONAL:
        /// </summary>
        public string address_3 { get; set; }
        
        
        /// <summary>
        /// REQUIRED:
        /// </summary>
        public string city { get; set; }
        
        /// <summary>
        /// REQUIRED:
        /// </summary>
        public string state_province { get; set; }
        
        /// <summary>
        /// REQUIRED:
        /// </summary>
        public string postal_code { get; set; }
        
        /// <summary>
        /// REQUIRED:
        /// </summary>
        public string country { get; set; }
        
        /// <summary>
        /// OPTIONAL
        /// </summary>
        public string phone_number { get; set; }
        
        /// <summary>
        /// OPTIONAL
        /// </summary>
        public string email { get; set; }
        
        /// <summary>
        /// REQUIRED: The items to ship
        /// </summary>
        public List<PlaceOrderItem> items { get; set; }
    }

    /// <summary>
    /// An item to order
    /// </summary>
    public class PlaceOrderItem
    {
        /// <summary>
        /// REQUIRED: The id of the item to order
        /// </summary>
        public int catalog_item_id { get; set; }
        
        /// <summary>
        /// REQUIRED: The quantity of the item to order
        /// </summary>
        public int quantity { get; set; }
        
        /// <summary>
        /// The currency to order in (eg. USD for US Dollars)
        /// </summary>
        public string currency { get; set; }
        
        /// <summary>
        /// REQUIRED: The current price of the item in the catalog. This is required as a check bit for the item.
        /// </summary>
        public decimal catalog_price { get; set; }
        
        /// <summary>
        /// OPTIONAL: The option_id of the item, if the item has options. This option_id must match the option_id the item already in the cart. Otherwise leave null
        /// </summary>
        public int? option_id { get; set; }
    }



    public class OrderPlaceResult
    {
        public Credentials credentials { get; set; }
        public string order_number { get; set; }
    }

    public class OrderPlaceResponse
    {
        public OrderPlaceResult order_place_result { get; set; }
    }



}









