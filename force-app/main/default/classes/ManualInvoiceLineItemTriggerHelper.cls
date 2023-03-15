public class ManualInvoiceLineItemTriggerHelper {
    public void checkValidation(List<Manual_Invoice_Line_Item__c> newItems){
        
        List<Invoice_Line_Item__c> invLineItemList = [Select Id,Invoice__c from Invoice_Line_Item__c 
                                                      where Invoice__c =: newItems[0].Invoice__c];
        Integer countInvLineItem = invLineItemList.size();
        List<Manual_Invoice_Line_Item__c> manInvLineItemList = [Select Id,Invoice__c from Manual_Invoice_Line_Item__c 
                                                                where Invoice__c =: newItems[0].Invoice__c];
        Integer countManInvLineItem = manInvLineItemList.size();
        
        if(countManInvLineItem == countInvLineItem){
            for(Manual_Invoice_Line_Item__c manInvLineItem : newItems){
                manInvLineItem.addError('Count of Manual Invoice Line Item cannot exceed Invoice Line Item count');
            }
        }
    }
}