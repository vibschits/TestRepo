public with sharing class X4E4DTriggerHandler extends TriggerHandler {
	private static final string X4E_4D_API = 'X4E_4D__c';
    public X4E4DTriggerHandler() {
    	super(X4E_4D_API);
    }
    /*****************************************************************************
    @Description : Return the name of the handler invoked
    ******************************************************************************/
    public override String getName() {
    	return X4E_4D_API;
    }
    /*****************************************************************************
    @Description : Trigger handlers for events
    ******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
        
    }
	public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject>
    newItemsMap, Map<Id, SObject> oldItemsMap) {
        
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject>
    newItemsMap, Map < Id, SObject > oldItemsMap) {
        
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject>
    newItemsMap) {
        X4E4DTriggerHelper.updateOppStage(newItems);
    }
}