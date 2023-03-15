public with sharing class OpportunityTriggerHandler extends TriggerHandler {
	private static final string OPPORTUNITY_API = 'Opportunity';
    public OpportunityTriggerHandler() {
    	super(OPPORTUNITY_API);
    }
    /*****************************************************************************
    @Description : Return the name of the handler invoked
    ******************************************************************************/
    public override String getName() {
    	return OPPORTUNITY_API;
    }
    /*****************************************************************************
    @Description : Trigger handlers for events
    ******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
        OpportunityTriggerHelper oppHelper = new OpportunityTriggerHelper();
        oppHelper.checkChildOpp(newItems);
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
    }
}