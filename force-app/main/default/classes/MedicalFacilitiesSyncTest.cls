@isTest
private class MedicalFacilitiesSyncTest {
    @isTest static void testUpsert() {
        Test.setMock(HttpCalloutMock.class, new MedicalFacilitiesHttpMock());
        Test.startTest();
        MedicalFacilitiesSync.upsertMedicalFacilities();
        Test.stopTest();

        List<Medical_Facility__c> facilities = [
            SELECT Name, Phone_Number__c, Address__Street__s, Address__PostalCode__s, Address__City__s
            FROM Medical_Facility__c
        ];
        System.assertEquals(2, facilities.size());
        System.assertEquals('Centrum Zdrowia Hipopotam', facilities[0].Name);
        System.assertEquals('+48 123 456 780', facilities[0].Phone_Number__c);
        System.assertEquals('Wyszyńskiego 7', facilities[0].Address__Street__s);
        System.assertEquals('75-620', facilities[0].Address__PostalCode__s);
        System.assertEquals('Koszalin', facilities[0].Address__City__s);
    }
}