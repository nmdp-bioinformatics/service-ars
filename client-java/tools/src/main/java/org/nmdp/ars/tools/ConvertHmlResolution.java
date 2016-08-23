package org.nmdp.ars.tools;

import static org.dishevelled.compress.Writers.writer;

import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.json.simple.JSONObject;
import org.dishevelled.commandline.ArgumentList;
import org.dishevelled.commandline.CommandLine;
import org.dishevelled.commandline.CommandLineParseException;
import org.dishevelled.commandline.CommandLineParser;
import org.dishevelled.commandline.Switch;
import org.dishevelled.commandline.Usage;
import org.dishevelled.commandline.argument.FileArgument;
import org.json.simple.JSONArray;
import org.nmdp.ars.client.ArsClient;
import org.nmdp.ars.client.HmlTypingResolution;

import com.google.common.base.Joiner;



public class ConvertHmlResolution {

	private final boolean printXml, printJson, printCsv;
	private final File inputHmlFile, jsonConfigFile, outputFile;
	private static final String USAGE = "hml-typing-resolution [args]";
	
	public ConvertHmlResolution(final File inputHmlFile,final File jsonConfigFile,final File outputFile, final boolean printXml, final boolean printJson, final boolean printCsv){
		this.inputHmlFile  	= inputHmlFile;
		this.jsonConfigFile = jsonConfigFile;
		this.outputFile 	= outputFile;
		this.printXml 		= printXml;
		this.printJson 		= printJson;
		this.printCsv 		= printCsv;
	}
	
    public Integer call() throws Exception {
    	try{
        	ArsClient arsClient                     = new ArsClient(jsonConfigFile);
        	HmlTypingResolution hmlTypingResolution = new HmlTypingResolution(inputHmlFile,arsClient);
        	JSONObject hmlTyping = hmlTypingResolution.getTyping();
        	printTyping(hmlTyping);
    	}catch (Exception e) {
            e.printStackTrace();
        }
    	return 1;
    }
    
    
    public void printTyping(JSONObject hmlTyping) throws Exception{
        PrintWriter writer    = null;
        try {
            writer = writer(outputFile);

            if(printXml){
	            String jsonString = hmlTyping.toString();
	            org.json.JSONObject jsonObject = new org.json.JSONObject(jsonString);
	            String xmlTyping = org.json.XML.toString(jsonObject);
            	writer.println(xmlTyping);
            }
            if(printJson){
            	hmlTyping.writeJSONString(writer);
            }
            if(printCsv){
				JSONArray subjects = (JSONArray) hmlTyping.get("Subjects");
				@SuppressWarnings("unchecked")
				Iterator<JSONObject> iterator = subjects.iterator();
				 while (iterator.hasNext()) {
					 JSONObject factObj = (JSONObject) iterator.next();
					 String subjectid = (String) factObj.get("SubjectID");
					 JSONArray typing = (JSONArray) factObj.get("typing");
					 List<String> reduxTyping = new ArrayList<String>();
					 for (int i = 0; i < typing.size(); i++) {
						reduxTyping.add(typing.get(i).toString());
					 }
					 String glstring = Joiner.on(",").join(reduxTyping);
					 writer.println(subjectid + "," + glstring);
				 }
            }
        }
        finally {
            try {
                writer.close();
            }
            catch (Exception e) {
                // ignore
            }
        }
    }
    

    /**
     * Main.
     *
     * @param args command line args
     */
    public static void main(final String[] args) {
        Switch about = new Switch("a", "about", "display about message");
        Switch help  = new Switch("h", "help", "display help message");
        Switch xml   = new Switch("x", "xml", "print output as xml");
        Switch json  = new Switch("s", "json", "print output as json");
        Switch csv   = new Switch("c", "csv", "print output as csv");
        FileArgument inputHmlFile = new FileArgument("i", "input-file", "input file, default stdin", false);
        FileArgument outputFile   = new FileArgument("o", "output-file", "output file for hml typing, default stout", false);
        FileArgument jsonFile     = new FileArgument("j", "json-file", "json configuration file", true);
        
        
        ArgumentList arguments  = new ArgumentList(about, help, inputHmlFile, jsonFile, xml, json, csv);
        CommandLine commandLine = new CommandLine(args);

        ConvertHmlResolution cnvertHmlResolution = null;
        try
        {
            CommandLineParser.parse(commandLine, arguments);
            if (help.wasFound()) {
                Usage.usage(USAGE, null, commandLine, arguments, System.out);
                System.exit(0);
            }
            cnvertHmlResolution = new ConvertHmlResolution(inputHmlFile.getValue(), jsonFile.getValue(), outputFile.getValue(), xml.wasFound(), json.wasFound(), csv.wasFound());
        }
        catch (CommandLineParseException e) {
            Usage.usage(USAGE, e, commandLine, arguments, System.err);
            System.exit(-1);
        }
        try {
            System.exit(cnvertHmlResolution.call());
        }
        catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
    
}
