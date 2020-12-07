/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class HcProcessCreateCarePlan extends HealthCloudGA.MoiBaseService implements HealthCloudGA.HcProcessCreateCarePlan.HcIProcessCreateCarePlan {
    global HcProcessCreateCarePlan() {

    }
    @InvocableMethod(label='Create CarePlan and Care Team' description='Create a care plan and care team for a patient')
    global static List<Id> CreateCarePlanFromLead(List<Id> leadIds) {
        return null;
    }
global interface HcIProcessCreateCarePlan {
    List<Id> CreateCarePlanFromLead(List<Id> param0);
}
}
