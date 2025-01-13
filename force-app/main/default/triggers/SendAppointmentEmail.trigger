trigger SendAppointmentEmail on Medical_Appointment__c (after insert, after update) {
    Set<Id> personIds = new Set<Id>();

    for(Medical_Appointment__c appt : Trigger.new) {
        if (appt.Patient__c != null && appt.Doctor__c != null) {
            personIds.add(appt.Patient__c);
        }
    }
    
    Map<Id, Person__c> personsMap = new Map<Id, Person__c>(
        [SELECT Id, Name, Email__c, First_Name__c, Last_Name__c 
         FROM Person__c 
         WHERE Id IN :personIds]
    );

    List<Medical_Appointment__c> validAppointments = new List<Medical_Appointment__c>();
    List<Person__c> validPatients = new List<Person__c>();
    
    for(Medical_Appointment__c appt : Trigger.new) {
        Person__c patient = personsMap.get(appt.Patient__c);
        if(patient.Email__c != null) {
            validAppointments.add(appt);
            validPatients.add(patient);
        }
    }

    if(!validAppointments.isEmpty()) {
        EmailManager.sendAppointmentEmail(validAppointments, validPatients);
    }

}