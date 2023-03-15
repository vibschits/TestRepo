@IsTest(SeeAllData=false)
public class CompileOfferControllerTest {

    private static testMethod void unit1(){

        Account testAcct = new Account (Name = 'My Test Account');
        insert testAcct;

        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = UserInfo.getUserId());
        insert salesReg;


        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id,Branch_Code__c = 'TBR');
        insert branch;

        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(Customer__c = testAcct.Id, Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert custSalesOrg1;

        testAcct.Status__c = 'Sync with SAP';
        update testAcct;

        Opportunity parentOpp = new Opportunity(Name ='tega',
        AccountID = testAcct.ID,
        StageName = 'Customer Won',
        Amount = 3000,
        CloseDate = System.today(),
        PriceBook2Id = Test.getStandardPricebookId(),
        Customer_Branch_Assignment__c = custSalesOrg1.Id
        );

        insert parentOpp;

        Opportunity oppt = new Opportunity(Name ='tega',
                            AccountID = testAcct.ID,
                            StageName = 'Customer Won',
                            Amount = 3000,
                            CloseDate = System.today(),
                            PriceBook2Id = Test.getStandardPricebookId(),
                            Parent_Opportunity__c = parentOpp.Id,
                            Customer_Branch_Assignment__c = custSalesOrg1.Id
                            );

        insert oppt;

        Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;

        List<Quote> quoteList = new List<Quote>();
        Id offerRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Combine');
        for(Integer i=0; i<2; i++){
            Quote quote = new Quote(Name = 'tegaTest1'+i ,
                            OpportunityId=oppt.Id,
                            recordTypeId = offerRecordTypeId,
                            Approval_Status__c = 'Price Accepted' ,
                            Quotation_Date__c = Date.today(),
                            Quotation_Validity__c = Date.today().adddays(20),
                            Branch__c = branch.Id, 
                            Sales_Org__c = sOrg.Id,
                            Pricebook2Id =  Test.getStandardPricebookId() );
            quoteList.add(quote);              
        }
        
        if(quoteList.size() > 0 ){
            insert quoteList; 
        }

        Product2 pr1 = new Product2(Name = 'product1');
        insert pr1;

        PriceBookEntry pre = new PriceBookEntry(
                                IsActive = true,
                                PriceBook2Id = Test.getStandardPricebookId(), 
                                Product2Id = pr1.Id , 
                                UnitPrice=123);
        insert pre;

        List<QuoteLineItem> lineList = new List<QuoteLineItem>();
        for (Integer i=0; i<2; i++) {
            QuoteLineItem qiItem = new  QuoteLineItem(QuoteId = quoteList[i].Id ,Product2Id=pr1.Id,
                                    PricebookEntryId=pre.Id, Quantity =1 , UnitPrice=123 );
            
            lineList.add(qiItem);
        }

        if(lineList.size() > 0){
            insert lineList;
        }
        
        List<L1_L2_Offer_Line_Item__c> l1l2List = new List<L1_L2_Offer_Line_Item__c>();
        for (Integer i=0; i<2; i++) {
            L1_L2_Offer_Line_Item__c l1l2 = new L1_L2_Offer_Line_Item__c(Offer__c = quoteList[i].Id, 
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

        CompileOfferController.getOffers(parentOpp.Id);
        CompileOfferController.compileOffer(IdsList);
    }
}