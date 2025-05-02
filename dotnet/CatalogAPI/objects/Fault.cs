using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    /// <summary>
    /// POCO for fault returned from Catalog API, used for generating CatalogAPIFaultException(s)
    /// </summary>
    public class Fault
    {

        /// <summary>
        /// The error code returned from the API. See catalogapi.com/docs/faults for a current list
        /// </summary>
        public string faultcode { get; set; }

        
        /// <summary>
        /// The string 
        /// </summary>
        public string faultstring { get; set; }
        
        /// <summary>
        /// Additional details on an error, usually empty
        /// </summary>
        public string detail { get; set; }
    }


    /// <summary>
    /// An exception for Catalog API Request faults
    /// see catalogapi.com/docs/faults/
    /// </summary>
    [Serializable]
    public class CatalogAPIFaultException : Exception
    {
        public string FaultCode { get; set; }
        public string FaultString { get; set; }
        public string Detail { get; set; }

        public string FaultCodeDescription
        {
            get
            {
                switch (this.FaultCode)
                {
                    case "Client.AuthenticationError":
                        return "Either your token or the credentials you are passing are not valid";
                        

                    case "Client.ValidationError":
                        return "The arguments you are passing do not pass type contraints." + 
                                "i.e., you are passing a float when the method is expecting an integer.";

                    case "Client.ArgumentError":
                        return "You are not passing a required argument, or an argument you are passing" + 
                                "is not valid. i.e., you are passing a country that is not a valid ISO 3166-1 value." + 
                                "This fault is very simlar to a ValidationError fault. You should likely treat them the same way.";

                    case "Client.RequestNotAllowed":
                        return "The request is incomplete or is being called incorrectly.";

                    case "Client.RequestTooLongError":
                        return "The size of the request data is too large.";
                        
                    case "Client.ResourceNotFound":
                        return "The method you are calling is not valid.";

                    case "Client.APIError":
                        return "This is a generic API error. You will need to read the faultstring for more information.";

                    case "Client.RateLimitError":
                        return "You have made more API requests than your maximum allowed requests per minute." +
                                "You will normally only see this error when using your development key," + 
                                " which is restricted to 30 requests per minute.";

                    default:
                        return "Unknown";
                        
                }
            }
        }


        public override string Message
        {
            get
            {
                return "CatalogAPI Fault: " + this.FaultCode + " - " + this.FaultString;
            }
        }


        #region [Constructors]

            public CatalogAPIFaultException(){}

            public CatalogAPIFaultException(string message) : base(message) { }

            public CatalogAPIFaultException(string message, Exception inner) : base(message, inner) { }

            public CatalogAPIFaultException(string faultCode, string faultString, string detail)
            {
                this.FaultCode = faultCode;
                this.FaultString = faultString;
                this.Detail = detail;
            }

            public CatalogAPIFaultException(Fault fault)
            {
                this.FaultCode = fault.faultcode;
                this.FaultString = fault.faultstring;
                this.Detail = fault.detail;
            }


        #endregion


    }
}
