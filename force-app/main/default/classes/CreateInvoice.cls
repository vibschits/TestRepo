/*
Name : CreateInvoice
Desc : This class used to call SOAP api and get Invocie data and create Invoice.
Author : 
*/
public class CreateInvoice {

	@future(callout = true)
    public static void createInvoiceFromSAP(String sapInvoiceId, String itId){
        Integration_Transaction__c it = new Integration_Transaction__c(Id = itId);
        try{
            //Making a connection
            String invoiceCurrency = '';
            RecordType expInvRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Invoice__c' AND DeveloperName = 'Export'];
            Id exportInvoiceRecTypeId = expInvRecType.Id;
            Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
            InvoiceQAS_WSDL_v2.ZWS_INV_GET_DETAILS_V3 zwInvoiceDetails = new InvoiceQAS_WSDL_v2.ZWS_INV_GET_DETAILS_V3();
            //Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + sapOrg.Password__c);
            Blob headerValue = Blob.valueOf('rfcuser1'+ ':' + 'Tega@1234');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            zwInvoiceDetails.inputHttpHeaders_x = new map<String,String>();
            zwInvoiceDetails.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            
            //Fetching Data from SAP
            InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element getDetailsResponse = new InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element();
            
            InvoiceQAS_WSDL_v2.ZinvHdrLn headerFields = new InvoiceQAS_WSDL_v2.ZinvHdrLn();
            InvoiceQAS_WSDL_v2.ZinvItemLn childFields = new InvoiceQAS_WSDL_v2.ZinvItemLn();
            InvoiceQAS_WSDL_v2.ZinvDelvItemLn deliveryFields = new InvoiceQAS_WSDL_v2.ZinvDelvItemLn();
            InvoiceQAS_WSDL_v2.ZinvBankLn bankFields = new InvoiceQAS_WSDL_v2.ZinvBankLn();
            
            List<InvoiceQAS_WSDL_v2.ZinvHdr> invoiceList = new List<InvoiceQAS_WSDL_v2.ZinvHdr>();
            List<InvoiceQAS_WSDL_v2.ZinvItem> invoiceLineItemList = new List<InvoiceQAS_WSDL_v2.ZinvItem>();
            List<InvoiceQAS_WSDL_v2.ZinvDelvItem> delvItemList = new List<InvoiceQAS_WSDL_v2.ZinvDelvItem>();
            List<InvoiceQAS_WSDL_v2.ZinvBank> bankItemList = new List<InvoiceQAS_WSDL_v2.ZinvBank>();
            
            
            getDetailsResponse = zwInvoiceDetails.ZinvGetDetailsV3('', sapInvoiceId, '');
            
            it.Response__c = String.valueOf(getDetailsResponse);
            
            headerFields = getDetailsResponse.ExHeader;
            childFields = getDetailsResponse.ExItemTab;
            deliveryFields = getDetailsResponse.ExDelvTab;
            bankFields = getDetailsResponse.ExBankInfo;
            
            //AK Changes 24/11/2022
            String exMessage = getDetailsResponse.ExMessage;
            
            if(exMessage != ''){
                it.Status__c = 'Fail';
                it.sync__c = false;
                it.Error__c = exMessage;
            }else{
                invoiceList = headerFields.item;
                invoiceLineItemList = childFields.item;
                delvItemList = deliveryFields.item;
                bankItemList = bankFields.item;
                
                system.debug('invoiceList==>'+invoiceList);
                system.debug('invoiceLineItemList==>'+invoiceLineItemList);
                system.debug('delvItemList==>'+delvItemList);
                system.debug('bankItemList==>'+bankItemList);
                
                Invoice__c existingInvoice = new Invoice__c();
                if(invoiceList.size() > 0 && invoiceList[0].OriginalInvNo != ''){
                    existingInvoice = [SELECT Id, Name, CurrencyIsoCode, SAP_Invoice_Number__c, 
                                       Invoice_Date__c, Billing_Type__c, Customer_Branch_Assignment__c, Customer__c, 
                                       Consignee__c, Investment_Net_Amount__c, Exchange_Rate__c, Basic_Price__c, 
                                       Packing_Charges__c, Forwarding_Charges__c, Discount__c, Freight__c, CGST__c, 
                                       SGST__c, IGST__c, Total_Value__c, Dispatch_Mode__c, Payment_Terms__c, 
                                       Payment_Terms_Desc__c, Tega_Bank_Ac_Code__c, GST_Number__c, VAT_Number__c, 
                                       Original_Invoice_Number__c, Commerical_Invoice__c, Cancel_Invoice__c, New_Invoice__c 
                                       FROM Invoice__c 
                                       WHERE SAP_Invoice_Number__c =: invoiceList[0].OriginalInvNo];
                }
                
                // AK 31/01/23 : Bank WSDL Changes
                Map<String,Wrapper> bankWrapperMap = new Map<String,Wrapper>();
                if(bankItemList != null && bankItemList.size() > 0){
                    for(InvoiceQAS_WSDL_v2.ZinvBank bank : bankItemList){
                        Wrapper wrp = new Wrapper();
                        wrp.bankName = bank.BankName;
                        wrp.accountNumber = bank.AccNo;
                        wrp.beneficiary = bank.Beneficery;
                        wrp.swiftCode = bank.SwiftCode;
                        bankWrapperMap.put(bank.InvNo,wrp);
                    }
                }
                
                
                Invoice__c invoice = new Invoice__c();
                for(InvoiceQAS_WSDL_v2.ZinvHdr iv : invoiceList){
                    	
                    	// AK 31/01/23 : Bank WSDL Changes
                    	if(bankItemList != null && bankItemList.size() > 0){
                            Wrapper wrp = bankWrapperMap.get(iv.InvNo);
                            invoice.Bank_Name__c = wrp.bankName;
                            invoice.Account_Number__c = wrp.accountNumber;	
                            invoice.Beneficiary__c = wrp.beneficiary;
                            invoice.Swift_Code__c = wrp.swiftCode;
                        }
                    
                        invoice.SAP_Invoice_Number__c = iv.InvNo;
                        invoice.Invoice_Date__c = Date.valueOf(iv.InvoiceDate);
                        invoice.Billing_Type__c = iv.BillingType;
                        invoice.Investment_Net_Amount__c = decimal.valueOf(iv.InvNetAmtDc);
                        invoice.CurrencyIsoCode = iv.DocCurrency;
                        invoiceCurrency = iv.DocCurrency;
                        invoice.Exchange_Rate__c = decimal.valueOf(iv.ExchangeRate);
                        invoice.Basic_Price__c = decimal.valueOf(iv.BasicPrice);
                        invoice.Packing_Charges__c = iv.PackingChg;
                        invoice.Forwarding_Charges__c = iv.ForwardingChg;
                        invoice.Discount__c = iv.Discount;
                        invoice.Freight__c = iv.Freight;
                        invoice.CGST__c = decimal.valueOf(iv.Cgst);
                        invoice.SGST__c = iv.Sgst;
                        invoice.IGST__c = iv.Igst;
                        invoice.Total_Value__c = decimal.valueOf(iv.TotalValue);
                        invoice.Dispatch_Mode__c = iv.DispatchMode;
                        invoice.Payment_Terms__c = iv.PaymentTerms;
                        invoice.Payment_Terms_Desc__c = iv.PayTermDesc;
                        //invoice.Tega_Bank_Ac_Code__c = decimal.valueOf(iv.TegaBankAcCode);
                        //invoice.GST_Number__c - iv.GstNo;
                        invoice.VAT_Number__c = iv.VatNo;
                        invoice.Original_Invoice_Number__c = iv.OriginalInvNo;
                    	invoice.RecordTypeId = exportInvoiceRecTypeId;
                        List<Customer_Sales_Organization__c> CSO = new List<Customer_Sales_Organization__c>();
                        if(iv.CustomerSf != null && iv.CustomerSf != ''){
                            //invoice.Customer__c = iv.CustomerSf;
                            CSO = [Select Id,Customer__c,Sales_Organizations__r.Name from Customer_Sales_Organization__c 
                                                              where Sales_Organizations__r.Name =: iv.SalesOrg AND Customer__c =: iv.CustomerSf];
                        }
                        if(iv.ConsigneeSf != null && iv.ConsigneeSF != ''){
                            //invoice.Consignee__c = iv.ConsigneeSf;
                        }
                        if(CSO != null && CSO.size()>0){
                            CSO[0].Distribution_Channel__c = iv.DistChannel;
                            CSO[0].Division__c = iv.Division + ';';
                            update CSO;
                        }
                        // Find existing Invoice and then Cancel that Invoice and Create clone of that Invoice with New Invoice Number
                        if(iv.OriginalInvNo != ''){
                            system.debug('Existing Invoice =>'+existingInvoice);
                            system.debug('Cloned Invoice =>'+invoice);
                            insert invoice;
                            existingInvoice.Cancel_Invoice__c = true;
                            existingInvoice.New_Invoice__c = invoice.Id;
                            update existingInvoice;
                        }else{
                            system.debug('New Invoice =>'+invoice);
                            insert invoice;
                    } 
                }
                
                Id invoiceId = invoice.Id;
                
                //AK 09/02/2022 Fixes
                Set<String> salesOrderNameSet = new Set<String>();
                Set<String> prodNameSet = new Set<String>();
                
                List<Invoice_Line_Item__c> listInvoiceLineItem = new List<Invoice_Line_Item__c>();
                
                for(InvoiceQAS_WSDL_v2.ZinvItem iv : invoiceLineItemList){
                    salesOrderNameSet.add(iv.SoNo);
                    prodNameSet.add(iv.ItemCode);
                }
                
                List<Order> salesOrderList = [Select Id,Name from Order WHERE Name IN: salesOrderNameSet];
                List<Product2> prodList = [Select Id,Name from Product2 WHERE Name IN: prodNameSet];
                
                Map<String,Id> salesOrderMap = new Map<String,Id>();
                for(Order ord : salesOrderList){
                    salesOrderMap.put(ord.Name,ord.Id);
                }
                
                Map<String,Id> prodMap = new Map<String,Id>();
                for(Product2 prod : prodList){
                    prodMap.put(prod.Name,prod.Id);
                }
                
                for(InvoiceQAS_WSDL_v2.ZinvItem iv : invoiceLineItemList){
                    system.debug('iv => '+iv);
                    Invoice_Line_Item__c tempIV = new Invoice_Line_Item__c();
                    tempIV.Invoice__c = invoiceId;
                    tempIV.Item_Number__c = decimal.valueOf(iv.ItemNo);
                    //tempIV.Item_Code__c = iv.ItemCode;
                    tempIV.Item_Description__c = iv.ItemDesc;
                    tempIV.Product_Type__c = iv.ProductType;
                    tempIV.Product_Group__c = iv.ProductGroup;
                    tempIV.Item_Quantity__c = decimal.valueOf(iv.ItemQty);
                    tempIV.SO_Item_Quantity__c = decimal.valueOf(iv.SoItemQty);
                    tempIV.UOM__c = iv.Uom;
                    tempIV.CurrencyIsoCode = invoiceCurrency;
                    tempIV.Item_Value__c = decimal.valueOf(iv.ItemValue);
                    tempIV.Drawing_Number__c = iv.DrawingNo;
                    tempIV.SO_Number__c	= salesOrderMap.get(iv.SoNo);
                    tempIV.Item_Code__c = prodMap.get(iv.ItemCode);
                    listInvoiceLineItem.add(tempIV);
                    system.debug('INVOICE Line Itme ==>'+tempIV);
                }
                
                insert listInvoiceLineItem;
                
                List<Invoice_Line_Item__c> invLineItemList = [Select Id,Item_Number__c,Invoice__c from Invoice_Line_Item__c WHERE Invoice__c =: invoiceId];
                Map<Decimal,Id> invLineItemMap = new Map<Decimal,Id>();
                for(Invoice_Line_Item__c invLineItem : invLineItemList){
                    invLineItemMap.put(invLineItem.Item_Number__c,invLineItem.Id);
                }
                
                List<Invoice_Line_Item__c> deliveryListInvoiceLineItem = new List<Invoice_Line_Item__c>();
                if(delvItemList != null && delvItemList.size()>0){
                    for(InvoiceQAS_WSDL_v2.ZinvDelvItem dv : delvItemList){
                        Invoice_Line_Item__c tempIV = new Invoice_Line_Item__c();
                        tempIV.Invoice__c = invoiceId;
                        tempIV.Delivery_Number__c = dv.DelvNo;
                        tempIV.Delivery_Date__c = Date.valueOf(dv.DelvDate);
                        tempIV.Item_Number__c = decimal.valueOf(dv.ItemNo);
                        //tempIV.Item_Code__c = dv.ItemCode;
                        tempIV.Item_Description__c = dv.ItemDesc;
                        tempIV.Item_Quantity__c = decimal.valueOf(dv.ItemQty);	
                        tempIV.UOM__c = dv.Uom;
                        tempIV.Plant__c = dv.Plant;
                        tempIV.CurrencyIsoCode = invoiceCurrency;
                        Id invLineItemId = invLineItemMap.get(decimal.valueOf(dv.HlItemNo));
                        system.debug('invLineItemId =>'+invLineItemId);
                        tempIV.Invoice_Line_Item__c = invLineItemId;
                        deliveryListInvoiceLineItem.add(tempIV);
                        system.debug('INVOICE Line Itme ==>'+tempIV);
                    }
                    
                    insert deliveryListInvoiceLineItem;
                }
                
                
                it.Status__c = 'Success';                
                it.sync__c = true;
                update it;
               
            }      
        }catch(Exception ex){
            it.Status__c = 'fail';
			it.Error__c = ex.getMessage()+ex.getLineNumber();
            update it;
            TegaUtility.trackLogs( ex,  'CreateInvoice',  'createInvoiceFromSAP');
        }
    }
    
    public class Wrapper{
        public String bankName;
        public String accountNumber;
        public String beneficiary;
        public String swiftCode;
	}
}