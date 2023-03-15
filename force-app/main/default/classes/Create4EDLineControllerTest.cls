/*
Name : Create4EDLineController_Test
Desc : This is test class to cover the Create4EDLineController class.
*/

@isTest(SeeAllData=false)
public class Create4EDLineControllerTest {
    public static testMethod void unit1(){
        
        
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
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(CreatedFromAccount__c = true,Customer__c = testAcct.Id, Branch__c = br.Id, sales_Organizations__c = sOrg.Id);
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
        
        list<Product2> lstprod = new list<Product2>();
        Product2 l2Prod = new Product2(Name = 'PLM-01256-02-SHELL');
        lstprod.add(l2Prod);
        
        Product2 l3Prod = new Product2(Name = 'M34-01026O000-0102');
        lstprod.add(l3Prod);
        
        insert lstprod;
        
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
        Id productRecordTypeId = TegaUtilityWithoutSharing.getProductRecordTypeId('Product_L3');
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
                                    Payment_Months__c = 12,
                                    CurrencyIsoCode = 'INR',
                                    Offer_Generation_at__c = 'L2'
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
            Sales_Org__c = sOrg.Id,
            Last_Sales_Date__c = Date.today().addDays(-50)
        );
        insert salesOrglastsapPrice;
        
        Fixed_Contract_Price__c fixedPrice = new Fixed_Contract_Price__c(Product__c = l3Prod.Id, 
                                                                         Price__c  = 4000,
                                                                         Part_List__c = prt.Id);
        insert fixedPrice;
        
        CurrencyType currenc = [SELECT ID, ConversionRate, IsoCode, IsActive from CurrencyType LIMIT 1 ];
        
        
        
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
        
        
        QuoteLineItem qutlineitemtest = new QuoteLineItem ();
        qutlineitemtest = new QuoteLineItem(QuoteId = quoteList[0].id ,
                                            Discount = 0.0,
                                            BTP_Price__c = 78.31,
                                            Margin__c = 0.0, Product2Id =l3Prod.id, Quantity = 3.00, UnitPrice = 12, PricebookEntryId = pbe.ID);
        insert qutlineitemtest; 
        
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
        
        system.debug(' quoteList[0].Id'+ quoteList[0].Id);
        system.debug(' l3Prod.Id'+ l3Prod.Id);
        system.debug(' lbtpMap'+ btpMap);
        
        // CreateOfferLineController.searchPartList(quoteList[0].Id, 'Test1993','');
        // CreateOfferLineController.getBTPPrice(quoteList[0].Id, l3Prod.Id, 20, btpMap);
        // CreateOfferLineController.saveOffer(quoteList[0].Id, 'INR', prt.id, recordStr, l2l3MapStr, btpMap, 0, sOrg.Id, false);
        
        quoteList[0].Part_List__c = prt.Id;
        update quoteList[0];
        // CreateOfferLineController.getl2l3Products(quoteList[0].Id);
        System.assertEquals('Test1993', prt.Name);
        
        L1_L2_Offer_Line_Item__c l1l2OfferLineItem = new L1_L2_Offer_Line_Item__c(Offer__c = quoteList[0].Id);
        insert l1l2OfferLineItem;
        
        L1_L2_Offer_Line_Item__c testLineItem = new L1_L2_Offer_Line_Item__c();
        testLineItem.Offer__c =quoteList[0].Id;
        testLineItem.Product_Description__c = 'test';
        testLineItem.RecordTypeId = TegaUtilityWithoutSharing.getL1L2RecordTypeId('L2');
        insert testLineItem;
        
        X4E_4D__c test4e4d = new X4E_4D__c(SF_Offer__c = quoteList[0].Id, Category__c = 'ASO', CurrencyIsoCode ='INR');
        insert test4e4d;
        
        Create4EDLineController.getLineItems(test4e4d.Id);
        
        quoteList[0].Offer_Generation_at__c = 'L3';
        update quoteList;
        
        X4E_4D_Line_Item__c test4e4dlineItem = new X4E_4D_Line_Item__c(X4E_4D__c =test4e4d.id,description__c ='This is the existing lines');
        insert test4e4dlineItem;
        Create4EDLineController.getLineItems(test4e4d.Id);
        
        
        
        X4E_4D__c test4e4d2 = new X4E_4D__c(SF_Offer__c = quoteList[0].Id, Category__c = 'ASO',CurrencyIsoCode ='INR');
        insert test4e4d2;
        // Create4EDLineController.getLineItems(test4e4d2.Id);
        
        List<Create4EDLineController.OfferLine> ofList = new List<Create4EDLineController.OfferLine>(); 
        ofList = Create4EDLineController.getLineItems(test4e4d.Id);
        
        Create4EDLineController.saveLines(ofList, test4e4d.Id);
        
        quoteList[0].recordTypeId = nonSpareOfferRecordTypeId.Id;
        update quoteList;
        
        RecordType millRecType = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = testAcct.Id, RecordTypeId = millRecType.Id);
        insert millCustEquip;
        Proposal_Form__c prf = new Proposal_Form__c(Opportunity__c = oppt.Id,Customer_Equipment__c = millCustEquip.Id);
        insert prf;
        Scope_With_Selection__c SWS = new Scope_With_Selection__c(Proposal_Form__c = prf.Id, Name = 'SWS', Offer__c = quoteList[0].Id);
        insert SWS;
        
        X4E_4D__c test4e4d3 = new X4E_4D__c(SF_Offer__c = quoteList[0].Id, Category__c = 'ASO');
        insert test4e4d3;
        Create4EDLineController.getLineItems(test4e4d3.Id);
        
        Order_Acknowledgement__c oAck = new Order_Acknowledgement__c(Name = 'Test OA',X4E_4D__c = test4e4d.Id);
        insert oAck;
        
        List<CreateOrderAcknowledgementLines.OALine> oaList = new List<CreateOrderAcknowledgementLines.OALine>(); 
        oaList = CreateOrderAcknowledgementLines.getLineItems(oAck.Id);
        
        CreateOrderAcknowledgementLines.saveLines(oaList, oAck.Id);
    }
    
}