using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Whapps.CatalogAPI
{
    public enum SortOptionEnum
    {

        /// <summary>
        /// Defaults to score descending when searching by"name" or "search", otherwise defaults to rank ascending
        /// </summary>
        auto,

        /// <summary>
        /// most relevant ones first.
        /// Sorting by score only makes sense when you are searching with the "name" or "search" arguments
        /// </summary>
        scoreDesc,

        /// <summary>
        /// most popular items first
        /// </summary>
        rankAsc,

        /// <summary>
        /// ordered from highest to lowest points
        /// </summary>
        pointsDesc,

        /// <summary>
        /// ordered from lowest to highest points
        /// </summary>
        pointsAsc,

        /// <summary>
        /// random order
        /// </summary>
        randomAsc
    }


    /// <summary>
    /// Options for searching a catalog
    /// </summary>
    public class SearchOptions
    {

        public SearchOptions() { }



        /// <summary>
        /// OPTIONAL: Searches the names of items.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// OPTIONAL: Search the name, description and model of items.
        /// </summary>
        public string Search { get; set; }

        /// <summary>
        /// OPTIONAL: Returns only items within this category id. 
        /// (This includes any child categories of the category id.) 
        /// The category id comes from the CatalogBreakdown method.
        /// </summary>
        public int? CategoryId { get; set; }

        /// <summary>
        /// OPTIONAL: Return only items that have a point value of at least this value.
        /// </summary>
        public int? MinPoints { get; set; }

        /// <summary>
        /// OPTIONAL: Return only items that have a point value of no more than this value.
        /// </summary>
        public int? MaxPoints { get; set; }

        /// <summary>
        /// Return only items that have a price of at least this value.
        /// </summary>
        public decimal? MinPrice { get; set; }

        /// <summary>
        /// Return only items that have a price of no more than this value.
        /// </summary>
        public decimal? MaxPrice { get; set; }

        /// <summary>
        /// Do not return items with a rank higher than this value.
        /// 
        /// The lower the rank on an item, the higher its popularity. 
        /// A rank of "1" would include only the most popular items in a catalog. 
        /// It is possible for a catalog to not have any items with a specific rank value.
        /// Rank values have a range from 1 to 1000. Most items will 
        /// have a rank somewhere around 300.
        /// 
        /// Note that the algorithms we use to rank items are subject to change;
        /// the rank of any one item could change drastically in the future.
        /// </summary>
        public int? MaxRank { get; set; }

        /// <summary>
        /// We have the ability to "tag" certain items based on custom criteria that is unique to our clients. 
        /// If we setup these tags on your catalog, you can pass a tag name with your search.
        /// </summary>
        public string Tag { get; set; }

        /// <summary>
        /// The page number. Defaults to 1.
        /// </summary>
        public int? Page { get; set; }

        /// <summary>
        /// The number of items to return, per page. Can be from 1 to 50. Defaults to 10.
        /// </summary>
        public int? PerPage { get; set; }

        /// <summary>
        ///  The following sort values are supported:
        ///
        /// "points desc"
        /// "points asc"
        /// "rank asc"
        /// "score desc"
        /// "random asc"
        /// 
        /// Sorting by "rank asc" will return items with the most popular ones first.
        /// Sorting by "score desc" will return items with the the most relevant ones first. 
        /// Sorting by score only makes sense when you are searching with the "name" or "search" arguments.
        /// Sorting by "random asc" will return the items in random order.
        /// Defaults to "score desc" when searching by "name" or "search". Otherwise, defaults to "rank asc".
        /// 
        /// 
        /// </summary>
        public SortOptionEnum Sort { get; set; }
    }
}
