@isTest(SeeAllData=false)
public class FinalizeOfferControllerTest {
    static testmethod void FinalOfferControllerMethod(){
        Account acc = new Account (Name = 'My Test Account');
        insert acc;
        
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = UserInfo.getUserId());
        insert salesReg;
        
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'TBR');
        insert branch;
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(
            Customer__c = acc.Id,
            Branch__c = branch.Id,
            CreatedFromAccount__c =true
        );
        
        insert custSalesOrg1;
        
        acc.Status__c = 'Sync with SAP';
        update acc;
        
        Opportunity oppt = new Opportunity(Name ='tega',
                                           AccountID = acc.Id,
                                           StageName = 'Customer Won',
                                           Amount = 3000,
                                           CloseDate = System.today(),
                                           PriceBook2Id = Test.getStandardPricebookId(),
                                           Customer_Branch_Assignment__c = custSalesOrg1.Id
                                          );
        
        insert oppt;
        
        Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;
        
        system.assertEquals('TGSO', sOrg.Name);
        
        List<Quote> quoteList = new List<Quote>();
        Id offerRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
        Quote quote = new Quote(Name = 'tegaTest1' ,
                                OpportunityId=oppt.Id,
                                recordTypeId = offerRecordTypeId,
                                Approval_Status__c = 'Price Accepted' ,
                                Quotation_Date__c = Date.today(),
                                Quotation_Validity__c = Date.today().adddays(20),
                                Branch__c = branch.Id, 
                                Sales_Org__c = sOrg.Id,
                                Status = 'Draft',
                                Pricebook2Id =  Test.getStandardPricebookId() );
        
        insert quote;
        
        //FinalizeOfferController Finalofferins = new FinalizeOfferController();
        FinalizeOfferController.finalOffer(quote.id);
        FinalizeOfferController.customLabelItem();
        Quote testquote = [select id,name,status,Approval_Status__c from Quote where Name = 'tegaTest1' ];
        System.assertEquals('Finalized', testquote.status);
        System.assertEquals('Submitted', testquote.Approval_Status__c);
    }
}