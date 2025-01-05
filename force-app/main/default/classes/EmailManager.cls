public class EmailManager {
    public static void sendAppointmentEmail(List<Medical_Appointment__c> appointments, List<Person__c> patients) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        
        for(Integer i = 0; i < appointments.size(); i++) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {patients[i].Email__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Aktualizacja wizyty lekarskiej');
            String body = createEmailBody(appointments[i], patients[i]);
            mail.setPlainTextBody(body);
            emailsToSend.add(mail);
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            inspectResults(results);
        }
    }
    
    private static String createEmailBody(Medical_Appointment__c appt, Person__c patient) {
        return 'Szanowny Pacjencie,\n\n' +
               'Twoja wizyta została ' + (Trigger.isInsert ? 'zaplanowana.' : 'zaktualizowana.') +
               '\n\nDane pacjenta: ' + patient.First_Name__c + ' ' + patient.Last_Name__c + 
               '\nNumer wizyty: ' + appt.Name +
               '\nSprawdź szczegóły wizyty na Twoim koncie.\n\n' +
               'Pozdrawiamy,\nZespół Medyczny Premium Clinic'; 
    }
    
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());
            }
        }
        return sendResult;
    }
}