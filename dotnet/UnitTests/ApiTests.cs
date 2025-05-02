using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Whapps.CatalogAPI;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Threading;
using RestSharp;
namespace Whapps.CatalogAPI.Tests
{
    [TestClass()]
    public class ApiTests
    {

        //demo catalog socket
        int socketId = 559;


        [TestMethod()]
        public void CreateChecksumTest()
        {
            var api = new Whapps.CatalogAPI.Api();
            var check = api.CreateChecksum("cart_view", "b93cee9d-dd04-4154-9b5a-8768971e72b8", "2013-01-01T01:30:00Z");

            Assert.AreEqual("fJ2OnDzILhZ1WoNum5qgJGbL7wE=", check.Checksum , "Checksums match documenation at http://apidemo1.catalogapi.com/docs/checksums/ ");
        }

        [TestMethod()]
        public void ViewItemTest()
        {
            var api = new Whapps.CatalogAPI.Api();
            var response = api.ViewItem(socketId, 3645415);
            Assert.AreEqual(response.view_item_result.item.catalog_item_id, 3645415);
        }


        [TestMethod()]
        public void CatalogSearchTest()
        {
            var api = new Whapps.CatalogAPI.Api();
            var response = api.SearchCatalog(socketId, new SearchOptions
            {
                Search = "red",
                PerPage = 20
            });
            //did we get 20 items back?
            Assert.AreEqual(response.search_catalog_result.items.CatalogItem.Count, 20);
        }

        [TestMethod()]
        public void ListAvailableCatalogsTest()
        {
            var api = new Whapps.CatalogAPI.Api();
            var response = api.ListAvailableCatalogs();
            
            //did we get something?
            Assert.IsNotNull(response);


            var sockets = response.list_available_catalogs_result.domain.sockets.Socket;

            //do we have a list of sockets?
            Assert.IsNotNull(sockets);

            //is there somthing in them?
            Assert.IsTrue(sockets.Count > 0);

            //do we have a socket id matching the ones in this test?
            Assert.IsTrue(response.list_available_catalogs_result.domain.sockets.Socket.FirstOrDefault(c => c.socket_id == socketId.ToString()) != null);
        }

        [TestMethod()]
        public void ListCatalogBreakdownTest()
        {
            var api = new Whapps.CatalogAPI.Api();
            var response = api.ListCatalogBreakdown(socketId);

            //did we get any thing?

            Assert.IsNotNull(response);

            //did we get categories?
            Assert.IsNotNull(response.catalog_breakdown_result.categories.Category);

            //did we get a category called "Electronics" (always part of th master catalog)
            Assert.IsTrue(response.catalog_breakdown_result.categories.Category.FirstOrDefault(c => c.name == "Electronics") != null);
        }


        [TestMethod()]
        public void TestCartAndOrders()
        {

            var rnd = new Random();

            var fakeUserId = "TestAPIUser-" + rnd.Next(1, 2000).ToString();

            var api = new Whapps.CatalogAPI.Api();

            var emptyCartResp = api.CartEmpty(socketId, fakeUserId);

            var getItemResp = api.SearchCatalog(socketId, new SearchOptions
            {
                Sort = SortOptionEnum.rankAsc
            });

            //grab the top item

            var item = getItemResp.search_catalog_result.items.CatalogItem[0];

            Console.WriteLine("Found one {0}:", item.catalog_item_id);
            Console.WriteLine("..AKA: {0}", item.name);

            //add it to the cart

            var addToCartResp = api.CartAddItem(socketId, fakeUserId, item.catalog_item_id, 2);

            Assert.IsNotNull(addToCartResp);

            Console.WriteLine("Add to cart result: {0}", addToCartResp.cart_add_item_result.description);

            var checkAddToCartResp = api.CartView(socketId, fakeUserId);

            //check that we got a response
            Assert.IsNotNull(checkAddToCartResp);

            var cartItems = checkAddToCartResp.cart_view_result.items.CartItem;

            //do we have the one item?
            Assert.IsTrue(cartItems.Count == 1);
            
            //is it the item we added?
            Assert.IsNotNull(cartItems.FirstOrDefault(c => c.catalog_item_id == item.catalog_item_id));
            
            //and are there two of them?

            Assert.AreEqual(cartItems.FirstOrDefault(c => c.catalog_item_id == item.catalog_item_id).quantity, 2);


            var setQuantityResp = api.CartSetItemQuantity(socketId, fakeUserId, item.catalog_item_id, 1);

            //did we get a response?

            Assert.IsNotNull(setQuantityResp.cart_set_item_quantity_result.description);

            Console.WriteLine("Set cart item quantity result: {0}", setQuantityResp.cart_set_item_quantity_result.description);

            //grab the cart again and see the new quantity (should be 1)

            var checkSetQuantityResp = api.CartView(socketId, fakeUserId);

            cartItems = checkSetQuantityResp.cart_view_result.items.CartItem;
            
            //should only be one!
            Assert.AreEqual(cartItems.FirstOrDefault(c => c.catalog_item_id == item.catalog_item_id).quantity, 1);

            
            //no address on the cart with throw an exception because it's a fault..
            //this is what SHOULD happen..

            CartValidateResponse validateCartResp = null;

            try
            {
                validateCartResp = api.CartValidate(socketId, fakeUserId);
            }
            catch (CatalogAPIFaultException ex)
            {
                Assert.AreEqual("A shipping address must be added to the cart.", ex.FaultString);
            }


            //so let's set an address

            var setAddressResp = api.CartSetAddress(socketId, fakeUserId, new CartAddress{
                  FirstName = "Unit",
                  LastName = "Tester",
                  Address1 = "123 Test Way",
                  City = "Nowhere",
                  StateProvince = "OH",
                  Country = "US",
                  PostalCode = "11111",
                  Email = "unittest@whapps.com"
            });


            //validate the address again and lock the cart for modifying
            validateCartResp = api.CartValidate(socketId, fakeUserId, 1);

            
            //did we get a response?
            Assert.IsNotNull(validateCartResp);

            //The cart should be valid... let's check
            Assert.AreEqual("The cart is valid. The cart has been locked.", validateCartResp.cart_validate_result.description);


            //is the cart actually locked?

            var checkLockResp = api.CartView(socketId, fakeUserId);
            Assert.AreEqual(1, checkLockResp.cart_view_result.locked);

            
            //now let's unlock it

            var unlockResp = api.CartUnlock(socketId, fakeUserId);
            Assert.IsNotNull(unlockResp);

            //is it unlocked?
            
            
            checkLockResp = api.CartView(socketId, fakeUserId);
            Assert.AreEqual(0, checkLockResp.cart_view_result.locked);


            //let's place a fake order

            var placeOrderResp = api.CartOrderPlace(socketId, fakeUserId);

            
           //we should have an order number

            Assert.IsNotNull(placeOrderResp.cart_order_place_result);

            var orderNumber = placeOrderResp.cart_order_place_result.order_number;
            
            Assert.IsNotNull(orderNumber);

            
            OrderListResponse listOrderResp = null;
            
            while ( listOrderResp == null ||  
                    listOrderResp.order_list_result.orders.OrderSummary == null || 
                    listOrderResp.order_list_result.orders.OrderSummary.Count == 0)
        	{
                Console.WriteLine("Waiting 5s for order processing...");
                Thread.Sleep(5000); 
                listOrderResp = api.OrderList(fakeUserId);
	        }


            //now let's see if our order is there

            Assert.IsNotNull(listOrderResp.order_list_result.orders.OrderSummary.FirstOrDefault(c => c.order_number == orderNumber));


            //sweet, now let's check the order detail


            var orderDetailResp = api.OrderTrack(orderNumber);

            Assert.IsNotNull(orderDetailResp.order_track_result.order);

            //do we have the item we ordered?

            Assert.IsNotNull(orderDetailResp.order_track_result.order.items.OrderItem.FirstOrDefault(c => c.catalog_item_id == item.catalog_item_id.ToString()));

            //SUCCESS!!
            

        }

        [TestMethod()]
        public void TestOrderPlace()
        {
            var rnd = new Random();

            var fakeUserId = "TestAPIUser-" + rnd.Next(1, 2000).ToString();

            var api = new Whapps.CatalogAPI.Api();

            var getItemResp = api.SearchCatalog(socketId, new SearchOptions
            {
                Sort = SortOptionEnum.rankAsc
            });

            //grab the top 2 items

            var items = getItemResp.search_catalog_result.items.CatalogItem.Take(2).ToList();

            //place a fake order 

            var orderPlaceResp = api.OrderPlace(new order_place
            {
                order_place_request = new order_place_request
                {
                    address_1 = "123 Order_place way",
                    address_2 = "Suite 404",
                    city = "Nowhere",
                    state_province = "OH",
                    postal_code = "11111",
                    country = "US",
                    email = "unittest@whapps.com",
                    external_order_number = "Fake_order_00" + rnd.Next(0, 9999).ToString(),
                    first_name = "Order",
                    last_name = "Tester",
                    external_user_id = fakeUserId,
                    socket_id = socketId.ToString(),
                    items = new List<PlaceOrderItem>{

                        new PlaceOrderItem {
                            catalog_item_id = items[0].catalog_item_id,
                            catalog_price = items[0].catalog_price,
                            currency = items[0].currency,
                            quantity = 1
                        },

                        new PlaceOrderItem {
                            catalog_item_id = items[1].catalog_item_id,
                            catalog_price = items[1].catalog_price,
                            currency = items[1].currency,
                            quantity = 1
                        }
                    }
                }
            });


            Assert.IsNotNull(orderPlaceResp);
            var orderNumber = orderPlaceResp.order_place_result.order_number;


            //wait for the order to process
            
            OrderListResponse listOrderResp = null;

            while (listOrderResp == null ||
                    listOrderResp.order_list_result.orders.OrderSummary == null ||
                    listOrderResp.order_list_result.orders.OrderSummary.Count == 0)
            {
                Console.WriteLine("Waiting 5s for order processing...");
                Thread.Sleep(5000);
                listOrderResp = api.OrderList(fakeUserId);
            }



            //now let's see if our order is there

            Assert.IsNotNull(listOrderResp.order_list_result.orders.OrderSummary.FirstOrDefault(c => c.order_number == orderNumber));


            //sweet, now let's check the order detail
            
            var orderDetailResp = api.OrderTrack(orderNumber);

            Assert.IsNotNull(orderDetailResp.order_track_result.order);

            //do we have the items we ordered?

            Assert.IsNotNull(orderDetailResp.order_track_result.order.items.OrderItem.FirstOrDefault(c => c.catalog_item_id == items[0].catalog_item_id.ToString()));
            Assert.IsNotNull(orderDetailResp.order_track_result.order.items.OrderItem.FirstOrDefault(c => c.catalog_item_id == items[1].catalog_item_id.ToString()));

        }
    }
}
