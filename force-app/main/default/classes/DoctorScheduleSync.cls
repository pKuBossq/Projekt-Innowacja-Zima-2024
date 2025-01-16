public with sharing class DoctorScheduleSync implements Queueable, Database.AllowsCallouts {

    private static final String loginUrl = 'https://test.salesforce.com/services/oauth2/token';
    private static final String username = 'restuser@innowacja.rest.rest';
    private static final String password = 'Haslo123!!';
    private static final String securityToken = '7NNzLKGSAIj6gtkTJbRFAjUX';
    private static final String clientId = '3MVG9xqN3LZmHU7n7G0NHUYpNLMsh55X1HNRUcsBJ5Dtevv.S1jOSgyx3l3DQXqRc1md0qpR_l7ewk1oK4Oa9';
    private static final String clientSecret = 'F5CF486958B3E03C7FEF2A26DDB959301FCD7CDF34F3736F51A409D5B378402F';

    private static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(loginUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody(
            'grant_type=password'
            + '&client_id=' + clientId
            + '&client_secret=' + clientSecret
            + '&username=' + EncodingUtil.urlEncode(username, 'UTF-8')
            + '&password=' + EncodingUtil.urlEncode(password + securityToken, 'UTF-8')
        );
        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        }
        return null;
    }

    private void updateDoctorSchedules(List<Doctor> doctors) {
        List<Person__c> doctorsToUpsert = new List<Person__c>();

        for (Doctor doctor : doctors) {
            Person__c person = new Person__c();
            person.DoctorId__c = doctor.DoctorId;
            String schedule = 'Poniedziałek: "' + formatSchedule(doctor.Schedule.Monday) + '"\n' +
                              'Wtorek: "' + formatSchedule(doctor.Schedule.Tuesday) + '"\n' +
                              'Środa: "' + formatSchedule(doctor.Schedule.Wednesday) + '"\n' +
                              'Czwartek: "' + formatSchedule(doctor.Schedule.Thursday) + '"\n' +
                              'Piątek: "' + formatSchedule(doctor.Schedule.Friday) + '"\n' +
                              'Sobota: "' + formatSchedule(doctor.Schedule.Saturday) + '"\n' +
                              'Niedziela: "' + formatSchedule(doctor.Schedule.Sunday) + '"';
            person.Schedule__c = schedule;
            person.Name = 'Dr ' + doctor.FirstName + ' ' + doctor.LastName;
            person.Personal_ID_Number__c = doctor.Pesel;
            person.First_Name__c = doctor.FirstName;
            person.Last_Name__c = doctor.LastName;
            person.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Doctor'].Id;
            doctorsToUpsert.add(person);
        }

        upsert doctorsToUpsert Person__c.DoctorId__c;
    }

    private String formatSchedule(Day day) {
    if (day == null) {
        return 'Nie pracuje';
    }
    return day.StartTime + ' - ' + day.EndTime;
    }

    public class Day {
        public String EndTime;
        public String StartTime;
    }

    public class Schedule {
        public Day Sunday;
        public Day Saturday;
        public Day Friday;
        public Day Thursday;
        public Day Wednesday;
        public Day Tuesday;
        public Day Monday;
    }

    public class Doctor {
        public Schedule Schedule;
        public String DoctorId;
        public String Name;
        public String FirstName;
        public String LastName;
        public String Pesel;
    }

    public void execute(QueueableContext context) {
        String accessToken = getAccessToken();
        if (accessToken == null) {
            return;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cw-inn--rest.sandbox.my.salesforce.com/services/apexrest/DoctorWorkSchedules');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            List<Doctor> doctors = (List<Doctor>) JSON.deserialize(res.getBody(), List<Doctor>.class);
            updateDoctorSchedules(doctors);
        }
    }
}