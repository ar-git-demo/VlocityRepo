/**
* OSCensusTools - make it easier for OmniScripts to work with Group Censuses by
* providing a library of tools to create censuses from both manually entered
* as well as CSV sources.
*
* @author Charles McGuinness
*/

global with sharing class OSCensusTools  implements vlocity_ins.VlocityOpenInterface {

    /**
     * Standard entrypoint for VlocityOpenInterface.
     */
     global Boolean InvokeMethod( String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        try {

            if (methodName.equals('Manual2Census')) {
                doManual2Census(methodName, input, output, options);
                return true;
            }

            if (methodName.equals('AttachCensus')) {
                doAttachCensus(methodName, input, output, options);
                return true;
            }

            if (methodName.equals('CheckStatus')) {
                doCheckStatus(methodName, input, output, options);
                return true;
            }

            if (methodName.equals('GetCensusHeaders')) {
                doGetCensusHeaders(methodName, input, output, options);
                return true;
            }
            if (methodName.equals('GetAccountsByName')) {
                GetAccountsByName(methodName, input, output, options);
                return true;
            }


        } catch (Exception e) {
            output.put('Error', e.getMessage());
            output.put('ErrorLine', e.getLineNumber());
        }

        return false;
    }


    /**
    * newCensus - Utility routine to create a new GroupCensus with starter
    * data.
    *
    * @param accountId Id for the account this census belongs to
    * @param accountName name of the same account.  I could find it via Id, but since someone already knows it this saves a lookup
    * @return the Id of the newly created census
    */
    private String newCensus(String accountId, String accountName, String EffectiveDate, String EndDate) {
        vlocity_ins__GroupCensus__c gc = new vlocity_ins__GroupCensus__c();
        gc.put('Name', accountName + ' Census ' + Datetime.now().format());
        gc.put('vlocity_ins__CensusStatus__c', 'Active');
        gc.put('vlocity_ins__GroupId__c', accountId);
        gc.put('vlocity_ins__EffectiveStartDate__c', Date.valueOf(EffectiveDate));
        gc.put('vlocity_ins__EffectiveEndDate__c', Date.valueOf(EndDate));
        insert gc;


        return (String) gc.get('Id');

    }


    private void processMember(Map<String,Object> primaryMember, String censusId ) {
        String firstName = (String) primaryMember.get('FirstName');
        System.debug(firstName);
        String lastName =  (String) primaryMember.get('LastName');
        String doh =  (String) primaryMember.get('DOH');
        String dob =  (String) primaryMember.get('DOB');
        String gender =  (String) primaryMember.get('Gender');

        vlocity_ins__GroupCensusMember__c gcm = new vlocity_ins__GroupCensusMember__c();
        gcm.put('vlocity_ins__CensusId__c', censusId);

        gcm.put('Name', lastName);
        gcm.put('vlocity_ins__FirstName__c', firstName);
        gcm.put('vlocity_ins__HireDate__c', Date.valueOf(doh));
        gcm.put('vlocity_ins__Birthdate__c', Date.valueOf(dob));
        gcm.put('vlocity_ins__Gender__c', gender);
        gcm.put('vlocity_ins__IsPrimaryMember__c', true);

        insert gcm;

        String gcmId =  (String)  gcm.get('Id');

        for (Integer j=1;j<4;j++) {
            String d = String.valueOf(j);
            Map<String,Object> depMember = (Map<String,Object>) primaryMember.get('Dependent' + d);
            String dFirst = (String) depMember.get('d' + d + 'FirstName' );
            if (dFirst == null) {
                continue;
            }
            String dlast = (String) depMember.get('d' + d + 'LastName' );
            if (dlast == null) {
                continue;
            }

            String dDOB = (string)  depMember.get('d' + d + 'DOB' );
            String dRel = (string)  depMember.get('d' + d + 'Relationship' );
            String dGender = (string)  depMember.get('d' + d + 'Gender' );

            vlocity_ins__GroupCensusMember__c depGcm = new vlocity_ins__GroupCensusMember__c();

            depGcm.put('vlocity_ins__CensusId__c', censusId);
            depGcm.put('vlocity_ins__RelatedCensusMemberId__c', gcmId);
            depGcm.put('Name', dlast);
            depGcm.put('vlocity_ins__FirstName__c', dFirst);
            depGcm.put('vlocity_ins__Birthdate__c', Date.valueOf(dDOB));
            depGcm.put('vlocity_ins__Gender__c', dGender);
            depGcm.put('vlocity_ins__IsPrimaryMember__c', false);
            // depGcm.put('vlocity_ins__IsFamily__c', true);

            insert depGcm;
        }

    }

    private void doManual2Census(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        String accountId = (String) input.get('accountId');
        String accountName = (String) input.get('accountName');
        String EffectiveDate=(String) input.get('EffectiveDate');
        String EndDate=(String) input.get('EndDate');
               
        Object oCensus = input.get('census');

        if (oCensus == null) {
            output.put('Error', 'No census passed in');
            return;
        }

        // Create new census
        String censusId = newCensus(accountId, accountName, EffectiveDate, EndDate);
        output.put('CensusId', censusId);

        // We can either get a list, meaning lots of primary members, or an object with just one
        if (oCensus instanceof List<Object>) {
            List<Object> manyCensys = (List<Object>) oCensus;


            // Loop over manual entrants
            for (Integer i=0; i<manyCensys.size(); i++) {
                Map<String,Object> primaryMember = (Map<String,Object>) manyCensys[i];
                processMember(primaryMember, censusId);
            }

        } else {
            // Just one member...
            processMember((Map<String,Object>) oCensus, censusId);
       }

    }


    private void GetAccountsByName(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        List<Map<String,String>> results = new List<Map<String,String>>();
        String name = String.valueOf(input.get('name'));
        List<Account> al =   [select Id, Name, BillingCity, BillingState from Account where Name like :name];
        output.put('debug_total', String.valueOf(al.size()));

        for (Account a: al) {
            Map<String,String> nv = new Map<String,String>();
            nv.put('Id', String.valueOf(a.get('Id')));
            nv.put('Name', String.valueOf(a.get('Name')));
            nv.put('BillingCity', String.valueOf(a.get('BillingCity')));
            nv.put('BillingState', String.valueOf(a.get('BillingState')));
            results.add(nv);

        }
        output.put('siAccounts', results);
        output.put('showAccounts', 'yes');
    }

    private void doGetCensusHeaders(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        String aid = (String) input.get('attachmentId');

        // String parentid = (String) input.get('accountId');
        Attachment att=   [Select Id,ParentId, Name,body,ContentType From Attachment where Id=:aid limit 1]; 

        String data = EncodingUtil.base64Decode(EncodingUtil.base64Encode(Blob.valueOf(att.body.toString()))).toString();
        // RecordType serviceRt = [select Id from RecordType where SobjectType='Account' and DeveloperName='Service' limit 1];

        String firstLine = data.substring(0, data.indexOf('\n'));

        List<String> headers = firstLine.split(',');

        output.put('FileHeaders', headers);
    }


    private void doAttachCensus(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {

        Datetime dtStart = Datetime.now();
        //  Get input parameters
        String attachmentId = (String) input.get('attachmentId');
        String accountId = (String) input.get('accountId');
        String accountName = (String) input.get('accountName');
        String EffectiveDate=(String) input.get('EffectiveDate');
        String EndDate=(String) input.get('EndDate');
        
        List<Object> fieldNames = (List<Object>) input.get('fieldNames');

        // Create new census
        String censusId = newCensus(accountId, accountName, EffectiveDate, EndDate);
        output.put('CensusId', censusId);

        // Retrieve the census file, convert it to a string
        Attachment att=   [Select Id,ParentId, Name,body,ContentType From Attachment where Id=:attachmentId limit 1]; 
        String data = EncodingUtil.base64Decode(EncodingUtil.base64Encode(Blob.valueOf(att.body.toString()))).toString();

        // Parse the headers of the file
        Integer headerPos = data.indexOf('\n');
        data = data.substring(headerPos+1);


        // Figure out the field types...
        Map<String, Schema.SObjectField> gcmFields =  Schema.SObjectType.vlocity_ins__GroupCensusMember__c.fields.getMap();
        Map<String, Schema.DisplayType> fieldTypes = new Map<String, Schema.DisplayType> ();

        for (Integer i=0;i<fieldNames.size();i++) {
            String fieldName = (String) fieldNames[i];
            if (fieldName != Null && ! fieldName.equalsIgnoreCase('unmapped')) {
                Schema.SObjectField thisField = gcmFields.get(fieldName);
                Schema.DescribeFieldResult dfr = thisField.getDescribe();
                Schema.DisplayType ftype = dfr.getType();
                fieldTypes.put(fieldName, ftype);
            }
        }


        // Feed the lines into the batch handler
        CensusBatchClass cbc;
        Id batchId;
        List<Id> batchIds = new List<Id>();


        List<String> linesToBatch = new List<String>();

        while (data.length() > 0) {
            Integer newlinePos = data.indexOf('\n');
            if (newlinePos < 0) {
                newlinePos = data.length();
                data = data + '\n';
            }

            String line = data.substring(0, newlinePos);
            data = data.substring(newlinePos+1);

            linesToBatch.add(line);

            if (linesToBatch.size() == 5000) {
                cbc = new CensusBatchClass(linesToBatch, censusId, fieldNames, fieldTypes);
                batchIds.add(Database.executeBatch(cbc));
                linesToBatch = new List<String>();
            }

        }

        if (linesToBatch.size() > 0) {
            cbc = new CensusBatchClass(linesToBatch, censusId, fieldNames, fieldTypes);
            batchIds.add(Database.executeBatch(cbc));
        }

        output.put('BatchIds', batchIds);
        output.put('BatchInProgress', batchIds.size());
        output.put('BatchFinished', 0);
        output.put('BatchStartTime', String.valueOf(dtStart.getTime()));


    }

    private void doCheckStatus(String methodName, Map<String,Object> input, Map<String,Object> output, Map<String,Object> options) {
        List<Object> batchIds = (List<Object>) input.get('BatchIds');
        Long lStart = Long.valueOf((String) input.get('BatchStartTime'));

        Integer inProgress = 0;
        Integer finished = 0;

        for (Integer i=0;i<batchIds.size(); i++) {
            String batchId = (String) batchIds[i];
            AsyncApexJob a = [Select Id, Status  from AsyncApexJob where Id = :batchId];   
            if (a.Status == 'Completed') {
                finished++;
            } else {
                inProgress++;
            }
        }

        Datetime dtNow = Datetime.now();

        Time elapsed = Time.newInstance(0,0,0,Integer.valueOf(dtNow.getTime() - lStart));
        String e = String.valueOf(elapsed).left(8);

        output.put('BatchInProgress', inProgress);
        output.put('BatchFinished', finished);
        output.put('ElapsedTime', e);

    }
}