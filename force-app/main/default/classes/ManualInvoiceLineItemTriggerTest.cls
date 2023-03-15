/* 
Name : ManualInvoiceLineItemTriggerTest
Description : Test Class for ManualInvoiceLineItemTrigger
Auhtor : Pavan
*/
@isTest(SeeAllData=false) 
public class ManualInvoiceLineItemTriggerTest {
    
    @isTest
    public static void test1(){
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Invoice__c testInvoice = new Invoice__c();
        testInvoice.GST_Number__c = '123';
        testInvoice.VAT_Number__c ='124';
        testInvoice.Consignee__c = testInvoice.Id;
        testInvoice.Customer__c = testInvoice.Id;
        testInvoice.SAP_Invoice_Number__c = '0110004943 0025000247';
        testInvoice.SAP_Invoice_Date__c = '4/27/2021  4/22/2010';
        insert testInvoice;
        
        Invoice_Line_Item__c testLineItem = new Invoice_Line_Item__c();
        testLineItem.Invoice__c = testInvoice.id;
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
        
       
        
        Manual_Invoice_Line_Item__c testManualItem = new Manual_Invoice_Line_Item__c();
        testManualItem.Invoice__c = testInvoice.id;
        testManualItem.Item_Description__c = 'T32-03725A000-0102';
        testManualItem.Item_Quantity__c = 20;
        testManualItem.Total_Price__c = 1234;
        insert testManualItem;
        
        Manual_Invoice_Line_Item__c testManualItem1 = new Manual_Invoice_Line_Item__c();
        testManualItem1.Invoice__c = testInvoice.id;
        testManualItem1.Item_Description__c = 'T32-03725A000-0102';
        testManualItem1.Item_Quantity__c = 20;
        testManualItem1.Total_Price__c = 1234;
        
        ManualInvoiceLineItemTriggerHandler testHandler = new ManualInvoiceLineItemTriggerHandler();
        testHandler.getName();
        
       
        
        try{
        insert testManualItem1;
        }
        catch(Exception e){
            
        }
    }
    
    @isTest
    public static void test2(){
        
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Invoice__c testInvoice = new Invoice__c();
        testInvoice.GST_Number__c = '123';
        testInvoice.VAT_Number__c ='124';
        testInvoice.Consignee__c = testInvoice.Id;
        testInvoice.Customer__c = testInvoice.Id;
        testInvoice.SAP_Invoice_Number__c = '0110004943 0025000247';
        testInvoice.SAP_Invoice_Date__c = '4/27/2021  4/22/2010';
        insert testInvoice;
        
        Invoice_Line_Item__c testLineItem = new Invoice_Line_Item__c();
        testLineItem.Invoice__c = testInvoice.id;
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
        
       
        
        Manual_Invoice_Line_Item__c testManualItem = new Manual_Invoice_Line_Item__c();
        testManualItem.Invoice__c = testInvoice.id;
        testManualItem.Item_Description__c = 'T32-03725A000-0102';
        testManualItem.Item_Quantity__c = 20;
        testManualItem.Total_Price__c = 1234;
        insert testManualItem;
        
        Manual_Invoice_Line_Item__c testManualItem1 = [select id,Item_Description__c from Manual_Invoice_Line_Item__c where Item_Description__c= 'T32-03725A000-0102'];
        testManualItem1.Item_Description__c= 'T32-03725A000-0102';
        update testManualItem1;
        delete testManualItem1;
        undelete testManualItem1;
    }
    

}