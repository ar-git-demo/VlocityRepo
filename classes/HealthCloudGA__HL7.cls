/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class HL7 {
    global HL7() {

    }
    global static String getTagNameByEntity(String entityName) {
        return null;
    }
    global static void setTag(String entityName, String tag) {

    }
global interface BusinessMapper {
    Object process(String param0, HealthCloudGA.HL7.Event param1);
}
global interface ContextParser {
    HealthCloudGA.HL7Context parse(String param0, Map<String,Object> param1);
}
global interface ElementParser {
    HealthCloudGA.HL7.Entity parse(HealthCloudGA.HL7Context param0, String param1, Object param2);
    List<HealthCloudGA.HL7.Entity> parseList(HealthCloudGA.HL7Context param0, String param1, Object param2);
}
global interface ElementProcessor {
    Object process(HealthCloudGA.HL7Context param0, String param1, Object param2);
}
global virtual class Entity {
    global Entity() {

    }
    global virtual void setDefaultFieldValue(Object value) {

    }
}
global interface Event {
}
global interface EventParser {
    HealthCloudGA.HL7.Event parse(HealthCloudGA.HL7Context param0, String param1, Map<String,Object> param2);
}
}
