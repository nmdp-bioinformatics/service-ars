package org.nmdp.ars.client;

import org.json.simple.JSONObject;

public abstract class ServiceResource {

	String serviceUrl;
	
	public String getUrl(){
		return serviceUrl;
	}
	boolean validUrl(String url){
		return true;
	}
	
	boolean validImgtDb(String imgtDb){
		return true;
	}
	
	public abstract JSONObject getBasePostRequest();
	

	
}
