
using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security;
using System.Security.Cryptography;
using Newtonsoft.Json;


//Uses RestSharp REST and HTTP API Client: see http://restsharp.org/
using RestSharp;



namespace Whapps.CatalogAPI
{

    /// <summary>
    /// Catalog API using REST endpoint
    /// </summary>
    public class Api 
    {

        /// <summary>
        /// The key for accessing the Catalog API service (stored in app/web.config)
        /// </summary>
        private String key
        {
            get
            {
                return ConfigurationManager.AppSettings.Get("CatalogApiKey");
            }
        }
        
        /// <summary>
        /// The base url to the Catalog API service (stored in app/web.config)
        /// </summary>
        public string BaseUrl {
            get {
                return ConfigurationManager.AppSettings.Get("CatalogApiUrl");
            }
        }

        /// <summary>
        /// The url to the Catalog API place_order endpoint
        /// </summary>
        public string PlaceOrderUrl
        {
            get
            {
                return ConfigurationManager.AppSettings.Get("CatalogApiOrderPlaceUrl");
            }
        }

        #region [Catalog & Item Display Methods]

            /// <summary>
            /// Lists available catalogs for your account
            /// </summary>
            /// <returns></returns>
            public ListAvailableCatalogsResponse ListAvailableCatalogs() {
            
                var r = new RestRequest("list_available_catalogs");
                r.RootElement = "list_available_catalogs_response";
                return Execute<ListAvailableCatalogsResponse>(r);

            }

            /// <summary>
            /// Returns a tree of all categories for the specified catalog
            /// </summary>
            /// <param name="socketId">
            /// REQUIRED: This is the socket you want to receive the breakdown for. 
            /// You can find your available sockets by using the list_available_catalogs method.
            /// </param>
            /// <param name="tag">
            /// OPTIONAL: We have the ability to "tag" certain items based on custom criteria 
            /// that is unique to our clients. If we setup these tags on your catalog, you can pass
            /// a tag name to receive back only categories that contain items matching the tag.
            /// </param>
            /// <returns></returns>
            public CatalogBreakdownResponse ListCatalogBreakdown(int socketId, string tag = null)
            {
                var r = new RestRequest("catalog_breakdown");

                r.AddQueryParameter("socket_id", socketId.ToString());
            
                //optional params
                if (!String.IsNullOrEmpty(tag))
                {
                    r.AddQueryParameter("tag", tag);
                }

                r.RootElement = "catalog_breakdown_response";

                return Execute<CatalogBreakdownResponse>(r);
            }



            /// <summary>
            /// Searches a catalog by socket id, with optional search parameters
            /// </summary>
            /// <param name="socketId">The socket id of the catalog to search. 
            /// You can find your available sockets by using the ListAvilableCatalogs method.</param>
            /// <param name="options">Optional: A SearchOptions object</param>
            /// <returns>A list of paged results</returns>
            public SearchCatalogResponse SearchCatalog(int socketId, SearchOptions options = null) {

                var r = new RestRequest("search_catalog");

                r.RootElement = "search_catalog_response";
                

                r.AddQueryParameter("socket_id", socketId.ToString());

                if (options != null)
                {
                    if (!String.IsNullOrEmpty(options.Name)) 
                        r.AddQueryParameter("name", options.Name);

                    if (!String.IsNullOrEmpty(options.Search)) 
                        r.AddQueryParameter("search", options.Search);
                
                    if (options.CategoryId.HasValue) 
                        r.AddQueryParameter("category_id", options.CategoryId.Value.ToString());
                
                    if (options.MinPoints.HasValue) 
                        r.AddQueryParameter("min_points", options.MinPoints.Value.ToString());
                
                    if (options.MaxPoints.HasValue) 
                        r.AddQueryParameter("max_points", options.MaxPoints.Value.ToString());
                
                    if (options.MinPrice.HasValue) 
                        r.AddQueryParameter("min_price", options.MinPrice.Value.ToString());
                
                    if (options.MaxPrice.HasValue) 
                        r.AddQueryParameter("max_price", options.MaxPrice.Value.ToString());
                
                    if (options.MaxRank.HasValue) 
                        r.AddQueryParameter("max_rank", options.MaxRank.Value.ToString());
                
                    if (!String.IsNullOrEmpty(options.Tag)) 
                        r.AddQueryParameter("tag", options.Tag);
                
                    if (options.Page.HasValue) 
                        r.AddQueryParameter("page", options.Page.Value.ToString());
                
                    if (options.PerPage.HasValue) 
                        r.AddQueryParameter("per_page", options.PerPage.Value.ToString());


                    var sort = String.Empty;

                    switch (options.Sort)
                    {
                        case SortOptionEnum.auto:
                            break;
                        case SortOptionEnum.scoreDesc:
                            sort = "sort desc";
                            break;
                        case SortOptionEnum.rankAsc:
                            sort = "rank asc";
                            break;
                        case SortOptionEnum.pointsDesc:
                            sort = "points desc";
                            break;
                        case SortOptionEnum.pointsAsc:
                            sort = "points asc";
                            break;
                        case SortOptionEnum.randomAsc:
                            sort = "random asc";
                            break;
                        default:
                            break;
                    }

                    if (!String.IsNullOrEmpty(sort))
                        r.AddQueryParameter("sort", sort);

                }

                return Execute<SearchCatalogResponse>(r);

            }

            public ViewItemResponse ViewItem(int socketId, int itemId)
            {
                var r = new RestRequest("view_item");
                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("catalog_item_id", itemId.ToString());
                r.RootElement = "view_item_response";

                return Execute<ViewItemResponse>(r);
            }

        #endregion



       #region [Cart Management Methods]

           

            /// <summary>
            /// </summary>
            /// <param name="socketId">The socket id of the catalog where the cart is </param>
            /// <param name="externalUserId">This is an id from your system that identifies the user that the cart is for. 
            /// It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <param name="cartAddress">The shipping address info for the cart. See <see cref="CartAddress"/> </param>
            public CartSetAddressResponse CartSetAddress(int socketId, string externalUserId, CartAddress cartAddress)
            {
                var r = new RestRequest("cart_set_address");
                
                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);
                r.AddQueryParameter("first_name", cartAddress.FirstName);
                r.AddQueryParameter("last_name", cartAddress.LastName);
                r.AddQueryParameter("address_1", cartAddress.Address1);

                if (!String.IsNullOrWhiteSpace(cartAddress.Address2))
                    r.AddQueryParameter("address_2", cartAddress.Address2);

                if (!String.IsNullOrWhiteSpace(cartAddress.Address3))
                    r.AddQueryParameter("address_3", cartAddress.Address3);

                r.AddQueryParameter("city", cartAddress.City);
                r.AddQueryParameter("state_province", cartAddress.StateProvince);
                r.AddQueryParameter("postal_code", cartAddress.PostalCode);
                r.AddQueryParameter("country", cartAddress.Country);

                if (!String.IsNullOrWhiteSpace(cartAddress.Email))
                    r.AddQueryParameter("email", cartAddress.Email);

                if (!String.IsNullOrWhiteSpace(cartAddress.PhoneNumber))
                    r.AddQueryParameter("phone_number", cartAddress.PhoneNumber);
                
                r.RootElement = "cart_set_address_response";

                

                return Execute<CartSetAddressResponse>(r);
            }

            

            /// <summary>
            /// Add an item to a users cart
            /// </summary>
            /// <param name="socketId">This is the socket that the item is in. You can find your available sockets by using the list_available_catalogs method.</param>
            /// <param name="externalUserId">This is an id from your system that identifies the user that the cart is for. It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <param name="catalogItemId">The catalog_item_id from the <see cref="SearchCatalog"/> method.</param>
            /// <param name="quantity">The number of items to add. If this item is already in the cart, this quantity will be added to the current quantity.</param>
            /// <param name="optionId">The option_id from the search_catalog method. (This is required for items that have options.) Otherwise leave null.</param>
            /// <returns></returns>
            public CartAddItemResponse CartAddItem(int socketId, string externalUserId, int catalogItemId, int quantity, int? optionId = null)
            {
                var r = new RestRequest("cart_add_item");
                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);
                r.AddQueryParameter("catalog_item_id", catalogItemId.ToString());
                r.AddQueryParameter("quantity", quantity.ToString());

                if (optionId.HasValue)
                    r.AddQueryParameter("option_id", optionId.Value.ToString());

                r.RootElement = "cart_add_item_response";

                return Execute<CartAddItemResponse>(r);
            }


            /// <summary>
            /// Change the quantity of an item in a users cart. Note: The quantity passed to this call overrides the quantity of a duplicate item.
            /// </summary>
            /// <param name="socketId">This is the socket that the item is in. You can find your available sockets by using the list_available_catalogs method.</param>
            /// <param name="externalUserId">his is an id from your system that identifies the user that the cart is for. It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <param name="catalogItemId">The catalog_item_id from the <see cref="SearchCatalog"/> method.</param>
            /// <param name="quantity">The quantity to set for this item. If the item isn't already in the cart, the item will be added and the quantity will be set to this amount</param>
            /// <param name="optionId">The option_id from the search_catalog method. (This is required for items that have options.) Otherwise leave null.</param>
            /// <returns></returns>
            public CartSetItemQuantityResponse CartSetItemQuantity(int socketId, string externalUserId, int catalogItemId, int quantity, int? optionId = null)
            {
                var r = new RestRequest("cart_set_item_quantity");
                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);
                r.AddQueryParameter("catalog_item_id", catalogItemId.ToString());
                r.AddQueryParameter("quantity", quantity.ToString());

                if (optionId.HasValue)
                    r.AddQueryParameter("option_id", optionId.Value.ToString());

                r.RootElement = "cart_set_item_quantity_response";
                


                return Execute<CartSetItemQuantityResponse>(r);
            }

            /// <summary>
            /// Remove an item from a users cart
            /// </summary>
            /// <param name="socketId">This is the socket that the item is in. You can find your available sockets by using the list_available_catalogs method.</param>
            /// <param name="externalUserId">This is an id from your system that identifies the user that the cart is for. It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <param name="catalogItemId">The catalog_item_id of the item. This item must already exist in the cart.</param>
            /// <param name="quantity">The quantity to decrement this item by. Defaults to the current quantity.</param>
            /// <param name="optionId">The option_id of the item, if the item has options. This option_id must match the option_id the item already in the cart. Otherwise leave null</param>
            /// <returns></returns>
            public CartRemoveItemResponse CartRemoveItem(int socketId, string externalUserId, int catalogItemId, int? quantity = null, int? optionId = null)
            {
                var r = new RestRequest("cart_remove_item");
                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);
                r.AddQueryParameter("catalog_item_id", catalogItemId.ToString());
                
                if (quantity.HasValue)
                    r.AddQueryParameter("quantity", quantity.Value.ToString());

                if (optionId.HasValue)
                    r.AddQueryParameter("option_id", optionId.Value.ToString());

                r.RootElement = "cart_remove_item_response";
                


                return Execute<CartRemoveItemResponse>(r);
            }

            public RestResponse CartEmpty(int socketId, string externalUserId)
            {
                var r = new RestRequest("cart_empty");

                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);

                
                return Execute(r);
                
            }

            
            /// <summary>
            /// Returns the current address and items in the cart.
            /// </summary>
            /// <remarks>
            /// This method can also be used to validate the cart. 
            /// While you can use the cart_validate method for this purpose, cart_validate will simply 
            /// throw a fault if the cart is invalid. You can use the results from the cart_view method to find all of 
            /// the problems with a cart in order to display helpful feedback to the user.
            /// 
            /// In order for a cart to be valid, it must have:
            /// 
            /// An address
            /// At least one item
            /// All items must be available (as specified through the is_available field on each item)
            /// All of the item's cart_price values must be less than or equal to the catalog_price values
            /// 
            /// </remarks>
            /// <param name="socketId">This is the socket that the item is in. You can find your available sockets by using the list_available_catalogs method.</param>
            /// <param name="externalUserId">This is an id from your system that identifies the user that the cart is for. It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <returns>A <see cref="CartViewResponse"/> object with the details of the cart</returns>
            public CartViewResponse CartView(int socketId, string externalUserId)
            {
                var r = new RestRequest("cart_view");

                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);
                r.RootElement = "cart_view_response";

                

                return Execute<CartViewResponse>(r);

            }

            
            /// <summary>
            /// Validates the address and items in the cart. You should call this method just 
            /// before placing an order to make sure that the order will not be rejected.
            /// </summary>
            /// <param name="socketId">This is the socket that the item is in. You can find your available sockets by using the list_available_catalogs method.</param>
            /// <param name="externalUserId">This is an id from your system that identifies the user that the cart is for. It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <param name="locked">
            /// Set this to "1" to lock the cart. (Defaults to "0") 
            /// A locked cart cannot be modified, meaning that items cannot be added or removed, 
            /// and the address cannot be changed. One use for this would be to lock the cart before 
            /// processing a credit card transaction in your system. You would then be ensured that 
            /// the item in the cart could not be changed while the transaction is processing. 
            /// You can only call cart_view, cart_unlock, or cart_order_place on a locked cart.
            /// </param>
            /// <returns></returns>
            public CartValidateResponse CartValidate(int socketId, string externalUserId, int? locked = null)
            {
                var r = new RestRequest("cart_validate");

                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);

                if (locked.HasValue)
                    r.AddQueryParameter("locked", locked.Value.ToString());

                r.RootElement = "cart_validate_response";

                

                return Execute<CartValidateResponse>(r);

            }

            /// <summary>
            /// Unlocks a cart that has been locked via the <see cref="CartValidate"/> method.
            /// </summary>
            /// <param name="socketId">This is the socket that the item is in. You can find your available sockets by using the ListAvailableCatalogs method.</param>
            /// <param name="externalUserId">This is an id from your system that identifies the user that the cart is for. It can contain alphanumeric characters, dashes and underscores. Max length is 25 characters.</param>
            /// <returns>The RestResponse</returns>
            public RestResponse CartUnlock(int socketId, string externalUserId)
            {
                var r = new RestRequest("cart_unlock");

                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);

                

                return Execute(r);

            }

            /// <summary>
            /// This method places an order using the address and items in the cart. Once the order is placed, the cart is deleted. A <see cref="CatalogApiFaultException"/>will be thrown if the order could not be placed.
            /// </summary>
            /// <param name="socketId"></param>
            /// <param name="externalUserId"></param>
            /// <param name="cartVersion"></param>
            public CartOrderPlaceResponse CartOrderPlace(int socketId, string externalUserId, string cartVersion = null)
            {
                var r = new RestRequest("cart_order_place");

                r.AddQueryParameter("socket_id", socketId.ToString());
                r.AddQueryParameter("external_user_id", externalUserId);

                if (!String.IsNullOrWhiteSpace(cartVersion))
                    r.AddQueryParameter("cart_version", cartVersion);

                
                r.RootElement = "cart_order_place_response";

                return Execute<CartOrderPlaceResponse>(r);
            }

       #endregion

       #region [Order Management]


            public OrderPlaceResponse OrderPlace(order_place orderPlace)
            {
                var method = "order_place";
                var client = new RestClient();
                client.BaseUrl = new Uri(this.PlaceOrderUrl);
                
                var r = new RestRequest();
                var checksum = CreateChecksum(method);

                //generate credentials
                orderPlace.order_place_request.credentials = new Credentials
                {
                    checksum = checksum.Checksum,
                    datetime = checksum.IsoDate,
                    method = checksum.Method,
                    uuid = checksum.UUID
                };

                //serialize and wrap request body in an additional layer of {} as required
                
                //use the always solid Json.Net to ignore null values...
                var json = JsonConvert.SerializeObject(orderPlace, Formatting.None, new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore
                });


                var sb = new StringBuilder();

                sb.Append("{ \"order_place\": ");
                sb.Append(json);
                sb.Append("}");

                //add our json as the request body
                r.AddParameter("text/json", sb.ToString(), ParameterType.RequestBody);
                
                r.RequestFormat = DataFormat.Json;

                r.Method = Method.POST;

                r.RootElement = "order_place_response";

                

                var resp = client.Execute<OrderPlaceResponse>(r);


                if (resp.ErrorException != null)
                {
                    string msg = "Error getting response. Check inner details for more info.";
                    var catalogApiEx = new ApplicationException(msg, resp.ErrorException);
                    throw catalogApiEx;
                }

                if (resp.StatusCode != System.Net.HttpStatusCode.OK || resp.Data == null)
                {
                    var jsonDeserializer = new RestSharp.Deserializers.JsonDeserializer();
                    jsonDeserializer.RootElement = "Fault";
                     
                    var fault = jsonDeserializer.Deserialize<Fault>(resp);

                    if (fault != null)
                    {
                        throw new CatalogAPIFaultException(fault);
                    }

                }


                return resp.Data;


            }

            /// <summary>
            /// Tracks and order
            /// </summary>
            /// <param name="order_number">The order number you received after placing an order with <see cref="OrderPlace"/> or <see cref="CartOrderPlace"/>.</param>
            /// <returns></returns>
            public OrderTrackResponse OrderTrack(string orderNumber)
            {
                var r = new RestRequest("order_track");

                r.AddQueryParameter("order_number", orderNumber);
                
                r.RootElement = "order_track_response";

                return Execute<OrderTrackResponse>(r);
            }

            /// <summary>
            /// Returns a paged list of orders for a user
            /// </summary>
            /// <param name="externalUserId">This is the external_user_id you passed when you placed the order. 
            /// This method does not work with orders that do not have an external_user_id set.</param>
            /// <param name="perPage">The number of orders to return per page. Defaults to 10. Can be increased to a maximum of 50.</param>
            /// <param name="page">The page number of results to return when there are more than per_page results.</param>
            public OrderListResponse OrderList(string externalUserId, int? perPage = null, int? page = null)
            {
                var r = new RestRequest("order_list");

                r.AddQueryParameter("external_user_id", externalUserId);

                if (perPage.HasValue)
                    r.AddQueryParameter("per_page", perPage.Value.ToString());

                if (page.HasValue)
                    r.AddQueryParameter("page", page.Value.ToString());

                r.RootElement = "order_list_response";

                return Execute<OrderListResponse>(r);
            }

       #endregion


       #region [Utility Methods]


            /// <summary>
            /// Execute a RestRequest and return a result of type T
            /// </summary>
            /// <typeparam name="T">Type of object to return</typeparam>
            /// <param name="r">The RestRequest</param>
            /// <returns>Object of type T</returns>
            public T Execute<T>(RestRequest r) where T : new()
            {

                var checksum = CreateChecksum(r.Resource);

                var client = new RestClient();
            
                client.BaseUrl = new Uri(this.BaseUrl);
                r.AddQueryParameter("creds_datetime", checksum.IsoDate);
                r.AddQueryParameter("creds_uuid", checksum.UUID);
                r.AddQueryParameter("creds_checksum", checksum.Checksum);

                


                var resp = client.Execute<T>(r);

                if (resp.ErrorException != null)
                {
                    string msg = "Error getting response. Check inner details for more info.";
                    var catalogApiEx = new ApplicationException(msg, resp.ErrorException);
                    throw catalogApiEx;
                }

                if (resp.StatusCode != System.Net.HttpStatusCode.OK || resp.Data == null) 
                {
                    var jsonDeserializer = new RestSharp.Deserializers.JsonDeserializer();
                    jsonDeserializer.RootElement = "Fault";
                    var fault = jsonDeserializer.Deserialize<Fault>(resp);

                    if (fault != null)
                    {
                        throw new CatalogAPIFaultException(fault);
                    }
            
                }


                return resp.Data;
            }

            /// <summary>
            /// Execute a RestRequest and return a response object
            /// </summary>
            /// <param name="r">The request</param>
            /// <returns>RestResponse</returns>
            public RestResponse Execute(RestRequest r)
            {
                var checksum = CreateChecksum(r.Resource);

                var client = new RestClient();

                client.BaseUrl = new Uri(this.BaseUrl);
                r.AddQueryParameter("creds_datetime", checksum.IsoDate);
                r.AddQueryParameter("creds_uuid", checksum.UUID);
                r.AddQueryParameter("creds_checksum", checksum.Checksum);

                var resp =  (RestResponse)client.Execute(r);

                if (resp.ErrorException != null)
                {
                    string msg = "Error getting response. Check inner details for more info.";
                    var catalogApiEx = new ApplicationException(msg, resp.ErrorException);
                    throw catalogApiEx;
                }

                if (resp.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    var jsonDeserializer = new RestSharp.Deserializers.JsonDeserializer();
                    jsonDeserializer.RootElement = "Fault";
                    var fault = jsonDeserializer.Deserialize<Fault>(resp);

                    if (fault != null)
                    {
                        throw new CatalogAPIFaultException(fault);
                    }

                }

                return resp;

            }
        

       
            /// <summary>
            /// Create a valid checksum for a Catalog API request from a method, uuid, and iso 8601 date
            /// </summary>
            /// <param name="method">The Catalog API method</param>
            /// <param name="uuid">optional: the uuid to use, leave empty for new Guid</param>
            /// <param name="iso8601Date">optional: the iso 8601 formatted date to use, 
            /// leave empty to generate from now()</param>
            /// <returns></returns>
            public ChecksumCredentials CreateChecksum(string method, string uuid = null, string isoDate = null)
            {
            
                //signature for checksum is Method + UUID + ISO8601 Date
            
                isoDate = String.IsNullOrEmpty(isoDate) ? DateTime.UtcNow.ToString("o") : isoDate;
                uuid = String.IsNullOrEmpty(uuid) ? System.Guid.NewGuid().ToString() : uuid;
                var signature = method + uuid + isoDate;

                //Encode with HMAC SHA1

                var enc = Encoding.UTF8;
                HMACSHA1 hmac = new HMACSHA1(enc.GetBytes(key));
                hmac.Initialize();

                byte[] buffer = enc.GetBytes(signature);

                //Encode hash as Base64
                var hash = System.Convert.ToBase64String(hmac.ComputeHash(buffer));

                return new ChecksumCredentials
                {
                    Method   = method,
                    UUID     = uuid,
                    IsoDate  = isoDate,
                    Checksum = hash
                };

            }

        #endregion


    }
}
