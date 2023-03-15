public class ProcessListViewApexController {
	
    @AuraEnabled
    public static List<Inventory_Score_Simulation__c> fetchISS(String inventoryId) {
        Customer_Inventory_Stock__c custInv = [Select Id,Customer__c from Customer_Inventory_Stock__c WHERE ID =: inventoryId];
        List<Inventory_Score_Simulation__c> issList = [SELECT Id,Name,Customer__c,LastModifiedDate from Inventory_Score_Simulation__c WHERE Customer__c =: custInv.Customer__c];
        return issList;
    }
    
    @AuraEnabled
    public static String createVirtualInvLines(String issId,List<String> invIds) {
        system.debug('issId'+issId);
        system.debug('invIds'+invIds);
        issId = issId.remove('"');
        system.debug('issId'+issId);
        Set<Id> inventoryIdSet = new Set<Id>();
        for(String invId : invIds){
            inventoryIdSet.add(invId);
        }
        system.debug('inventoryIdSet'+inventoryIdSet);
        List<Customer_Inventory_Stock__c> custInvList = [SELECT Id, Name, Cargo_Inspection__c, Customer__c, Item__c, Quantity__c, Where_it_is__c, 
                                                         All_Quantity_Applied__c, Installation_Date__c, Installation_Quantity__c, Invoice_Line_Item__c, 
                                                         Item_Code__c, Owned_by__c, Sales_Order__c, Part_List_Purchased_For__c, Equipment_has_been_installed_at__c, 
                                                         Equipment_has_been_purchased_for__c 
                                                         FROM Customer_Inventory_Stock__c 
                                                         WHERE Id IN: inventoryIdSet];
        
        List<Virtual_Inventory_Line__c> virtualInvLineListDel = [Select Id,Inventory_Score_Simulation__c from Virtual_Inventory_Line__c 
                                                              WHERE Inventory_Score_Simulation__c =: issId];
        if(virtualInvLineListDel.size() > 0){
            delete virtualInvLineListDel;
        }
        
        List<Virtual_Inventory_Line__c> virInvList = new List<Virtual_Inventory_Line__c>();
        
        for(Customer_Inventory_Stock__c custInv : custInvList){
            Virtual_Inventory_Line__c virInv = new Virtual_Inventory_Line__c();
            virInv.Customer_Inventory_Line_Stock__c = custInv.Id;
            virInv.Inventory_Score_Simulation__c = issId;
            virInv.Original_Quantity__c = custInv.Quantity__c;
            virInvList.add(virInv);
        }
        
        try{
        	insert virInvList;
        }catch(Exception e){
            return 'FAIL';
        }
        return issId;
    }
}