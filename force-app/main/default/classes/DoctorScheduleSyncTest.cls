@isTest
private class DoctorScheduleSyncTest {
    @isTest 
    static void testUpsert() {
        Test.setMock(HttpCalloutMock.class, new DoctorScheduleHttpMock());
        Test.startTest();
        DoctorScheduleSync sync = new DoctorScheduleSync();
        System.enqueueJob(sync);
        Test.stopTest();

        List<Person__c> doctors = [
            SELECT DoctorId__c, Schedule__c, Personal_ID_Number__c, Name, Last_Name__c, First_Name__c, RecordTypeId
            FROM Person__c
        ];
        System.assertEquals(1, doctors.size());
        System.assertEquals([SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Doctor'].Id, doctors[0].RecordTypeId);
        System.assertEquals('Grzegorz', doctors[0].First_Name__c);
        System.assertEquals('Król', doctors[0].Last_Name__c);
        System.assertEquals('Dr Grzegorz Król', doctors[0].Name);
        System.assertEquals('61072632139', doctors[0].Personal_ID_Number__c);
        System.assertEquals('Poniedziałek: "9:00 - 14:00"\nWtorek: "10:00 - 14:00"\nŚroda: "9:00 - 14:00"\nCzwartek: "Nie pracuje"\nPiątek: "Nie pracuje"\nSobota: "10:00 - 17:00"\nNiedziela: "8:00 - 13:00"', doctors[0].Schedule__c);
        System.assertEquals('D0000013', doctors[0].DoctorId__c);
    }
}