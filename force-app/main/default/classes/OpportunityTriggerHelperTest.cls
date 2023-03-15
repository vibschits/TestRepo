/* 
Name : OpportunityTriggerHelperTest
Descroption : Test Class for OpportunityTriggerHelper
Author : Pavan
*/
@isTest
public class OpportunityTriggerHelperTest {
    
    @isTest
    public static void test1(){
        
        List<Account> lstAccount = new List<Account>();
        Account acc = new Account(Name = 'Test Account',Status__c = 'Sync with SAP');
        lstAccount.add(acc);
        //insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1');
        lstAccount.add(acc1);
        //insert acc1;
        insert lstAccount;
        // User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
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
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'UDR');
        insert branch;
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c=true,Customer__c = acc.Id, Branch__c = branch.Id);
        insert custSalesOrg1;
        
        RecordType MillRecTypeOpp = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        RecordType HydrocycloneRecTypeOpp = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Hydrocyclone'];
        
        List<Opportunity> lstopp = new List<Opportunity>();
        Opportunity millOpp = new Opportunity(Name = 'Test Child Opp Mill', AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        lstopp.add(millOpp);
        //insert millOpp;
        
        Opportunity millOpp1 = new Opportunity(Name = 'Test Child Opp Mill1',Parent_Opportunity__c =millOpp.id, AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        lstopp.add(millOpp1);
        //insert millOpp1;
        
        Opportunity millOpp4 = new Opportunity(Name = 'Test Child Opp Hydroclone',Parent_Opportunity__c =millOpp.id, AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = HydrocycloneRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        lstopp.add(millOpp4);
        //insert millOpp4;
        
        try{
            Opportunity millOpp2 = new Opportunity(Name = 'Test Child Opp Mill2',Parent_Opportunity__c =millOpp.id, AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
            //insert millOpp2;
            lstopp.add(millOpp2);  
            Opportunity millOpp3 = new Opportunity(Name = 'Test Child Opp Mill3',Parent_Opportunity__c =millOpp.id, AccountId = acc1.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
            //insert millOpp3;
            lstopp.add(millOpp3);  
            insert lstopp;
        }
        catch(Exception e){System.debug('exception e '+e.getMessage());}
        
    }
    
    @isTest
    public static void test2(){
        
        List<Account> lstAccount = new List<Account>();
        Account acc = new Account(Name = 'Test Account',Status__c = 'Sync with SAP');
        lstAccount.add(acc);
        //insert acc;
        
        Account acc1 = new Account(Name = 'Test Account1');
        lstAccount.add(acc1);
        //insert acc1;
        insert lstAccount;
        
        // User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        //Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
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
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'UDR');
        insert branch;
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c=true,Customer__c = acc.Id, Branch__c = branch.Id);
        insert custSalesOrg1;
        
        RecordType MillRecTypeOpp = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        
        Opportunity millOpp = new Opportunity(Name = 'Test Child Opp Mill', AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        insert millOpp;
        
        Opportunity testmillOpp = [select id,name,TSS_Comments__c from Opportunity where name = 'Test Child Opp Mill'];
        testmillOpp.TSS_Comments__c = 'test';
        update testmillOpp;
        
        delete testmillOpp;
        undelete testmillOpp;
        
        OpportunityTriggerHandler testHandler = new OpportunityTriggerHandler();
        testHandler.getName();
        
        List<Opportunity> lstopp = new List<Opportunity>();
        Opportunity millOpp1 = new Opportunity(Name = 'Test Child Opp Mill1',Parent_Opportunity__c =millOpp.id, AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        //insert millOpp1;
        lstopp.add(millOpp1);
        try{
            Opportunity millOpp2 = new Opportunity(Name = 'Test Child Opp Mill2',Parent_Opportunity__c =millOpp.id, AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
            //insert millOpp2;
            lstopp.add(millOpp2);
            Opportunity millOpp3 = new Opportunity(Name = 'Test Child Opp Mill3',Parent_Opportunity__c =millOpp.id, AccountId = acc1.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
            //insert millOpp3;
            lstopp.add(millOpp3);
            insert lstopp;
        }
        catch(Exception e){System.debug('exception e '+e.getMessage());}
        
    }
    
}