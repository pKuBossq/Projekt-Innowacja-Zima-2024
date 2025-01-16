public with sharing class MedicalFacilityController {
    @AuraEnabled(cacheable=true)
    public static Medical_Facility__c getMedicalFacility(String facilityId) {
        return [SELECT Name, Address__Street__s, Address__PostalCode__s, Address__City__s FROM Medical_Facility__c WHERE Id =: facilityId];
    }
}