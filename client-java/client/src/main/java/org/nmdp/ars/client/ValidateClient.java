package org.nmdp.ars.client;

import java.net.URLEncoder;

import org.json.*;
import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;

public class ValidateClient {
	
	private final String restUrl;
	
	public ValidateClient(final String restUrl){
		this.restUrl = restUrl;
	}
	
	 public String validateAllele(String dbversion, String allele) {
		 
			try {

				Client client = Client.create();

				StringBuilder restBuilder = new StringBuilder(1200);
				restBuilder.append(restUrl);
				restBuilder.append("/validateAllele?dbversion=" + dbversion);
				restBuilder.append("&allele="    + allele);
				String restCall = restBuilder.toString();

				WebResource webResource = client.resource(restCall);

				ClientResponse response = webResource.accept("application/json")
		                   .get(ClientResponse.class);

				if (response.getStatus() != 200) {
				   throw new RuntimeException("Failed : HTTP error code : "
					+ response.getStatus());
				}

				String output  = response.getEntity(String.class);
				JSONObject obj = new JSONObject(output);
				
				String valid = obj.getString("valid");
				return valid;
				
			  } catch (Exception e) {

				e.printStackTrace();
				return null;
			  }

	 }
	 
	 public String getValidGlstring(String dbversion, String glstring) {
		 
			try {

				Client client = Client.create();

				StringBuilder restBuilder = new StringBuilder(1200);
				restBuilder.append(restUrl);
				restBuilder.append("/validGlstring?dbversion=" + dbversion);
				restBuilder.append("&glstring="      +  URLEncoder.encode(glstring));
				String restCall = restBuilder.toString();
				
				WebResource webResource = client.resource(restCall);

				ClientResponse response = webResource.accept("application/json")
		                   .get(ClientResponse.class);

				if (response.getStatus() != 200) {
				   throw new RuntimeException("Failed : HTTP error code : "
					+ response.getStatus());
				}

				String output  = response.getEntity(String.class);
				JSONObject obj = new JSONObject(output);
				
				String validGlstring = obj.getString("validGl");
				return validGlstring;
				
			  } catch (Exception e) {

				e.printStackTrace();
				return null;
			  }

	 }
	 
	 public String getInvalidAlleles(String dbversion, String glstring) {
		 
			try {

				Client client = Client.create();

				StringBuilder restBuilder = new StringBuilder(1200);
				restBuilder.append(restUrl);
				restBuilder.append("/validGlstring?dbversion=" + dbversion);
				restBuilder.append("&glstring="    + glstring);
				String restCall = restBuilder.toString();

				WebResource webResource = client.resource(restCall);

				ClientResponse response = webResource.accept("application/json")
		                   .get(ClientResponse.class);

				if (response.getStatus() != 200) {
				   throw new RuntimeException("Failed : HTTP error code : "
					+ response.getStatus());
				}

				String output  = response.getEntity(String.class);
				JSONObject obj = new JSONObject(output);
				
				String invalidGlstring = obj.getString("invalid");
				return invalidGlstring;
				
			  } catch (Exception e) {

				e.printStackTrace();
				return null;
			  }

	 }
	 
	 
	 
}
