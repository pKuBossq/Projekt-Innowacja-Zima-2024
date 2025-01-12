@isTest
private class MedicalFacilitiesSyncScheduleTest {
    @isTest static void testScheduleJob() {
        Test.setMock(HttpCalloutMock.class, new MedicalFacilitiesHttpMock());
        Test.startTest();
        MedicalFacilitiesSyncSchedule.scheduleJob();
        Test.stopTest();

        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered
            FROM CronTrigger
            WHERE CronJobDetail.Name = 'Daily Medical Facilities Update'
            LIMIT 1
        ];
        System.assertEquals('0 0 5 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}