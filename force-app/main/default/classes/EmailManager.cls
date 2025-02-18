public class EmailManager {
    public static void sendAppointmentEmail(List<Medical_Appointment__c> appointments, List<Person__c> persons) {
        EmailTemplate template = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'AppointmentUpdateMail' LIMIT 1];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();        

        for(Integer i = 0; i < appointments.size(); i++) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            Medical_Appointment__c appt = appointments[i];
            Person__c patient = persons[i];
            Person__c doctor = persons[i + 1];

            String htmlBody = template.HtmlValue;
            htmlBody = htmlBody
                .replace('{!Medical_Appointment__c.Appointment_Name__c}', appt.Appointment_Name__c)
                .replace('{!Patient__c.First_Name__c}', patient.First_Name__c)
                .replace('{!Patient__c.Last_Name__c}', patient.Last_Name__c)
                .replace('{!Doctor__c.First_Name__c}', doctor.First_Name__c)
                .replace('{!Doctor__c.Last_Name__c}', doctor.Last_Name__c)
                .replace('{!Medical_Appointment__c.Appointment_Date__c}', String.valueOf(appt.Appointment_Date__c));

            String[] toAddresses = new String[] {patient.Email__c};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Aktualizacja wizyty lekarskiej');
            mail.setHtmlBody(htmlBody);
            emailsToSend.add(mail);
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            inspectResults(results);
        }
    }
    
    private static void inspectResults(Messaging.SendEmailResult[] results) {
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                System.debug('The following errors occurred: ' + res.getErrors());
                
                Messaging.SingleEmailMessage errorMail = new Messaging.SingleEmailMessage();
                String[] adminEmails = new String[] {'245775@edu.p.lodz.pl'}; 
                
                errorMail.setToAddresses(adminEmails);
                errorMail.setSubject('Błąd podczas wysyłania maila - Medical Appointment Update');
                errorMail.setPlainTextBody('Wystąpił błąd podczas wysyłania maila:\n' + String.join(res.getErrors(), '\n'));
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { errorMail });
            }
        }
    }
}