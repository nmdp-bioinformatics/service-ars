package org.nmdp.ars.client;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;

import static org.dishevelled.compress.Readers.reader;
import static org.dishevelled.compress.Writers.writer;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import java.util.concurrent.Callable;

import com.google.common.base.Joiner;
import com.google.common.base.Splitter;

import com.google.common.collect.ArrayListMultimap;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ListMultimap;

import com.google.common.io.CharStreams;
import com.google.common.io.LineProcessor;

import org.apache.http.util.TextUtils;
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import org.nmdp.gl.Allele;
import org.nmdp.gl.AlleleList;
import org.nmdp.gl.Genotype;
import org.nmdp.gl.Haplotype;

import org.nmdp.gl.client.GlClient;
import org.nmdp.gl.client.GlClientException;

import org.nmdp.gl.client.local.LocalGlClient;
import org.nmdp.ngs.hml.HmlReader;
import org.nmdp.ngs.hml.jaxb.AlleleAssignment;
import org.nmdp.ngs.hml.jaxb.Glstring;
import org.nmdp.ngs.hml.jaxb.Haploid;
import org.nmdp.ngs.hml.jaxb.Hml;
import org.nmdp.ngs.hml.jaxb.Sample;
import org.nmdp.ngs.hml.jaxb.Typing;


public class HmlTypingResolution{

	private static File inputHmlFile;
	private ArsClient arsClient;

	public HmlTypingResolution(File inputHmlFile,final ArsClient arsClient){
		this.inputHmlFile = inputHmlFile;
		this.arsClient = arsClient;
	}
	
    @SuppressWarnings("unchecked")
	public JSONObject getTyping() throws Exception {
    	
    	JSONArray subjects = new JSONArray();  
        BufferedReader reader = null;
        try {

            reader = reader(inputHmlFile);
            
            Hml hml = HmlReader.read(reader);
            for (Sample sample : hml.getSample()) {
                String sampleId = sample.getId();
                JSONObject subject = new JSONObject();
                subject.put("SubjectID", sampleId); 
                List<String> genotypes = new ArrayList<String>();
                JSONArray jsonTyping = new JSONArray(); 
                for (Typing typing : sample.getTyping()) {
                    String geneFamily = typing.getGeneFamily();
                    for (AlleleAssignment alleleAssignment : typing.getAlleleAssignment()) {
                        String alleleDb = alleleAssignment.getAlleleDb();
                        String alleleVersion = alleleAssignment.getAlleleVersion();

                        ListMultimap<String, Haploid> haploidsByLocus = ArrayListMultimap.create();
                        for (Object child : alleleAssignment.getPropertyAndHaploidAndGenotypeList()) {
                            if (child instanceof Haploid) {
                                Haploid haploid = (Haploid) child;
                                haploidsByLocus.put(haploid.getLocus(), haploid);
                            }
                        }
                        for (String locus : haploidsByLocus.keySet()) {
                            List<Haploid> haploids = haploidsByLocus.get(locus);

                            String genotype = toGenotype(haploids.get(0), haploids.size() > 1 ? haploids.get(1) : null);
                            jsonTyping.add(genotype);                       
                        }
                    }
                }
                subject.put("typing", jsonTyping);
                subjects.add(subject);
                
            }
            JSONObject arsSubject = arsClient.convertSubjects(subjects);
            return arsSubject;
        }
        finally {
            try {
                reader.close();
            }
            catch (Exception e) {
            	 System.out.println("E1");
            	e.printStackTrace();
            }
        }
    }
    
    static String toGenotype(final Haploid haploid0, final Haploid haploid1) {
        StringBuilder sb = new StringBuilder();
        sb.append(haploid0.getLocus());
        sb.append("*");
        sb.append(haploid0.getType());
        if (haploid1 != null) {
            sb.append("+");
            sb.append(haploid1.getLocus());
            sb.append("*");
            sb.append(haploid1.getType());
        }
        return sb.toString();
    }

	
}






