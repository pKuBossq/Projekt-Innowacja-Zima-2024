trigger MedicalAppointmentNameTrigger on Medical_Appointment__c (before insert, before update) {
    Set<Id> patientIds = new Set<Id>();
    Set<Id> doctorIds = new Set<Id>();

    for (Medical_Appointment__c appointment : Trigger.new) {
        if (appointment.Patient__c != null) {
            patientIds.add(appointment.Patient__c);
        }
        if (appointment.Doctor__c != null) {
            doctorIds.add(appointment.Doctor__c);
        }
    }

    Map<Id, Person__c> patientsMap = new Map<Id, Person__c>(
        [SELECT Id, Last_Name__c FROM Person__c WHERE Id IN :patientIds]
    );

    Map<Id, Person__c> doctorsMap = new Map<Id, Person__c>(
        [SELECT Id, Last_Name__c, Medical_Facility__r.Name FROM Person__c WHERE Id IN :doctorIds]
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
            if (doctorsMap.get(appointment.Doctor__c).Medical_Facility__r != null) {
                facilityName = doctorsMap.get(appointment.Doctor__c).Medical_Facility__r.Name;
            }
        }

        String formattedDate = '';
        if (appointment.Appointment_Date__c != null) {
            formattedDate = appointment.Appointment_Date__c.format('dd-MM-yyyy', 'en_US');
        }

        if (!String.isEmpty(facilityName) &&
            !String.isEmpty(patientLastName) &&
            !String.isEmpty(doctorLastName) &&
            !String.isEmpty(formattedDate)) {

            appointment.Name = facilityName + '-' +
                               doctorLastName + '-' +
                               patientLastName + '-' +
                               formattedDate;
        } else {
            appointment.Name = 'Incomplete Information';
        }
    }
}