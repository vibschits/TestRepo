/*
Name : IntegrationTransactionHandler
Desc : This is a trigger handler class.
Author : Kuhinoor
*/
public with sharing class IntegrationTransactionHandler extends TriggerHandler{
    private static final string OBJECT_API = 'Integration_Transaction__c';
    
    public IntegrationTransactionHandler() {
        super(OBJECT_API);
    }
    
    public override String getName() {
        return OBJECT_API;
    }
    
    public override void beforeInsert(List<SObject> newItems) {
    }
    public override void beforeUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map<Id, SObject> oldItemsMap) {
    }
    public override void beforeDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUpdate(List<SObject> newItems, Map<Id, SObject> newItemsMap, Map < Id, SObject > oldItemsMap) {
        //   updateCustomer(newItems);
        // updatesapOfferId(newItems);
        //updatesapOfferId(newItems);
        //  List<Integration_Transaction__c> newlines = new List<Integration_Transaction__c>();
        //  IntegrationTransactionHelper.updateOfferRecord(response, offerid);
        
    }
    public override void afterDelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterUndelete(Map<Id, SObject> oldItemsMap) {
    }
    public override void afterInsert(List<SObject> newItems, Map<Id, SObject> newItemsMap) {
        Map<Id, SObject> tempMap = new Map<Id, SObject>();
        processIntegration(newItems);
        getSAPOfferidFromSAP(newItems);
        
    }
    
    /*
Name : updateCustomer
Desc : this method future mathod and update customer with latest response.
Params : newList
*/
    public void processIntegration(List<Integration_Transaction__c> newList){
        system.debug('update customer is calling');
        Integration_Transaction__c it = newList[0];
        if(it.Operation__c == label.Create_Customer){
            SAPCallout_Utility.updateCustomer(it.Record_Id__c, it.Id);
        }
        if(it.Operation__c == label.Create_Partlist){
            CreatePartListController.getPartList(it.Record_Id__c, it.Id);
        }
        if(it.Operation__c == label.Create_Non_Spare_Offer){
            system.enqueueJob(new CreateNonSpareOffer(it.Record_Id__c, it.Id));
        }
        if(it.Operation__c == 'Create Invoice'){
            CreateInvoice.createInvoiceFromSAP(it.Record_Id__c, it.Id);
        }
        if(it.Operation__c == 'Create SO-BOM'){
            system.enqueueJob(new OrderCreateController(it.Record_Id__c, it.Id,'Create SO-BOM'));
        }
        if(it.Operation__c == 'Update SO-BOM'){
           system.enqueueJob(new OrderCreateController(it.Record_Id__c, it.Id,'Update SO-BOM'));
        }
        
    }
    public void getSAPOfferidFromSAP(List<Integration_Transaction__c> newList){
        Integration_Transaction__c it = newList[0];
        if(it.Operation__c == 'Create Offer Spare' ){
            //sapComDocumentSapRfcFunctions3.requestSapOfferId(it.Record_Id__c, it.Id);
            offerSpare.requestSapOfferId(it.Record_Id__c, it.Id);
        }
    }
}