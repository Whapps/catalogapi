package com.catalogapi.util;

import java.io.ByteArrayInputStream;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class XMLTools
{
    DocumentBuilderFactory doc_builder_factory;
    DocumentBuilder doc_builder;
    
    // this object is NOT thread safe!
    // however, this object can be re-used within the same thread
    public XMLTools() throws Exception
    {
        this.doc_builder_factory = DocumentBuilderFactory.newInstance();
        doc_builder_factory.setNamespaceAware(true);
        
        this.doc_builder = doc_builder_factory.newDocumentBuilder();
    }
    
    public Document parse(String xml_string) throws Exception
    {
        ByteArrayInputStream xml_bytes = new ByteArrayInputStream(xml_string.getBytes("UTF8"));
        
        doc_builder.reset();
        Document doc = doc_builder.parse(xml_bytes);
        
        return doc;
    }
    
    public String getChildValue(Element parent, String child_name)
    {
        String value = "";
        
        NodeList results = parent.getElementsByTagName("ns0:"+child_name);
        outerloop: for (int i = 0; i < results.getLength(); i++)
        {
            Element e = (Element)results.item(i);
            NodeList nodes = e.getChildNodes();
            for (int j = 0; j < nodes.getLength(); j++)
            {
                Node child = nodes.item(j);
                if (child.getNodeType() == Node.TEXT_NODE)
                    value = child.getNodeValue();
                    break outerloop;
            }
        }
        
        return value;
    }
}