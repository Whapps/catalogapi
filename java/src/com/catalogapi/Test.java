package com.catalogapi;

public class Test
{ 
    public static void main(String [] args)
    {
        try
        {
            CatalogAPI api = new CatalogAPI(args[0], args[1]);
            api.listAvailableCatalogs();
            
            
        }
        catch (Exception ex)
        {
            throw new RuntimeException("Arrrg! " + ex);
        }
    }
}
