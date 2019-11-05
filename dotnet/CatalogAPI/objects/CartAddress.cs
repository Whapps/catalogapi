using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Whapps.CatalogAPI
{
    /// <summary>
    /// The shipping address information for a cart, used with the CartSetAddress method.
    /// </summary>
    public class CartAddress
    {
        /// <summary>
        /// REQUIRED: Shipping address first name, max length is 40 characters
        /// </summary>
        public string FirstName { get; set; }
        
        /// <summary>
        /// REQUIRED: Shipping address last name, max length is 40 characters
        /// </summary>
        public string LastName { get; set; }
        
        /// <summary>
        /// REQUIRED: Street Address, max length is 75 characters (NO PO BOXES)
        /// </summary>
        public string Address1 { get; set; }
        
        /// <summary>
        /// OPTIONAL: Apt/Floor/Suite/Etc, max length is 60 characters
        /// </summary>
        public string Address2 { get; set; }

        /// <summary>
        /// OPTIONAL: Apt/Floor/Suite/Etc, max length is 60 characters
        /// </summary
        public string Address3 { get; set; }
        
        /// <summary>
        /// REQUIRED: The city name
        /// </summary>
        public string City { get; set; }
        
        /// <summary>
        /// REQUIRED: For US states, this must be the two character abbreviation
        /// </summary>
        public string StateProvince { get; set; }
        
        /// <summary>
        /// REQUIRED: The 5 digit zip code for the shipping address
        /// </summary>
        public string PostalCode { get; set; }
        
        /// <summary>
        /// REQUIRED: The ISO 3166-1 alpha-2 country code of the country the order will be shipped to.
        /// see https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 
        /// (Unites States is "US", Canada is "CA")
        /// </summary>
        public string Country { get; set; }
        
        /// <summary>
        /// OPTIONAL: If set, this must be a valid email address. 
        /// We highly recommend that you provide an email address so that we can 
        /// contact the addressee if there is a problem with the order.
        /// </summary>
        public string Email { get; set; }
        
        /// <summary>
        /// OPTIONAL: If set, this must be a valid phone number. 
        /// This will only be used for order support or to contact the addressee to arrange a
        /// delivery time for any items that require a signature.
        /// </summary>
        public string PhoneNumber { get; set; }
    }
}
