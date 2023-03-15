/* 
Class : CreateOrdeLinesTest
Description : test Class for CreateOrdeLines
Author : Pavan
*/
@isTest(SeeAllData=false)
public class CreateOrdeLinesTest {
    
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
        
        SAPOrderWebServiceV2.ZitemVbapStr testZitemVbapStr = new SAPOrderWebServiceV2.ZitemVbapStr();
        testZitemVbapStr.Vbeln = 'test';
        testZitemVbapStr.Matnr = '1234';
        testZitemVbapStr.Netwr = '1234';
        testZitemVbapStr.Taxes= '1234';
        testZitemVbapStr.BasePrice= '1234';
        testZitemVbapStr.Discount= '1234';
        testZitemVbapStr.Freight= '1234';
        testZitemVbapStr.PackingFrwd= '1234';
        testZitemVbapStr.Kwmeng= '1234';
        testZitemVbapStr.HlItem = '1234';
        List<SAPOrderWebServiceV2.ZitemVbapStr> lstZitemVbapStr = new List<SAPOrderWebServiceV2.ZitemVbapStr>();
        lstZitemVbapStr.add(testZitemVbapStr);
        
        SAPOrderWebServiceV2.ZtitemVbapTt testZtitemVbapTt = new SAPOrderWebServiceV2.ZtitemVbapTt();
        testZtitemVbapTt.item =lstZitemVbapStr;
        
        
        
        
        // Sales_Org__c salesOrg1 = [select id, Name from Sales_Org__c where Name='TSSO'];
        SAPOrderWebServiceV2.ZstrcSono testZstrcSono = new SAPOrderWebServiceV2.ZstrcSono();
        testZstrcSono.Vbeln = 'test';
        testZstrcSono.IncotermCity = 'test';
        testZstrcSono.Erdat = '2021-12-11';
        testZstrcSono.Ernam = 'test';
        testZstrcSono.Netwr = '12';
        testZstrcSono.DocCurr = 'INR';
        testZstrcSono.Spart = 'test';
        testZstrcSono.SalesOrg = 'TSSO';
        testZstrcSono.SalesOffice = 'test';
        testZstrcSono.SalesGrp = 'test';
        testZstrcSono.Zterm = 'test';
        testZstrcSono.Bstdk = '2021-12-11';
        testZstrcSono.NetwrLc = '1234';
        testZstrcSono.Bstkd = 'test';
        //  testZstrcSono.CurrencyIsoCode = localCurrency;
        testZstrcSono.SoldtoSf = acc.id;
        //odr.AccountId = '001Bl000003FXDFIA4';
        testZstrcSono.ShiptoSf = acc.id;    
        testZstrcSono.EndcustPo ='2021-12-11';
        testZstrcSono.EndcustPoDt = '2021-12-11';
        testZstrcSono.PtermDesc = 'test';
        SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element testElement = new SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element();
        testElement.GwHeader = testZstrcSono;
        testElement.GtItem= testZtitemVbapTt;
        testElement.ExMessage = '';
        
        //  test.startTest();
        Test.setMock(WebServiceMock.class, new CreateProductAndOfferLineTestMock());
        System.enqueueJob(new CreateOrderLines(ord,pricebook2,testElement,it,'INR'));
        //   System.enqueueJob(new OrderCreateController(ord.Name,it.id,'test'));
        // test.stopTest();
    }
    
    @isTest
    public static void test2(){
        
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
        
        Product2 testprod = new Product2();
        testprod.Name = 'test';
        testprod.ProductCode = '1234';
        insert testprod;
        
        //     PricebookEntry pb2 = new PricebookEntry(Product2id =testprod.Id,UnitPrice = 121, IsActive = true,PriceBook2Id = Test.getStandardPricebookId());
        //    insert pb2;
        
        SAPOrderWebServiceV2.ZitemVbapStr testZitemVbapStr = new SAPOrderWebServiceV2.ZitemVbapStr();
        testZitemVbapStr.Vbeln = 'test';
        testZitemVbapStr.Matnr = '1234';
        testZitemVbapStr.Netwr = '1234';
        testZitemVbapStr.Taxes= '1234';
        testZitemVbapStr.BasePrice= '1234';
        testZitemVbapStr.Discount= '1234';
        testZitemVbapStr.Freight= '1234';
        testZitemVbapStr.PackingFrwd= '1234';
        testZitemVbapStr.Kwmeng= '1234';
        testZitemVbapStr.HlItem = '000000';
        List<SAPOrderWebServiceV2.ZitemVbapStr> lstZitemVbapStr = new List<SAPOrderWebServiceV2.ZitemVbapStr>();
        lstZitemVbapStr.add(testZitemVbapStr);
        
        SAPOrderWebServiceV2.ZtitemVbapTt testZtitemVbapTt = new SAPOrderWebServiceV2.ZtitemVbapTt();
        testZtitemVbapTt.item =lstZitemVbapStr;
        
        
        
        
        // Sales_Org__c salesOrg1 = [select id, Name from Sales_Org__c where Name='TSSO'];
        SAPOrderWebServiceV2.ZstrcSono testZstrcSono = new SAPOrderWebServiceV2.ZstrcSono();
        testZstrcSono.Vbeln = 'test';
        testZstrcSono.IncotermCity = 'test';
        testZstrcSono.Erdat = '2021-12-11';
        testZstrcSono.Ernam = 'test';
        testZstrcSono.Netwr = '12';
        testZstrcSono.DocCurr = 'INR';
        testZstrcSono.Spart = 'test';
        testZstrcSono.SalesOrg = 'TSSO';
        testZstrcSono.SalesOffice = 'test';
        testZstrcSono.SalesGrp = 'test';
        testZstrcSono.Zterm = 'test';
        testZstrcSono.Bstdk = '2021-12-11';
        testZstrcSono.NetwrLc = '1234';
        testZstrcSono.Bstkd = 'test';
        //  testZstrcSono.CurrencyIsoCode = localCurrency;
        testZstrcSono.SoldtoSf = acc.id;
        //odr.AccountId = '001Bl000003FXDFIA4';
        testZstrcSono.ShiptoSf = acc.id;    
        testZstrcSono.EndcustPo ='2021-12-11';
        testZstrcSono.EndcustPoDt = '2021-12-11';
        testZstrcSono.PtermDesc = 'test';
        SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element testElement = new SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element();
        testElement.GwHeader = testZstrcSono;
        testElement.GtItem= testZtitemVbapTt;
        testElement.ExMessage = '';
        
        //  test.startTest();
        Test.setMock(WebServiceMock.class, new CreateProductAndOfferLineTestMock());
        System.enqueueJob(new CreateOrderLines(ord,pricebook2,testElement,it,'INR'));
        //   System.enqueueJob(new OrderCreateController(ord.Name,it.id,'test'));
        // test.stopTest();
    }
    
}