/*
Name : CreateOfferLineControllerTest
Desc :  this is test class cover this CreateOfferLineControllerTest class.
*/

@isTest(SeeAllData=false)
public class CreateOfferLineControllerTest {
    //  private static Boolean isMultiCurrency = null;
    
    private static testMethod void unit1(){
        // isMultiCurrency = Schema.getGlobalDescribe().containsKey('CurrencyType');  
        Account testAcct = new Account (Name = 'My Test Account');
        insert testAcct;
        
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = UserInfo.getUserId());
        insert salesReg;
        
        Branch__c br = new Branch__c(Name = 'Bokaro', Branch_Code__c = 'BKR',
                                     Sales_Region__c = salesReg.Id,
                                     Mark_Up__c = 1.5,
                                     Rate_PckFwd__c = 1.5,
                                     CIF_Factor__c = 1.5,
                                     Rate_Freight__c= 1.5,
                                     Rate_Insurance__c = 1.5,
                                     Rate_Interest__c = 1.5,
                                     Rate_Hedging__c = 1.5);
        insert br;
        
        Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = testAcct.Id, Branch__c = br.Id, sales_Organizations__c = sOrg.Id,CreatedFromAccount__c = true);
        insert custSalesOrg1;
        
        testAcct.Status__c = 'Sync with SAP';
        update testAcct;
        
        Opportunity oppt = new Opportunity(Name ='tega',
                                           AccountID = testAcct.ID,
                                           StageName = 'Customer Won',
                                           Amount = 3000,
                                           CloseDate = System.today(),
                                           PriceBook2Id = Test.getStandardPricebookId(),
                                           CurrencyIsoCode ='INR',
                                           Customer_Branch_Assignment__c = custSalesOrg1.Id
                                          );
        
        insert oppt;
        
        Port_of_Destination__c port = new Port_of_Destination__c(Name ='Kolkata' , Port_Code__c = '001');
        insert port;
        
        Freight__c freight = new Freight__c(Port_Code__c = port.Id, Container_Rate_20Ft__c = 200, Container_Rate_40Ft__c =200);
        insert freight;
        
        List<Product2> lstProduct = new List<Product2>();
        Product2 l2Prod = new Product2(Name = 'PLM-01256-02-SHELL');
        lstProduct.add(l2Prod);
        //insert l2Prod;
        
        Product2 l3Prod = new Product2(Name = 'M34-01026O000-0102');
        lstProduct.add(l3Prod);
        //insert l3Prod;
        
        insert lstProduct;
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
            Product2Id = l3Prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert pbe;
        
        pbe = [SELECT Id, Pricebook2.IsStandard FROM PricebookEntry];
        //It should return true
        System.assertEquals(true, pbe.Pricebook2.IsStandard);

        List<Quote> quoteList = new List<Quote>();
        Id offerRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
        RecordType nonSpareOfferRecordTypeId = [Select Id,Name From RecordType  Where SobjectType = 'Quote' and DeveloperName = 'Offer_Non_Spare'];
        for(Integer i=0; i<2; i++){
            Quote quote = new Quote(Name = 'tegaTest1'+i ,
                                    OpportunityId=oppt.Id,
                                    recordTypeId = offerRecordTypeId,
                                    Approval_Status__c = 'Price Accepted' ,
                                    Quotation_Date__c = Date.today(),
                                    Quotation_Validity__c = Date.today().adddays(20),
                                    Pricebook2Id =  Test.getStandardPricebookId(),
                                    Branch__c = br.Id,
                                    Branch__r = br,
                                    Port__c = port.Id,
                                    Sales_Org__c = sOrg.Id,
                                    BTP_Type__c = 'CIF',
                                    Payment_Months__c = 24,
                                    Offer_Generation_at__c = 'L3',
                                    CurrencyIsoCode = 'INR'
                                   );
            quoteList.add(quote);              
        }
        
        if(quoteList.size() > 0 ){
            insert quoteList; 
        }
           
        Item_Weight__c itemWeight = new Item_Weight__c(Net_Weight__c = 500, Product_L3__c = l3Prod.Id);
        insert itemWeight;   
        
        Sales_Organization_Product__c sorgProduct = new Sales_Organization_Product__c(Product__c = l3Prod.Id,
                                                                                      Price__c = 500,
                                                                                      Sales_Org__c = sOrg.Id
                                                                                     );
        
        Part_List__c prt = new Part_List__c(Name = 'Test1993', Customer__c = testAcct.Id);
        insert prt;
        
        List<L2_L3_product__c> lstL2L3Product = new List<L2_L3_product__c>();
        L2_L3_product__c l2l3Pro = new L2_L3_product__c(Part_List__c = prt.Id, 
                                                        Product_L2__c= l2Prod.Id,
                                                        Product_L3__c = l3Prod.Id
                                                       );
        lstL2L3Product.add(l2l3Pro);
        //insert l2l3Pro;                                          
        
        Derived_SO_Price_Factor__c df = new Derived_SO_Price_Factor__c(SO_Price_Factor__c = 1, Part_List__c = prt.Id);
        insert df;
        
        SAP_Last_Sale_Price__c sapLastSales = new SAP_Last_Sale_Price__c(Product_L3__c = l3Prod.Id);
        insert sapLastSales;
        
        Sales_Org_Last_SAP_SO__c salesOrglastsapPrice = new Sales_Org_Last_SAP_SO__c(
            SAP_Last_Sale__c = sapLastSales.Id,
            Last_Sales_Price__c = 200,
            Sales_Org__c = sOrg.Id,
            Last_Sales_Date__c = Date.today().addDays(-50)
        );
        insert salesOrglastsapPrice;
        
        Fixed_Contract_Price__c fixedPrice = new Fixed_Contract_Price__c(Product__c = l3Prod.Id, 
                                                                         Price__c  = 4000,
                                                                         Part_List__c = prt.Id);
        insert fixedPrice;
        
        // CurrencyType currenc = [SELECT ID, ConversionRate, IsoCode, IsActive from CurrencyType LIMIT 1 ];     
        L2_L3_product__c l2_l3_product = new L2_L3_product__c(
            CurrencyIsoCode = 'USD',
            Product_L2__c = l2Prod.Id,
            Product_L3__c = l3Prod.Id,
            Part_List__c = prt.Id,
            Quantity__c = 12.0);
        lstL2L3Product.add(l2_l3_product);
        //insert l2_l3_product;
        insert lstL2L3Product;
        Map<String, Integer> productQuantity = new Map<String, Integer>();
        productQuantity.put(l3Prod.id,20);
        Map<String, Object> btpMap = new Map<String, Object>();
        Map<Id, Decimal> cotainer20FtMap = new Map<Id, Decimal>(); 
        Map<Id, Item_Weight__c> weightMap = new Map<Id, Item_Weight__c>();
        Map<Id, Sales_Organization_Product__c> productMap = new Map<Id, Sales_Organization_Product__c>();  
        Map<String,Double> currencyMap = new Map<String,Double>();
        Map<String,Double> conversion_rates = new Map<String,Double>();
        
        Map<Id, Quote> offerMap = new Map<Id, Quote>();
        
        offerMap.put(quoteList[0].Id, quoteList[0]);
        productMap.put(sorgProduct.Product__c, sorgProduct);
        cotainer20FtMap.put(port.Id, 2000);
        weightMap.put(itemWeight.Product_L3__c, itemWeight);
        currencyMap.put('INR', 12);
        currencyMap.put(UserInfo.getDefaultCurrency(), 12);
        
        btpMap.put('offerMap', offerMap);
        btpMap.put('productMap', productMap);
        btpMap.put('cotainer20FtMap', cotainer20FtMap);
        btpMap.put('weightMap', weightMap);
        btpMap.put('currencyMap',currencyMap);
             
        Sales_Org_Currency_Mapping__mdt salesOrgCurr = Sales_Org_Currency_Mapping__mdt.getInstance(offerMap.get(quoteList[0].id).Sales_Org__r.Name);
        List<CurrencyType> currenc = [SELECT ConversionRate, IsoCode, IsActive FROM CurrencyType LIMIT 1];
        for(CurrencyType ct : currenc){
            conversion_rates.put(ct.IsoCode, ct.ConversionRate);
        }
        system.debug('conversion_rates'+conversion_rates);
        
        List<CreateOfferLineController.offerLine> oferLienList = new List<CreateOfferLineController.offerLine>();
        CreateOfferLineController.offerLine oferLienStr = new CreateOfferLineController.offerLine();
        oferLienStr.discount = 10;
        oferLienStr.margin = 10;
        oferLienStr.salesPrice = 1000;
        oferLienStr.btpPrice = 20000;
        oferLienStr.l3ProductId = l3Prod.Id;
        oferLienStr.l2ProductId  = l2Prod.Id;
        oferLienStr.customQuantity = 12;
        oferLienStr.quantityL2Wise ='';
        oferLienStr.isFG = true;
        oferLienStr.RMCCost = 20;
        oferLienStr.branchRateOfInterest = 20;
        oferLienStr.offerpayment= 20;
        oferLienStr.branchHedging= 20;
        oferLienStr.costPackingForwarding= 20;
        oferLienStr.CostFreight= 20;
        oferLienStr.costInsurance= 20;
        oferLienStr.costInterest= 20;
        oferLienStr.costHedging= 20;
        oferLienStr.exchangeRate= 20;
        oferLienStr.basicPrice= 20;
        oferLienStr.OriginalBTP=20;
        
        CreateOfferLineController.offerLine oferLienStr1 = new CreateOfferLineController.offerLine();
        oferLienStr1.discount = 10;
        oferLienStr1.margin = 10;
        oferLienStr1.salesPrice = 1000;
        oferLienStr1.btpPrice = 20000;
        oferLienStr1.l3ProductId = l3Prod.Id;
        oferLienStr1.l2ProductId  = l2Prod.Id;
        oferLienStr1.customQuantity = 12;
        oferLienStr1.quantityL2Wise ='Test-10';
        oferLienStr1.isFG = true;
        oferLienStr1.RMCCost = 20;
        oferLienStr1.branchRateOfInterest = 20;
        oferLienStr1.offerpayment= 20;
        oferLienStr1.branchHedging= 20;
        oferLienStr1.costPackingForwarding= 20;
        oferLienStr1.CostFreight= 20;
        oferLienStr1.costInsurance= 20;
        oferLienStr1.costInterest= 20;
        oferLienStr1.costHedging= 20;
        oferLienStr1.exchangeRate= 20;
        oferLienStr1.basicPrice= 20;
        oferLienStr1.OriginalBTP=20;
        
        oferLienList.add(oferLienStr);
        oferLienList.add(oferLienStr1);
        String recordStr = JSON.serialize(oferLienList);
        Map<Id, Decimal > l2l3Map = new Map<Id, Decimal >();
        String l2l3MapStr = JSON.serialize(l2l3Map);
        
        system.debug(' quoteList[0].Id'+ quoteList[0].Id);
        system.debug(' l3Prod.Id'+ l3Prod.Id);
        system.debug(' lbtpMap'+ btpMap);
        Decimal BtpValue = currenc[0].ConversionRate * 12;
        system.debug('BtpValue'+BtpValue);
        
        CreateOfferLineController.headersWrap testheadersWrap= new CreateOfferLineController.headersWrap();
        testheadersWrap.Name = 'Test';
        testheadersWrap.value = 10;
        testheadersWrap.isSelected =true;
        
        List<CreateOfferLineController.headersWrap> lstheadersWrap= new List<CreateOfferLineController.headersWrap>();
        lstheadersWrap.add(testheadersWrap);
        
        String testheadstr = JSON.serialize(lstheadersWrap);
        String testheader = '{"value":10,"Name":"Test","isSelected":true}';
        System.debug('json string '+testheadstr);
         
        CreateOfferLineController.searchPartList(quoteList[0].Id, 'Test1993','','','');
        // CreateOfferLineController.searchPartList(quoteList[0].Id, 'Test1993','Test','','');
        CreateOfferLineController.getBTPPrice(quoteList[0].Id, l3Prod.Id, 20,productQuantity, btpMap);
        CreateOfferLineController.saveOffer(quoteList[0].Id, 'INR', prt.id, recordStr, l2l3MapStr, btpMap, 0, sOrg.Id, false,testheadstr);
        CreateOfferLineController.calculateBTPPrice(quoteList[0].Id, l3Prod.Id, 20, btpMap,weightMap,20);
        quoteList[0].Part_List__c = prt.Id;
        update quoteList[0];
        CreateOfferLineController.getl2l3Products(quoteList[0].Id);
        System.assertEquals('Test1993', prt.Name);
        L1_L2_Offer_Line_Item__c l1l2OfferLineItem = new L1_L2_Offer_Line_Item__c(Offer__c = quoteList[0].Id);
        insert l1l2OfferLineItem;
        
        //  System.assertEquals('Test1993', prt.Name);
        //  System.assertEquals('Test1993', prt.Name);
        //	String lstteststr = 'Test_10';
        //   oferLienStr.quantityL2Wise =lstteststr;
        //   update oferLienStr;
           
        CreateOfferLineController.calculateInterest(123.90, 12.00, 6.00);
        
        // TegaUtility Class Test Coverage code
        Exception exception1 = new System.MathException();
        exception1.setMessage('my message');
        String testid = TegaUtility.trackLogs(exception1, 'CreateOfferLineController', 'searchPartList');
        QuoteLineItem     qutlineitemtest = new QuoteLineItem();
        qutlineitemtest.QuoteId= quoteList[0].id;
        qutlineitemtest.Quantity = 3.00;
        qutlineitemtest.UnitPrice = 12;
        qutlineitemtest.PricebookEntryId =pbe.id;
        qutlineitemtest.L2_L3_Product__c = l2_l3_product.id;
        insert qutlineitemtest;
        
        TegaUtility.createL1L2OfferLine(quoteList[0].id, 10, prt.id, testheadstr);
        TegaUtility.createL1L2OfferLine('', 10, prt.id, testheadstr);
        TegaUtility.headersWrap testtegaheadersWrap= new TegaUtility.headersWrap();
        testtegaheadersWrap.Name = 'Test';
        testtegaheadersWrap.value = 10;
        testtegaheadersWrap.isSelected =true;
        
        // test coverage for ProdUpdateCheck
        String teststr = ProdUpdateCheck.productUpdate();
        
        /* THIS IS THE OLD TEST CLASS CODE */
        // Decimal noOfmonth;
        // Decimal pAmount;
        //  Decimal incrementPercent = 6.00;
        
        
        /*  Account testAcct = new Account (Name = 'My Test Account');
insert testAcct;

Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = UserInfo.getUserId());
insert salesReg;

Branch__c br = new Branch__c(Name = 'Bokaro', Branch_Code__c = 'BKR',
Sales_Region__c = salesReg.Id,
Mark_Up__c = 1.5,
Rate_PckFwd__c = 1.5,
CIF_Factor__c = 1.5,
Rate_Freight__c= 1.5,
Rate_Insurance__c = 1.5,
Rate_Interest__c = 1.5,
Rate_Hedging__c = 1.5);
insert br;
Sales_Org__c sOrginsert = new Sales_Org__c(Name = 'TGSO', company_code__c= 'TG01', CurrencyIsoCode = 'INR');
insert sOrginsert;

Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = testAcct.Id, Branch__c = br.Id, Sales_Organizations__c = sOrginsert.id	 );
insert custSalesOrg1;

testAcct.Status__c = 'Sync with SAP';
update testAcct;

Opportunity oppt = new Opportunity(Name ='tega',
AccountID = testAcct.ID,
StageName = 'Customer Won',
Amount = 3000,
CloseDate = System.today(),
PriceBook2Id = Test.getStandardPricebookId(),
CurrencyIsoCode ='INR',
Customer_Branch_Assignment__c = custSalesOrg1.Id
);

insert oppt;


Port_of_Destination__c port = new Port_of_Destination__c(Name ='Kolkata' , Port_Code__c = '001');
insert port;


Freight__c freight = new Freight__c(Port_Code__c = port.Id, Container_Rate_20Ft__c = 200, Container_Rate_40Ft__c =200);
insert freight;


List<Quote> quoteList = new List<Quote>();
Id offerRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
for(Integer i=0; i<2; i++){
Quote quote = new Quote(Name = 'tegaTest1'+i ,
OpportunityId=oppt.Id,
recordTypeId = offerRecordTypeId,
Approval_Status__c = 'Price Accepted' ,
Quotation_Date__c = Date.today(),
Quotation_Validity__c = Date.today().adddays(20),
Pricebook2Id =  Test.getStandardPricebookId(),
Branch__c = br.Id,
Port__c = port.Id,
Sales_Org__c = sOrginsert.Id,
BTP_Type__c = 'CIF',
Payment_Months__c = 12,
CurrencyIsoCode = 'INR'                  
);
quoteList.add(quote);              
}
system.debug('quoteList sorgid '+quoteList[0].Sales_Org__c+'offer name'+quoteList[0].Name);

if(quoteList.size() > 0 ){
insert quoteList; 
}
system.debug('quoteList'+quoteList);

Product2 l2Prod = new Product2(Name = 'PLM-01256-02-SHELL');
insert l2Prod;

Product2 l3Prod = new Product2(Name = 'M34-01026O000-0102');
insert l3Prod;

Item_Weight__c itemWeight = new Item_Weight__c(Net_Weight__c = 500, Product_L3__c = l3Prod.Id);
insert itemWeight;   

Sales_Organization_Product__c sorgProduct = new Sales_Organization_Product__c(Product__c = l3Prod.Id,
Price__c = 500,
Sales_Org__c = sOrginsert.Id
);
insert sorgProduct;

Part_List__c prt = new Part_List__c(Name = 'Test1993', Customer__c = testAcct.Id, CurrencyIsoCode ='USD');
insert prt;

L2_L3_product__c l2l3Pro = new L2_L3_product__c(Part_List__c = prt.Id, 
Product_L2__c= l2Prod.Id,
Product_L3__c = l3Prod.Id
);
insert l2l3Pro;                                          

Derived_SO_Price_Factor__c df = new Derived_SO_Price_Factor__c(SO_Price_Factor__c = 1, Part_List__c = prt.Id);
insert df;

SAP_Last_Sale_Price__c sapLastSales = new SAP_Last_Sale_Price__c(Product_L3__c = l3Prod.Id);
insert sapLastSales;

Sales_Org_Last_SAP_SO__c salesOrglastsapPrice = new Sales_Org_Last_SAP_SO__c(
SAP_Last_Sale__c = sapLastSales.Id,
Last_Sales_Price__c = 200,
Sales_Org__c = sOrginsert.Id,        
Last_Sales_Date__c = Date.today().addDays(-100)
);
insert salesOrglastsapPrice;
//  integer noOfmonth = integer.valueOf(salesOrglastsapPrice.Last_Sales_Date__c);
//   system.debug('Last_Sales_Date__c'+salesOrglastsapPrice.Last_Sales_Date__c);

/* Sales_org_last_sap_so__c salesorglastsapsocObj = new Sales_org_last_sap_so__c (
Sales_Org__c=sOrg.Id,
Last_Sales_Price__c = 100,
SAP_Last_Sale__c=sapLastSales.Id,
Last_Sales_Date__c = Date.today()

);
insert salesorglastsapsocObj;*/
        
        /*CurrencyType currenc = [SELECT ID, ConversionRate, IsoCode, IsActive from CurrencyType LIMIT 1 ];

Fixed_Contract_Price__c fixedPrice = new Fixed_Contract_Price__c(Product__c = l3Prod.Id, 
Price__c  = 4000,
Part_List__c = prt.Id);
insert fixedPrice;
Pricebookentry pricebookentryObj = new Pricebookentry (
UnitPrice = 1.1,
Pricebook2Id = Test.getStandardPricebookId(),
Product2Id =l2Prod.id
);
insert pricebookentryObj;


List<L1_L2_Offer_Line_Item__c> l1l2List = new List<L1_L2_Offer_Line_Item__c>();
for (Integer i=0; i<2; i++) {
L1_L2_Offer_Line_Item__c l1l2 = new L1_L2_Offer_Line_Item__c(Offer__c = quoteList[i].Id, 
Product_Description__c = 'ABC');
l1l2List.add(l1l2);
}

Map<String, Object> btpMap = new Map<String, Object>();
Map<Id, Decimal> cotainer20FtMap = new Map<Id, Decimal>(); 
Map<Id, Item_Weight__c> weightMap = new Map<Id, Item_Weight__c>();
Map<Id, Sales_Organization_Product__c> productMap = new Map<Id, Sales_Organization_Product__c>();  
Map<String,Double> currencyMap = new Map<String,Double>();
Map<Id, Quote> offerMap = new Map<Id, Quote>();

offerMap.put(quoteList[0].Id, quoteList[0]);
productMap.put(sorgProduct.Product__c, sorgProduct);
cotainer20FtMap.put(port.Id, 2000);
weightMap.put(itemWeight.Product_L3__c, itemWeight);
currencyMap.put('INR', 12);
currencyMap.put(UserInfo.getDefaultCurrency(), 12);

btpMap.put('offerMap', offerMap);
btpMap.put('productMap', productMap);
btpMap.put('cotainer20FtMap', cotainer20FtMap);
btpMap.put('weightMap', weightMap);
btpMap.put('currencyMap',currencyMap);

List<CreateOfferLineController.offerLine> oferLienList = new List<CreateOfferLineController.offerLine>();
CreateOfferLineController.offerLine oferLienStr = new CreateOfferLineController.offerLine();
oferLienStr.discount = 10;
oferLienStr.margin = 10;
oferLienStr.salesPrice = 1000;
oferLienStr.btpPrice = 20000;
oferLienStr.l3ProductId = l3Prod.Id;
oferLienStr.l2ProductId  = l2Prod.Id;
oferLienStr.customQuantity = 12;

oferLienList.add(oferLienStr);
String recordStr = JSON.serialize(oferLienList);
Map<Id, Decimal > l2l3Map = new Map<Id, Decimal >();
String l2l3MapStr = JSON.serialize(l2l3Map);


CreateOfferLineController.searchPartList(quoteList[0].Id, 'Test1993', '');
CreateOfferLineController.saveOffer(quoteList[0].Id, 'INR', prt.id, recordStr, l2l3MapStr, btpMap, 0, sOrginsert.Id, false);
CreateOfferLineController.getBTPPrice(quoteList[0].Id, l3Prod.Id, 20, btpMap);
CreateOfferLineController.calculateBTPPrice(quoteList[0].Id, l3Prod.Id, 20, btpMap);

quoteList[0].Part_List__c = prt.Id;
update quoteList[0];
CreateOfferLineController.getl2l3Products(quoteList[0].Id);
System.assertEquals('Test1993', prt.Name);

CreateOfferLineController.calculateInterest(123.90, 12.00, 6.00);
*/       
    }
    
}