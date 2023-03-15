/*
Name : ProductInstalledHandler
Desc : This is a handler class of ProductInstalledTrigger 
US :
*/

public with sharing class ProductInstalledHandler extends TriggerHandler {
	private static final string Product_Installed = 'Product_Installed__c';
    public ProductInstalledHandler() {
    	super(Product_Installed);
    }
    /*****************************************************************************
    @Description : Return the name of the handler invoked
    ******************************************************************************/
    public override String getName() {
    	return Product_Installed;
    }
    /*****************************************************************************
    @Description : Trigger handlers for events
    ******************************************************************************/
    public override void beforeInsert(List<SObject> newItems) {
        ProductInstalledHelper oppHelper = new ProductInstalledHelper();
        oppHelper.updateProductInstalled(newItems);
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