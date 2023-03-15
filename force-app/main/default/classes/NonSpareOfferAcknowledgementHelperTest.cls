/* 
Class Name : NonSpareOfferAcknowledgementHelperTest
Author : Pavan
Description : Test Class for NonSpareOfferAcknowledgementHelper and NonSpareOfferAcknowledgementController
*/
@isTest(SeeAllData=false) 
public class NonSpareOfferAcknowledgementHelperTest {
    
    @isTest
    public static void test1(){
        Integration_Transaction__c it = new Integration_Transaction__c(Response__c='test');
        insert it;
        // User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        //   Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
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
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'UDR');
        insert branch;
        List<Account> lstAccount = new List<Account>();
        Account acc = new Account(Name = 'Test Account');
        lstAccount.add(acc);
        //insert acc;
        Account acc1 = new Account(Name = 'Test Account1', BillingCountry ='India');
        //insert acc1;
        lstAccount.add(acc1);
        insert lstAccount;
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
        List<Customer_Equipments__c> lstCE = new List<Customer_Equipments__c>();
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = acc.Id,
                                                                          RecordTypeId = millRecType.Id,
                                                                          Tag__c ='Test Record',
                                                                          Mill_Type__c = 'PbM',
                                                                          Mill_Type_Stage__c = 'Pbm',
                                                                          Type_of_Discharge__c= 'Grate',
                                                                          Dia_m__c = 12.00,
                                                                          Length_m__c=12.00);
        //insert millCustEquip;
        lstCE.add(millCustEquip);
        Customer_Equipments__c hydroCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = hydroRecType.Id);
        //insert hydroCustEquip;
        lstCE.add(hydroCustEquip);
        Customer_Equipments__c millCustEquip1 = new Customer_Equipments__c(Customer__c = acc1.Id, RecordTypeId = millRecType.Id);
        //insert millCustEquip1;
        lstCE.add(millCustEquip1);
        insert lstCE;
        List<Opportunity> lstopp=new List<Opportunity>();
        Opportunity millOpp = new Opportunity(Name = 'Test Child Opp Mill', AccountId = acc.Id,Customer_Branch_Assignment__c = custSalesOrg1.Id, RecordTypeId = MillRecTypeOpp.Id , CurrencyIsoCode = 'USD', CloseDate = Date.newInstance(2022, 12, 9), StageName = 'Qualification');
        //insert millOpp;
        lstopp.add(millOpp);
        Opportunity opportunity = new Opportunity(
            AccountId = acc.id,
            Name = 'Test AK OPP 6 Jul',
            Customer_Branch_Assignment__c   = custSalesOrg1.id,
            status__c = 'closed',
            Probability = 100.0,
            CloseDate = Date.newInstance(2022,07,21),
            ForecastCategoryName = 'Closed',
            CurrencyIsoCode = 'USD',
            stagename='closed won',
            //   Pricebook2Id = pricebook2.id,
            IsExcludedFromTerritory2Filter = false,
            Budget_Confirmed__c = false,
            ROI_Analysis_Completed__c = false,
            //ABG_PBG_if_applicable__c = 'Applicable',
            //Delivery_Terms__c = 'FCA',
            //Dispatch_Mode__c = 'FCL (Sea)',
            Drawings__c = false
            //Guarantee_Warranty_Terms_if_applicable__c = 'Applicable',
            //Packing_Forwarding__c = 'Included in price',
            //Payment_Terms__c = '100% due in Immediately',
            //Tax_Duty_if_applicable__c = 'Included in price'
        );
        //insert opportunity;
        lstopp.add(opportunity);
        insert lstopp;  
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
        
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Test Contack AK 6 Jul',
            Email = 'kandikatla.nikhil@gmail.com',
            CurrencyIsoCode = 'EUR',
            Status__c = 'ACTIVE',
            isActive__c = true);
        insert contact;
        
        
        Quote quote = new Quote(
            Name = 'Test Nikhil offer',
            CurrencyIsoCode = 'EUR',
            OpportunityId = opportunity.id,
            //  Pricebook2Id = pricebook2.id,
            PriceBook2Id = Test.getStandardPricebookId(),
            
            ContactId = contact.id,
            Status = 'Draft',
            BillingStreet = 'YOUGA, PROVINCE DE BOULGOU,,,,',
            BillingCity = 'YOUGA',
            BillingState = 'Assam',
            BillingPostalCode = '9999',
            BillingCountry = 'India',
            BillingStateCode = 'AS',
            BillingCountryCode = 'IN',
            BillingName = 'BURKINA MINING COMPANY SA',
            ShippingName = 'BURKINA MINING COMPANY SA',
            Email = 'test6@gmail.com',
            Phone = '1234567890',
            Approval_Status__c = 'Delivery SLA Accepted',
            //   BTP_Type__c = 'CIF',
            Branch__c = branch.id,
            Delivery_Schedule__c = 12.0,
            //   Opportunity_Equipments__c = proposal_form.id,
            // PMG_Head__c = user.id,
            //   Part_List__c = part_list.id,
            Payment_Months__c = 12.0,
            //  Port__c = port_of_destination.id,
            RSM_Approval_Required__c = false,
            // Regional_Sales_Head__c = user.id,
            Customer_code_identification_required__c = false,
            Notes__c = 'We are a leading manufacturer of specialized ‘critical to operate’ and recurring consumable products for the global mineral beneficiation, mining and bulk solids handling industry. Globally, we are the second largest producers of polymer-based mill liners.',
            // Sales_Org__c = sales_org.id,
            // Company__c = company.id,
            Distribution_Channel__c = 'XP',
            Division__c = 'ML',
            Offer_Generation_at__c = 'L3',
            //   Offer_Template__c = offertemplate.id,
            Company_Branch_Assignment__c = custSalesOrg2.id);
        
        insert quote;
        //Pricebook2 pricebook =  [Select Id,name,isstandard  from Pricebook2 Where IsStandard=true];
        Pricebook2 pricebook2 = new Pricebook2(
            Name = 'Standard Price Book',
            CurrencyIsoCode = 'USD',
            IsActive = true);
        insert pricebook2;
        List<Product2> lstProduct = new List<Product2>();
        Product2  product21 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        lstProduct.add(product21);
        //insert product21;
        Product2  product22 = new Product2(
            Name = 'PLM-03960-02-FEHhh',
            ProductCode = 'PLM-03960-02-FEHhh',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        lstProduct.add(product22);
        insert lstProduct;
        //insert product22;
        Test.startTest(); 
        Test.setMock(WebServiceMock.class, new NonSpareOfferAcknowledgementHelperMock());
        System.enqueueJob(new NonSpareOfferAcknowledgementController(quote,it));
        Test.stopTest();
        
    }
    
}