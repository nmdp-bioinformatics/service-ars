package org.nmdp.ars.client;

import org.json.simple.*;
import org.json.simple.parser.JSONParser;

import java.io.File;
import java.io.FileReader;


import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpPut;
import org.apache.http.entity.StringEntity;
import org.apache.http.util.EntityUtils;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.protocol.HTTP;


/**
 * ArsClient
 *
 */
public class ArsClient 
{

	private ArsServiceResource arsServiceResource;
	final private File jsonConfigFile;
	
	public ArsClient(final File jsonConfigFile){
		this.jsonConfigFile = jsonConfigFile;
		this.arsServiceResource = new ArsServiceResource(getJsonConfig());
	}
	
	@SuppressWarnings("unchecked")
	public JSONObject convertSubjects(JSONArray jsonSubjects) {
		 
		 JSONObject arsRequest = arsServiceResource.getBasePostRequest();
		 arsRequest.put("Subjects",jsonSubjects);

	    HttpClient httpClient = new DefaultHttpClient();
	    try {
	        HttpPut request = new HttpPut(arsServiceResource.getUrl());
	        StringEntity params =new StringEntity(arsRequest.toString(),"UTF-8");
	        params.setContentType("application/json");
	        request.addHeader("content-type", "application/json");
	        request.addHeader("Accept", "*/*");
	        request.setEntity(params);
	        
	        HttpPost post = new HttpPost(arsServiceResource.getUrl());
	        StringEntity entity = new StringEntity(arsRequest.toString(), HTTP.UTF_8);
	        entity.setContentType("application/json");
	        post.setEntity(entity);
	        post.addHeader("Content-Type", "application/json");
	        HttpResponse response = httpClient.execute(post);

		     String json_string = EntityUtils.toString(response.getEntity());
		     JSONObject jsonResponse = (JSONObject) JSONValue.parse(json_string);
		     return jsonResponse;
		 } catch (Exception ex) {
			 ex.printStackTrace();
		 } 
		 
		 return null;
		 
	 }
	
	private JSONObject getJsonConfig() {
	    JSONParser parser = new JSONParser();
	    try {
	        Object obj = parser.parse(new FileReader(jsonConfigFile));
	        JSONObject jsonObject = (JSONObject) obj;
	        return jsonObject;
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	    return null;
	}
	 

}