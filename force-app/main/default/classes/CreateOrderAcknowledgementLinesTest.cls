/*
Name : CreateOrderAcknowledgementLinesTest
Desc :  this is test class cover this CreateOrderAcknowledgementLines class.
author : Pavan
*/

@isTest(SeeAllData=false)
public class CreateOrderAcknowledgementLinesTest {
    
    @isTest
    public static void testgetLineItems(){
        
        Account testAcct = new Account (Name = 'My Test Account');
        insert testAcct;
        testAcct.Status__c = 'Sync with SAP';
        update testAcct;
        
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
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = testAcct.Id,CreatedFromAccount__c =true, Branch__c = br.Id, sales_Organizations__c = sOrg.Id);
        insert custSalesOrg1;
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        Opportunity parentOpp = new Opportunity(Name ='tega',
                                                AccountID = testAcct.ID,
                                                StageName = 'Customer Won',
                                                Amount = 3000,
                                                CloseDate = System.today(),                                        
                                                Customer_Branch_Assignment__c = custSalesOrg1.Id,
                                                PriceBook2Id = Test.getStandardPricebookId());
        lstOpp.add(parentOpp);
        Opportunity oppt = new Opportunity(Name ='tega',
                                           AccountID = testAcct.ID,
                                           StageName = 'Customer Won',
                                           Amount = 3000,
                                           CloseDate = System.today(),
                                           PriceBook2Id = Test.getStandardPricebookId(),
                                           Parent_Opportunity__c = parentOpp.Id,
                                           Customer_Branch_Assignment__c = custSalesOrg1.Id
                                          );
        lstOpp.add(oppt);
        insert lstOpp;
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
                                    
                                    Payment_Months__c = 12,
                                    CurrencyIsoCode = 'USD',
                                    Offer_Generation_at__c = 'L2'
                                   );
            quoteList.add(quote);              
        }
        
        if(quoteList.size() > 0 ){
            insert quoteList; 
        }
        
        X4E_4D__c test4e4d = new X4E_4D__c(SF_Offer__c = quoteList[0].Id, Category__c = 'ASO', CurrencyIsoCode ='INR');
        insert test4e4d;
        
        Order_Acknowledgement__c oAck = new Order_Acknowledgement__c(Name = 'Test OA',X4E_4D__c = test4e4d.Id);
        insert oAck;
        
        X4E_4D_Line_Item__c test4e4dlineItem = new X4E_4D_Line_Item__c(X4E_4D__c =test4e4d.id,description__c ='This is the existing lines');
        insert test4e4dlineItem;
        
        List<CreateOrderAcknowledgementLines.OALine> listtestoALines = new List<CreateOrderAcknowledgementLines.OALine>();
        CreateOrderAcknowledgementLines.OALine testoALines = new  CreateOrderAcknowledgementLines.OALine();
        testoALines.description='Test Line Item';
        testoALines.lineId=test4e4dlineItem.id;
        listtestoALines.add(testoALines);
        
        Test.startTest();
        CreateOrderAcknowledgementLines.getLineItems(oAck.id);
        CreateOrderAcknowledgementLines.saveLines(listtestoALines, oAck.id);       
        Test.stopTest();
        
        List<Order_Acknowledgement_Line_Item__c> oALineList =[select id,Order_Acknowledgement__c,Name,X4E_4D_Line_Item__c from Order_Acknowledgement_Line_Item__c where X4E_4D_Line_Item__c = :test4e4dlineItem.Id];
        System.assertEquals('Test Line Item',oALineList[0].Name);
        System.assertEquals(oAck.Id,oALineList[0].Order_Acknowledgement__c);
        System.assertEquals(test4e4dlineItem.Id,oALineList[0].X4E_4D_Line_Item__c);
    }
    
}