/*
Name : CreateInvoiceTest
Desc : Test class for CreateInvoice
Author : Pavan
*/
@isTest(SeeAllData=false)
public class CreateInvoiceTest {
    
    @isTest
    public static void test1(){
        
        Sales_Org__c salesOrg1 = new Sales_Org__c(Name='TSSO');
        insert salesOrg1;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Integration_Transaction__c It = new Integration_Transaction__c();
        it.Record_Id__c = acc.id;
        it.Status__c = 'Draft';
        //  it.operation__c = 'Create Customer';
        it.Request__c = 'Create Customer:0Q0Bl0000000IJVKA2';
        it.Response__c = 'this is customer code : cn065';
        insert it;
        
        Invoice__c invoice = new Invoice__c();
        invoice.SAP_Invoice_Number__c = '12';
        insert invoice;
        
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
        
        Product2     product21 = new Product2(
            Name = 'PLM-03960-02-FEH',
            ProductCode = 'PLM-03960-02-FEH',
            Description = 'FEH-BALL DIA- 2400 X 4300 MM EGL',
            IsActive = true,
            CurrencyIsoCode = 'USD',
            Product_Level__c = 'L3',
            Quantity__c = 1.0);
        insert product21;
        
        test.startTest();
        Test.setMock(WebServiceMock.class, new CreateInvoiceTestMock());
        CreateInvoice.createInvoiceFromSAP('1234', it.Id);
        test.stopTest();
        
        //    Error_Log__c errorLog= [select id , Class_Name__c,Line_Number__c,Method_Name__c,Error_Message__c from Error_Log__c where Class_Name__c = 'CreateInvoice'];
        //   system.debug('errolo log error message '+errorLog.Error_Message__c +'no '+errorLog.Line_Number__c);
        //  Integration_Transaction__c It1 = [select id,Status__c,];
    }
    
}