/*
Name : CreatePaymentDocTest
Description : Test class for CreatePaymentDoc.
Author : Pavan
*/
@isTest(SeeAllData=false)
public class CreatePaymentDocTest {
    @isTest
    public static void testMEthod1(){
        Integration_Transaction__c it = new Integration_Transaction__c(Response__c='test');
        insert it;
        // User testUser = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        //Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = testUser.Id);
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

        Account acc1 = new Account(Name = 'Test Account1', BillingCountry ='India');
        lstAccount.add(acc1);

        insert lstAccount;
        List<Customer_Sales_Organization__c> lstCSO = new List<Customer_Sales_Organization__c>();
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c=true,Customer__c = acc.Id, Branch__c = branch.Id);
        //insert custSalesOrg1;
        lstCSO.add(custSalesOrg1);
        Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;
        Customer_Sales_Organization__c custSalesOrg2 = new Customer_Sales_Organization__c(CreatedFromAccount__c=true,Customer__c = acc1.Id, Branch__c = branch.Id);
        //insert custSalesOrg2;
        lstCSO.add(custSalesOrg2);
        insert lstCSO;
        acc.Status__c = 'Sync with SAP';
        update acc;
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
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
        lstCE.add(millCustEquip);

        Customer_Equipments__c hydroCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = hydroRecType.Id);
        lstCE.add(hydroCustEquip);

        Customer_Equipments__c millCustEquip1 = new Customer_Equipments__c(Customer__c = acc1.Id, RecordTypeId = millRecType.Id);
        lstCE.add(millCustEquip1);
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
        
        Part_List__c part_list = new Part_List__c(
            Name = 'PLM-03960-01 SAP2',
            CurrencyIsoCode = 'USD',
            BOM__c = 'BALL DIA- 2400 X 4300 MM EGL',
            Delivery_Req__c = 56.0,
            Description__c = 'BALL DIA- 2400 X 4300 MM EGL',
            Direct_Quoted_Exchange_Rate__c = 54.0,
            Last_Offer_Value_Foreign_Currency__c = 0.0,
            Customer__c=acc.id);
        insert part_list;
        
        Product2 product2 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = false,
            CurrencyIsoCode = 'USD',
            Part_List__c = part_list.id,
            Product_Level__c = 'L2',
            Quantity__c = 1.0);
        //    insert product2;
        //    
        Payment_Doc__c tstDoc = new Payment_Doc__c();
        tstDoc.Company_Code__c = 'test';
        tstDoc.PMT_Doc_Number__c = '12345';
        tstDoc.Posting_Date__c = date.valueOf('2021-12-12');
        insert tstDoc;
        Payment_Doc__c tstDoc1 = new Payment_Doc__c();
        tstDoc1.Company_Code__c = '12345'; 
        tstDoc1.PMT_Doc_Number__c = '12345';
        tstDoc1.Posting_Date__c = date.valueOf('2021-12-12');
        insert tstDoc1;
        
        Payment_Doc_Line__c tstLine = new Payment_Doc_Line__c();
        tstLine.Company_Code__c   = '12345';
        tstLine.PMT_Doc_Number_c__c  = '12345';
        tstLine.Posting_Date__c= date.valueOf('2021-12-12');
        insert tstLine;
        
        RecordType expInvRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Invoice__c' AND DeveloperName = 'Export'];
        Id exportInvoiceRecTypeId = expInvRecType.Id;
        Invoice__c invoice = new Invoice__c();
        invoice.SAP_Invoice_Number__c = '12345';
        invoice.Customer__c = acc.id;
        invoice.Consignee__c = acc.id;
        invoice.GST_Number__c = 'test';
        invoice.VAT_Number__c = '1234';
        invoice.RecordTypeId = exportInvoiceRecTypeId;
        invoice.CurrencyIsoCode = 'INR';
        insert invoice;
        
        Test.startTest(); 
        Test.setMock(WebServiceMock.class, new CreatePaymentDocTestMock());
        SchedulePaymentIntegration sh1 = new SchedulePaymentIntegration();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
        Test.stopTest();
    }}