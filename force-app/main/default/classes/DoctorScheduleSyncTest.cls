@isTest
private Class DoctorScheduleSyncTest {
    @isTest static void testUpsert() {
        Test.setMock(HttpCalloutMock.class, new DoctorScheduleHttpMock());
        Test.startTest();
        DoctorScheduleSync sync = new DoctorScheduleSync();
        System.enqueueJob(sync);
        Test.stopTest();

        List<Person__c> doctors = [
            SELECT DoctorId__c, Schedule__c, Personal_ID_Number__c, Name, Last_Name__c, First_Name__c
            FROM Person__c
        ];
        System.assertEquals(1, doctors.size());
        System.assertEquals('Jakub', doctors[0].First_Name__c);
        System.assertEquals('Borkiewicz', doctors[0].Last_Name__c);
        System.assertEquals('Doktor', doctors[0].Name);
        System.assertEquals('19282675484', doctors[0].Personal_ID_Number__c);
        System.assertEquals('Poniedziałek: "9:00 - 14:00"\nWtorek: "10:00 - 14:00"\nŚroda: "9:00 - 14:00"\nCzwartek: "Brak danych"\nPiątek: "Brak danych"\nSobota: "10:00 - 17:00"\nNiedziela: "8:00 - 13:00"', doctors[0].Schedule__c);
        System.assertEquals('D0000011', doctors[0].DoctorId__c);
    }
}