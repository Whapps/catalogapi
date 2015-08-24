using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public class Pager
    {
        public int has_next { get; set; }
        public string sort { get; set; }
        public int page { get; set; }
        public int first_page { get; set; }
        public int last_page { get; set; }
        public int has_previous { get; set; }
        public int per_page { get; set; }
        public Pages pages { get; set; }
        public int result_count { get; set; }
    }

    public class Pages
    {
        public List<int> integer { get; set; }
    }


}
