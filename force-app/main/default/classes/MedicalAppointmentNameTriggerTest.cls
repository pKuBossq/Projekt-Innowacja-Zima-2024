@isTest
public class MedicalAppointmentNameTriggerTest {
    @isTest
    static void testTrigger() {
        Medical_Facility__c facility = new Medical_Facility__c(Name = 'City Hospital');
        insert facility;

        Person__c doctor = new Person__c(
            Last_Name__c = 'Smith',
            First_Name__c = 'John',
            Personal_ID_Number__c = '19282675484',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Doctor'].Id
        );
        insert doctor;

        Person__c patient = new Person__c(
            Last_Name__c = 'Doe',
            First_Name__c = 'Jane',
            Personal_ID_Number__c = '95112981129',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Patient'].Id
        );
        insert patient;
        
        Medical_Appointment__c appointment = new Medical_Appointment__c(
            Patient__c = patient.Id,
            Doctor__c = doctor.Id,
            Medical_Facility__c = facility.Id,
            Appointment_Date__c = DateTime.newInstance(2025, 12, 28, 10, 30, 0)
        );
        insert appointment;

        appointment = [SELECT Name FROM Medical_Appointment__c WHERE Id = :appointment.Id];

        String expectedName = 'City Hospital-Smith-Doe-28-12-2025';
        System.assertEquals(expectedName, appointment.Name);
    }
    @isTest
    static void testIncompleteTrigger() {
        Person__c doctor = new Person__c(
            Last_Name__c = 'Smith',
            First_Name__c = 'John',
            Personal_ID_Number__c = '19282675484',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Doctor'].Id
        );
        insert doctor;

        Person__c patient = new Person__c(
            Last_Name__c = 'Doe',
            First_Name__c = 'Jane',
            Personal_ID_Number__c = '95112981129',
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Person__c' AND Name = 'Patient'].Id
        );
        insert patient;

		Medical_Appointment__c appointment = new Medical_Appointment__c(
            Patient__c = patient.Id,
            Doctor__c = doctor.Id,
        	Appointment_Date__c = DateTime.newInstance(2025, 12, 28, 10, 30, 0)
        );
        insert appointment;

        appointment = [SELECT Name FROM Medical_Appointment__c WHERE Id = :appointment.Id];
        
        String expectedName = 'Missing Facility Name-Smith-Doe-28-12-2025';
        System.assertEquals(expectedName, appointment.Name);
    }
}