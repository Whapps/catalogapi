<?php

// THIS MODULE IS NOT YET COMPLETE

class CatalogAPI
{
    // subdomain: the first part of your SUBDOMAIN.dev.catalogapi.com domain
    // secret key: the secret key you were given
    // endpoint: use "rest" for JSON responses or "restx" for XML responses
    // is_prod, FALSE for dev, TRUE for production (you must you your prod key if this is TRUE)
    function __construct($sub_domain, $secret_key, $endpoint="rest", $is_prod=FALSE)
    {
        $this->sub_domain = $sub_domain;
        $this->secret_key = $secret_key;
        $this->endpoint = $endpoint; # rest or restx
        $this->is_prod = $is_prod;
        $this->error = NULL;
    }
    
    function list_available_catalogs()
    {
        return $this->_make_request("list_available_catalogs", array());
    }
    
    function catalog_breakdown($socket_id, $is_flat=FALSE)
    {
        return $this->_make_request("catalog_breakdown", array("socket_id" => $socket_id, "is_flat" => ($is_flat?"1":"0")));
    }
    
    function search_catalog($socket_id, $search_args=array())
    {
        $search_args["socket_id"] = $socket_id;
        return $this->_make_request("search_catalog", $search_args);
    }
    
    function view_item($socket_id, $catalog_item_id)
    {
        return $this->_make_request("view_item", array("socket_id" => $socket_id, "catalog_item_id" => $catalog_item_id));
    }

    function _make_request($method, $args)
    {
        $data = NULL;
        $this->error = NULL;
        
        try
        {
            $url = "https://" . $this->sub_domain . ($this->is_prod ? ".prod" : ".dev") . ".catalogapi.com/v1/" . $this->endpoint . "/$method/?";
            $url .= $this->_generate_checksum_args($method);
            foreach ($args as $key => $value)
            {
                $url .= "&$key=" . rawurlencode($value);
            }
            
            #print("URL:" . $url . "\n");

            $ch = curl_init( $url );
            
            curl_setopt($ch,CURLOPT_TIMEOUT,30);
            curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);
            
            $result = curl_exec($ch);
            
            if ($this->endpoint == "rest")
            {
                //print "REST!\n";
                $data = json_decode($result, true); // true here returns arrays instead of objects
            }
            elseif ($this->endpoint == "restx")
            {
                //print "XML!\n";
                // TODO return a DOM?
                $data = $result;
            }
        }
        catch (Exception $ex)
        {
            $this->error = $ex->getMessage();
        }
        
        return $data;
    }
    
    function _generate_checksum_args($method)
    {
        $message_id = $this->_get_guid();
        
        $now_datetime = new DateTime('NOW', new DateTimeZone('UTC'));
        $now_string = $now_datetime->format('Y-m-d H:i:s');
        
        #print "NOW: $now_string\n";
        
        $digest_string = "$method$message_id$now_string";
        
        $checksum = base64_encode( hash_hmac("sha1", $digest_string, $this->secret_key, TRUE) );
        
        return "creds_datetime=" . rawurlencode($now_string)
            . "&creds_uuid=" . rawurlencode($message_id)
            . "&creds_checksum=" . rawurlencode($checksum);
    }
    
    function _get_guid()
    {
        if (function_exists('com_create_guid'))
        {
            return substr(com_create_guid(), 1, 36);
        }
        else
        {
            mt_srand((double)microtime()*10000); //optional for php 4.2.0 and up.
            $charid = strtoupper(md5(uniqid(rand(), true)));
            $hyphen = chr(45); // "-"
            $uuid = substr($charid, 0, 8).$hyphen
                .substr($charid, 8, 4).$hyphen
                .substr($charid,12, 4).$hyphen
                .substr($charid,16, 4).$hyphen
                .substr($charid,20,12);
            return $uuid;
        }
    }
}

?>