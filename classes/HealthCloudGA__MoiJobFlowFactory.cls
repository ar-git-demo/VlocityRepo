/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MoiJobFlowFactory {
global interface MoiIErrorHandler {
    void handleError(HealthCloudGA.MoiJobFlowFactory.MoiIJobContext param0, Exception param1);
}
global interface MoiIJob {
    HealthCloudGA.MoiJobFlowFactory.MoiIErrorHandler getErrorHandler();
    String getJobName();
    Boolean processJob(HealthCloudGA.MoiJobFlowFactory.MoiIJobContext param0);
    void setJobName(String param0);
}
global interface MoiIJobContext {
    List<Map<String,Object>> getContextData();
    void setContextData(List<Map<String,Object>> param0);
    void setStopProcess(Boolean param0);
    Boolean stopProcess();
}
global virtual class MoiJobBase implements HealthCloudGA.MoiJobFlowFactory.MoiIJob {
    global List<HealthCloudGA.MoiJobFlowFactory.MoiIJob> dependencies;
    global Datetime endTime;
    global String jobId;
    global String jobName;
    global HealthCloudGA.MoiJobFlowFactory.Status jobStatus;
    global Datetime startTime;
    global MoiJobBase() {

    }
    global virtual HealthCloudGA.MoiJobFlowFactory.MoiIErrorHandler getErrorHandler() {
        return null;
    }
    global String getJobId() {
        return null;
    }
    global String getJobName() {
        return null;
    }
    global virtual Boolean processJob(HealthCloudGA.MoiJobFlowFactory.MoiIJobContext jc) {
        return null;
    }
    global void setJobId(String id) {

    }
    global void setJobName(String jobName) {

    }
}
global virtual class MoiJobContextBase implements HealthCloudGA.MoiJobFlowFactory.MoiIJobContext {
    global MoiJobContextBase() {

    }
    global List<Map<String,Object>> getContextData() {
        return null;
    }
    global void setContextData(List<Map<String,Object>> contextDataMap) {

    }
    global void setStopProcess(Boolean value) {

    }
    global Boolean stopProcess() {
        return null;
    }
}
}
