global class CensusBatchClass implements Database.batchable<String> {
    String[] source;
    String censusId;
    List<Object> fieldNames;
    Map<String, Schema.DisplayType> fieldTypes;

    global CensusBatchClass(String[] source, String censusId, List<Object> fieldNames, Map<String, Schema.DisplayType> fieldTypes) {
        this.source = source;
        this.censusId = censusId;
        this.fieldNames = fieldNames;
        this.fieldTypes = fieldTypes;
    }

    global Iterable<String> start(Database.BatchableContext info) {

        return this.source;
    }    
    global void execute(Database.BatchableContext info, List<String> scope) {

        List<vlocity_ins__GroupCensusMember__c> members = new List<vlocity_ins__GroupCensusMember__c>();

        for (String line: scope) {
            try {
                List<String> fields = line.split(',');

                vlocity_ins__GroupCensusMember__c gcm = new vlocity_ins__GroupCensusMember__c();
                gcm.put('vlocity_ins__CensusId__c', this.censusId);

                for (Integer i=0;i<fields.size();i++) {
                    String fieldName = (String) this.fieldNames[i];
                    if (fieldName != Null && ! fieldName.equalsIgnoreCase('unmapped')) {
                        Schema.DisplayType ftype = this.fieldTypes.get(fieldName);
                        if (ftype ==  Schema.DisplayType.Double) {
                            gcm.put(fieldName, Double.valueOf(fields[i]));
                        } else if (ftype ==  Schema.DisplayType.Integer) {
                            gcm.put(fieldName, Integer.valueOf(fields[i]));
                        } else if (ftype ==  Schema.DisplayType.Currency) {
                            gcm.put(fieldName, Decimal.valueOf(fields[i]));
                        } else if (ftype ==  Schema.DisplayType.Date) {
                            try {
                                gcm.put(fieldName, Date.valueOf(fields[i]));
                            } catch (Exception e) {
                                // ignore bad dates
                            }
                        } else if (ftype ==  Schema.DisplayType.Boolean) {
                            gcm.put(fieldName, Boolean.valueOf(fields[i]));
                        } else {
                            gcm.put(fieldName, fields[i]);
                        }
                    }
                }
                members.add(gcm);
            } catch (Exception e) {
                System.debug('Error: '+e.getMessage());
                System.debug('ErrorLine: '+e.getLineNumber());
                System.debug('Processing line: '+line);
            }
        }
        insert members;
    }    
    global void finish(Database.BatchableContext info){    
    }
}