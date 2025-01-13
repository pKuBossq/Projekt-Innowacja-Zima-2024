public class EmailManager {
    public static void sendAppointmentEmail(List<Medical_Appointment__c> appointments, List<Person__c> patients) {
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'AppointmentUpdateMail' LIMIT 1];

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();        
        List<Contact> tempContacts = new List<Contact>();
        
        for(Person__c patient : patients) {
            Contact tempContact = new Contact(
                LastName = patient.Last_Name__c,
                FirstName = patient.First_Name__c,
                Email = patient.Email__c
            );
            tempContacts.add(tempContact);
        }
        insert tempContacts;

        for(Integer i = 0; i < appointments.size(); i++) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {tempContacts[i].Email};
            mail.setTemplateId(template.Id);
            mail.setTargetObjectId(tempContacts[i].Id);
            mail.setWhatId(appointments[i].Id); 
            mail.setToAddresses(toAddresses);
            mail.setSaveAsActivity(false);
            emailsToSend.add(mail);
        }
        
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
            inspectResults(results);
        }
        
        if(!tempContacts.isEmpty()) {
            delete tempContacts;
        }
    }
    
    private static void inspectResults(Messaging.SendEmailResult[] results) {
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            } else {
                System.debug('The following errors occurred: ' + res.getErrors());
            }
        }
    }
}