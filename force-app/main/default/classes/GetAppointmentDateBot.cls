public with sharing class GetAppointmentDateBot {
    public class AppointmentOutput {
        @InvocableVariable(required=true)
        public DateTime AppointmentDate;
    }
    
    public class AppointmentInput {
        @InvocableVariable(required=true)
        public String AppointmentId;
    }
    
    @InvocableMethod(label='Check Appointment Date')
    public static List<AppointmentOutput> GetAppointmentDate(List<AppointmentInput> appointmentInputs){
        Set<String> appointmentIds = new Set<String>();
        
        for(AppointmentInput appInp : appointmentInputs){
            appointmentIds.add(appInp.AppointmentId);
        }
        
        List<Medical_Appointment__c> appointments = [
            SELECT Name, Appointment_Date__c 
            FROM Medical_Appointment__c 
            WHERE Name IN :appointmentIds
        ];
        
        Map<String, DateTime> appointmentDateMap = new Map<String, DateTime>();

        for(Medical_Appointment__c app : appointments){
            appointmentDateMap.put(String.valueOf(app.Name), app.Appointment_Date__c);
        }

        List<AppointmentOutput> appointmentOutputs = new List<AppointmentOutput>();

        for(AppointmentInput appInp : appointmentInputs){
            AppointmentOutput appOut = new AppointmentOutput();
            if (appointmentDateMap.containsKey(appInp.AppointmentId)){
                appOut.AppointmentDate = appointmentDateMap.get(appInp.AppointmentId);
            } else {
                appOut.AppointmentDate = null;
            }
            appointmentOutputs.add(appOut);
        }
        return appointmentOutputs;
    }
}