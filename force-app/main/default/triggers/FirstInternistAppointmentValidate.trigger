trigger FirstInternistAppointmentValidate on Medical_Appointment__c (before insert) 
{
    Id onlineRecordTypeId  = Schema.SObjectType.Medical_Appointment__c.getRecordTypeInfosByName().get('Online').getRecordTypeId();
    
    List<Medical_Appointment__c> onlineAppointments = new List<Medical_Appointment__c>();
    Set<Id> patientsIds = new Set<Id>();
    Set<Id> doctorsIds = new Set<Id>();

    for(Medical_Appointment__c appointment: Trigger.new) 
    {
        if(appointment.RecordTypeId == onlineRecordTypeId) 
        {
            onlineAppointments.add(appointment);
            patientsIds.add(appointment.Patient__c);
            doctorsIds.add(appointment.Doctor__c);
        }
    }
    
    if(onlineAppointments.isEmpty())
    {
        return;
    }
    
    Map<Id, Person__c> internistMap = new Map<Id, Person__c>([Select Id FROM Person__c WHERE Id IN :doctorsIds AND Specialization__c = 'Internist']);
    
    List<Medical_Appointment__c> prevInternistAppointments = [SELECT Patient__c FROM Medical_Appointment__c WHERE Doctor__r.Specialization__c = 'Internist' AND Patient__c IN :patientsIds];
    
    Set<Id> patientsWithPrevInternistAppointments = new Set<Id>();
    
    for(Medical_Appointment__c appointment: prevInternistAppointments)
    {
        patientsWithPrevInternistAppointments.add(appointment.Patient__c);
    }
    
    for (Medical_Appointment__c appointment: onlineAppointments) 
    {
        if(internistMap.containsKey(appointment.Doctor__c) && !patientsWithPrevInternistAppointments.contains(appointment.Patient__c))
        {
            appointment.addError('First Internist Appointment must be on site');
        }
    }
}