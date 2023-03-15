trigger ManualInvoiceLineItemTrigger on Manual_Invoice_Line_Item__c (before insert,after insert,before update,after update,before delete, after delete,after undelete) {
	
    public static string triggerName ='ManualInvoiceLineItemTrigger';
    ManualInvoiceLineItemTriggerHandler manualInvLineItemHandlerObj = new ManualInvoiceLineItemTriggerHandler();
    TriggerDispatcher.run(manualInvLineItemHandlerObj);
}