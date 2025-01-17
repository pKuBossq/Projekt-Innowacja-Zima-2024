public with sharing class MedicalAppointmentHandler 
{
    private static final String ADMIN_EMAIL = '245838@edu.p.lodz.pl';

    public static void sendErrorNotification(String subject, String errorMessage) 
    {
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { ADMIN_EMAIL });
            email.setSubject(subject);
            email.setPlainTextBody(errorMessage);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e) 
        {
            System.debug('Error sending notification email: ' + e.getMessage());
        }
    }

    public static void handleFirstInternistAppointmentValidation(List<Medical_Appointment__c> newAppointments) 
    {
        try {
            Id onlineRecordTypeId  = Schema.SObjectType.Medical_Appointment__c.getRecordTypeInfosByName().get('Online').getRecordTypeId();
    
            List<Medical_Appointment__c> onlineAppointments = new List<Medical_Appointment__c>();
            Set<Id> patientsIds = new Set<Id>();
        
            for(Medical_Appointment__c appointment: newAppointments) 
            {
                if(appointment.RecordTypeId == onlineRecordTypeId) 
                {
                    onlineAppointments.add(appointment);
                    patientsIds.add(appointment.Patient__c);
                }
            }
            
            if(onlineAppointments.isEmpty())
            {
                return;
            }
             
            List<Medical_Appointment__c> prevInternistAppointments = [SELECT Patient__c FROM Medical_Appointment__c WHERE Doctor__r.Specialization__c = 'Internist' AND Patient__c IN :patientsIds];
            
            Set<Id> patientsWithPrevInternistAppointments = new Set<Id>();
            
            for(Medical_Appointment__c appointment: prevInternistAppointments)
            {
                patientsWithPrevInternistAppointments.add(appointment.Patient__c);
            }
            
            for (Medical_Appointment__c appointment: onlineAppointments) 
            {
                if(!patientsWithPrevInternistAppointments.contains(appointment.Patient__c))
                {
                    appointment.addError('First Internist Appointment must be on site');
                }
            }
            
        } catch (Exception e) {
            sendErrorNotification(
                'Error in First Internist Appointment Validation',
                'An error occurred: ' + e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString()
            );
            throw e;
        }
    }

    public static void handleInsuranceRequiredValidation(List<Medical_Appointment__c> newAppointments) 
    {
        try {
            Set<Id> facilityIds = new Set<Id>();
            Set<Id> patientsIds = new Set<Id>();
        
            for (Medical_Appointment__c appointment: newAppointments) 
            {
                patientsIds.add(appointment.Patient__c);
                facilityIds.add(appointment.Medical_Facility__c);
            }
        
            Map<Id, Medical_Facility__c> facilityMap = new Map<Id, Medical_Facility__c>(
                [SELECT Id, Insurance_Required__c FROM Medical_Facility__c WHERE Id IN :facilityIds]
            );
        
            Map<Id, Medical_Insurance__c> patientInsuranceMap = new Map<Id, Medical_Insurance__c>();
            
            List<Medical_Insurance__c> patientInsuranceList = [SELECT Id, Person__c FROM Medical_Insurance__c 
                WHERE Person__c IN :patientsIds AND Status__c = 'Active' AND End_Date__c >= Today AND Start_Date__c <= Today];
            
            for (Medical_Insurance__c insurance :patientInsuranceList) 
            {
                patientInsuranceMap.put(insurance.Person__c, insurance);
            }
        
            for (Medical_Appointment__c appointment: newAppointments) 
            {
                Medical_Facility__c facility = facilityMap.get(appointment.Medical_Facility__c);
                
                if (facilityMap.containsKey(appointment.Medical_Facility__c) && facility.Insurance_Required__c == true && !patientInsuranceMap.containsKey(appointment.Patient__c)) 
                {
                    appointment.addError('Medical Insurance is required in this Facility to get the Medical Appointment');   
                }
            }
            
        } catch (Exception e) {
            sendErrorNotification(
                'Error in Insurance Required Validation',
                'An error occurred: ' + e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString()
            );
            throw e;
        }
    }

    public static void handleMedicalAppointmentName(List<Medical_Appointment__c> newAppointments) 
    {
        try {
            Set<Id> patientIds = new Set<Id>();
            Set<Id> doctorIds = new Set<Id>();
            Set<Id> facilityIds = new Set<Id>();
        
            for (Medical_Appointment__c appointment : newAppointments) {
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
        
            for (Medical_Appointment__c appointment : newAppointments) {
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
            
        } catch (Exception e) {
            sendErrorNotification(
                'Error in Medical Appointment Name Handling',
                'An error occurred: ' + e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString()
            );
            throw e;
        }
    }

    public static void handleSendAppointmentEmail(List<Medical_Appointment__c> newAppointments, Map<Id, Medical_Appointment__c> oldAppointmentsMap, Boolean isInsert, Boolean isUpdate) 
    {
        try {
            Set<Id> personIds = new Set<Id>();
            List<Medical_Appointment__c> appointments = new List<Medical_Appointment__c>();
            
            for(Medical_Appointment__c appt : newAppointments) {
                if (isInsert) {
                    if (appt.Patient__c != null && appt.Doctor__c != null) {
                        personIds.add(appt.Patient__c);
                        personIds.add(appt.Doctor__c);
                        appointments.add(appt);
                    }
                } else if (isUpdate) {
                    Medical_Appointment__c oldAppt = oldAppointmentsMap.get(appt.Id);
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
            
        } catch (Exception e) {
            sendErrorNotification(
                'Error in Send Appointment Email Handling',
                'An error occurred: ' + e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString()
            );
        }
    }
}