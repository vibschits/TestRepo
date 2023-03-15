@isTest(SeeAllData=false)
private class OpportunityTriggerTestClass {
    
    @testSetup static void setup() {    
        // Create test Opportunity records
        //  Id, Name, RecordType.Name, CurrencyIsoCode, CloseDate, StageName FROM Opportunity
        //User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        // Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        list<user>lstUsers = new list<user>();
        for(integer i=0;i<3;i++)
        {
            user usr = new user();
            usr.Alias = 'sales'+string.ValueOf(i);
            usr.Email = 'sales'+string.ValueOf(i)+'@testorg.com';
            usr.EmailEncodingKey = 'UTF-8'; 
            usr.firstname = 'Test'; 
            usr.LastName = 'Leadassign'+string.ValueOf(i);
            usr.LanguageLocaleKey = 'en_US';
            usr.LocaleSidKey = 'en_US'; 
            usr.ProfileId = p.Id; 
            usr.TimeZoneSidKey = 'America/Los_Angeles';
            usr.UserName = 'salesuser1'+string.ValueOf(i)+'@testorg.com';
            lstUsers.add(usr);
        }
        insert lstUsers;
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = lstUsers[0].Id);
        insert salesReg;
        Account acc = new Account(Name = 'Test Account',CurrencyIsoCode = 'USD');
        insert acc;
        system.debug('Account'+acc);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c =true,Customer__c = acc.Id, Branch__c = branch.Id);
        insert custSalesOrg1;
        acc.Status__c = 'Sync with SAP';
        update acc;
        
    }
    static testmethod void validateData(){
        Account acc = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        Customer_Sales_Organization__c custSalesOrg1 = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        //Opportunity ParentOpp = [Select Id,Name,Parent_Opportunity__c from Opportunity where Name = 'Test Parent Opp'];
        RecordType MillRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        RecordType ScreenRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Screen'];
        RecordType ParentRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Parent'];  
        RecordType TrommelRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Trommel'];                     
        Opportunity ParentOpp = new Opportunity(Name = 'Test Parent Opp',AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = ParentRecType.Id, CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        insert ParentOpp;
        Opportunity ChildOppMill = new Opportunity(Name = 'Test Child Opp Mill',AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecType.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification', Parent_Opportunity__c = ParentOpp.Id);
        Opportunity ChildOppScreen = new Opportunity(Name = 'Test Child Opp Screen',AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = ScreenRecType.Id, CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification', Parent_Opportunity__c = ParentOpp.Id);
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(ChildOppMill);
        oppList.add(ChildOppScreen);
        insert oppList;
        Opportunity ChildOppMill2 = new Opportunity(Name = 'Test Child Opp Mill2',Customer_Branch_Assignment__c = custSalesOrg1.Id,AccountId = acc.Id, RecordTypeId = TrommelRecType.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification', Parent_Opportunity__c = ParentOpp.Id);
        try{
            insert ChildOppMill2;
            ChildOppMill2.Name = 'Modified';
            update ChildOppMill2;
            delete ChildOppMill2;
            undelete ChildOppMill2;
            OpportunityTriggerHandler tstHandler = new OpportunityTriggerHandler();
            tstHandler.getName();
        }catch(Exception e){
            system.debug('opportunity error '+e.getMessage() + 'line no '+e.getLineNumber());
        }
    }
}