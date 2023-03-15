/* 
Class : OrderCreateControllerTestMock
Description : Mock test Class for OrderCreateController
Author : Pavan
*/

@isTest
global class OrderCreateControllerTestMock implements WebServiceMock {
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            
            Account acc = new Account(Name = 'Test Account1');
            insert acc;
            
            SAPOrderWebServiceV2.ZitemVbapStr testZitemVbapStr = new SAPOrderWebServiceV2.ZitemVbapStr();
            testZitemVbapStr.Vbeln = 'test';
            
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
            
            response.put('response_x',testElement);           
        }}