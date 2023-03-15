public class CalculateScore {
    @InvocableMethod (label = 'Calculate Score' description = 'returns nothing')
    public static void calculateScoreForInventory (List<ID> ids){
        
        // Even though we are receiving list of id, we will always receive only one id from flow
        List<Inventory_Score_Simulation__c> invScoreSimList = [SELECT Id, Name, All_Customer_Inventory_applicable__c,Inventory_Score_Simulation__c.Customer__c 
                                                               FROM Inventory_Score_Simulation__c 
                                                               WHERE Id IN: ids];
        system.debug('invScoreSimList => '+invScoreSimList);
        system.debug('customerId =>'+invScoreSimList[0].Customer__c);
        
        //SK - 270123: Converting Equip has been purchased/installed field to Lookup --> removing reference from this class. Earlier query is as below 
        /*List<Customer_Inventory_Stock__c> inventoryList = [SELECT Id, Name, Item__c, Quantity__c, Where_it_is__c, Cargo_Inspection__c, Customer__c, Invoice_Line_Item__c, 
                                                           Sales_Order__c, Item_Code__c, Equipment_has_been_purchased_for__c, Equipment_has_been_installed_at__c 
                                                           FROM Customer_Inventory_Stock__c 
                                                           WHERE Customer__c =: invScoreSimList[0].Customer__c];*/
        
        List<Customer_Inventory_Stock__c> inventoryList = [SELECT Id, Name, Item__c, Quantity__c, Where_it_is__c, Cargo_Inspection__c, Customer__c, Invoice_Line_Item__c, 
                                                           Sales_Order__c, Item_Code__c
                                                           FROM Customer_Inventory_Stock__c 
                                                           WHERE Customer__c =: invScoreSimList[0].Customer__c];
        
        List<Virtual_Inventory_Line__c> virtualInvLineListISS = [Select Id,Inventory_Score_Simulation__c,Residual_Quantity__c,Used_Quantity__c from Virtual_Inventory_Line__c 
                                                              WHERE Inventory_Score_Simulation__c =: invScoreSimList[0].Id AND Zone_Priority_Selection__c = ''];
        
        List<Virtual_Inventory_Line__c> virtualInvLineListZPS = [Select Id,Inventory_Score_Simulation__c,Residual_Quantity__c,Used_Quantity__c from Virtual_Inventory_Line__c 
                                                              WHERE Inventory_Score_Simulation__c =: invScoreSimList[0].Id AND Zone_Priority_Selection__c != ''];
        
        if(virtualInvLineListZPS.size() > 0){
            delete virtualInvLineListZPS;
        }
        
        if(virtualInvLineListISS.size() > 0){
            //delete virtualInvLineListDel;
            for(Virtual_Inventory_Line__c inventory : virtualInvLineListISS){
                inventory.Residual_Quantity__c = null;
                inventory.Used_Quantity__c = null;
            }
            update virtualInvLineListISS;
        }else{
            List<Virtual_Inventory_Line__c> virtualInvLineList = new List<Virtual_Inventory_Line__c>();
            
            if(invScoreSimList[0].All_Customer_Inventory_applicable__c == true){
                for(Customer_Inventory_Stock__c inventory : inventoryList){
                    Virtual_Inventory_Line__c virtualInvLine  = new Virtual_Inventory_Line__c();
                    virtualInvLine.Customer_Inventory_Line_Stock__c = inventory.Id;
                    virtualInvLine.Inventory_Score_Simulation__c = invScoreSimList[0].Id;
                    virtualInvLine.Original_Quantity__c = inventory.Quantity__c;
                    virtualInvLineList.add(virtualInvLine);
                }
                
                // Virtual lines at ISS Level
                if(virtualInvLineList.size() > 0){
                    insert virtualInvLineList; 
                }
                
            }
        }
        
        

        

        
        List<Inventory_Score_Relationship__c> invPartRelList = [SELECT Id, Inventory_Score_Simulation__c, Customer__c, Part_List__c, L2_Set_Qty__c, 
                                                                Priority__c FROM Inventory_Score_Relationship__c 
                                                                WHERE Inventory_Score_Simulation__c IN: ids 
                                                                ORDER BY Priority__c];
        system.debug('invPartRelList => '+invPartRelList);
        
        system.enqueueJob(new CalculateScoreController(invPartRelList, 0));
    }
}