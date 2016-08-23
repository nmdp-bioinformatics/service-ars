package org.nmdp.ars.tools;

import org.nmdp.ars.client.ValidateClient;

import java.io.File;
import java.io.PrintWriter;
import java.util.concurrent.Callable;

import static org.dishevelled.compress.Readers.reader;
import static org.dishevelled.compress.Writers.writer;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.PrintWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.List;
import java.util.NoSuchElementException;

import org.dishevelled.commandline.ArgumentList;
import org.dishevelled.commandline.CommandLine;
import org.dishevelled.commandline.CommandLineParseException;
import org.dishevelled.commandline.CommandLineParser;
import org.dishevelled.commandline.Switch;
import org.dishevelled.commandline.Usage;
import org.dishevelled.commandline.argument.FileArgument;
import org.dishevelled.commandline.argument.IntegerArgument;
import org.dishevelled.commandline.argument.StringArgument;



/**
 * ValidateAlleles
 *
 */
public final class RemoveInvalidAlleles implements Callable<Integer> {
    private final String restUrl;
    private final String dbversion;
    private final String glstring;
    private final File outputFile;
    private final File inputFile;
    private static final String USAGE = "hla-validate [args]";


    /**
     * Extract consensus sequences from a file in HML format.
     *
     * @param inputHmlFile input HML file, if any
     */
    public RemoveInvalidAlleles(final String restUrl, 
    		            final String dbversion,
    		            final String glstring,
    		            final File outputFile,
    		            final File inputFile) {
        this.restUrl     = restUrl;
        this.dbversion   = dbversion;
        this.glstring    = glstring;
        this.outputFile  = outputFile;
        this.inputFile   = inputFile;        
    }


    //@Override
    public Integer call() throws Exception {
    	PrintWriter writer = null;
    	
        try {
        	writer = writer(outputFile);
        	ValidateClient val        = new ValidateClient(restUrl);
        	
        	if(glstring != null){
	        	String validGl = val.getValidGlstring(dbversion, glstring);
	        	writer.println(validGl);
	            return 0;
        	}else{
        		
        		BufferedReader reader = null;
        		
                try {
                	String line;
                    reader = reader(inputFile);

        			while ((line = reader.readLine()) != null) {
        	        	String validGl = val.getValidGlstring(dbversion, line);
        	        	writer.println(validGl);
        			}
                }finally {
                    try {
                    	reader.close();
                    }
                    catch (Exception e) {
                    	 e.printStackTrace();
                    	 System.exit(1);
                    }
                }
            
        		return 0;
        	}
        }
        finally {
            try {
               writer.close();
            }
            catch (Exception e) {
                e.printStackTrace();
                System.exit(1);
            }
        }
        
    }
    

    /**
     * Main.
     *
     * @param args command line args
     */
    public static void main(final String[] args) {
        
        Switch help = new Switch("h", "help", "display help message");
        
        StringArgument restUrl    = new StringArgument("u", "restUrl", "allele cutoff value", true);
        StringArgument dbversion  = new StringArgument("d", "dbversion", "input blast file, default stdin", true);
        StringArgument glstring   = new StringArgument("g", "glstring", "input blast file, default stdin", false);
       
        FileArgument outputFile   = new FileArgument("o", "output-file", "output file, default stdout", false);
        FileArgument inputFile    = new FileArgument("i", "input-file", "input file, default stdin", false);
        
        ArgumentList arguments    = new ArgumentList( help, restUrl, dbversion, glstring);
        CommandLine commandLine   = new CommandLine(args);

        RemoveInvalidAlleles remove = null;
        try
        {
            CommandLineParser.parse(commandLine, arguments);

            if (help.wasFound()) {
                Usage.usage(USAGE, null, commandLine, arguments, System.out);
                System.exit(0);
            }
            if (restUrl.getValue() == null || dbversion.getValue() == null ) {
                Usage.usage(USAGE, null, commandLine, arguments, System.out);
                System.exit(0);
            }


            remove = new RemoveInvalidAlleles(restUrl.getValue(),dbversion.getValue(),glstring.getValue(),outputFile.getValue(),inputFile.getValue());
        }
        catch (CommandLineParseException e) {
            Usage.usage(USAGE, e, commandLine, arguments, System.err);
            System.exit(-1);
        }
        try {
            System.exit(remove.call());
        }
        catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
    }
}
