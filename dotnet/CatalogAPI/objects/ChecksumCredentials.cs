using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    /// <summary>
    /// The credentials required for a valid Catalog API request
    /// </summary>
    public class ChecksumCredentials
    {
        public ChecksumCredentials() { }

        public String IsoDate { get; set; }
        public String Method { get; set; }
        public String UUID { get; set; }
        public string Checksum { get; set; }
    }
}
