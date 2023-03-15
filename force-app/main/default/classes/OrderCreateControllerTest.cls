/* 
Class : OrderCreateControllerTest
Description : test Class for OrderCreateController
Author : Pavan
*/
@isTest(SeeAllData=false)
public class OrderCreateControllerTest {
    
    @isTest
    public static void test1(){
        
        String operationType='Update SO-BOM';
        
        Sales_Org__c salesOrg1 = new Sales_Org__c(Name='TSSO');
        insert salesOrg1;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Integration_Transaction__c It = new Integration_Transaction__c();
        it.Record_Id__c = acc.id;
        it.Status__c = 'Draft';
        it.operation__c = 'Create Customer';
        it.Request__c = 'Create Customer:0Q0Bl0000000IJVKA2';
        it.Response__c = 'this is customer code : cn065';
        insert it;
        
        Pricebook2 pricebook2 = new Pricebook2(
            Name = 'Standard Price Book',
            CurrencyIsoCode = 'USD',
            IsActive = true);
        insert pricebook2;
        
        Order ord = new Order();
        ord.Name= 'test';
        ord.Pricebook2Id = pricebook2.id;
        ord.AccountId = acc.id;
        ord.EffectiveDate = date.newInstance(2022, 12, 10);
        ord.Status = 'Draft';
        insert ord;
        
        //  test.startTest();
        Test.setMock(WebServiceMock.class, new OrderCreateControllerTestMock());
        System.enqueueJob(new OrderCreateController(ord.Name,it.id,operationType));
        System.enqueueJob(new OrderCreateController(ord.Name,it.id,'test'));
        // test.stopTest();
    }
    
}