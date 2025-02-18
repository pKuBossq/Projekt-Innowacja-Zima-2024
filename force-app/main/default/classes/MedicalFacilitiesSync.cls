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

    private void upsertMedicalFacilities(List<MedicalFacility> medicalFacilities) {
        List<Medical_Facility__c> medicalFacilitesToUpsert = new List<Medical_Facility__c>();

        for (MedicalFacility facility : medicalFacilities) {
            Medical_Facility__c medicalFacility = new Medical_Facility__c();
            medicalFacility.Name = facility.Name;
            medicalFacility.Phone_Number__c = facility.Phone;
            medicalFacility.Email__c = facility.Email;
            medicalFacility.Id__c = facility.Id;
            medicalFacility.Address__Street__s = facility.Address.Street;
            medicalFacility.Address__PostalCode__s = facility.Address.PostalCode;
            medicalFacility.Address__City__s = facility.Address.City;
            String openingHours = 'Poniedziałek: "' + facility.OpeningHours.get('Poniedziałek') + '"\n' +
                                  'Wtorek: "' + facility.OpeningHours.get('Wtorek') + '"\n' +
                                  'Środa: "' + facility.OpeningHours.get('Środa') + '"\n' +
                                  'Czwartek: "' + facility.OpeningHours.get('Czwartek') + '"\n' +
                                  'Piątek: "' + facility.OpeningHours.get('Piątek') + '"\n' +
                                  'Sobota: "' + facility.OpeningHours.get('Sobota') + '"\n' +
                                  'Niedziela: "' + facility.OpeningHours.get('Niedziela') + '"';
            medicalFacility.Opening_Hours__c = openingHours;
            medicalFacilitesToUpsert.add(medicalFacility);
        }

        upsert medicalFacilitesToUpsert Medical_Facility__c.Id__c;
    }

    public class Address {
        public String Street;
        public String PostalCode;
        public String City;
    }

    public class MedicalFacility {
        public String Phone;
        public String Name;
        public String Id;
        public String Email;
        public Address Address;
        public Map<String, String> OpeningHours;
    }

    public void execute(QueueableContext context) {
        String accessToken = getAccessToken();
        if (accessToken != null) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://cw-inn--rest.sandbox.my.salesforce.com/services/apexrest/MedicalFacilities');
            req.setMethod('GET');
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            HttpResponse res = new Http().send(req);

            if (res.getStatusCode() == 200) {
                List<MedicalFacility> medicalFacilities = (List<MedicalFacility>) JSON.deserialize(res.getBody(), List<MedicalFacility>.class);
                upsertMedicalFacilities(medicalFacilities);
            } else {
                System.debug('Failed to fetch medical facilities');
            }
        }
    }
}