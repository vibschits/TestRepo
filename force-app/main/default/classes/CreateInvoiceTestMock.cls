/*
Name : CreateInvoiceTestMock
Desc : Mock Test class for CreateInvoice
Author : Pavan
*/

@isTest
global class CreateInvoiceTestMock implements WebServiceMock {
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
            
            InvoiceQAS_WSDL_v2.ZinvHdr iteminvoice = new InvoiceQAS_WSDL_v2.ZinvHdr();
            
            iteminvoice.InvNo = '12345';
            iteminvoice.InvoiceDate = '2021-12-1';
            iteminvoice.BillingType = 'test';
            iteminvoice.InvNetAmtDc = '1234';
            iteminvoice.DocCurrency = 'INR';
            iteminvoice.DocCurrency= 'INR';
            iteminvoice.ExchangeRate= '1234';
            iteminvoice.BasicPrice= '1234';
            iteminvoice.PackingChg= '1234';
            iteminvoice.ForwardingChg= '1234';
            iteminvoice.Discount= '12';
            iteminvoice.Freight='test';
            iteminvoice.Cgst= '12';
            iteminvoice.Sgst= '12';
            iteminvoice.Igst= '12';
            iteminvoice.TotalValue= '12';
            iteminvoice.DispatchMode='test';
            iteminvoice.PaymentTerms='test';
            iteminvoice.PayTermDesc='test';
            iteminvoice.VatNo= '12';
            iteminvoice.OriginalInvNo= '12';
            
            List<InvoiceQAS_WSDL_v2.ZinvHdr> invoiceList = new List<InvoiceQAS_WSDL_v2.ZinvHdr>();
            invoiceList.add(iteminvoice);
            
            InvoiceQAS_WSDL_v2.ZinvBank bank  = new InvoiceQAS_WSDL_v2.ZinvBank();
            
            bank.bankName = 'ICICI';
            bank.AccNo = '12345678';	
            bank.Beneficery = 'test';
            bank.swiftCode = '1234';
            bank.InvNo = '12345';
            List<InvoiceQAS_WSDL_v2.ZinvBank> bankItemList = new List<InvoiceQAS_WSDL_v2.ZinvBank>();
            bankItemList.add(bank);
            
            InvoiceQAS_WSDL_v2.ZinvItem testLineItem = new InvoiceQAS_WSDL_v2.ZinvItem();
            
            testLineItem.ItemNo = '1234';
            testLineItem.ItemDesc = 'test';
            testLineItem.ProductType= 'test';
            testLineItem.ProductGroup= 'test';
            testLineItem.ItemQty= '12';
            testLineItem.SoItemQty= '12';
            testLineItem.Uom= 'test';
            testLineItem.ItemValue= '1234';
            testLineItem.DrawingNo= 'test';
            testLineItem.SoNo= 'test';
            testLineItem.ItemCode= 'PLM-03960-02-FEH';
            List<InvoiceQAS_WSDL_v2.ZinvItem> invoiceLineItemList = new List<InvoiceQAS_WSDL_v2.ZinvItem>();
            invoiceLineItemList.add(testLineItem);
            
            InvoiceQAS_WSDL_v2.ZinvDelvItem lineitems = new InvoiceQAS_WSDL_v2.ZinvDelvItem();
            lineitems.DelvNo = '1234';
            lineitems.DelvDate = '2021-12-12';
            lineitems.ItemNo = '12';
            lineitems.ItemDesc= 'test';
            lineitems.ItemQty= '12';	
            lineitems.Uom = 'test';
            lineitems.Plant = 'test';
            lineitems.HlItemNo = '123';
            
            List<InvoiceQAS_WSDL_v2.ZinvDelvItem> delvItemList = new List<InvoiceQAS_WSDL_v2.ZinvDelvItem>();
            delvItemList.add(lineitems);
            
            InvoiceQAS_WSDL_v2.ZinvHdrLn headerFields = new InvoiceQAS_WSDL_v2.ZinvHdrLn();
            headerFields.item = invoiceList;
            InvoiceQAS_WSDL_v2.ZinvItemLn childFields = new InvoiceQAS_WSDL_v2.ZinvItemLn();
            childFields.item = invoiceLineItemList;
            InvoiceQAS_WSDL_v2.ZinvDelvItemLn deliteminvoiceeryFields = new InvoiceQAS_WSDL_v2.ZinvDelvItemLn();
            deliteminvoiceeryFields.item = delvItemList;
            InvoiceQAS_WSDL_v2.ZinvBankLn bankFields = new InvoiceQAS_WSDL_v2.ZinvBankLn();
            bankFields.item = bankItemList;
            
            InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element resp= new InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element();
            resp.ExBankInfo = bankFields;
            resp.ExDelvTab = deliteminvoiceeryFields;
            resp.ExHeader = headerFields;
            resp.ExItemTab = childFields;
            resp.ExMessage ='';
            InvoiceQAS_WSDL_v2.ZWS_INV_GET_DETAILS_V3 testv3= new InvoiceQAS_WSDL_v2.ZWS_INV_GET_DETAILS_V3();
            response.put('response_x',resp);
            
        }
    
}