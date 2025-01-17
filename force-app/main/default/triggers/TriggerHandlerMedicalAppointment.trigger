trigger TriggerHandlerMedicalAppointment on Medical_Appointment__c (before insert, before update, after insert, after update) 
{
    try {
        if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) 
            {
                MedicalAppointmentHandler.handleFirstInternistAppointmentValidation(Trigger.new);
                MedicalAppointmentHandler.handleInsuranceRequiredValidation(Trigger.new);
                MedicalAppointmentHandler.handleMedicalAppointmentName(Trigger.new);
            }
            if (Trigger.isUpdate) 
            {
                MedicalAppointmentHandler.handleInsuranceRequiredValidation(Trigger.new);
                MedicalAppointmentHandler.handleMedicalAppointmentName(Trigger.new);
            }
        }
    
        if (Trigger.isAfter) 
        {
            if (Trigger.isInsert || Trigger.isUpdate) 
            {
                MedicalAppointmentHandler.handleSendAppointmentEmail(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
            }
        }
        
    } catch (Exception e) {
        MedicalAppointmentHandler.sendErrorNotification(
            'Trigger Execution Error',
            'An error occurred: ' + e.getMessage() + '\nStack Trace:\n' + e.getStackTraceString()
        );
        throw e;
    }

}