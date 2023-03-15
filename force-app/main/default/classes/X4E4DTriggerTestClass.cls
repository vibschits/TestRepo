@IsTest(SeeAllData=false)
public class X4E4DTriggerTestClass {
    
    @testSetup static void setup() {    
        // Create test Opportunity records
        //  Id, Name, RecordType.Name, CurrencyIsoCode, CloseDate, StageName FROM Opportunity
       
        
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
        
        Account acc = new Account(Name = 'Test Account' , Status__c = 'Sync with SAP');
        insert acc;
        system.debug('Account'+acc);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = acc.Id, Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert custSalesOrg1;
        
        
    }
    
    static testmethod void validateData(){
        
        Account acc = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        Customer_Sales_Organization__c custSalesOrg1 = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        //Opportunity ParentOpp = [Select Id,Name,Parent_Opportunity__c from Opportunity where Name = 'Test Parent Opp'];
        RecordType MillRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        
        
        RecordType ScreenRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Screen'];
        RecordType ParentRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Parent'];                     
        Opportunity ParentOpp = new Opportunity(Name = 'Test Parent Opp',AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = ParentRecType.Id, CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        insert ParentOpp;
        Opportunity ChildOppMill = new Opportunity(Name = 'Test Child Opp Mill',AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecType.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification', Parent_Opportunity__c = ParentOpp.Id);
        Opportunity ChildOppScreen = new Opportunity(Name = 'Test Child Opp Screen',AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = ScreenRecType.Id, CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification', Parent_Opportunity__c = ParentOpp.Id);
        
        
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(ChildOppMill);
        oppList.add(ChildOppScreen);
        
        insert oppList;
        
        RecordType millequp = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = millequp.Id);
        insert millCustEquip;
        Proposal_Form__c oppEquip = new Proposal_Form__c(Opportunity__c =ChildOppMill.id ,Customer_Equipment__c = millCustEquip.Id);
        
        Quote offer = new Quote( Name = 'test offer' ,OpportunityId =ChildOppMill.id ,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 );
        insert offer;
        
        Quote offerNext = new Quote( Name = 'test offer 1' ,OpportunityId =ChildOppScreen.id ,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 , Status='LS' );
        insert offerNext;
        
        Quote offerNextOne = new Quote( Name = 'test offer 2' ,OpportunityId =ChildOppScreen.id ,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30  );
        insert offerNextOne;
        
        
        
        X4E_4D__c record = new X4E_4D__c(Category__c = 'SO' , SF_Offer__c=offer.id	);
        insert record;
        
        X4E_4D__c recordNew = new X4E_4D__c(Category__c = 'SO' , SF_Offer__c=offer.id	);
        insert recordNew;
        
        X4E_4D__c recordNewOne = new X4E_4D__c(Category__c = 'SO' , SF_Offer__c=offerNext.id	);
        insert recordNewOne;
        
        record.Category__c='ASO';
		update record;
		delete record;  
        undelete record;
    }
}