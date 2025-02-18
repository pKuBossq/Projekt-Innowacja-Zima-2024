trigger InsuranceRequiredValidation on Medical_Appointment__c (before insert, before update) 
{
    // Set<Id> facilityIds = new Set<Id>();
    // Set<Id> patientsIds = new Set<Id>();

    // for (Medical_Appointment__c appointment : Trigger.new) 
    // {
    //     patientsIds.add(appointment.Patient__c);
    //     facilityIds.add(appointment.Medical_Facility__c);
    // }

    // Map<Id, Medical_Facility__c> facilityMap = new Map<Id, Medical_Facility__c>(
    //     [SELECT Id, Insurance_Required__c FROM Medical_Facility__c WHERE Id IN :facilityIds]
    // );

    // Map<Id, Medical_Insurance__c> patientInsuranceMap = new Map<Id, Medical_Insurance__c>();
    
    // List<Medical_Insurance__c> patientInsuranceList = [SELECT Id, Person__c FROM Medical_Insurance__c 
    //     WHERE Person__c IN :patientsIds AND Status__c = 'Active' AND End_Date__c >= Today AND Start_Date__c <= Today];
    
    // for (Medical_Insurance__c insurance :patientInsuranceList) 
    // {
    //     patientInsuranceMap.put(insurance.Person__c, insurance);
    // }

    // for (Medical_Appointment__c appointment : Trigger.new) 
    // {
    //     Medical_Facility__c facility = facilityMap.get(appointment.Medical_Facility__c);
        
    //     if (facilityMap.containsKey(appointment.Medical_Facility__c) && facility.Insurance_Required__c == true && !patientInsuranceMap.containsKey(appointment.Patient__c)) 
    //     {
    //         appointment.addError('Medical Insurance is required in this Facility to get the Medical Appointment');   
    //     }
    // }
}