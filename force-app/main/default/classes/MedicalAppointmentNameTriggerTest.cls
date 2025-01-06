@isTest
public class MedicalAppointmentNameTriggerTest {
    @isTest
    static void testBulkTrigger() {
        Medical_Facility__c facility = new Medical_Facility__c(Name = 'City Hospital');
        insert facility;

        Person__c doctor = new Person__c(
            Last_Name__c = 'Smith',
            First_Name__c = 'John',
            PESEL__c = '12345678',
            Medical_Facility__c = facility.Id
        );
        insert doctor;

        List<Person__c> patients = new List<Person__c>();
        for (Integer i = 1; i <= 10; i++) {
            patients.add(new Person__c(
                Last_Name__c = 'Doe' + i,
                First_Name__c = 'Jane' + i,
                PESEL__c = '12345678' + i
            ));
        }
        insert patients;

        List<Medical_Appointment__c> appointments = new List<Medical_Appointment__c>();

        for (Person__c patient : patients) {
            appointments.add(new Medical_Appointment__c(
                Patient__c = patient.Id,
                Doctor__c = doctor.Id,
                Appointment_Date__c = DateTime.newInstance(2024, 12, 28, 10, 30, 0)
            ));
        }
        insert appointments;

        List<Medical_Appointment__c> savedAppointments = [
            SELECT Name
            FROM Medical_Appointment__c
            WHERE Id IN :appointments
        ];

        for (Integer i = 0; i < savedAppointments.size(); i++) {
            String expectedName = 'City Hospital-Smith-Doe' + (i + 1) + '-28-12-2024';
            System.assertEquals(expectedName, savedAppointments[i].Name, 'Nazwa rekordu nie jest zgodna dla indeksu: ' + i);
        }
    }
    @isTest
    static void testIncompleteTrigger() {
        Person__c doctor = new Person__c(
            Last_Name__c = 'Smith',
            First_Name__c = 'John',
            PESEL__c = '12345678'
        );
        insert doctor;

        Person__c patient = new Person__c(
            Last_Name__c = 'Doe',
            First_Name__c = 'Jane',
            PESEL__c = '12345678'
        );
        insert patient;

		Medical_Appointment__c appointment = new Medical_Appointment__c(
            Patient__c = patient.Id,
            Doctor__c = doctor.Id,
        	Appointment_Date__c = DateTime.newInstance(2024, 12, 28, 10, 30, 0)
        );
        insert appointment;

        appointment = [SELECT Name FROM Medical_Appointment__c WHERE Id = :appointment.Id];
        
        System.assertEquals('Incomplete Information', appointment.Name);
    }
}