/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class HcServiceOrchestrationEngine {
    global static List<HealthCloudGA.HcServiceOrchestrationEngine.OrchestrationStepResult> start(String processName, HealthCloudGA.HcServiceOrchestrationEngine.OrchestrationDataContainer stepData) {
        return null;
    }
global class OrchestrationDataContainer {
    global Object BO;
    global HealthCloudGA.HL7Context context;
    global Decimal step;
    global OrchestrationDataContainer() {

    }
    global OrchestrationDataContainer(HealthCloudGA.HL7Context context, Object BO) {

    }
}
global class OrchestrationStepException extends Exception {
    global String message;
    global String scope;
}
global class OrchestrationStepResult {
    global List<Map<String,String>> result;
    global String returnMessage;
    global String sObjectName;
    global OrchestrationStepResult() {

    }
    global OrchestrationStepResult(String returnMessage, String sObjectName, List<Map<String,String>> result) {

    }
}
}
