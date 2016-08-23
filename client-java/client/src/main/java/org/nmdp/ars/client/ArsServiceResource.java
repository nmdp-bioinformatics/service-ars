package org.nmdp.ars.client;

import org.json.simple.parser.JSONParser;
import org.json.simple.JSONObject;

public class ArsServiceResource extends ServiceResource {

	private String arsType, macUrl, imgtDb, arsFile, expandGenomic, expandGlstring;
	private JSONObject arsJson = new JSONObject();

	@SuppressWarnings("unchecked")
	public ArsServiceResource(final JSONObject arsJsonConfig){
	
		if((String) arsJsonConfig.get("arsUrl") != null && validUrl((String) arsJsonConfig.get("arsUrl")) == true){
			serviceUrl = (String) arsJsonConfig.get("arsUrl");
		}else{
			throw new IllegalArgumentException("No ars service url");
		}
		
		if((String) arsJsonConfig.get("arsFile") != null){
			arsFile = (String) arsJsonConfig.get("arsFile");
		}else{
			throw new IllegalArgumentException("No arsFile provided");
		}
		
		if((String) arsJsonConfig.get("macUrl") != null && validUrl((String) arsJsonConfig.get("macUrl"))){
			macUrl = (String) arsJsonConfig.get("macUrl");
		}else{
			throw new IllegalArgumentException("No url provided for mac service");
		}
		
		if((String) arsJsonConfig.get("arsType") != null && validArsType((String) arsJsonConfig.get("arsType"))){
			arsType = (String) arsJsonConfig.get("arsType");
		}else{
			throw new IllegalArgumentException("No ars type provided");
		}
		
		if((String) arsJsonConfig.get("dbversion") != null && validImgtDb((String) arsJsonConfig.get("dbversion"))){
			imgtDb = (String) arsJsonConfig.get("dbversion");
		}else{
			throw new IllegalArgumentException("No imgtDb ");
		}
		
		if((String) arsJsonConfig.get("expandGenomic") != null)
			expandGenomic = (String) arsJsonConfig.get("expandGenomic");
			
		if((String) arsJsonConfig.get("expandGlstring") != null)
			expandGlstring = (String) arsJsonConfig.get("expandGlstring");

		arsJson.put("arsType", arsType);
		arsJson.put("arsUrl", serviceUrl);
		arsJson.put("macUrl", macUrl);
		arsJson.put("dbversion", imgtDb);
		arsJson.put("arsFile", arsFile);
		
		if(expandGenomic != null)
			arsJson.put("expandGen", expandGenomic);

		if(expandGlstring != null)
			arsJson.put("expandGeno", expandGlstring);
		
	}
	
	public JSONObject getBasePostRequest(){
		return arsJson;
	}
	
	private boolean validArsType(String arsType){
		if(arsType.equals("G") || arsType.equals("g") || arsType.equals("P")){
			return true;
		}else{
			return false;
		}
	}

	
}
