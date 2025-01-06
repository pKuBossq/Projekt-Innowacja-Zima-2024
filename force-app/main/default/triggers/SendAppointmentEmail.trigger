trigger SendAppointmentEmail on Medical_Appointment__c (after insert, after update) {
    Set<Id> patientIds = new Set<Id>();
    for(Medical_Appointment__c appt : Trigger.new) {
        patientIds.add(appt.Patient__c);
    }
    
    Map<Id, Person__c> patientsMap = new Map<Id, Person__c>(
        [SELECT Id, Name, Email__c, First_Name__c, Last_Name__c 
         FROM Person__c 
         WHERE Id IN :patientIds]
    );

    List<Medical_Appointment__c> validAppointments = new List<Medical_Appointment__c>();
    List<Person__c> validPatients = new List<Person__c>();
    
    for(Medical_Appointment__c appt : Trigger.new) {
        Person__c patient = patientsMap.get(appt.Patient__c);
        if(patient != null && patient.Email__c != null) {
            validAppointments.add(appt);
            validPatients.add(patient);
        }
    }

    if(!validAppointments.isEmpty()) {
        EmailManager.sendAppointmentEmail(validAppointments, validPatients);
    }

}