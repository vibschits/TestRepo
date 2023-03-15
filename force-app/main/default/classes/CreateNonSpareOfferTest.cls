/*
Name : CreateNonSpareOfferTest
Description : Test class for CreateNonSpareOffer.
Author : Pavan
*/

@isTest(SeeAllData=false)
public class CreateNonSpareOfferTest {
    
    @isTest
    public static void testExecute(){
        
        Integration_Transaction__c it = new Integration_Transaction__c(Response__c='test');
        insert it;
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
        // User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = lstUsers[0].Id);
        insert salesReg;
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'UDR');
        insert branch;
        List<Account> lstaccount = new List<Account>();
        Account acc = new Account(Name = 'Test Account');
        lstaccount.add(acc);
        //insert acc;
        Account acc1 = new Account(Name = 'Test Account1', BillingCountry ='India');
        lstaccount.add(acc1);
        insert lstaccount;
        //insert acc1;
        List<Customer_Sales_Organization__c> lstCSO = new List<Customer_Sales_Organization__c>();
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c=true,Customer__c = acc.Id, Branch__c = branch.Id);
        lstCSO.add(custSalesOrg1);
        //insert custSalesOrg1;

        Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;
        Customer_Sales_Organization__c custSalesOrg2 = new Customer_Sales_Organization__c(CreatedFromAccount__c=true,Customer__c = acc1.Id, Branch__c = branch.Id);
        lstCSO.add(custSalesOrg2);
        insert lstCSO;
        //insert custSalesOrg2;
        acc.Status__c = 'Sync with SAP';
        update acc;
        RecordType millRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        RecordType hydroRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Hydrocyclone'];
        RecordType MillRecTypeOpp = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        List<Customer_Equipments__c> lstCE= new List<Customer_Equipments__c>();
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = acc.Id,
                                                                          RecordTypeId = millRecType.Id,
                                                                          Tag__c ='Test Record',
                                                                          Mill_Type__c = 'PbM',
                                                                          Mill_Type_Stage__c = 'Pbm',
                                                                          Type_of_Discharge__c= 'Grate',
                                                                          Dia_m__c = 12.00,
                                                                          Length_m__c=12.00);
        lstCE.add(millCustEquip);
        //insert millCustEquip;
        Customer_Equipments__c hydroCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = hydroRecType.Id);
        lstCE.add(hydroCustEquip);
        //insert hydroCustEquip;
        Customer_Equipments__c millCustEquip1 = new Customer_Equipments__c(Customer__c = acc1.Id, RecordTypeId = millRecType.Id);
        lstCE.add(millCustEquip1);
        //insert millCustEquip1;
       	insert lstCE;
        Opportunity millOpp = new Opportunity(Name = 'Test Child Opp Mill', AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        insert millOpp;
        
        Operating_Parameters__c operating = new Operating_Parameters__c( Customer__c = acc1.Id, 
                                                                        ore__c = 'Aggregate',
                                                                        Motor_Power_Kwh__c= 12.00,
                                                                        F80_mm__c =12.00,
                                                                        Media_Top_Size_mm__c=12.00,
                                                                        Mill_Speed_rpm__c=13.00,
                                                                        Charge_Volume__c =23.00,
                                                                        Throughput_tph__c =23.00,
                                                                        Type_of_Grinding__c ='wet',
                                                                        Circuit_Type__c ='open',
                                                                        Circulating_Load_if_closed_tph__c=23.00,
                                                                        Max_Temperature__c=23.00,
                                                                        pH_Value_of_the_Slurry__c = 31.00);
        insert operating;
        
        
        Proposal_Form__c oppEquip = new Proposal_Form__c(Operating_Parameters__c =operating.id,SAP_Offer_Number__c='0020034308',
                                                         Opportunity__c = millOpp.Id,Customer_Equipment__c = millCustEquip.Id);
        
        insert oppEquip;
        Test.startTest(); 
        Test.setMock(WebServiceMock.class, new CreateNonSpareOfferTestMock());
        System.enqueueJob(new CreateNonSpareOffer('12345',it.Id));
        //   CreateNonSpareOfferController.getNonSpareOffer();
        System.debug('exception e '+it.Error__c);
        Test.stopTest();
    }
    
}