/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class HCGlobals {
    global static Boolean ENABLE_AUTO_ADD_PATIENT_TO_CARETEAM;
    global static Boolean ISREQUIRED;
    global HCGlobals() {

    }
global interface IProcessCreateCarePlan {
    List<Id> createCarePlanFromLead(List<Id> param0);
}
global interface IProcessLeadToIndividual {
    List<Id> createIndividualsFromLead(List<Id> param0);
}
global class Message {
    global String code {
        get;
    }
    global String detail {
        get;
        set;
    }
    global Double resultCode;
    global String scope {
        get;
        set;
    }
    global HealthCloudGA.HCGlobals.Severity severity {
        get;
        set;
    }
    global String summary {
        get;
    }
    global Message(String code, String summary, Double resultCode) {

    }
    global Boolean equals(Object obj) {
        return null;
    }
    global String getMessageString() {
        return null;
    }
    global Double getResultCode() {
        return null;
    }
    global Integer hashCode() {
        return null;
    }
}
global class ParseGenericException extends Exception {
}
global enum Severity {DEBUG, ERROR, FATAL, INFO, WARN}
}
