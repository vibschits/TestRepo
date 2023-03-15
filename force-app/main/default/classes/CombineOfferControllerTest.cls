@IsTest(SeeAllData=false)
public class CombineOfferControllerTest {
    static priceBookEntry pbe1 = new priceBookEntry(); 
    static priceBookEntry pbe2 = new priceBookEntry(); 
    static product2 product21 = new product2(); 
    static product2 product22 = new product2();
   static Id pricebookId;
    
    
    @testSetup static void setup() {    
        // Create test Opportunity records
        //  Id, Name, RecordType.Name, CurrencyIsoCode, CloseDate, StageName FROM Opportunity
        User user = [Select Id,Email from User where Email = 'ayush.khanna1@ibm.com' limit 1];
        Sales_Region__c sales_region = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = user.Id);
        insert sales_region;
        Account account = new Account(Name = 'Test Account');
        insert account;
        system.debug('Account'+account);
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = sales_region.Id,Branch_Code__c = 'TBR');
        insert branch;
        Customer_Sales_Organization__c customer_sales_organization = new Customer_Sales_Organization__c(CreatedFromAccount__c  =true,Customer__c = account.Id, Branch__c = branch.Id);
        insert customer_sales_organization;
        account.Status__c = 'Sync with SAP';
        update account;
        Customer_Equipments__c customer_equipments = new Customer_Equipments__c(
            CurrencyIsoCode = 'EUR',
            Circuit_diagram_available__c = false,
            Dia_m__c = 123.0,
            Mill_Type__c = 'SAG Mill',
            Tag__c = 'Test AK Mill 6 Jul',
            Type_of_Discharge__c = 'Grate',
            Customer__c = account.id,
            Recordtypeid = '012Bl0000000H46IAE');
        insert customer_equipments;
     /*  Pricebook2 custompricebook2 = new Pricebook2(
            Name = 'custom Price Book Test',
            CurrencyIsoCode = 'USD',
            IsActive = true
        );
        insert custompricebook2;*/
        
        
    }
    public static testMethod void unit1(){
        
        Account account = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        Customer_Equipments__c customer_equipments = [SELECT id, name from Customer_Equipments__c WHERE Createddate = today order by CreatedDate DESC LIMIT 1];
        Customer_Sales_Organization__c customer_sales_organization = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        Branch__c branch =[SELECT id from Branch__c WHERE name = 'Test Branch'];
       //  Pricebook2 custompricebook2 =[SELECT id from pricebook2 WHERE name = 'custom Price Book Test' LIMIT 1];
        
        
        Opportunity opportunity = new Opportunity(
            AccountId = account.id,
            Name = 'Test AK OPP 6 Jul',
            Customer_Branch_Assignment__c	= customer_sales_organization.id,
            status__c = 'closed',
            Probability = 100.00,
            CloseDate = Date.newInstance(2022,07,21),
            ForecastCategoryName = 'Closed',
            CurrencyIsoCode = 'USD',
            stagename='closed won',
            RecordTypeId ='012Bl0000000IZfIAM'
        );
        insert opportunity;
        
        list<Product2> lstProducts = new list<Product2>();
        
        product21 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        product22 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        lstProducts.add(product21);
        lstProducts.add(product22);
        insert lstProducts;
          /* pricebookId = Test.getStandardPricebookId();

        list<priceBookEntry> lstPBEs = new list<priceBookEntry>();
        pbe1 = new priceBookEntry(priceBook2Id = pricebookId, product2Id = product21.Id,unitPrice=10,isActive=true);
      
        pbe2 = new priceBookEntry(priceBook2Id = custompricebook2.id,product2Id = product22.Id,unitPrice=20,isActive=true);
       // lstPBEs.add(pbe1);
       // lstPBEs.add(pbe2);
        insert pbe1;
        system.debug('pbe1----'+pbe1);

        insert pbe2;
        
        system.debug('pbe2----'+pbe2.priceBook2Id);*/
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.id,
            Product2Id = product21.Id,
            UnitPrice = 10000, IsActive = true);
        insert pbe;
        
        pbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];
        //It should return true
        System.assertEquals(true, pbe.Pricebook2.IsStandard);
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = product21.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

                List<Quote> quoteList = new List<Quote>();
        Id offerRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
        for(Integer i=0; i<2; i++){
            Quote offer = new Quote(Name = 'tegaTest'+i,
                                    CurrencyIsoCode = 'EUR',
                                    RecordTypeId  =offerRecordTypeId,
                                    OpportunityId = opportunity.id,
                                    PriceBook2Id = Test.getStandardPricebookId(),
                                    Status = 'Price Accepted',
                                    BillingStreet = 'YOUGA, PROVINCE DE BOULGOU,,,,',
                                    BillingCity = 'YOUGA',
                                    BillingState = 'Assam',
                                    BillingPostalCode = '99599',
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
                                    Approval_Required__c =true,
                                    Is_Partlist_Same__c = true,
                                    Delivery_Schedule__c = 12.0,
                                    Payment_Months__c = 12.0,
                                    RSM_Approval_Required__c = false,
                                    Customer_code_identification_required__c = false,
                                    Notes__c = 'We are a leading manufacturer of specialized ‘critical to operate’ and recurring consumable products for the global mineral beneficiation, mining and bulk solids handling industry. Globally, we are the second largest producers of polymer-based mill liners.',
                                    Distribution_Channel__c = 'XP',
                                    Division__c = 'ML',
                                    Offer_Generation_at__c = 'L3',
                                    Company_Branch_Assignment__c = customer_sales_organization.id);
            quoteList.add(offer);              
        }
        if(quoteList.size() > 0 ){
            insert quoteList; 
        }
        
     //   List<QuoteLineItem> lineList = new List<QuoteLineItem>();
       /* for (Integer i=0; i<2; i++) {
            QuoteLineItem qiItem = new  QuoteLineItem(QuoteId = quoteList[i].Id ,Product2Id=product2.Id,
                                                      Pricebook2Id = Test.getStandardPricebookId(), Quantity =1, UnitPrice=123 );
            
            lineList.add(qiItem);
        }*/
        // Test.startTest();
        list<quoteLineItem>lstQteLI = new list<quoteLineItem>();
       // for(PricebookEntry pricebook : lstPBEs){
            QuoteLineItem qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = pbe.ID);
            //lstQteLI.add(qutlineitemtest);
            
          /*  qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = pricebook.id);
            lstQteLI.add(qutlineitemtest);
            
            qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = pricebook.id);
            lstQteLI.add(qutlineitemtest);
      //  }
        insert lstQteLI;
        system.debug('quote pBE'+lstQteLI[0].PricebookEntryId);
        Test.stopTest();*/
        
     
      /*  if(lineList.size() > 0){
            insert lineList;
        }*/
        insert qutlineitemtest;
        
        List<L1_L2_Offer_Line_Item__c> l1l2List = new List<L1_L2_Offer_Line_Item__c>();
        for (Integer i=0; i<2; i++) {
            L1_L2_Offer_Line_Item__c l1l2 = new L1_L2_Offer_Line_Item__c(Offer__c = quoteList[0].Id, 
                                                                         Product_Description__c = 'ABC');
            l1l2List.add(l1l2);
        }
        if(l1l2List.size() > 0){
            insert l1l2List;
        }
        
        
        List<Id> IdsList = new List<Id>();
        for(Quote qt : quoteList) {
            IdsList.add(qt.Id);
        }
       system.debug('lstPBes---181-'+pbe.priceBook2Id);

      CombineOfferController.getOffers(opportunity.Id, 'ALL');
        CombineOfferController.combineOffer(IdsList);
        
        
        
    }
 public static testMethod void unit2(){
        
        Account account = [Select Id,Name,Status__c from Account where Name = 'Test Account'];
        Customer_Equipments__c customer_equipments = [SELECT id, name from Customer_Equipments__c WHERE Createddate = today order by CreatedDate DESC LIMIT 1];
        Customer_Sales_Organization__c customer_sales_organization = [Select Id from Customer_Sales_Organization__c where Branch__r.Name = 'Test Branch'];
        Branch__c branch =[SELECT id from Branch__c WHERE name = 'Test Branch'];
       //  Pricebook2 custompricebook2 =[SELECT id from pricebook2 WHERE name = 'custom Price Book Test' LIMIT 1];
        
        
        Opportunity opportunity = new Opportunity(
            AccountId = account.id,
            Name = 'Test AK OPP 6 Jul',
            Customer_Branch_Assignment__c	= customer_sales_organization.id,
            status__c = 'closed',
            Probability = 100.00,
            CloseDate = Date.newInstance(2022,07,21),
            ForecastCategoryName = 'Closed',
            CurrencyIsoCode = 'USD',
            stagename='closed won',
            RecordTypeId ='012Bl0000000IZfIAM'
        );
        insert opportunity;
        
        list<Product2> lstProducts = new list<Product2>();
        
        product21 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        product22 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        lstProducts.add(product21);
        lstProducts.add(product22);
        insert lstProducts;
          /* pricebookId = Test.getStandardPricebookId();

        list<priceBookEntry> lstPBEs = new list<priceBookEntry>();
        pbe1 = new priceBookEntry(priceBook2Id = pricebookId, product2Id = product21.Id,unitPrice=10,isActive=true);
      
        pbe2 = new priceBookEntry(priceBook2Id = custompricebook2.id,product2Id = product22.Id,unitPrice=20,isActive=true);
       // lstPBEs.add(pbe1);
       // lstPBEs.add(pbe2);
        insert pbe1;
        system.debug('pbe1----'+pbe1);

        insert pbe2;
        
        system.debug('pbe2----'+pbe2.priceBook2Id);*/
        
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.id,
            Product2Id = product21.Id,
            UnitPrice = 10000, IsActive = true);
        insert pbe;
        
        pbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];
        //It should return true
        System.assertEquals(true, pbe.Pricebook2.IsStandard);
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = product21.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

                List<Quote> quoteList = new List<Quote>();
        Id offerRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
        for(Integer i=0; i<2; i++){
            Quote offer = new Quote(Name = 'tegaTest'+i,
                                    CurrencyIsoCode = 'EUR',
                                    RecordTypeId  =offerRecordTypeId,
                                    OpportunityId = opportunity.id,
                                    PriceBook2Id = Test.getStandardPricebookId(),
                                    Status = 'Price Accepted',
                                    BillingStreet = 'YOUGA, PROVINCE DE BOULGOU,,,,',
                                    BillingCity = 'YOUGA',
                                    BillingState = 'Assam',
                                    BillingPostalCode = '99599',
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
                                    //Approval_Required__c =true,
                                    //Is_Partlist_Same__c = true,
                                    Delivery_Schedule__c = 12.0,
                                    Payment_Months__c = 12.0,
                                    RSM_Approval_Required__c = false,
                                    Customer_code_identification_required__c = false,
                                    Notes__c = 'We are a leading manufacturer of specialized ‘critical to operate’ and recurring consumable products for the global mineral beneficiation, mining and bulk solids handling industry. Globally, we are the second largest producers of polymer-based mill liners.',
                                    Distribution_Channel__c = 'XP',
                                    Division__c = 'ML',
                                    Offer_Generation_at__c = 'L3',
                                    Company_Branch_Assignment__c = customer_sales_organization.id);
            quoteList.add(offer);              
        }
        if(quoteList.size() > 0 ){
            insert quoteList; 
        }
        
     //   List<QuoteLineItem> lineList = new List<QuoteLineItem>();
       /* for (Integer i=0; i<2; i++) {
            QuoteLineItem qiItem = new  QuoteLineItem(QuoteId = quoteList[i].Id ,Product2Id=product2.Id,
                                                      Pricebook2Id = Test.getStandardPricebookId(), Quantity =1, UnitPrice=123 );
            
            lineList.add(qiItem);
        }*/
        // Test.startTest();
        list<quoteLineItem>lstQteLI = new list<quoteLineItem>();
       // for(PricebookEntry pricebook : lstPBEs){
            QuoteLineItem qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = pbe.ID);
            //lstQteLI.add(qutlineitemtest);
            
          /*  qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = pricebook.id);
            lstQteLI.add(qutlineitemtest);
            
            qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = pricebook.id);
            lstQteLI.add(qutlineitemtest);
      //  }
        insert lstQteLI;
        system.debug('quote pBE'+lstQteLI[0].PricebookEntryId);
        Test.stopTest();*/
        
     
      /*  if(lineList.size() > 0){
            insert lineList;
        }*/
        insert qutlineitemtest;
        
        List<L1_L2_Offer_Line_Item__c> l1l2List = new List<L1_L2_Offer_Line_Item__c>();
        for (Integer i=0; i<2; i++) {
            L1_L2_Offer_Line_Item__c l1l2 = new L1_L2_Offer_Line_Item__c(Offer__c = quoteList[0].Id, 
                                                                         Product_Description__c = 'ABC');
            l1l2List.add(l1l2);
        }
        if(l1l2List.size() > 0){
            insert l1l2List;
        }
        
        
        List<Id> IdsList = new List<Id>();
        for(Quote qt : quoteList) {
            IdsList.add(qt.Id);
        }
       system.debug('lstPBes---181-'+pbe.priceBook2Id);

      CombineOfferController.getOffers(opportunity.Id, 'ALL');
        CombineOfferController.combineOffer(IdsList);
        
        
        
    }
    
    
    
   
    
    
}