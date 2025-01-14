@isTest
private class MedicalFacilitiesSyncTest {
    @isTest static void testUpsert() {
        Test.setMock(HttpCalloutMock.class, new MedicalFacilitiesHttpMock());
        Test.startTest();
        MedicalFacilitiesSync sync = new MedicalFacilitiesSync();
        System.enqueueJob(sync);
        Test.stopTest();

        List<Medical_Facility__c> facilities = [
            SELECT Name, Phone_Number__c, Address__Street__s, Address__PostalCode__s, Address__City__s, Opening_Hours__c, Id__c, Email__c
            FROM Medical_Facility__c
        ];
        System.assertEquals(1, facilities.size());
        System.assertEquals('Jeż Medyczny', facilities[0].Name);
        System.assertEquals('+48 123 456 780', facilities[0].Phone_Number__c);
        System.assertEquals('Puławska 45', facilities[0].Address__Street__s);
        System.assertEquals('02-508', facilities[0].Address__PostalCode__s);
        System.assertEquals('Warszawa', facilities[0].Address__City__s);
        System.assertEquals('Poniedziałek: "10:00 - 16:00"\nWtorek: "10:00 - 16:00"\nŚroda: "10:00 - 19:00"\nCzwartek: "9:00 - 17:00"\nPiątek: "8:00 - 16:00"\nSobota: "9:00 - 19:00"\nNiedziela: "9:00 - 19:00"', facilities[0].Opening_Hours__c);
        System.assertEquals('AB123456', facilities[0].Id__c);
        System.assertEquals('kontakt0@placowka.com', facilities[0].Email__c);
    }
}