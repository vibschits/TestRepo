public with sharing class LeadTriggerHandler extends TriggerHandler {
    private static final string LEAD_API = 'LEAD';
    public LeadTriggerHandler() {
        super(LEAD_API);
    }
    /*****************************************************************************
@Description : Return the name of the handler invoked
******************************************************************************/
    public override String getName() {
        return LEAD_API;
    }
    /*****************************************************************************
@Description : Trigger handlers for events
******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
    }
    public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map <Id, SObject> oldItemsMap) {
      Map<id, Lead> newMap = (Map<id, Lead>)newItemsMap;
       Map<id, Lead> OldMap = (Map<id, Lead>)oldItemsMap;
     //  LeadTriggerHelper.assignrecordtouserORgroup(newItems);
        
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
        Map<id, Lead> newMap = (Map<id, Lead>)newItemsMap;
        
        LeadTriggerHelper.assignrecordtouserORgroup(newItems);
    }
    
}