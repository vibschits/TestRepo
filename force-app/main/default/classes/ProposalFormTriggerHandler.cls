public with sharing class ProposalFormTriggerHandler extends TriggerHandler {
	private static final string PROPOSAL_FORM_API = 'Proposal_Form__c';
    public ProposalFormTriggerHandler() {
    	super(PROPOSAL_FORM_API);
    }
    /*****************************************************************************
    @Description : Return the name of the handler invoked
    ******************************************************************************/
    public override String getName() {
    	return PROPOSAL_FORM_API;
    }
    /*****************************************************************************
    @Description : Trigger handlers for events
    ******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
        ProposalFormTriggerHelper oppEquipHandler = new ProposalFormTriggerHelper();
        oppEquipHandler.checkEquipmentType(newItems);
        //oppEquipHandler.defaultOperatingParameter(newItems);
        oppEquipHandler.defaultDesignParameter(newItems);
    }
	public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject>
    newItemsMap, Map<Id, SObject> oldItemsMap) {
        ProposalFormTriggerHelper oppEquipHandler = new ProposalFormTriggerHelper();
        oppEquipHandler.checkEquipmentType(newItems);
        //oppEquipHandler.defaultOperatingParameter(newItems);
        oppEquipHandler.defaultDesignParameter(newItems);
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