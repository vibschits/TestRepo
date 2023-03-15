public class CreateCommercialInvoiceController {
    
    public List<Invoice__c> selInvLst;
    public Set<Id> selInvIdsSet = new Set<Id>();
    Id customerInvoice = null;
    Id consigneeInvoice = null;
    String gstNumber = '';
    String vatNumber = '';
    String currencyInv = '';
    public String commercialInvUrl{get;set;}
    public Boolean displayToast{get;set;}
    public Boolean isError{get;set;}
    public Boolean isSuccess{get;set;}
    String soNumbers = '';
    String invoiceNumbers = '';
    String invoiceDates = '';
    
    public CreateCommercialInvoiceController( ApexPages.StandardSetController cntlr ) {
        selInvLst = cntlr.getSelected();
        system.debug('selInvLst'+selInvLst);
        for(Invoice__c inv : selInvLst){
            selInvIdsSet.add(inv.Id);   
        }
        displayToast  = false;
        commercialInvUrl = '';
       // isError = false;
        system.debug('selInvIdsSet'+selInvIdsSet);
    }
            
    
    public void CreateCommercialRecord(){
        List<Invoice__c> invoiceList = [Select Id,CurrencyIsoCode,RecordTypeId,Customer__c,Consignee__c,GST_Number__c,VAT_Number__c,SAP_Invoice_Number__c,SAP_Invoice_Date__c,format(Invoice_Date__c)Invoice_Date__c from Invoice__c where Id IN: selInvIdsSet];
        system.debug('invoiceList'+invoiceList);
        RecordType expInvRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Invoice__c' AND DeveloperName = 'Export'];
        Id exportInvoiceRecTypeId = expInvRecType.Id;
        if(invoiceList != null && invoiceList.size() > 0 && invoiceList[0].Customer__c != null && invoiceList[0].Consignee__c != null && invoiceList[0].GST_Number__c != null && invoiceList[0].VAT_Number__c != null){
            customerInvoice = invoiceList[0].Customer__c;
            consigneeInvoice = invoiceList[0].Consignee__c;
            gstNumber = invoiceList[0].GST_Number__c;
            vatNumber = invoiceList[0].VAT_Number__c;
            currencyInv = invoiceList[0].CurrencyIsoCode;
        }else{
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'No Invoice Selected OR Customer, Consignee, GST Number, VAT Number are empty for one of the selected Invoices'));
        }
        
        for(Invoice__c inv : invoiceList){
            if(inv.Customer__c == customerInvoice && inv.Consignee__c == consigneeInvoice 
               && inv.GST_Number__c == gstNumber && inv.VAT_Number__c == vatNumber && inv.CurrencyIsoCode == currencyInv && inv.RecordTypeId == exportInvoiceRecTypeId){
				             invoiceNumbers = invoiceNumbers + inv.SAP_Invoice_Number__c + ' '+ ' '; 
                             invoiceDates = invoiceDates +  inv.Invoice_Date__c + ' '+ ' ';
                             
            }else{
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Customer, Consignee, GST Number, VAT Number are not same for all selected Invoices OR Selected Invoices are not of Export Type'));
            }
        }
        invoiceNumbers = invoiceNumbers.removeEnd(' ');
        invoiceNumbers = invoiceNumbers.removeEnd(' ');
        invoiceDates = invoiceDates.removeEnd(' ');
        invoiceDates = invoiceDates.removeEnd(' ');
        
        if(isError==null){
            List<Invoice_Line_Item__c> invoiceLineItemList = [SELECT Id, Name, CurrencyIsoCode, Invoice__c, Item_Number__c, 
                                                          Item_Code__c, Item_Description__c, Product_Type__c, Product_Group__c,Item_Value__c, 
                                                          Item_Quantity__c, SO_Item_Quantity__c, UOM__c, Drawing_Number__c,SO_Number__c
                                                          FROM Invoice_Line_Item__c 
                                                          WHERE Invoice__c =: selInvIdsSet];
        
            List<Invoice_Payment_Relationship__c> invoicePmtRelList = [SELECT Id, IsDeleted, Name, CurrencyIsoCode, Invoice__c, Payment_Doc_Number__c, Payment_Doc_Line__c 
                                                                   FROM Invoice_Payment_Relationship__c 
                                                                   WHERE Invoice__c =: selInvIdsSet];
        
            RecordType commercialInvRecType = [Select Id,SobjectType,DeveloperName from RecordType where SobjectType = 'Invoice__c' AND DeveloperName = 'Commercial'];
        	
            for(Invoice_Line_Item__c invLine : invoiceLineItemList){
                soNumbers = invLine.SO_Number__c + ',';
            }
            
            soNumbers = soNumbers.removeEnd(',');
            
            Invoice__c commercialInv = new Invoice__c(RecordTypeId = commercialInvRecType.Id, Customer__c = customerInvoice, Consignee__c = consigneeInvoice, 
                                                     GST_Number__c = gstNumber, VAT_Number__c = vatNumber, SO_Numbers__c = soNumbers, SAP_Invoice_Number__c = invoiceNumbers, SAP_Invoice_Date__c = invoiceDates);
            insert commercialInv;
        
            Map<String,Invoice_Line_Item__c> newInvLineItemMap = new Map<String,Invoice_Line_Item__c>();
            for(Invoice_Line_Item__c invLine : invoiceLineItemList){
                if(newInvLineItemMap.containsKey(invLine.Item_Code__c)){
                    Invoice_Line_Item__c invLineItem = newInvLineItemMap.get(invLine.Item_Code__c);
                    Decimal itemValue = invLineItem.Item_Value__c;
                    itemValue += invLine.Item_Value__c;
                    Decimal itemQty = invLineItem.Item_Quantity__c;
                    itemQty += invLine.Item_Quantity__c;
                    invLineItem.Item_Value__c = itemValue;
                    invLineItem.Item_Quantity__c = itemQty;
                    newInvLineItemMap.put(invLine.Item_Code__c,invLineItem);
                }else{
                    Invoice_Line_Item__c invLineItem = new Invoice_Line_Item__c();
                    invLineItem = invLine.clone(false, false, false, false);
                    invLineItem.Invoice__c = commercialInv.Id;
                    newInvLineItemMap.put(invLine.Item_Code__c,invLineItem);
                }
            }
            
            List<Invoice_Payment_Relationship__c> newInvPmtRelList = new List<Invoice_Payment_Relationship__c>();
            for(Invoice_Payment_Relationship__c invPmtRel : invoicePmtRelList){
                Invoice_Payment_Relationship__c invPmtRecord = new Invoice_Payment_Relationship__c();
                invPmtRecord = invPmtRel.clone(false, false, false, false);
                invPmtRecord.Invoice__c = commercialInv.Id;
                newInvPmtRelList.add(invPmtRecord);
            }
            
            insert newInvLineItemMap.values();
            insert newInvPmtRelList;
            displayToast = true;
            
            commercialInvUrl = commercialInv.Id;
            isSuccess = true;
            /*String returnUrl = '/'+commercialInvUrl;
            system.debug('returnUrl => '+returnUrl);
            
            
            PageReference pgReturnPage = new PageReference(returnUrl);
            pgReturnPage.setRedirect(true);
            system.debug('pgReturnPage => '+pgReturnPage);
            return pgReturnPage;*/
        }
    }   
}