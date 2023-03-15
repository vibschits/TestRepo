@isTest(SeeAllData=false)
private class TriggerHandlerTestClass {
static testMethod boolean isDisabled() {
boolean isTriggerDisabledValue=false;
Contact c = new Contact(FirstName='Tushar',LastName='Sinha');
Test.startTest();
 // Insert Contact
 insert c;
 Contact c1 = new Contact(FirstName='Stalin',LastName='Mohapatra');   
 insert c1;
    Contact c2 = new Contact(FirstName='Tony',LastName='Stark');   
    insert c2;
    c.LastName='SinhaSinha';
    update c;
    delete c1;
    undelete c1;
    
            Account acc = new Account(Name = 'Test Account');
        insert acc;
            Account acc1 = new Account(Name = 'Test Account1');
        insert acc1;
    acc1.Name= 'Test';
    update acc1;
            Account acc2 = new Account(Name = 'Test Account2');
        insert acc2;
        delete acc2;
    undelete acc2;
    
    Profile salesPersonProfile = [Select Id From Profile Where Name = 'System Administrator'];

    String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
          //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = salesPersonProfile.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
    insert u;
       TriggerManager__c triggerSettings = new TriggerManager__c();
    triggerSettings.DisabledObjects__c = 'Account';
   triggerSettings.MuteAllTriggers__c= true;
    triggerSettings.SetupOwnerId=u.id;
   insert triggerSettings;
    System.runAs(u){
    TriggerDispatcher.skipObjectfromRecursiveCall(c1);
    TriggerDispatcher.skipObjectfromRecursiveCall(acc1);
    TriggerDispatcher.skipObjectfromRecursiveCall(acc2);
    TriggerDispatcher.skipObjectfromRecursiveCall(acc);
    }
 Test.stopTest();
     return isTriggerDisabledValue;
    

 }
    
}