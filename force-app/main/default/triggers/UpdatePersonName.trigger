trigger UpdatePersonName on Person__c (before insert)
{
    Map<Id,String> recordTypeMap = new Map<Id, String>();
    for (RecordType rt: [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Person__c'])
    {
        recordTypeMap.put(rt.Id, rt.Name);
    }
    
    for (Person__c person: Trigger.new)
    {
        if(recordTypeMap.containsKey(person.RecordTypeId) && recordTypeMap.get(person.RecordTypeId) == 'Patient')
        {
            person.Name = person.First_Name__c + ' ' + person.Last_Name__c;
        }
    }
    
}