using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class Category
    {
        public string name { get; set; }
        public string item_count { get; set; }
        public int depth { get; set; }
        public int parent_category_id { get; set; }
        public string category_id { get; set; }
        public Children children { get; set; }
    }


    public class Children
    {
        public List<Category> Category { get; set; }
    }

    public class Categories
    {
        public List<Category> Category { get; set; }
    }
}
