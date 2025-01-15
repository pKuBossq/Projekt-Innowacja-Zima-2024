trigger MedicalAppointmentNameTrigger on Medical_Appointment__c (before insert, before update) {
    Set<Id> patientIds = new Set<Id>();
    Set<Id> doctorIds = new Set<Id>();
    Set<Id> facilityIds = new Set<Id>();

    for (Medical_Appointment__c appointment : Trigger.new) {
        if (appointment.Patient__c != null) {
            patientIds.add(appointment.Patient__c);
        }
        if (appointment.Doctor__c != null) {
            doctorIds.add(appointment.Doctor__c);
        }
        if (appointment.Medical_Facility__c != null) {
            facilityIds.add(appointment.Medical_Facility__c);
        }
    }

    Map<Id, Person__c> patientsMap = new Map<Id, Person__c>(
        [SELECT Id, Last_Name__c FROM Person__c WHERE Id IN :patientIds]
    );

    Map<Id, Person__c> doctorsMap = new Map<Id, Person__c>(
        [SELECT Id, Last_Name__c FROM Person__c WHERE Id IN :doctorIds]
    );

    Map<Id, Medical_Facility__c> facilitiesMap = new Map<Id, Medical_Facility__c>(
        [SELECT Id, Name FROM Medical_Facility__c WHERE Id IN :facilityIds]
    );

    for (Medical_Appointment__c appointment : Trigger.new) {
        String facilityName = '';
        String patientLastName = '';
        String doctorLastName = '';

        if (appointment.Patient__c != null && patientsMap.containsKey(appointment.Patient__c)) {
            patientLastName = patientsMap.get(appointment.Patient__c).Last_Name__c;
        }
        if (appointment.Doctor__c != null && doctorsMap.containsKey(appointment.Doctor__c)) {
            doctorLastName = doctorsMap.get(appointment.Doctor__c).Last_Name__c;
        }
        if (appointment.Medical_Facility__c != null && facilitiesMap.containsKey(appointment.Medical_Facility__c)) {
            facilityName = facilitiesMap.get(appointment.Medical_Facility__c).Name;
        }

        String formattedDate = '';
        if (appointment.Appointment_Date__c != null) {
            formattedDate = appointment.Appointment_Date__c.format('dd-MM-yyyy', 'en_US');
        }

        if (!String.isEmpty(facilityName) &&
            !String.isEmpty(patientLastName) &&
            !String.isEmpty(doctorLastName) &&
            !String.isEmpty(formattedDate)) {

            appointment.Appointment_Name__c = facilityName + '-' +
                               doctorLastName + '-' +
                               patientLastName + '-' +
                               formattedDate;
        } else if(String.isEmpty(facilityName) && 
        !String.isEmpty(patientLastName) && 
        !String.isEmpty(doctorLastName) && 
        !String.isEmpty(formattedDate)){
            appointment.Appointment_Name__c = 'Missing Facility Name-' +
                               doctorLastName + '-' +
                               patientLastName + '-' +
                               formattedDate;
        }
    }
}