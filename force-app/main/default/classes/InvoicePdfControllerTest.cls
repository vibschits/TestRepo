@isTest(seealldata=false)
public class InvoicePdfControllerTest {
@isTest
    public static void test1(){
        Sales_Org__c salesOrg1 = new Sales_Org__c(Name='TSSO');
        insert salesOrg1;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Integration_Transaction__c It = new Integration_Transaction__c();
        it.Record_Id__c = acc.id;
        it.Status__c = 'Draft';
        it.Request__c = 'Create Customer:0Q0Bl0000000IJVKA2';
        it.Response__c = 'this is customer code : cn065';
        insert it;
        
        
        
        RecordType proInvRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Invoice__c' AND DeveloperName = 'Proforma'];
        Id proformaInvoiceRecTypeId = proInvRecType.Id;
        Invoice__c invoice = new Invoice__c();
        invoice.SAP_Invoice_Number__c = '12';
        invoice.Customer__c = acc.id;
        invoice.Consignee__c = acc.id;
        invoice.GST_Number__c = 'test';
        invoice.VAT_Number__c = '1234';
        invoice.RecordTypeId = proformaInvoiceRecTypeId;
        invoice.CurrencyIsoCode = 'INR';
        invoice.is_Manual_Line_Item_Applicable__c=true;
        insert invoice;
        
        
        
        
        Invoice_Line_Item__c testLineItem = new Invoice_Line_Item__c();
        testLineItem.Invoice__c = invoice.id;
        testLineItem.Item_Number__c = 10;
        testLineItem.Item_Code__c = 'T32-03725A000-0102';
        testLineItem.Item_Description__c= 'T32-03725A000-0102';
        testLineItem.Product_Type__c = 'FERT';
        testLineItem.Product_Group__c = 'SERVICE';
        testLineItem.Item_Quantity__c = 20;
        testLineItem.SO_Item_Quantity__c = 10;
        testLineItem.UOM__c = 'EA';
        testLineItem.Item_Value__c = 1234;
        insert testLineItem;
        
        Invoice_Line_Item__c testLineItem1 = new Invoice_Line_Item__c();
        testLineItem1.Invoice__c = invoice.id;
        testLineItem1.Item_Number__c = 10;
        testLineItem1.Item_Code__c = 'T32-03725A000-0102';
        testLineItem1.Item_Description__c= 'T32-03725A000-0102';
        testLineItem1.Product_Type__c = 'FERT';
        testLineItem1.Product_Group__c = 'SERVICE';
        testLineItem1.Item_Quantity__c = 20;
        testLineItem1.SO_Item_Quantity__c = 10;
        testLineItem1.UOM__c = 'EA';
        testLineItem1.Item_Value__c = 1234;
        insert testLineItem1;
        
        Manual_Invoice_Line_Item__c testManualItem = new Manual_Invoice_Line_Item__c();
        testManualItem.Invoice__c = invoice.id;
        testManualItem.Item_Description__c = 'T32-03725A000-0102';
        testManualItem.Item_Quantity__c = 20;
        testManualItem.Total_Price__c = 1234;
        insert testManualItem;
        
        Payment_Doc_Line__c tstDocLine = new Payment_Doc_Line__c();
        tstDocLine.Advance_Payment__c = false;
        tstDocLine.PMT_Doc_Number_c__c = 'test';
        insert tstDocLine;
        
        Invoice_Payment_Relationship__c tstPaymentRelation = new Invoice_Payment_Relationship__c();
       // tstPaymentRelation.Name = 'test';
        tstPaymentRelation.CurrencyIsoCode = 'INR';
        tstPaymentRelation.Invoice__c = invoice.id;
        tstPaymentRelation.Payment_Doc_Number__c = '12345';
        tstPaymentRelation.Payment_Doc_Line__c = tstDocLine.Id;
        insert tstPaymentRelation;
        
        List<Invoice__c> lstinvoice = new List<Invoice__c>();
        lstinvoice.add(invoice);
        
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
		test.setCurrentPage(page.ProformaInvoicePDF);
        ApexPages.StandardController  stdSetController = new ApexPages.StandardController(invoice);
  		//stdSetController.setSelected(lstinvoice);
        Invoice_PDF_Controller tstController = new Invoice_PDF_Controller(stdSetController);
        tstController.getproductdetails();
        
        test.stopTest();
    }
    
    @isTest
    public static void test2(){
        Sales_Org__c salesOrg1 = new Sales_Org__c(Name='TSSO');
        insert salesOrg1;
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Integration_Transaction__c It = new Integration_Transaction__c();
        it.Record_Id__c = acc.id;
        it.Status__c = 'Draft';
        it.Request__c = 'Create Customer:0Q0Bl0000000IJVKA2';
        it.Response__c = 'this is customer code : cn065';
        insert it;
        
        
        
        RecordType proInvRecType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Invoice__c' AND DeveloperName = 'Proforma'];
        Id proformaInvoiceRecTypeId = proInvRecType.Id;
        Invoice__c invoice = new Invoice__c();
        invoice.SAP_Invoice_Number__c = '12';
        invoice.Customer__c = acc.id;
        invoice.Consignee__c = acc.id;
        invoice.GST_Number__c = 'test';
        invoice.VAT_Number__c = '1234';
        invoice.RecordTypeId = proformaInvoiceRecTypeId;
        invoice.CurrencyIsoCode = 'INR';
        invoice.is_Manual_Line_Item_Applicable__c=false;
        insert invoice;
        
        
        
        
        Invoice_Line_Item__c testLineItem = new Invoice_Line_Item__c();
        testLineItem.Invoice__c = invoice.id;
        testLineItem.Item_Number__c = 10;
        testLineItem.Item_Code__c = 'T32-03725A000-0102';
        testLineItem.Item_Description__c= 'T32-03725A000-0102';
        testLineItem.Product_Type__c = 'FERT';
        testLineItem.Product_Group__c = 'SERVICE';
        testLineItem.Item_Quantity__c = 20;
        testLineItem.SO_Item_Quantity__c = 10;
        testLineItem.UOM__c = 'EA';
        testLineItem.Item_Value__c = 1234;
        insert testLineItem;
        
        Invoice_Line_Item__c testLineItem1 = new Invoice_Line_Item__c();
        testLineItem1.Invoice__c = invoice.id;
        testLineItem1.Item_Number__c = 10;
        testLineItem1.Item_Code__c = 'T32-03725A000-0102';
        testLineItem1.Item_Description__c= 'T32-03725A000-0102';
        testLineItem1.Product_Type__c = 'FERT';
        testLineItem1.Product_Group__c = 'SERVICE';
        testLineItem1.Item_Quantity__c = 20;
        testLineItem1.SO_Item_Quantity__c = 10;
        testLineItem1.UOM__c = 'EA';
        testLineItem1.Item_Value__c = 1234;
        insert testLineItem1;
        
        Manual_Invoice_Line_Item__c testManualItem = new Manual_Invoice_Line_Item__c();
        testManualItem.Invoice__c = invoice.id;
        testManualItem.Item_Description__c = 'T32-03725A000-0102';
        testManualItem.Item_Quantity__c = 20;
        testManualItem.Total_Price__c = 1234;
        insert testManualItem;
        
        Payment_Doc_Line__c tstDocLine = new Payment_Doc_Line__c();
        tstDocLine.Advance_Payment__c = false;
        tstDocLine.PMT_Doc_Number_c__c = 'test';
        insert tstDocLine;
        
        Invoice_Payment_Relationship__c tstPaymentRelation = new Invoice_Payment_Relationship__c();
       // tstPaymentRelation.Name = 'test';
        tstPaymentRelation.CurrencyIsoCode = 'INR';
        tstPaymentRelation.Invoice__c = invoice.id;
        tstPaymentRelation.Payment_Doc_Number__c = '12345';
        tstPaymentRelation.Payment_Doc_Line__c = tstDocLine.Id;
        insert tstPaymentRelation;
        
        List<Invoice__c> lstinvoice = new List<Invoice__c>();
        lstinvoice.add(invoice);
        
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
		test.setCurrentPage(page.ProformaInvoicePDF);
        ApexPages.StandardController  stdSetController = new ApexPages.StandardController(invoice);
  		//stdSetController.setSelected(lstinvoice);
        Invoice_PDF_Controller tstController = new Invoice_PDF_Controller(stdSetController);
        tstController.getproductdetails();
        
        test.stopTest();
    }
}