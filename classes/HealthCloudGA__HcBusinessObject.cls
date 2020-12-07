/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class HcBusinessObject {
    global HcBusinessObject() {

    }
global class Address {
    global String City;
    global String Country;
    global String County;
    global String State;
    global String StreetAddress;
    global String Zip;
    global Address() {

    }
    global String getCity() {
        return null;
    }
    global String getCountry() {
        return null;
    }
    global String getCounty() {
        return null;
    }
    global String getState() {
        return null;
    }
    global String getStreetAddress() {
        return null;
    }
    global String getZip() {
        return null;
    }
    global void setCity(String City) {

    }
    global void setCountry(String Country) {

    }
    global void setCounty(String County) {

    }
    global void setState(String State) {

    }
    global void setStreetAddress(String StreetAddress) {

    }
    global void setZip(String Zip) {

    }
}
global class AllergyType {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global AllergyType() {

    }
}
global virtual class CDA {
    global List<HealthCloudGA.HcBusinessObject.PatientAllergy> Allergies;
    global List<HealthCloudGA.HcBusinessObject.Encounter> Encounters;
    global List<HealthCloudGA.HcBusinessObject.Immunization> Immunizations;
    global List<HealthCloudGA.HcBusinessObject.Medication> Medications;
    global HealthCloudGA.HcBusinessObject.Patient Patient;
    global List<HealthCloudGA.HcBusinessObject.PlanOfCare> PlanOfCares;
    global List<HealthCloudGA.HcBusinessObject.Problem> Problems;
    global List<HealthCloudGA.HcBusinessObject.Procedures> Procedures;
    global List<HealthCloudGA.HcBusinessObject.Result> Results;
    global List<HealthCloudGA.HcBusinessObject.VitalSign> VitalSigns;
    global CDA() {

    }
}
global class Category {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Category() {

    }
}
global class CodedValue {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global CodedValue() {

    }
}
global class Contact {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global List<String> EmailAddresses;
    global String FirstName;
    global String Lastname;
    global String MiddleName;
    global HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber;
    global String RelationToPatient;
    global List<String> Roles;
    global Contact() {

    }
}
global virtual class Context {
    global HealthCloudGA.HcBusinessObject.Meta Meta;
    global Context() {

    }
}
global class Criticality {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global Criticality() {

    }
}
global virtual class Demographics {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global List<String> Citizenship;
    global Datetime DeathDateTime;
    global Datetime DOB;
    global List<String> EmailAddresses;
    global String FirstName;
    global Boolean IsDeceased;
    global Boolean IsHispanic;
    global String Language;
    global String LastName;
    global String MaritalStatus;
    global String MiddleName;
    global HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber;
    global String Race;
    global String Sex;
    global String SSN;
    global Demographics() {

    }
    global HealthCloudGA.HcBusinessObject.Address getAddress() {
        return null;
    }
    global List<String> getCitizenship() {
        return null;
    }
    global Datetime getDOB() {
        return null;
    }
    global Datetime getDeathDateTime() {
        return null;
    }
    global List<String> getEmailAddresses() {
        return null;
    }
    global String getFirstName() {
        return null;
    }
    global Boolean getIsDeceased() {
        return null;
    }
    global Boolean getIsHispanic() {
        return null;
    }
    global String getLanguage() {
        return null;
    }
    global String getLastName() {
        return null;
    }
    global String getMaritalStatus() {
        return null;
    }
    global String getMiddleName() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.PhoneNumber getPhoneNumber() {
        return null;
    }
    global String getRace() {
        return null;
    }
    global String getSSN() {
        return null;
    }
    global String getSex() {
        return null;
    }
    global void setAddress(HealthCloudGA.HcBusinessObject.Address Address) {

    }
    global void setCitizenship(List<String> Citizenship) {

    }
    global void setDOB(Datetime DOB) {

    }
    global void setDeathDateTime(Datetime DeathDateTime) {

    }
    global void setEmailAddresses(List<String> EmailAddresses) {

    }
    global void setFirstName(String FirstName) {

    }
    global void setIsDeceased(Boolean IsDeceased) {

    }
    global void setIsHispanic(Boolean IsHispanic) {

    }
    global void setLanguage(String Language) {

    }
    global void setLastName(String LastName) {

    }
    global void setMaritalStatus(String MaritalStatus) {

    }
    global void setMiddleName(String MiddleName) {

    }
    global void setPhoneNumber(HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber) {

    }
    global void setRace(String Race) {

    }
    global void setSSN(String SSN) {

    }
    global void setSex(String Sex) {

    }
}
global class Destinations {
    global String ID;
    global String Name;
    global Destinations() {

    }
    global String getId() {
        return null;
    }
    global String getName() {
        return null;
    }
    global void setId(String ID) {

    }
    global void setName(String Name) {

    }
}
global class Diagnose {
    global String COde;
    global String Codeset;
    global String Name;
    global String Type;
    global Diagnose() {

    }
}
global class Diagnosis {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global Diagnosis() {

    }
}
global class Dose {
    global Decimal Quantiy;
    global String Units;
    global Dose() {

    }
}
global class Employer {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global String Name;
    global HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber;
    global Employer() {

    }
}
global virtual class Encounter {
    global List<HealthCloudGA.HcBusinessObject.Diagnosis> diagnosis;
    global Datetime encounterDateTime;
    global Datetime endDateTime;
    global List<HealthCloudGA.HcBusinessObject.Identifiers> identifiers;
    global List<HealthCloudGA.HcBusinessObject.Location> locations;
    global List<HealthCloudGA.HcBusinessObject.Provider> providers;
    global List<HealthCloudGA.HcBusinessObject.Reason> reasonForVisit;
    global HealthCloudGA.HcBusinessObject.Type type;
    global Encounter() {

    }
    global Datetime getDateTime() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Diagnosis> getDiagnosis() {
        return null;
    }
    global Datetime getEndDateTime() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Identifiers> getIdentifiers() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Location> getLocations() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Provider> getProviders() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Reason> getReasonForVisit() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Type getType() {
        return null;
    }
    global void setDateTime(Datetime encounterDateTime) {

    }
    global void setDiagnosis(List<HealthCloudGA.HcBusinessObject.Diagnosis> diagnosis) {

    }
    global void setEndDateTime(Datetime endDateTime) {

    }
    global void setIdentifiers(List<HealthCloudGA.HcBusinessObject.Identifiers> identifiers) {

    }
    global void setLocations(List<HealthCloudGA.HcBusinessObject.Location> locations) {

    }
    global void setProviders(List<HealthCloudGA.HcBusinessObject.Provider> providers) {

    }
    global void setReasonForVisit(List<HealthCloudGA.HcBusinessObject.Reason> reasonForVisit) {

    }
    global void setType(HealthCloudGA.HcBusinessObject.Type type) {

    }
}
global class Frequency {
    global String Period;
    global String Units;
    global Frequency() {

    }
}
global class HealthStatus {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global HealthStatus() {

    }
}
global class HouseHoldMember {
    global String FirstName;
    global String LastName;
    global HouseHoldMember() {

    }
}
global class Identifiers {
    global String ID;
    global String IDType;
    global String getIDType() {
        return null;
    }
    global String getId() {
        return null;
    }
    global void setIDType(String IDType) {

    }
    global void setId(String ID) {

    }
}
global virtual class Immunization {
    global HealthCloudGA.HcBusinessObject.Dose dose;
    global Datetime immunizationDateTime;
    global HealthCloudGA.HcBusinessObject.Product product;
    global HealthCloudGA.HcBusinessObject.Route route;
    global Immunization() {

    }
    global Datetime getDateTime() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Dose getDose() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Product getProduct() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Route getRoute() {
        return null;
    }
    global void setDateTime(Datetime immunizationDateTime) {

    }
    global void setDose(HealthCloudGA.HcBusinessObject.Dose dose) {

    }
    global void setProduct(HealthCloudGA.HcBusinessObject.Product product) {

    }
    global void setRoute(HealthCloudGA.HcBusinessObject.Route route) {

    }
}
global class Individual {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global String DOB;
    global HealthCloudGA.HcBusinessObject.Employer Employer;
    global String FirstName;
    global String Id;
    global String LastName;
    global HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber;
    global String RelationToPatient;
    global String Sex;
    global HealthCloudGA.HcBusinessObject.HouseHoldMember Spouse;
    global String Type;
    global Individual() {

    }
}
global class Insurances {
    global Insurances() {

    }
}
global class Location {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global String Department;
    global String Facility;
    global String Room;
    global String Type;
    global Location() {

    }
    global HealthCloudGA.HcBusinessObject.Address getAddress() {
        return null;
    }
    global String getDepartment() {
        return null;
    }
    global String getFacility() {
        return null;
    }
    global String getRoom() {
        return null;
    }
    global String getType() {
        return null;
    }
    global void setAddress(HealthCloudGA.HcBusinessObject.Address Address) {

    }
    global void setDepartment(String Department) {

    }
    global void setFacility(String Facility) {

    }
    global void setRoom(String Room) {

    }
    global void setType(String Type) {

    }
}
global virtual class Medication {
    global HealthCloudGA.HcBusinessObject.Dose Dose;
    global Date EndDate;
    global String FreeTextSig;
    global HealthCloudGA.HcBusinessObject.Frequency Frequency;
    global Boolean IsPRN;
    global Boolean Prescription;
    global HealthCloudGA.HcBusinessObject.Product Product;
    global HealthCloudGA.HcBusinessObject.Rate Rate;
    global HealthCloudGA.HcBusinessObject.Route Route;
    global Date StartDate;
    global String Status;
    global Medication() {

    }
    global HealthCloudGA.HcBusinessObject.Dose getDose() {
        return null;
    }
    global Date getEndDate() {
        return null;
    }
    global String getFreeTextSig() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Frequency getFrequency() {
        return null;
    }
    global Boolean getIsPRN() {
        return null;
    }
    global Boolean getPrescription() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Product getProduct() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Rate getRate() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Route getRoute() {
        return null;
    }
    global Date getStartDate() {
        return null;
    }
    global String getStatus() {
        return null;
    }
    global void setDose(HealthCloudGA.HcBusinessObject.Dose Dose) {

    }
    global void setEndDate(Date EndDate) {

    }
    global void setFreeTextSig(String FreeTextSig) {

    }
    global void setFrequency(HealthCloudGA.HcBusinessObject.Frequency Frequency) {

    }
    global void setIsPRN(Boolean IsPRN) {

    }
    global void setPrescription(Boolean Prescription) {

    }
    global void setProduct(HealthCloudGA.HcBusinessObject.Product Product) {

    }
    global void setRate(HealthCloudGA.HcBusinessObject.Rate Rate) {

    }
    global void setRoute(HealthCloudGA.HcBusinessObject.Route Route) {

    }
    global void setStartDate(Date StartDate) {

    }
    global void setStatus(String Status) {

    }
}
global class Message {
    global Integer ID;
    global Integer getID() {
        return null;
    }
    global void setID(Integer ID) {

    }
}
global class Meta {
    global String DataModel;
    global List<HealthCloudGA.HcBusinessObject.Destinations> Destinations;
    global Datetime EventDateTime;
    global String EventType;
    global String FacilityCode;
    global Boolean IsTest;
    global HealthCloudGA.HcBusinessObject.Message Message;
    global HealthCloudGA.HcBusinessObject.Source Source;
    global HealthCloudGA.HcBusinessObject.Transmission Transmission;
    global Meta() {

    }
    global String getDataModel() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Destinations> getDestinations() {
        return null;
    }
    global Datetime getEventDateTime() {
        return null;
    }
    global String getEventType() {
        return null;
    }
    global String getFacilityCode() {
        return null;
    }
    global Boolean getIsTest() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Message getMessage() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Source getSource() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Transmission getTransmission() {
        return null;
    }
    global void setDataModel(String DataModel) {

    }
    global void setDestinations(List<HealthCloudGA.HcBusinessObject.Destinations> Destinations) {

    }
    global void setEventDateTime(Datetime EventDateTime) {

    }
    global void setEventType(String EventType) {

    }
    global void setFacilityCode(String FacilityCode) {

    }
    global void setIsTest(Boolean IsTest) {

    }
    global void setMessage(HealthCloudGA.HcBusinessObject.Message Message) {

    }
    global void setSource(HealthCloudGA.HcBusinessObject.Source Source) {

    }
    global void setTransmission(HealthCloudGA.HcBusinessObject.Transmission Transmission) {

    }
}
global class Notes {
    global Notes() {

    }
}
global class Observation {
    global String code;
    global HealthCloudGA.HcBusinessObject.CodedValue codedValue;
    global String codeSystem;
    global String codeSystemName;
    global String interpretation;
    global String name;
    global Datetime observationDateTime;
    global HealthCloudGA.HcBusinessObject.ReferenceRange referenceRange;
    global String status;
    global HealthCloudGA.HcBusinessObject.TargetSite targetSite;
    global String units;
    global String value;
    global String valueType;
    global Observation() {

    }
}
global class Order {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Datetime orderDateTime;
    global String status;
    global Order() {

    }
}
global virtual class PCP {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global List<String> Credentials;
    global String FirstName;
    global String LastName;
    global HealthCloudGA.HcBusinessObject.Location Location;
    global String NPI;
    global String PhoneNumber;
    global PCP() {

    }
}
global class Patient {
    global List<HealthCloudGA.HcBusinessObject.VisitAllergies> Allergies;
    global List<HealthCloudGA.HcBusinessObject.Contact> Contacts;
    global HealthCloudGA.HcBusinessObject.Demographics Demographics;
    global List<HealthCloudGA.HcBusinessObject.Diagnose> Diagnosis;
    global List<HealthCloudGA.HcBusinessObject.Identifiers> Identifiers;
    global List<HealthCloudGA.HcBusinessObject.Notes> Notes;
    global HealthCloudGA.HcBusinessObject.PCP PCP;
    global Patient() {

    }
    global List<HealthCloudGA.HcBusinessObject.VisitAllergies> getAllergies() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Contact> getContacts() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Demographics getDemographics() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Identifiers> getIdentifiers() {
        return null;
    }
    global void setAllergies(List<HealthCloudGA.HcBusinessObject.VisitAllergies> Allergies) {

    }
    global void setContacts(List<HealthCloudGA.HcBusinessObject.Contact> Contacts) {

    }
    global void setDemographics(HealthCloudGA.HcBusinessObject.Demographics Demographics) {

    }
    global void setIdentifiers(List<HealthCloudGA.HcBusinessObject.Identifiers> Identifiers) {

    }
}
global virtual class PatientAdmitArrival {
    global HealthCloudGA.HcBusinessObject.Meta Meta;
    global HealthCloudGA.HcBusinessObject.Patient Patient;
    global HealthCloudGA.HcBusinessObject.Visit Visit;
    global PatientAdmitArrival() {

    }
    global HealthCloudGA.HcBusinessObject.Meta getMeta() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Patient getPatient() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Visit getVisit() {
        return null;
    }
    global void setMeta(HealthCloudGA.HcBusinessObject.Meta Meta) {

    }
    global void setPatient(HealthCloudGA.HcBusinessObject.Patient Patient) {

    }
    global void setVisit(HealthCloudGA.HcBusinessObject.Visit Visit) {

    }
}
global virtual class PatientAllergy {
    global String Comment;
    global HealthCloudGA.HcBusinessObject.Criticality Criticality;
    global Datetime EndDate;
    global HealthCloudGA.HcBusinessObject.PatientReaction Reaction;
    global HealthCloudGA.HcBusinessObject.Severity Severity;
    global Datetime StartDate;
    global HealthCloudGA.HcBusinessObject.Status Status;
    global HealthCloudGA.HcBusinessObject.Substance Substance;
    global HealthCloudGA.HcBusinessObject.AllergyType Type;
    global PatientAllergy() {

    }
    global HealthCloudGA.HcBusinessObject.AllergyType getAllergyType() {
        return null;
    }
    global String getComment() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Criticality getCriticality() {
        return null;
    }
    global Datetime getEndDate() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.PatientReaction getPatientReaction() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Severity getSeverity() {
        return null;
    }
    global Datetime getStartDate() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Status getStatus() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Substance getSubstance() {
        return null;
    }
    global void setAlleryType(HealthCloudGA.HcBusinessObject.AllergyType Type) {

    }
    global void setComment(String Comment) {

    }
    global void setCriticality(HealthCloudGA.HcBusinessObject.Criticality Criticality) {

    }
    global void setEndDate(Datetime EndDate) {

    }
    global void setPatientReaction(HealthCloudGA.HcBusinessObject.PatientReaction Reaction) {

    }
    global void setSeverity(HealthCloudGA.HcBusinessObject.Severity Severity) {

    }
    global void setStartDate(Datetime StartDate) {

    }
    global void setStatus(HealthCloudGA.HcBusinessObject.Status Status) {

    }
    global void setSubstance(HealthCloudGA.HcBusinessObject.Substance Substance) {

    }
}
global class PatientReaction {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global HealthCloudGA.HcBusinessObject.Severity Severity;
    global String Text;
    global PatientReaction() {

    }
}
global class PhoneNumber {
    global String Home;
    global String Mobile;
    global String Office;
    global PhoneNumber() {

    }
    global String getHome() {
        return null;
    }
    global String getMobile() {
        return null;
    }
    global String getOffice() {
        return null;
    }
    global void setHome(String Home) {

    }
    global void setMobile(String Mobile) {

    }
    global void setOffice(String Office) {

    }
}
global class PlanEncounter {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global Datetime encounterDateTime;
    global String name;
    global String status;
    global PlanEncounter() {

    }
}
global virtual class PlanOfCare {
    global List<HealthCloudGA.HcBusinessObject.PlanEncounter> encounters;
    global List<HealthCloudGA.HcBusinessObject.Medication> medicationAdministration;
    global List<HealthCloudGA.HcBusinessObject.Order> orders;
    global List<HealthCloudGA.HcBusinessObject.Procedure> procedures;
    global List<HealthCloudGA.HcBusinessObject.Service> services;
    global List<HealthCloudGA.HcBusinessObject.Supply> supplies;
    global PlanOfCare() {

    }
    global List<HealthCloudGA.HcBusinessObject.PlanEncounter> getEncounters() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Medication> getMedicationAdministration() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Order> getOrders() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Procedure> getProcedures() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Service> getServices() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Supply> getSupplies() {
        return null;
    }
    global void setEncounters(List<HealthCloudGA.HcBusinessObject.PlanEncounter> encounters) {

    }
    global void setMedicationAdministration(List<HealthCloudGA.HcBusinessObject.Medication> medicationAdministration) {

    }
    global void setOrders(List<HealthCloudGA.HcBusinessObject.Order> orders) {

    }
    global void setProcedures(List<HealthCloudGA.HcBusinessObject.Procedure> procedures) {

    }
    global void setServices(List<HealthCloudGA.HcBusinessObject.Service> services) {

    }
    global void setSupplies(List<HealthCloudGA.HcBusinessObject.Supply> supplies) {

    }
}
global virtual class Problem {
    global HealthCloudGA.HcBusinessObject.Category category;
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global Datetime EndDate;
    global HealthCloudGA.HcBusinessObject.HealthStatus healthStatus;
    global String Name;
    global Datetime StartDate;
    global HealthCloudGA.HcBusinessObject.Status status;
    global Problem() {

    }
    global HealthCloudGA.HcBusinessObject.Category getCategory() {
        return null;
    }
    global String getCode() {
        return null;
    }
    global String getCodeSystem() {
        return null;
    }
    global String getCodeSystemName() {
        return null;
    }
    global Datetime getEndDate() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.HealthStatus getHealthStatus() {
        return null;
    }
    global String getName() {
        return null;
    }
    global Datetime getStartDate() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Status getStatus() {
        return null;
    }
    global void setCategory(HealthCloudGA.HcBusinessObject.Category category) {

    }
    global void setCode(String code) {

    }
    global void setCodeSystem(String codeSystem) {

    }
    global void setCodeSystemName(String codeSystemName) {

    }
    global void setEndDate(Datetime endDate) {

    }
    global void setHealthStatus(HealthCloudGA.HcBusinessObject.HealthStatus healthStatus) {

    }
    global void setName(String name) {

    }
    global void setStartDate(Datetime startDate) {

    }
    global void setStatus(HealthCloudGA.HcBusinessObject.Status status) {

    }
}
global class Procedure {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Datetime procedureDateTime;
    global String status;
    global HealthCloudGA.HcBusinessObject.TargetSite targetSite;
    global Procedure() {

    }
}
global virtual class Procedures {
    global List<HealthCloudGA.HcBusinessObject.Observation> observations;
    global List<HealthCloudGA.HcBusinessObject.Procedure> procedures;
    global List<HealthCloudGA.HcBusinessObject.Service> services;
    global Procedures() {

    }
    global List<HealthCloudGA.HcBusinessObject.Observation> getObservations() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Procedure> getProcedures() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Service> getServices() {
        return null;
    }
    global void setObservations(List<HealthCloudGA.HcBusinessObject.Observation> observations) {

    }
    global void setProcedures(List<HealthCloudGA.HcBusinessObject.Procedure> procedures) {

    }
    global void setServices(List<HealthCloudGA.HcBusinessObject.Service> services) {

    }
}
global class Product {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String LotNumber;
    global String Manufacturer;
    global String Name;
    global Product() {

    }
}
global class Provider {
    global HealthCloudGA.HcBusinessObject.Address Address;
    global List<String> Credentials;
    global String FirstName;
    global String ID;
    global String IDType;
    global String Lastname;
    global HealthCloudGA.HcBusinessObject.Location Location;
    global String MiddleName;
    global HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber;
    global HealthCloudGA.HcBusinessObject.Role Role;
    global Provider() {

    }
    global HealthCloudGA.HcBusinessObject.Address getAddress() {
        return null;
    }
    global List<String> getCredentials() {
        return null;
    }
    global String getFirstName() {
        return null;
    }
    global String getID() {
        return null;
    }
    global String getIDType() {
        return null;
    }
    global String getLastname() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Location getLocation() {
        return null;
    }
    global String getMiddleName() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.PhoneNumber getPhoneNumber() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Role getRole() {
        return null;
    }
    global void setAddress(HealthCloudGA.HcBusinessObject.Address Address) {

    }
    global void setCredentials(List<String> Credentials) {

    }
    global void setFirstName(String FirstName) {

    }
    global void setID(String ID) {

    }
    global void setIDType(String IDType) {

    }
    global void setLastname(String Lastname) {

    }
    global void setLocation(HealthCloudGA.HcBusinessObject.Location Location) {

    }
    global void setMiddleName(String MiddleName) {

    }
    global void setPhoneNumber(HealthCloudGA.HcBusinessObject.PhoneNumber PhoneNumber) {

    }
    global void setRole(HealthCloudGA.HcBusinessObject.Role Role) {

    }
}
global class Rate {
    global Decimal Quantiy;
    global String Units;
    global Rate() {

    }
}
global class Reaction {
    global String Code;
    global String Codeset;
    global String Name;
    global Reaction() {

    }
    global String getCode() {
        return null;
    }
    global String getCodeset() {
        return null;
    }
    global String getName() {
        return null;
    }
    global void setCode(String Code) {

    }
    global void setCodeset(String Codeset) {

    }
    global void setName(String Name) {

    }
}
global class Reason {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Reason() {

    }
}
global class ReferenceRange {
    global Decimal high;
    global Decimal low;
    global String text;
    global ReferenceRange() {

    }
}
global virtual class Result {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global List<HealthCloudGA.HcBusinessObject.Observation> resultObservations;
    global String status;
    global Result() {

    }
    global String getCode() {
        return null;
    }
    global String getCodeSystem() {
        return null;
    }
    global String getCodeSystemName() {
        return null;
    }
    global String getName() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Observation> getResultObservations() {
        return null;
    }
    global String getStatus() {
        return null;
    }
    global void setCode(String code) {

    }
    global void setCodeSystem(String codeSystem) {

    }
    global void setCodeSystemName(String codeSystemName) {

    }
    global void setName(String name) {

    }
    global void setResultObservations(List<HealthCloudGA.HcBusinessObject.Observation> resultObservations) {

    }
    global void setStatus(String status) {

    }
}
global class Role {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Role() {

    }
}
global class Route {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global Route() {

    }
}
global class Service {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Datetime serviceDateTime;
    global String status;
    global HealthCloudGA.HcBusinessObject.TargetSite targetSite;
    global Service() {

    }
}
global class Severity {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global Severity() {

    }
}
global class Source {
    global String ID;
    global String Name;
    global Source() {

    }
    global String getId() {
        return null;
    }
    global String getName() {
        return null;
    }
    global void setId(String ID) {

    }
    global void setName(String Name) {

    }
}
global class Status {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global Status() {

    }
}
global class Substance {
    global String Code;
    global String CodeSystem;
    global String CodeSystemName;
    global String Name;
    global Substance() {

    }
}
global class Supply {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global String status;
    global Datetime supplyDateTime;
    global Supply() {

    }
}
global class TargetSite {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global TargetSite() {

    }
}
global class Transmission {
    global Integer ID;
    global Integer getID() {
        return null;
    }
    global void setID(Integer ID) {

    }
}
global class Type {
    global String code;
    global String codeSystem;
    global String codeSystemName;
    global String name;
    global Type() {

    }
}
global class Visit {
    global String AccountNumber;
    global HealthCloudGA.HcBusinessObject.Provider AttendingProvider;
    global Double Balance;
    global HealthCloudGA.HcBusinessObject.Provider ConsultingProvider;
    global String Duration;
    global HealthCloudGA.HcBusinessObject.Individual Guarantor;
    global List<String> Instructions;
    global HealthCloudGA.HcBusinessObject.Location Location;
    global String PatientClass;
    global String Reason;
    global HealthCloudGA.HcBusinessObject.Provider ReferringProvider;
    global Datetime VisitDateTime;
    global String VisitNumber;
    global Visit() {

    }
    global String getAccountNumber() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Provider getAttendingProvider() {
        return null;
    }
    global Double getBalance() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Provider getConsultingProvider() {
        return null;
    }
    global String getDuration() {
        return null;
    }
    global List<String> getInstructions() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Location getLocation() {
        return null;
    }
    global String getPatientClass() {
        return null;
    }
    global String getReason() {
        return null;
    }
    global HealthCloudGA.HcBusinessObject.Provider getReferringProvider() {
        return null;
    }
    global Datetime getVisitDateTime() {
        return null;
    }
    global String getVisitNumber() {
        return null;
    }
    global void setAccountNumber(String AccountNumber) {

    }
    global void setAttendingProvider(HealthCloudGA.HcBusinessObject.Provider AttendingProvider) {

    }
    global void setBalance(Double Balance) {

    }
    global void setConsultingProvider(HealthCloudGA.HcBusinessObject.Provider ConsultingProvider) {

    }
    global void setDuration(String Duration) {

    }
    global void setInstructions(List<String> Instructions) {

    }
    global void setLocation(HealthCloudGA.HcBusinessObject.Location Location) {

    }
    global void setPatientClass(String PatientClass) {

    }
    global void setReason(String Reason) {

    }
    global void setReferringProvider(HealthCloudGA.HcBusinessObject.Provider ReferringProvider) {

    }
    global void setVisitDateTime(Datetime VisitDateTime) {

    }
    global void setVisitNumber(String VisitNumber) {

    }
}
global virtual class VisitAllergies {
    global String Code;
    global String Codeset;
    global String Name;
    global Datetime OnsetDateTime;
    global List<HealthCloudGA.HcBusinessObject.Reaction> Reaction;
    global VisitAllergies() {

    }
    global String getCode() {
        return null;
    }
    global String getCodeset() {
        return null;
    }
    global String getName() {
        return null;
    }
    global Datetime getOnsetDateTime() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Reaction> getReaction() {
        return null;
    }
    global void setCode(String Code) {

    }
    global void setCodeset(String Codeset) {

    }
    global void setName(String Name) {

    }
    global void setOnsetDateTime(Datetime OnsetDateTime) {

    }
    global void setReaction(List<HealthCloudGA.HcBusinessObject.Reaction> Reaction) {

    }
}
global virtual class VitalSign {
    global List<HealthCloudGA.HcBusinessObject.Observation> observations;
    global Datetime vitalSignDateTime;
    global VitalSign() {

    }
    global Datetime getDatetime() {
        return null;
    }
    global List<HealthCloudGA.HcBusinessObject.Observation> getObservations() {
        return null;
    }
    global void setDatetime(Datetime vitalSignDateTime) {

    }
    global void setObservations(List<HealthCloudGA.HcBusinessObject.Observation> observations) {

    }
}
}
