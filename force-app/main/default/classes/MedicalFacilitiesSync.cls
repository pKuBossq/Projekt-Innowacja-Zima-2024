public with sharing class MedicalFacilitiesSync implements Queueable, Database.AllowsCallouts {

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

    public static void upsertMedicalFacilities() {
        String token = getAccessToken();
        if (token == null) return;

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://cw-inn--rest.sandbox.my.salesforce.com/services/apexrest/MedicalFacilities');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + token);

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() == 200) {
            List<Object> facilitiesList = (List<Object>) JSON.deserializeUntyped(res.getBody());
            List<Map<String, Object>> facilitiesListMap = new List<Map<String, Object>>();
            for (Object facility : facilitiesList) {
                facilitiesListMap.add((Map<String, Object>) facility);
            }
            List<Medical_Facility__c> facilities = new List<Medical_Facility__c>();

            for (Map<String, Object> facilityMap : facilitiesListMap) {
                Medical_Facility__c facility = new Medical_Facility__c();
                facility.Name = (String) facilityMap.get('Name');
                facility.Phone_Number__c = (String) facilityMap.get('Phone');
                Map<String, Object> addressMap = (Map<String, Object>) facilityMap.get('Address');
                facility.Address__Street__s = (String) addressMap.get('Street');
                facility.Address__PostalCode__s = (String) addressMap.get('PostalCode');
                facility.Address__City__s = (String) addressMap.get('City');
                facilities.add(facility);
            }

            upsert facilities;
        }
    }

    public void execute(QueueableContext context) {
        upsertMedicalFacilities();
    }
}