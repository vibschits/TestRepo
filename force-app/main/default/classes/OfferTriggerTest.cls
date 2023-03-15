@isTest
public class OfferTriggerTest {
    private static testMethod void unit1(){
        Account acc = new Account (Name = 'My Test Account');
        insert acc;
        
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = UserInfo.getUserId());
        insert salesReg;
        
        Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id, Branch_Code__c = 'TBR');
        insert branch;
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c(
            Customer__c = acc.Id,
            Branch__c = branch.Id , CreatedFromAccount__c = true
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
        RecordType MillRecType = [Select Id,Name From RecordType  Where SobjectType = 'Opportunity' and DeveloperName = 'Mill'];
        
        
        Opportunity ChildOppMill = new Opportunity(Name = 'Test Child Opp Mill',
                                                   AccountId = acc.Id,
                                                   Customer_Branch_Assignment__c = custSalesOrg1.Id,
                                                   RecordTypeId = MillRecType.Id ,
                                                   CurrencyIsoCode = 'USD',
                                                   CloseDate = Date.newInstance(2022, 12, 9),
                                                   StageName = 'Qualification'
                                                  );
        
        
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
        
        RecordType millequp = [Select Id,Name From RecordType  Where SobjectType = 'Customer_Equipments__c' and DeveloperName = 'Mill'];  

        
        Customer_Equipments__c millCustEquip = new Customer_Equipments__c(Customer__c = acc.Id, RecordTypeId = millequp.Id);
        insert millCustEquip;
        
        Proposal_Form__c oppEquip = new Proposal_Form__c(Opportunity__c =oppt.id ,Customer_Equipment__c = millCustEquip.Id ,Status__c='Closed', SAP_Offer_Number__c='123');
        
        insert oppEquip;
        
        Scope_With_Selection__c scope = new Scope_With_Selection__c(Name='test' , Proposal_Form__c=oppEquip.id);
        insert scope;
        
        
        Id recordTypeIdNonSpare = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();

        Quote offer = new Quote( Branch__c= branch.id ,SAP_Offer_Id__c='123', Name = 'test offer' ,OpportunityId =oppt.id ,RecordTypeId = recordTypeIdNonSpare,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 );
        insert offer;
        
        Quote offerTwo = new Quote( Name = 'test offer 2' ,OpportunityId =oppt.id ,SAP_Offer_Id__c='12345',RecordTypeId = recordTypeIdNonSpare,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 );
        insert offerTwo;
        
        Quote offerThree = new Quote( Name = 'test offer 3' ,OpportunityId =oppt.id ,SAP_Offer_Id__c='12453',RecordTypeId = recordTypeIdNonSpare,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 );
        insert offerThree;
        
        Quote offerFour = new Quote( Name = 'test offer 4',SAP_Offer_Id__c='12323' ,OpportunityId =oppt.id ,RecordTypeId = recordTypeId,  Opportunity_Equipments__c=oppEquip.id , Payment_Months__c =10 , BTP_Type__c= 'FOB' ,  Delivery_Schedule__c=30 );
        insert offerFour;
        
        
        offerThree.status='DF';
        offerTwo.status='HO';
        offer.status = 'LS';
        quote.status = 'LS'; 
        
      //  update quote;
        update offer;
        update offerThree;
        update offerTwo;
        //update offerFive;
        
        


        
        delete quote;
        
        undelete quote;
        
        test.startTest();
        Test.setMock(WebServiceMock.class, new OfferTriggerMockTest());
        test.stopTest();
    }
}