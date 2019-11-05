using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{

    #region [View Cart & Items]

        /// <summary>
        /// Details of an item in a user's cart
        /// </summary>
        public class CartItem
        {
            /// <summary>
            /// The price of the item when it was added to the cart
            /// </summary>
            public string cart_price { get; set; }
            
            /// <summary>
            /// The id of the item in the catalog
            /// </summary>
            
            public int catalog_item_id { get; set; }
            /// <summary>
            /// The current point value of the item in the catalog.
            /// </summary>
            public int catalog_points { get; set; }
            
            /// <summary>
            /// The current price of the item in the catalog. 
            /// If the price went up, the cart will not validate. 
            /// You can update the item to the current price by removing it, then re-adding it 
            /// with the cart_set_item_quantity method. This is the price we charge you for the item.
            /// </summary>
            public string catalog_price { get; set; }

            public string currency { get; set; }

            /// <summary>
            ///  If there is a problem with the item that is causing 
            ///  the cart to be invalid, this will be the reason.
            /// </summary>
            public string error { get; set; }
            
            
            public string image_uri { get; set; }
            
            /// <summary>
            /// This will be 1 if the item is available, or 0 if it is not. If it possible that an item can become 
            /// unavailable after being added to the cart if the item sits in the cart for a long period of time.
            /// </summary>
            public int is_available { get; set; }

            /// <summary>
            /// is_valid - This will be 1 if the cart is valid and 0 if it is invalid. 
            /// The cart must be valid before you can place an order for the cart contents.
            /// </summary>
            public int is_valid { get; set; }
            
            /// <summary>
            /// The name of the item
            /// </summary>
            public string name { get; set; }
            
            /// <summary>
            /// The point value of the item when it was added to the cart. 
            /// You can display points to your users instead of actual prices. 
            /// (In hindsight, we should have called this "cart_points")
            /// </summary>
            public int points { get; set; }

            /// <summary>
            /// The quantity for the item
            /// </summary>
            public int quantity { get; set; }
            
            /// <summary>
            /// The MSRP of the item. This is for informational use only.
            /// </summary>
            public string retail_price { get; set; }

            /// <summary>
            /// The estimated shipping price of the item.
            /// This is for informational use only. 
            /// Shipping costs are already included in the catalog price.
            /// </summary>
            public string shipping_estimate { get; set; }
        }

        /// <summary>
        /// A list of items in a users cart
        /// </summary>
        public class CartItems
        {
            public List<CartItem> CartItem { get; set; }
        }

        
        /// <summary>
        /// Details of a users cart
        /// </summary>
        public class CartViewResult
        {

            public Credentials credentials { get; set; }
            
            public string address_1 { get; set; }
            public string address_2 { get; set; }
            public string address_3 { get; set; }
            public string city { get; set; }
            public string country { get; set; }
            public string email { get; set; }
            public string phone_number { get; set; }
            public string postal_code { get; set; }
            public string state_province { get; set; }
            
            /// <summary>
            /// This value changes any time the cart is modified. 
            /// This includes adding/removing items, updating the address, and locking the cart.
            /// </summary>
            public string cart_version { get; set; }
            
            /// <summary>
            /// If the cart is not valid, this will contain the reason.
            /// </summary>
            public string error { get; set; }
            
            public string first_name { get; set; }
            
            /// <summary>
            /// If there is an error for one or more items in the cart, this will be 1
            /// </summary>
            public int has_item_errors { get; set; }
            
            /// <summary>
            /// This will be 1 if the cart is valid and 0 if it is invalid. 
            /// The cart must be valid before you can place an order for the cart contents.
            /// </summary>
            public int is_valid { get; set; }
            
            /// <summary>
            /// The items in the cart
            /// </summary>
            public CartItems items { get; set; }
            
            public string last_name { get; set; }
            
            /// <summary>
            /// This will be 1 if the cart is locked or 0 if the cart is not locked.
            /// </summary>
            public int locked { get; set; }
            
            /// <summary>
            /// If the cart doesn't yet have an addres, this will be 1. Use the CartSetAddress method
            /// to give a valid shipping address
            /// </summary>
            public int needs_address { get; set; }
            
           
        }

        public class CartViewResponse
        {
            public CartViewResult cart_view_result { get; set; }
        }

    #endregion



    #region [Cart Place Order]

    public class CartOrderPlaceResult
        {
            public Credentials credentials { get; set; }
            public string order_number { get; set; }
        }

        public class CartOrderPlaceResponse
        {
            public CartOrderPlaceResult cart_order_place_result { get; set; }
        }

    #endregion



    #region [Cart Validation]

    public class CartValidateResult
        {
            public Credentials credentials { get; set; }
            public string description { get; set; }
        }

        public class CartValidateResponse
        {
            public CartValidateResult cart_validate_result { get; set; }
        }

    #endregion


    #region [Cart Add Item]


        /// <summary>
        ///  Result of an item being added to a cart
        /// </summary>
        public class CartAddItemResult
        {
            public Credentials credentials { get; set; }
            /// <summary>
            /// Description of result
            /// </summary>
            public string description { get; set; }

        }


        /// <summary>
        /// Response wrapper when an item is added to a cart
        /// </summary>
        public class CartAddItemResponse
        {
            public CartAddItemResult cart_add_item_result { get; set; }
        }

    #endregion

    #region [Cart Remove Item]

        public class CartRemoveItemResult
        {
            public Credentials credentials { get; set; }
            public string description { get; set; }
        }

        public class CartRemoveItemResponse
        {
            public CartRemoveItemResult cart_remove_item_result { get; set; }
        }

    #endregion


    #region [Cart Set Quantity]
        
        public class CartSetItemQuantityResult
        {
            public Credentials credentials { get; set; }
            public string description { get; set; }
        }

        public class CartSetItemQuantityResponse
        {
            public CartSetItemQuantityResult cart_set_item_quantity_result { get; set; }
        }

    #endregion


    #region [Cart Set Address]

        public class CartSetAddressResult
        {
            public Credentials credentials { get; set; }
            public string description { get; set; }
        }

        public class CartSetAddressResponse
        {
            public CartSetAddressResult cart_set_address_result { get; set; }
        }

    #endregion


}
