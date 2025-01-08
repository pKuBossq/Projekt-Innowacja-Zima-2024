@isTest
private class MedicalFacilitiesSyncTest {
    @isTest static void testUpdate() {
        Test.setMock(HttpCalloutMock.class, new MyFacilitiesHttpMock());
        Test.startTest();
        MedicalFacilitiesSync.updateMedicalFacilities();
        Test.stopTest();
    }

    @isTest static void testScheduleJob() {
        Test.startTest();
        MedicalFacilitiesSync.scheduleJob();
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = 'Daily Medical Facilities Update' LIMIT 1];
        System.assertEquals('0 0 5 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }

    // Mock dla calloutu
    private class MyFacilitiesHttpMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            if (req.getEndpoint().contains('/oauth2/token')) {
                res.setStatusCode(200);
                res.setBody('{"access_token":"fakeToken"}');
            } else {
                res.setStatusCode(200);
                res.setBody('[{"Name":"Clinic A","Type__c":"General"}]');
            }
            return res;
        }
    }
}