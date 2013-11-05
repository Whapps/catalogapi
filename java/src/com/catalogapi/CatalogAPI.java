package com.catalogapi;

/* native java imports */
import java.net.URL;
import java.net.URLConnection;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.ByteArrayInputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.SortedMap;
import java.util.TimeZone;
import java.util.TreeMap;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/* included in libs */
// commons-codec-1.8.jar
import org.apache.commons.codec.binary.Base64;

// much of the code for this class was created using the awesome book Java Web Services: Up and Running, 2nd Edition

public class CatalogAPI
{
    private static final String utf8 = "UTF8";
    
    private String sub_domain;
    private String secret_key;
    
    public CatalogAPI(String sub_domain, String secret_key)
    {
        this.sub_domain = sub_domain;
        this.secret_key = secret_key;
    }
    
    public ListAvailableCatalogsResponse listAvailableCatalogs() throws Exception
    {
        Map<String, String> params = new HashMap<String, String>();
        String response_xml = makeRequest("list_available_catalogs", params);
        ListAvailableCatalogsResponse response = new ListAvailableCatalogsResponse(response_xml);
        return response;
    }
    
    private String makeRequest(String method, Map<String, String> params)
    {
        StringBuffer response = new StringBuffer();
        try
        {
            String stringUrl = generateURL(method, params);
            URL url = new URL(stringUrl);
            URLConnection conn = url.openConnection();
            conn.setDoInput(true);
            BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String chunk = null;
            while ((chunk = in.readLine()) != null) response.append(chunk);
            in.close();
        }
        catch (Exception ex)
        {
            throw new RuntimeException("Arrrg! " + ex);
        }
        
        return response.toString();
    }
    
    private String generateURL(String method, Map<String, String> params)
    {
        StringBuffer buffer = new StringBuffer();
        buffer.append("https://");
        buffer.append(sub_domain);
        buffer.append(".dev.catalogapi.com/v1/restx/");
        buffer.append(method);
        buffer.append("?");
        
        // add the validation params
        String creds_uuid = UUID.randomUUID().toString();
        String creds_datetime = timestamp();
        String creds_checksum = hmac(method + creds_uuid + creds_datetime);
        
        System.out.println("creds_uuid: " + creds_uuid);
        System.out.println("creds_datetime: " + creds_datetime);
        System.out.println("checksum: " + creds_checksum);
        
        params.put("creds_uuid", creds_uuid);
        params.put("creds_datetime", creds_datetime);
        params.put("creds_checksum", creds_checksum);
        
        Iterator<Map.Entry<String, String>> iter = params.entrySet().iterator();
        while (iter.hasNext())
        {
            Map.Entry<String, String> kvpair = iter.next();
            buffer.append(encodeRfc3986(kvpair.getKey()));
            buffer.append("=");
            buffer.append(encodeRfc3986(kvpair.getValue()));
            if (iter.hasNext()) buffer.append("&");
        }
        
        return buffer.toString();
    }
    
    private String hmac(String to_sign)
    {
        String checksum;
        try {
            SecretKeySpec secretKeySpec = new SecretKeySpec(secret_key.getBytes(utf8), "HmacSHA1");
            Mac mac = Mac.getInstance("HmacSHA1");
            mac.init(secretKeySpec);
            
            byte[] data = to_sign.getBytes(utf8);
            byte[] raw_hmac = mac.doFinal(data);
            Base64 encoder = new Base64();
            checksum = new String(encoder.encode(raw_hmac));
        }
        catch (Exception ex)
        {
            throw new RuntimeException("Arrrg! " + ex);
        }
        
        return checksum;
    }
    
    private String encodeRfc3986(String s)
    {
        String out;
        try
        {
            out = URLEncoder.encode(s, utf8)
                .replace("+", "%20")
                .replace("*", "%2A")
                .replace("%7E", "~");
        }
        catch (UnsupportedEncodingException e)
        {
            out = s;
        }
        
        return out;
    }
    
    private String timestamp()
    {
        String timestamp = null;
        Calendar cal = Calendar.getInstance();
        DateFormat dfm = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        dfm.setTimeZone(TimeZone.getTimeZone("GMT"));
        timestamp = dfm.format(cal.getTime());
        return timestamp;
    }
}
