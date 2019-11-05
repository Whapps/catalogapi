using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{

    
    public class ItemCategories
    {
        public List<int> integer { get; set; }
    }
    
    public class CatalogItem
    {
        public string original_price { get; set; }
        public decimal catalog_price { get; set; }
        public string image_300 { get; set; }
        public string name { get; set; }
        public Tags tags { get; set; }
        public string brand { get; set; }
        public ItemCategories categories { get; set; }
        public int rank { get; set; }
        public Options options { get; set; }
        public int catalog_item_id { get; set; }
        public string currency { get; set; }
        public int points { get; set; }
        public string shipping_estimate { get; set; }
        public string image_150 { get; set; }
        public int original_points { get; set; }
        public string retail_price { get; set; }
        public int has_options { get; set; }
        public string model { get; set; }
        public string image_75 { get; set; }
    }

    public class Options
    {
        //todo: need the props for this 
    }
}
