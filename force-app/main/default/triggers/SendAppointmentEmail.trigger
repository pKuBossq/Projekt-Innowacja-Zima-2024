trigger SendAppointmentEmail on Medical_Appointment__c (after insert, after update) {
    Set<Id> patientIds = new Set<Id>();
    Set<Id> doctorIds = new Set<Id>();

    for(Medical_Appointment__c appt : Trigger.new) {
        patientIds.add(appt.Patient__c);
        doctorIds.add(appt.Doctor__c);
    }
    
    Map<Id, Person__c> patientsMap = new Map<Id, Person__c>(
        [SELECT Id, Name, Email__c, First_Name__c, Last_Name__c 
         FROM Person__c 
         WHERE Id IN :patientIds]
    );

    Map<Id, Person__c> doctorsMap = new Map<Id, Person__c>(
        [SELECT Id, First_Name__c, Last_Name__c 
         FROM Person__c 
         WHERE Id IN :doctorIds]
    );

    List<Medical_Appointment__c> validAppointments = new List<Medical_Appointment__c>();
    List<Person__c> validPatients = new List<Person__c>();
    List<Person__c> validDoctors = new List<Person__c>();
    
    for(Medical_Appointment__c appt : Trigger.new) {
        Person__c patient = patientsMap.get(appt.Patient__c);
        Person__c doctor = doctorsMap.get(appt.Doctor__c);
        if(patient != null && patient.Email__c != null && doctor != null) {
            validAppointments.add(appt);
            validPatients.add(patient);
            validDoctors.add(doctor);
        }
    }

    if(!validAppointments.isEmpty()) {
        EmailManager.sendAppointmentEmail(validAppointments, validPatients, validDoctors);
    }

}