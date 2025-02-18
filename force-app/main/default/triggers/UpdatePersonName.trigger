trigger UpdatePersonName on Person__c (before insert)
{
    Id patientRecordTypeId = Schema.SObjectType.Person__c.getRecordTypeInfosByName().get('Patient').getRecordTypeId();
    
    for (Person__c person: Trigger.new)
    {
        if(patientRecordTypeId != null && patientRecordTypeId == person.RecordTypeId)
        {
            person.Name = person.First_Name__c + ' ' + person.Last_Name__c;
        }
    }
}