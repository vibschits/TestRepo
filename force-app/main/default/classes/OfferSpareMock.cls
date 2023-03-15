@isTest
global class OfferSpareMock implements WebServiceMock {
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
            OfferSpareWebServiceNew.ZrfcSpareOfferCreateResponse_element fakeResponse = new OfferSpareWebServiceNew.ZrfcSpareOfferCreateResponse_element();
            fakeResponse.SapOfferNo ='0020024108';
            Quote offer = [SELECT ID, QuoteNumber,Account.Name, Delivery_Date__c, Division__c,Enquiry_Number__c, Part_List__r.name,
                           Distribution_Channel__c, Sales_Document_Type__c, Email, Quotation_Validity__c, Quotation_Date__c, Account.Sales_Organization__c,
                           Opportunity.Customer_Branch_Assignment__r.Customer_Code__c,Opportunity.Account.Name,Sales_Org__c,Sales_Org__r.Name FROM QUOTE WHERE Name  ='Test Nikhil offer' LIMIT 1  ];
            
            OfferSpareWebServiceNew.ZrfcSpareOfferCreate_element quotesap = new OfferSpareWebServiceNew.ZrfcSpareOfferCreate_element();
            quotesap.Gmatnr = offer.Part_List__c;
            quotesap.PDistrChan = offer.Distribution_Channel__c;
            quotesap.PDivision = offer.Division__c; 
            quotesap.pDocType = 'ZQT';
            quotesap.PPurchNoC =offer.Enquiry_Number__c;
            quotesap.PQtValidF = String.valueof(offer.Quotation_Date__c);
            quotesap.PQtValidT =String.valueof(offer.Quotation_Validity__c);
            quotesap.PReqDateH =String.valueof(offer.Delivery_Date__c);
            quotesap.PSalesOff ='CND';
            quotesap.PSalesOrg = offer.Sales_Org__r.Name;
            quotesap.PSoldtoName = 'CN0094'; 
            quotesap.SfOfferNo ='00000023';
            
            
            OfferSpareWebServiceNew.TableOfZqtItemSf tableitems = new OfferSpareWebServiceNew.TableOfZqtItemSf();
            OfferSpareWebServiceNew.ZqtItemSf[] zqitemslist = new OfferSpareWebServiceNew.ZqtItemSf[]{};
                OfferSpareWebServiceNew.ZqtItemSf zqitem = new OfferSpareWebServiceNew.ZqtItemSf();
            zqitem.ItmNumber  ='PLM-03960-01 SAP2';
            zqitem.Material ='plm-01256-01';
            zqitem.ReqDate='2022-06-29';
            zqitem.ReqQty='2.0';
            zqitem.CondType='PR00';
            zqitem.CondRate='4121';
            zqitemslist.add(zqitem);
            
            tableitems.item = zqitemslist;
            fakeResponse.TItems =tableitems;
            
            
            OfferSpareWebServiceNew.TableOfZvbOfrmsg TableitemReturn = new OfferSpareWebServiceNew.TableOfZvbOfrmsg();
            OfferSpareWebServiceNew.ZvbOfrmsg[] msglist = new OfferSpareWebServiceNew.ZvbOfrmsg[]{};
                OfferSpareWebServiceNew.ZvbOfrmsg msg = new OfferSpareWebServiceNew.ZvbOfrmsg();
            msg.Type_x ='S';
            msg.Msgtxt ='VBAKKOM has been processed successfully';
            msglist.add(msg);
            TableitemReturn.item = msglist;
            fakeResponse.TReturn = TableitemReturn;
            
            
            response.put('response_x', fakeResponse);       
        }
    
}