public class OfferTriggerHandler extends TriggerHandler {
    
    private static final string OBJECT_API = 'Quote';
    
    public OfferTriggerHandler() {
        super(OBJECT_API);
    }
    
    public override String getName() {
        return OBJECT_API;
    }
    
    public override void beforeInsert(List<SObject> newItems) {
        OfferTriggerHelper.afterIDcreation(newItems);
        offerTriggerHelper.populatePriceBook(newItems);
         OfferTriggerHelper.populateHead(newItems, null, false);    
    }
    public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map < Id, SObject > oldItemsMap) {
        
        OfferTriggerHelper.updateScopeWithOffer(newItemsMap, oldItemsMap);
        offerTriggerHelper.CreateSAPOfferId(newItemsMap,oldItemsMap);
        
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
        OfferTriggerHelper.updateScopeWithOffer(newItemsMap, null);
        
     // offerTriggerHelper.CreateSAPOfferId(newItemsMap, null);
    }
    
    
    
}