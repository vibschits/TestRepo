public class DismantleApexController {

    @AuraEnabled
    public static List<Dismantle__c> fetchDismRecs(String instLineItemId) {
        Installation_line_Items__c instLineItem = [Select Id from Installation_line_Items__c WHERE ID =: instLineItemId];
        List<Dismantle__c> dismList = [SELECT Id,Name,Status__c,Dismantle_Date__c,Dismantle_Superior_Id__c,Dismantle_Superior_Name__c from Dismantle__c];
        return dismList;
    }
    
    @AuraEnabled
    public static String dismantleInstLineItems(String dismantleId,List<String> insLineItemIds) {
        system.debug('dismantleId'+dismantleId);
        system.debug('insLineItemIds'+insLineItemIds);
        dismantleId = dismantleId.remove('"');
        system.debug('dismantleId'+dismantleId);
        Set<Id> instLineItemIdSet = new Set<Id>();
        for(String insLineItemId : insLineItemIds){
            instLineItemIdSet.add(insLineItemId);
        }
        system.debug('instLineItemIdSet'+instLineItemIdSet);
        
        Dismantle__c dismantleRec = [SELECT Id,Name,Status__c from Dismantle__c WHERE Id =: dismantleId];
        system.debug('dismantleRec'+dismantleRec);
        
        List<Installation_line_Items__c> instLineItemList = [SELECT Id, Name, Installation__c, Equipment_has_been_Installed_at__c, Disposal_Date__c, 
                                                             Installation_Date__c, Item__c, Installed_Quantity__c, Who_has_installted__c, Referenced_Part_List__c, 
                                                             Other_Tega_Members_That_Attended__c, Part_List__c, Product__c, Installation_Montitored_at_Site__c, 
                                                             Supervisor_s_Name__c, Starting_Date_of_Job__c, Ending_Date_of_Job__c, Comments__c, 
                                                             Installer_Company_Name__c, Number_of_Employees__c, Number_of_Shifts__c, 
                                                             Name_of_Supervisor_In_Charge__c, Supervisor_s_Phone__c, Supervisor_s_Email__c, Name_of_Safety_In_Charge__c, 
                                                             Safety_In_Charge_s_Phone__c, Safety_In_Charge_s_Email__c, Customer_Inventory_Line_Stock__c, 
                                                             Operating_Parameter__c, Inspection_Comments__c, Equipment_Dismantled_From__c, Dismantle__c 
                                                             FROM Installation_line_Items__c 
                                                             WHERE Id IN: instLineItemIdSet];
        system.debug('instLineItemList'+instLineItemList);
        
        Set<Id> custInvIds = new Set<Id>();
        
        for(Installation_line_Items__c insLineItem : instLineItemList){
            custInvIds.add(insLineItem.Customer_Inventory_Line_Stock__c);
        }
        
        List<Customer_Inventory_Stock__c> custInvList = [Select Id,Quantity__c from Customer_Inventory_Stock__c where Id IN :custInvIds];
        
        Map<Id,Customer_Inventory_Stock__c> custInvMap = new Map<Id,Customer_Inventory_Stock__c>();
        
        for(Customer_Inventory_Stock__c custInv : custInvList){
            custInvMap.put(custInv.Id,custInv);
        }

        
        for(Installation_line_Items__c insLineItem : instLineItemList){
            if(dismantleRec.Status__c == 'Inventory'){
                Customer_Inventory_Stock__c custInv = custInvMap.get(insLineItem.Customer_Inventory_Line_Stock__c);
                custInv.Quantity__c += insLineItem.Installed_Quantity__c;
                custInvMap.put(custInv.Id,custInv);
                
                insLineItem.Dismantle__c = dismantleRec.Id;
                insLineItem.Equipment_Dismantled_From__c = insLineItem.Equipment_has_been_Installed_at__c;
                insLineItem.Equipment_has_been_Installed_at__c = null;
            }else{
                insLineItem.Dismantle__c = dismantleRec.Id;
                insLineItem.Equipment_Dismantled_From__c = insLineItem.Equipment_has_been_Installed_at__c;
                insLineItem.Equipment_has_been_Installed_at__c = null;
            }
        }
        
        update instLineItemList;
        update custInvMap.values();
        
        return dismantleId;
    }
}