trigger SendAppointmentEmail on Medical_Appointment__c (after insert, after update) {
    Set<Id> personIds = new Set<Id>();
    List<Medical_Appointment__c> appointments = new List<Medical_Appointment__c>();
    
    for(Medical_Appointment__c appt : Trigger.new) {
        if (Trigger.isInsert) {
            if (appt.Patient__c != null && appt.Doctor__c != null) {
                personIds.add(appt.Patient__c);
                personIds.add(appt.Doctor__c);
                appointments.add(appt);
            }
        } else if (Trigger.isUpdate) {
            Medical_Appointment__c oldAppt = Trigger.oldMap.get(appt.Id);
            if (appt.Patient__c != null && appt.Doctor__c != null &&
                (appt.Appointment_Date__c != oldAppt.Appointment_Date__c ||
                appt.Patient__c != oldAppt.Patient__c || 
                appt.Doctor__c != oldAppt.Doctor__c ||
                ((appt.Medical_Facility__c != oldAppt.Medical_Facility__c) || 
                (appt.Medical_Facility__c == null && oldAppt.Medical_Facility__c != null) ||
                (appt.Medical_Facility__c != null && oldAppt.Medical_Facility__c == null)))) {
                personIds.add(appt.Patient__c);
                personIds.add(appt.Doctor__c);
                appointments.add(appt);
            }
        }
    }
    
    Map<Id, Person__c> personsMap = new Map<Id, Person__c>(
        [SELECT Id, Name, Email__c, First_Name__c, Last_Name__c 
         FROM Person__c 
         WHERE Id IN :personIds]
    );

    List<Medical_Appointment__c> validAppointments = new List<Medical_Appointment__c>();
    List<Person__c> validPersons = new List<Person__c>();
    
    for(Medical_Appointment__c appt : appointments) {
        Person__c patient = personsMap.get(appt.Patient__c);
        Person__c doctor = personsMap.get(appt.Doctor__c);

        if(patient.Email__c != null) {
            validAppointments.add(appt);
            validPersons.add(patient);
            validPersons.add(doctor);
        }
    }

    if(!validAppointments.isEmpty()) {
        EmailManager.sendAppointmentEmail(validAppointments, validPersons);
    }

}