/*

    ngs-tools  Next generation sequencing (NGS/HTS) command line tools.
    Copyright (c) 2014-2015 National Marrow Donor Program (NMDP)

    This library is free software; you can redistribute it and/or modify it
    under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation; either version 3 of the License, or (at
    your option) any later version.

    This library is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; with out even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
    License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this library;  if not, write to the Free Software Foundation,
    Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA.

    > http://www.gnu.org/licenses/lgpl.html

*/
package org.nmdp.ars.client;


import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;
import java.util.Map;

import com.google.common.base.Charsets;

import com.google.common.collect.ListMultimap;

import com.google.common.io.Files;
import com.google.common.io.Resources;

import junit.framework.TestCase;
import junit.framework.TestSuite;


import org.nmdp.gl.AlleleList;
import org.nmdp.gl.Genotype;

import org.nmdp.gl.client.GlClient;

import org.nmdp.gl.client.local.LocalGlClient;

import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

/**
 * Unit test for ValidateInterpretation.
 */
public final class ArsServiceResourceTest extends TestCase{
	
    private File jsonConfig;
    
    /**
     * Create the test case
     *
     * @param testName name of the test case
     */
    public ArsServiceResourceTest( String testName )
    {
        super( testName );
    }
    
    
    /**
     * @return the suite of tests being tested
     */
    public static Test suite()
    {
        return new TestSuite( ArsServiceResourceTest.class );
    }

    /**
     * Rigourous Test :-)
     * @throws URISyntaxException 
     */
    @SuppressWarnings("unchecked")
	public void testApp() throws URISyntaxException
    {
    	
    	ClassLoader classLoader = getClass().getClassLoader();
    	File file = new File(classLoader.getResource("arsServiceResource.json").getFile());
    	File hmlFile = new File(classLoader.getResource("arsHmlExample.xml").getFile());
    	
    	try {

	        JSONParser parser = new JSONParser();
	        try {
//	            Object obj = parser.parse(new FileReader(file));
//	            JSONObject jsonObject = (JSONObject) obj;
//	            System.out.println((String) jsonObject.get("arsUrl"));
//	            ArsServiceResource arsServiceResourse = new ArsServiceResource(jsonObject);
//	            
//	            JSONObject baseRequest = arsServiceResourse.getBasePostRequest();
	            
//	            ArsClient arsClient = new ArsClient(file);
//	            
//	            
//	            JSONArray subjects = new JSONArray();  
//	            
//	            JSONObject subject = new JSONObject(); 
//	            subject.put("SubjectID", 1); 
//	            JSONArray typing = new JSONArray(); 
//	            typing.add("A*02:01+A*02:AB");
//	            typing.add("A*01:01+A*01:01");
//	            
//	            subject.put("typing", typing);
//     
//	            subjects.add(subject);
//	            
//	            HmlTypingResolution hmlRes = new HmlTypingResolution(hmlFile,arsClient);
//	            
//	            JSONObject convertedSubject = hmlRes.getTyping();
//	            
//	            String jsonString = convertedSubject.toString();
//	            org.json.JSONObject o = new org.json.JSONObject(jsonString);
//	            String xml = org.json.XML.toString(o);
//	            System.out.println(xml);
	           // JSONObject convertedSubject = arsClient.convertSubjects(hmlTyping);
	            
	           // System.out.println(convertedSubject);
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        assertTrue( true );
    }

    

}
