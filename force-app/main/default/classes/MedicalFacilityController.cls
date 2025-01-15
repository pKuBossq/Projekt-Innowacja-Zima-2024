public with sharing class MedicalFacilityController {
    @AuraEnabled(cacheable=true)
    public static List<Medical_Facility__c> getMedicalFacilityData() {
        return [SELECT Id, Name, Address__c, Address__Street__s, Address__PostalCode__s, Address__City__s FROM Medical_Facility__c];
    }
}
