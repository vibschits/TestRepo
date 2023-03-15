public with sharing class ManualInvoiceLineItemTriggerHandler extends TriggerHandler {
	private static final string MANUAL_INVOICE_LINE_ITEM_API = 'Manual_Invoice_Line_Item__c';
    public ManualInvoiceLineItemTriggerHandler() {
    	super(MANUAL_INVOICE_LINE_ITEM_API);
    }
    /*****************************************************************************
    @Description : Return the name of the handler invoked
    ******************************************************************************/
    public override String getName() {
    	return MANUAL_INVOICE_LINE_ITEM_API;
    }
    /*****************************************************************************
    @Description : Trigger handlers for events
    ******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
        
        ManualInvoiceLineItemTriggerHelper manInvLineObj = new ManualInvoiceLineItemTriggerHelper();
        manInvLineObj.checkValidation(newItems);
    }
	public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject>newItemsMap, Map< Id, SObject > oldItemsMap) {
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject>newItemsMap) {
    }
}