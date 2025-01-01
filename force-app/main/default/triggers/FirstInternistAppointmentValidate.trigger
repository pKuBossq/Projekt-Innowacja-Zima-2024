trigger FirstInternistAppointmentValidate on Medical_Appointment__c (before insert) 
{
    Id onlineRecordTypeId  = Schema.SObjectType.Medical_Appointment__c.getRecordTypeInfosByName().get('Online').getRecordTypeId();
    
    List<Medical_Appointment__c> onlineAppointments = new List<Medical_Appointment__c>();
    Set<Id> patientsIds = new Set<Id>();

    for(Medical_Appointment__c appointment: Trigger.new) 
    {
        if(appointment.RecordTypeId == onlineRecordTypeId) 
        {
            onlineAppointments.add(appointment);
            patientsIds.add(appointment.Patient__c);
        }
    }
    
    List<Person__c> internistDoctors  = [SELECT Id FROM Person__c WHERE Specialization__c = 'Internist'];
    Set<Id> internistIds = new Set<Id>();
    
    for(Person__c doctor: internistDoctors)
    {
        internistIds.add(doctor.Id);
    }
    
    List<Medical_Appointment__c> prevInternistAppointments = [SELECT Patient__c FROM Medical_Appointment__c WHERE Doctor__c IN :internistIds AND Patient__c IN :patientsIds];
    Set<Id> patientsWithPrevAppointments = new Set<Id>();
    
    for(Medical_Appointment__c appointment: prevInternistAppointments)
    {
        patientsWithPrevAppointments.add(appointment.Patient__c);
    }
    
    for (Medical_Appointment__c appointment: onlineAppointments) 
    {
        if(internistIds.contains(appointment.Doctor__c) && !patientsWithPrevAppointments.contains(appointment.Patient__c))
        {
            appointment.addError('First Internist Appointment must be on site');
        }
    }
}