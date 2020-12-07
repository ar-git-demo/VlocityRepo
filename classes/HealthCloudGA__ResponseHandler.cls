/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class ResponseHandler {
    global Object Context {
        get;
        set;
    }
    global Object Data {
        get;
        set;
    }
    global Boolean isDebug;
    global Set<HealthCloudGA.HCGlobals.Message> Messages {
        get;
        set;
    }
    global static void addMessage(HealthCloudGA.HCGlobals.Message message, HealthCloudGA.HCGlobals.Severity severity, String scope, String detail) {

    }
    global static void addMessage(HealthCloudGA.HCGlobals.Message message, HealthCloudGA.HCGlobals.Severity severity, String scope, String detail, Exception ex) {

    }
    global static HealthCloudGA.ResponseHandler getInstance() {
        return null;
    }
    global static String getMessageTrace() {
        return null;
    }
    global static List<HealthCloudGA.HCGlobals.Message> getMessages() {
        return null;
    }
    global void setDebug(Boolean isDebug) {

    }
}
