@isTest
private class DoctorScheduleSyncTest {
    @isTest 
    static void testUpsert() {
        Test.setMock(HttpCalloutMock.class, new DoctorScheduleHttpMock());

        Person__c doctor = new Person__c(
            Name = 'Doktor',
            DoctorId__c = 'D0000011',
            First_Name__c = 'Adrian',
            Last_Name__c = 'Kowalski',
            Personal_ID_Number__c = '19282675484',
            Schedule__c = 'Poniedziałek: "Brak danych"\nWtorek: "Brak danych"\nŚroda: "danych"\nCzwartek: "Brak danych"\nPiątek: "Brak danych"\nSobota: "Brak danych"\nNiedziela: "Brak danych"',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Doctor'].Id
        );
        Test.startTest();
        DoctorScheduleSync sync = new DoctorScheduleSync();
        System.enqueueJob(sync);
        Test.stopTest();

        List<Person__c> doctors = [
            SELECT DoctorId__c, Schedule__c, Personal_ID_Number__c, Name, Last_Name__c, First_Name__c, RecordTypeId
            FROM Person__c
        ];
        System.assertEquals(1, doctors.size());
        System.assertEquals('Doctor', doctors[0].RecordTypeId);
        System.assertEquals('Adrian', doctors[0].First_Name__c);
        System.assertEquals('Kowalski', doctors[0].Last_Name__c);
        System.assertEquals('Doktor', doctors[0].Name);
        System.assertEquals('19282675484', doctors[0].Personal_ID_Number__c);
        System.assertEquals('Poniedziałek: "9:00 - 14:00"\nWtorek: "10:00 - 14:00"\nŚroda: "9:00 - 14:00"\nCzwartek: "Brak danych"\nPiątek: "Brak danych"\nSobota: "10:00 - 17:00"\nNiedziela: "8:00 - 13:00"', doctors[0].Schedule__c);
        System.assertEquals('D0000011', doctors[0].DoctorId__c);
    }
}