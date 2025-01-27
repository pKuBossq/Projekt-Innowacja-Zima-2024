public with sharing class GetAllAppointmentsBot {
    public class AppointmentOutput {
        @InvocableVariable(required = true)
        public List<Medical_Appointment__c> appointments;
    }

    @InvocableMethod(label = 'Get All Appointments')
    public static List<AppointmentOutput> getAllAppointments() {
        AppointmentOutput output = new AppointmentOutput();
        output.appointments = new List<Medical_Appointment__c>();

        List<Medical_Appointment__c> appointments = [
            SELECT Name
            FROM Medical_Appointment__c
        ];

        for (Medical_Appointment__c app : appointments) {
            output.appointment.add(app);
        }

        List<AppointmentOutput> results = new List<AppointmentOutput>();
        results.add(output);
        return results;
    }
}