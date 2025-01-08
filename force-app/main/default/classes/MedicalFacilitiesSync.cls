public with sharing class MedicalFacilitiesSync implements Schedulable{
    private static String getAccessToken() {
        String loginUrl = 'https://cw-inn--inn.sandbox.my.salesforce.com/services/oauth2/token';
        String username = 'restuser@innowacja.rest.rest';
        String password = 'Haslo123!!';
        String securityToken = '7NNzLKGSAIj6gtkTJbRFAjUX';
        String clientId = '3MVG9xqN3LZmHU7n7G0NHUYpNLMsh55X1HNRUcsBJ5Dtevv.S1jOSgyx3l3DQXqRc1md0qpR_l7ewk1oK4Oa9'; 
        String clientSecret = 'F5CF486958B3E03C7FEF2A26DDB959301FCD7CDF34F3736F51A409D5B378402F';

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

    public static void updateMedicalFacilities() {
        String token = getAccessToken();
        if (token == null) return;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cw-inn--rest.sandbox.my.salesforce.com/services/apexrest/MedicalFacilities');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() == 200) {
            List<Medical_Facility__c> facilities = (List<Medical_Facility__c>) JSON.deserialize(res.getBody(), List<Medical_Facility__c>.class);
            upsert facilities;
        }
    }

    public void execute(SchedulableContext sc) {
        updateMedicalFacilities();
    }

    public static void ScheduleJob() {
        String cron = '0 0 5 * * ?';
        String jobName = 'Daily Medical Facilities Update';
        System.schedule(jobName, cron, new MedicalFacilitiesSync());
    }
}