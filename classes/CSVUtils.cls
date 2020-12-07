/**
 * This class provides some useful utilities for dealing with CSV files.
 * 
 * @author Joe McMaster (jmcmaster@vlocity.com)
 * @version 1.0
 * 
 * History
 * =======
 * v1.0 - 09-19-2018 - Initial Version
 * 
 */
global with sharing class CSVUtils implements vlocity_ins.VlocityOpenInterface {

    public class ParsingException extends Exception {
    
        public override String getStackTraceString() {
            return super.getCause().getStackTraceString();
        }
    }

    /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName == 'load') return load(inputMap, outputMap, options);  
        
        return false;
    }
    
    /**
     * This method will attempt to parse one or more CSV files and convert them into a JSON structure
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - The output map provided to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if this method completes successfully, false otherwise
     */
     private Boolean load(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
         
         List<Object> rows = new List<Object>();
         
         // Get the file(s) uploaded
         Map<String, Object> files = (Map<String, Object>)options.get('vlcFilesMap');
         for (String key : files.keySet()) {
             
             // Load the file content
             String fileContent = String.valueOf(files.get(key));
             rows.addAll(processContent(decode(fileContent)));
         }
         outputMap.put('data', rows);
         
         return true;
     }
    
    /**
     * This method attempts to process the raw CSV file content to produce a Map structure for each row.  It assumes
     * the first row of the content is the header and those fields will be used as the keys for the cells in each row.
     * 
     * @param content - The raw content
     * 
     * @return The list of rows, each as a Map object
     * 
     * @throws Exception if there are any problems parsing the data
     */
    private List<Object> processContent(String content) {
        
        List<Object> maps = new List<Object>();
        
        if (content != null) {
            
            // Get the rows
            List<List<String>> rows = parseCSV(content);
    
            if (rows.size() > 0) {
            
                // Assume the first row is the header (If I ever need to support CSV files with no header, I'll enhance this)
                List<String> headers = rows.get(0);
                
                // Process remaining rows
                for (Integer i=1; i<rows.size(); i++) {
                    
                    // Get the values
                    List<String> values = rows.get(i);
                    
                    // Check for inconsistencies 
                    if (values.size() != headers.size()) throw new ParsingException('Number of values ' + values + ' do not match the number of headers ' + headers);
                    
                    // Create the Map representing this row
                    Map<String, Object> entry = new Map<String, Object>();
                    for (Integer x=0; x<values.size(); x++) entry.put(headers.get(x), values.get(x));                
                    maps.add(entry);
                }
            }
        }

        return maps;
    }

    /*
     * Here is a CSV parsing function that returns an array (lines) of string arrays (fields). Does not handle newlines in the content though. 
     *  
     * @param contents  The raw content
     * 
     * @return List of rows, each containing a list of values
     *
     * @see https://developer.salesforce.com/page/Code_Samples#Parse_a_CSV_with_APEX
     */    
    public static List<List<String>> parseCSV(String contents) {

        List<List<String>> allFields = new List<List<String>>();

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"_DBLQT_').replaceall('""",','_DBLQT_",');

        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','_DBLQT_');

        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();

        try {
            
            lines = contents.split('\n');
        } 
        catch (System.ListException e) {
            
            System.debug('Limits exceeded?' + e.getMessage());
        }

        Integer num = 0;
        for(String line : lines) {

            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
 
            List<String> fields = line.split(',');   
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                
                if (field.startsWith('"') && field.endsWith('"')) cleanFields.add(field.trim().replaceAll('_DBLQT_','"'));
                else if (field.startsWith('"')) {
                    
                    makeCompositeField = true;
                    compositeField = field;
                }
                else if (field.endsWith('"')) {
                    
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.trim().replaceAll('_DBLQT_','"'));
                    makeCompositeField = false;

                }
                else if (makeCompositeField) compositeField +=  ',' + field;
                else cleanFields.add(field.trim().replaceAll('_DBLQT_','"'));
            }
            
            allFields.add(cleanFields);
        }

        return allFields;
    }
    
    /*
     * Decodes the raw content content
     * 
     * @param content  The raw content
     * 
     * @return The decoded content as a string
     * 
     * @throws ParsingException if there are any problems decoding the content (i.e. Unsupported format, etc.);
     */
    private String decode(String content) {
        
        // The raw content of an uploaded CSV file uses the following format
        // data:text/csv;base64,QmlsbGluZ0FjY291bnQsTmFtZSxTZXJpYWx.......
        //
        // however, it may also look like this if the user has selected "Upload To Content Document" on the OmniScript File Input element
        // which causes the file to instead be uploaded into the Salesforce Files repository and the content then becomes the Id of the File
        // 0691j0000004arwAAA
        //
        // Check to make sure we can process the file in either case
        if (content.contains(',')) { 

            String metadata = content.substring(0, content.indexOf(','));
        
            // Determine the type of data we are dealing with
            if (metadata.contains('data:text/csv;')) {
            
                if (metadata.contains('base64')) return EncodingUtil.base64Decode(content.removeStart(metadata + ',')).toString();
                return content.removeStart(metadata + ',');
            }
            else throw new ParsingException('Unable to parse content with type = ' + metadata);
        }
        else {
            
            // Try to pull the file content out of Salesforce Content
            List<ContentVersion> contentVersions = (List<ContentVersion>)Database.query('SELECT FileType, VersionData FROM ContentVersion WHERE ContentDocumentId=\'' + content + '\' AND IsLatest=true LIMIT 1');
            if (!contentVersions.isEmpty()) {
                
                ContentVersion version = contentVersions.get(0);
                
                if (version.FileType.equalsIgnoreCase('CSV')) {
                
                    // Stored as a Blob, so just convert it to a String
                    return version.VersionData.toString();
                }
                else throw new ParsingException('Unable to parse file type "' + version.FileType + '".');
            }
            else throw new ParsingException('Unable to retrieve Content Document with Id=' + content + ' from Salesforce Files Repository.');
        }
    }
}