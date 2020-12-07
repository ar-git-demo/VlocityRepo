/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class HcProcessLeadToIndividual extends HealthCloudGA.MoiBaseService implements HealthCloudGA.HcProcessLeadToIndividual.HcIProcessLeadToIndividual {
    global HcProcessLeadToIndividual() {

    }
    @InvocableMethod(label='Lead To Individual Conversion' description='Convert Lead To Individuals')
    global static List<Id> createIndividualsFromLead(List<Id> leadIds) {
        return null;
    }
global interface HcIProcessLeadToIndividual {
    List<Id> createIndividualsFromLead(List<Id> param0);
}
}
