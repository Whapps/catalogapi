package com.catalogapi;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.catalogapi.util.XMLTools;

public class ListAvailableCatalogsResponse
{
    XMLTools xml_tools = new XMLTools();
    
    public ListAvailableCatalogsResponse(String response_xml) throws Exception
    {
        Document doc = xml_tools.parse(response_xml);
        
        NodeList domain_nodes = doc.getElementsByTagName("ns0:domain");
        for (int i = 0; i < domain_nodes.getLength(); i++)
        {
            Element domain_node = (Element)domain_nodes.item(i);
            System.out.println("Found domain: " + xml_tools.getChildValue(domain_node, "domain_name"));
            
            NodeList socket_nodes = domain_node.getElementsByTagName("ns0:Socket");
            
            for (int j = 0; j < socket_nodes.getLength(); j++)
            {
                Element socket_node = (Element)socket_nodes.item(j);
                System.out.println("Found socket: " + xml_tools.getChildValue(socket_node, "socket_name"));
            }
        }
    }
    
    
}
