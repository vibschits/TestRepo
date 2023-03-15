public with sharing class AccountTriggerHandler extends TriggerHandler {
    private static final string ACCOUNT_API = 'Account';
    public AccountTriggerHandler() {
        super(ACCOUNT_API);
    }
    /*****************************************************************************
@Description : Return the name of the handler invoked
******************************************************************************/
    public override String getName() {
        return ACCOUNT_API;
    }
    /*****************************************************************************
@Description : Trigger handlers for events
******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
        
        AccountTriggerHelper acc = new AccountTriggerHelper();
        acc.typeUpdateOnInsert(newItems);
        
    }
    public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
        
        AccountTriggerHelper acc = new AccountTriggerHelper();
        Map<id, Account> newMap = (Map<id, Account>)newItemsMap;
        Map<id, Account> oldMap = (Map<id, Account>)oldItemsMap;
        
         acc.UpdatechildTypebefore(newMap,oldMap);
        
        //AccountTriggerHelper.currencyValidation(accid, OldMap);
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject>newItemsMap, Map <Id, SObject> oldItemsMap) {
                AccountTriggerHelper acc = new AccountTriggerHelper();

        Map<id, Account> newMap = (Map<id, Account>)newItemsMap;
        Map<id, Account> OldMap = (Map<id, Account>)oldItemsMap;
        acc.updateChildType(newMap,oldMap);
        //AccountTriggerHelper.opportunityCurrUpdate(newMap, OldMap);
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject>
                                     newItemsMap) {
                                     }
}