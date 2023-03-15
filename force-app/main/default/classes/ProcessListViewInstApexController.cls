public class ProcessListViewInstApexController {

    @AuraEnabled
    public static List<Installation__c> fetchInvs(String inventoryId) {
        Customer_Inventory_Stock__c custInv = [Select Id,Customer__c from Customer_Inventory_Stock__c WHERE ID =: inventoryId];
        List<Installation__c> invList = [SELECT Id,Name,LastModifiedDate from Installation__c WHERE Customer__c =: custInv.Customer__c];
        return invList;
    }
    
    @AuraEnabled
    public static String createInstallationLinesPartial(String installationId,String inLineItemStr, String custInvSTR) {
        system.debug('INSIDE Partial Method'+installationId);      
        List<Installation_line_Items__c> inLineItemList = (List<Installation_line_Items__c>) JSON.deserialize(inLineItemStr, List<Installation_line_Items__c>.class);
        List<Customer_Inventory_Stock__c> custInvList = (List<Customer_Inventory_Stock__c>) JSON.deserialize(custInvSTR, List<Customer_Inventory_Stock__c>.class);
        system.debug('inLineItemList'+inLineItemList);    
        system.debug('custInvList'+custInvList);
        system.debug('installationId'+installationId);
        String insId = installationId;
        insert inLineItemList;
        update custInvList;
        return insId;
    }
    
    @AuraEnabled
    public static ReturnWrapper createInstallationLines(String installationId,List<String> invIds) {
        Boolean isError = false;
        List<String> errorInvList = new List<String>();
        system.debug('installationId'+installationId);
        system.debug('invIds'+invIds);
        installationId = installationId.remove('"');
        system.debug('installationId'+installationId);
        Set<Id> inventoryIdSet = new Set<Id>();
        for(String invId : invIds){
            inventoryIdSet.add(invId);
        }
        system.debug('inventoryIdSet'+inventoryIdSet);
        
        Installation__c installationRec = [SELECT Id,Name,Equipment_Installed_At__c,Part_List__c,Product__c from Installation__c WHERE Id =: installationId];
        system.debug('installationRec'+installationRec);
        
        List<Customer_Inventory_Stock__c> custInvList = [SELECT Id, Name, Cargo_Inspection__c, Customer__c, Item__c,Item__r.Name, Quantity__c, Where_it_is__c, 
                                                         All_Quantity_Applied__c, Installation_Date__c, Installation_Quantity__c, Invoice_Line_Item__c, 
                                                         Item_Code__c, Owned_by__c, Sales_Order__c, Part_List_Purchased_For__c, Equipment_has_been_installed_at__c, 
                                                         Equipment_has_been_purchased_for__c,Group_Items__c 
                                                         FROM Customer_Inventory_Stock__c 
                                                         WHERE Id IN: inventoryIdSet];
        system.debug('custInvList'+custInvList);
        
        // AK 27/02/2022 Changes
        List<L2_L3_product__c> l2L3ProdListPerL2 = [SELECT Id, Name, Product_L2__c,Product_L2__r.Name, Product_L3__c, Product_L3__r.Name,Quantity__c, Part_List__c 
                                               FROM L2_L3_product__c 
                                               where Part_List__c =: installationRec.Part_List__c AND Product_L2__c =: installationRec.Product__c];
        Map<String,Decimal> l2L3ProdMapPerL2 = new Map<String,Decimal>();
        
        for(L2_L3_product__c l2L3Rec : l2L3ProdListPerL2){
            l2L3ProdMapPerL2.put(l2L3Rec.Product_L3__r.Name,l2L3Rec.Quantity__c);
            system.debug('l2L3Rec.Product_L3__r.Name =>'+l2L3Rec.Product_L3__r.Name);
            system.debug('l2L3Rec.Quantity__c =>'+l2L3Rec.Quantity__c);
        }
        
        
        // This map prepares all the qty require per item vs all the items present in inventory per item
        //Map<Id,wrapper> invQtyMap = new Map<Id,wrapper>();
        
        // This map will list all Customer Inventory Records that have same Item
        Map<Id,List<Customer_Inventory_Stock__c>> custInvMap = new  Map<Id,List<Customer_Inventory_Stock__c>>();
        
        // All updated Customer Inventory's Quantity will be stored in custInvUpdList list
        List<Customer_Inventory_Stock__c>  custInvUpdList = new List<Customer_Inventory_Stock__c>();
        
        /*for(Customer_Inventory_Stock__c custInv : custInvList){
            system.debug('custInv'+custInv);
            if(!invQtyMap.containsKey(custInv.Item__c)){
                system.debug('inside'+custInv);
                wrapper wrp = new wrapper();
                wrp.itemQtyInInv = custInv.Quantity__c;
                wrp.qtyForInst = custInv.Installation_Quantity__c;
                invQtyMap.put(custInv.Item__c,wrp);
                
                List<Customer_Inventory_Stock__c>  custInvNewList = new List<Customer_Inventory_Stock__c>();
                custInvNewList.add(custInv);
                custInvMap.put(custInv.Item__c,custInvNewList);
                
            }else if(invQtyMap.containsKey(custInv.Item__c)){
                wrapper wrp = invQtyMap.get(custInv.Item__c);
                wrp.itemQtyInInv += custInv.Quantity__c;
                wrp.qtyForInst += custInv.Installation_Quantity__c;
                invQtyMap.put(custInv.Item__c,wrp);
                
                List<Customer_Inventory_Stock__c>  custInvNewList = custInvMap.get(custInv.Item__c);
                custInvNewList.add(custInv);
                custInvMap.put(custInv.Item__c,custInvNewList);
            }
            
        }*/
        
        List<Installation_line_Items__c> newInstLineItemList = new List<Installation_line_Items__c>();
        ReturnWrapper retWrp = new ReturnWrapper();        
        
        for(Customer_Inventory_Stock__c custInv : custInvList){
            //wrapper wrp = invQtyMap.get(custInv.Item__c);
            /*if(wrp.qtyForInst > wrp.itemQtyInInv){
                // throw error that quantities required for installation are more than present in inventory and stop whole operation
            }else{*/
                if(custInv.Group_Items__c == true){
                    system.debug('custInv'+custInv);
                    if(l2L3ProdMapPerL2.containsKey(custInv.Item__r.Name) && (custInv.Installation_Quantity__c > l2L3ProdMapPerL2.get(custInv.Item__r.Name))){
                        // Error = true and store this inventory number to show detail on error page
                        isError = true;
                        errorInvList.add(custInv.Item__r.Name);
                        
                    }else if(!l2L3ProdMapPerL2.containsKey(custInv.Item__r.Name)){
                        // Error = true and store this inventory number to show detail on error page
                        isError = true;
                        errorInvList.add(custInv.Item__r.Name);
                    }else{
                        Installation_line_Items__c instLineItem = new Installation_line_Items__c();
                        instLineItem.Installation__c = installationRec.Id;
                        instLineItem.Equipment_has_been_Installed_at__c = installationRec.Equipment_Installed_At__c;
                        instLineItem.Item__c = custInv.Item__c;
                        instLineItem.Customer_Inventory_Line_Stock__c = custInv.Id;
                        if(custInv.Quantity__c >= custInv.Installation_Quantity__c){
                            
                            instLineItem.Installed_Quantity__c = custInv.Installation_Quantity__c;
                            custInv.Quantity__c = custInv.Quantity__c - custInv.Installation_Quantity__c;
                            custInv.Installation_Quantity__c  = 0;
                            system.debug('custInv2'+custInv);
                            custInvUpdList.add(custInv);
                        }/*else if(custInv.Quantity__c < custInv.Installation_Quantity__c){
                            instLineItem.Installed_Quantity__c = custInv.Installation_Quantity__c;
                            List<Customer_Inventory_Stock__c> custInvNewList = custInvMap.get(custInv.Item__c);
                            for(Customer_Inventory_Stock__c custInv2 : custInvNewList){
                                if(custInv2 == custInv){
                                    custInv2.Quantity__c = 0;
                                    custInvUpdList.add(custInv2);
                                }else{
                                    custInv2.Quantity__c = custInv2.Quantity__c - (custInv.Installation_Quantity__c - custInv.Quantity__c);
                                    custInvUpdList.add(custInv2);
                                }
                                
                            }
                        }*/
                        newInstLineItemList.add(instLineItem);
                    }
                    
                }else{
                    system.debug('custIvName =>'+custInv.Item__r.Name);
                    if(l2L3ProdMapPerL2.containsKey(custInv.Item__r.Name) && (custInv.Quantity__c > l2L3ProdMapPerL2.get(custInv.Item__r.Name))){
                        // Error = true and store this inventory number to show detail on error page
                        isError = true;
                        errorInvList.add(custInv.Item__r.Name);
                    }else if(!l2L3ProdMapPerL2.containsKey(custInv.Item__r.Name)){
                        // Error = true and store this inventory number to show detail on error page
                        isError = true;
                        errorInvList.add(custInv.Item__r.Name);
                    }else{
                        if(custInv.Quantity__c >= custInv.Installation_Quantity__c){
                            system.debug('custInv3'+custInv);
                            Integer numberOfInstInvItem = (Integer)custInv.Installation_Quantity__c;
                            system.debug('numberOfInstInvItem'+numberOfInstInvItem);
                            for(Integer i=0; i<numberOfInstInvItem ; i++){
                                Installation_line_Items__c instLineItem = new Installation_line_Items__c();
                                instLineItem.Installation__c = installationRec.Id;
                                instLineItem.Equipment_has_been_Installed_at__c = installationRec.Equipment_Installed_At__c;
                                instLineItem.Installed_Quantity__c = 1;
                                instLineItem.Item__c = custInv.Item__c;
                                instLineItem.Customer_Inventory_Line_Stock__c = custInv.Id;
                                system.debug('instLineItem'+instLineItem);
                                newInstLineItemList.add(instLineItem);
                            }
                            custInv.Quantity__c = custInv.Quantity__c - custInv.Installation_Quantity__c;
                            custInv.Installation_Quantity__c  = 0;
                            system.debug('custInv'+custInv);
                            custInvUpdList.add(custInv);
                        }
                    }/*else if(custInv.Quantity__c < custInv.Installation_Quantity__c){
                        Integer numberOfInstInvItem = (Integer)custInv.Installation_Quantity__c;
                        for(Integer i=0; i<numberOfInstInvItem ; i++){
                            Installation_line_Items__c instLineItem = new Installation_line_Items__c();
                            instLineItem.Installation__c = installationRec.Id;
                            instLineItem.Equipment_has_been_Installed_at__c = installationRec.Equipment_Installed_At__c;
                            instLineItem.Installed_Quantity__c = 1;
                            instLineItem.Item__c = custInv.Item__c;
                            newInstLineItemList.add(instLineItem);
                            
                            List<Customer_Inventory_Stock__c> custInvNewList = custInvMap.get(custInv.Item__c);
                            for(Customer_Inventory_Stock__c custInv2 : custInvNewList){
                                if(custInv2 == custInv){
                                    custInv2.Quantity__c = 0;
                                    custInvUpdList.add(custInv2);
                                }else{
                                    custInv2.Quantity__c = custInv2.Quantity__c - (custInv.Installation_Quantity__c - custInv.Quantity__c);
                                    custInvUpdList.add(custInv2);
                                }
                            }
                        }
                    }*/
                //}
            }
        }
        
        system.debug('newInstLineItemList'+newInstLineItemList);
        system.debug('custInvUpdList'+custInvUpdList);
        
        try{
            if(isError == false){
                insert newInstLineItemList;
                update custInvUpdList;
                retWrp.Status = 'SUCCESS';
                return retWrp;
            }else{
                String errMsg = 'FAIL ';
                for(String str : errorInvList){
                    errMsg += str + ',';
                }
                errMsg = errMsg.removeEnd(',');
                errMsg += ' cannot be created because either these Inventorys Item is not present in Installation Product(L2) or Installed Qty is more than required for that L2';
                retWrp.Status = 'FAIL';
                retWrp.responseMsg = errMsg;
                retWrp.instLineItemList = newInstLineItemList;
                retWrp.custInvUpdatedList = custInvUpdList;
                retWrp.installationRecId = installationId;
                return retWrp;
            }
            
        }catch(Exception e){
            retWrp.Status = 'EXCEPTION';
            return retWrp;
        }
        
        ////////////////////////////////////////////////////////////////////////////////////////////
        ///////////////////////////////////Need to implement junction object linkage logic below////
        ///////////////////////////////////////////////////////////////////////////////////////////
        
        /*List<Customer_Inventory_Stock__c> custInvNonGroupItemList = [SELECT Id, Name, Cargo_Inspection__c, Customer__c, Item__c, Quantity__c, Where_it_is__c, 
                                                         All_Quantity_Applied__c, Installation_Date__c, Installation_Quantity__c, Invoice_Line_Item__c, 
                                                         Item_Code__c, Owned_by__c, Sales_Order__c, Part_List_Purchased_For__c, Equipment_has_been_installed_at__c, 
                                                         Equipment_has_been_purchased_for__c,Group_Items__c 
                                                         FROM Customer_Inventory_Stock__c 
                                                         WHERE Id IN: inventoryIdSet AND Group_Items__c != true];
        
        
        List<Installation_line_Items__c> installationLineItemList = [Select Id,Item__c from Installation_line_Items__c 
                                                                     where Installation__c =: installationId];
        system.debug(installationLineItemList);
        
        // This map will bring count of installation item and its line item count
        Map<Id,List<Installation_line_Items__c>> installationLineItemMap = new Map<Id,List<Installation_line_Items__c>>();
        
        for(Installation_line_Items__c instLineItem : installationLineItemList){
            if(!installationLineItemMap.containsKey(instLineItem.Item__c)){
                List<Installation_line_Items__c> instLineItemList = new List<Installation_line_Items__c>();
                instLineItemList.add(instLineItem);
                installationLineItemMap.put(instLineItem.Item__c,instLineItemList);
            }else if(installationLineItemMap.containsKey(instLineItem.Item__c)){
                List<Installation_line_Items__c> instLineItemList = installationLineItemMap.get(instLineItem.Item__c);
                instLineItemList.add(instLineItem);
                installationLineItemMap.put(instLineItem.Item__c,instLineItemList);
            }   
        }
        
        List<Inventory_Installation_Relationship__c> invInstJuncList = new List<Inventory_Installation_Relationship__c>();
        
        for(Customer_Inventory_Stock__c custInv : custInvNonGroupItemList){
            if(installationLineItemMap.containsKey(custInv.Item__c)){
                if(custInv.Quantity__c >= custInv.Installation_Quantity__c){
                    List<Installation_line_Items__c> instLineItemList = installationLineItemMap.get(custInv.Item__c);
                    for(Installation_line_Items__c instLineItem : instLineItemList){
                        Inventory_Installation_Relationship__c invInsRel = new Inventory_Installation_Relationship__c();
                        invInsRel.Inventory_Lines__c = custInv.Id;
                        invInsRel.Installation_line_Item__c = instLineItem.Id;
                        invInstJuncList.add(invInsRel);
                    }
                }else if(custInv.Quantity__c < custInv.Installation_Quantity__c){
                    List<Installation_line_Items__c> instLineItemList = installationLineItemMap.get(custInv.Item__c);
                    Integer lesserQty = (Integer)custInv.Quantity__c;
                    for(Integer i=0; i<lesserQty; i++){
                        Inventory_Installation_Relationship__c invInsRel = new Inventory_Installation_Relationship__c();
                        invInsRel.Inventory_Lines__c = custInv.Id;
                        invInsRel.Installation_line_Item__c = instLineItemList[i].Id;
                        invInstJuncList.add(invInsRel);
                    }
                }
            }
        }
        
        /*for(Installation_line_Items__c instLineItem : installationLineItemList){
            if(instLineItem.Installed_Quantity__c == 1){
                for(Customer_Inventory_Stock__c custInv : custInvNonGroupItemList){
                    if(custInv.Item__c == instLineItem.Item__c){
                        if(custInv.Quantity__c >= custInv.Installation_Quantity__c){
                            Inventory_Installation_Relationship__c invInsRel = new Inventory_Installation_Relationship__c();
                            
                        }
                    }
                }
            }else{
                
            }
        }*/
        
        
    }
    
    /*public class wrapper{
        public Decimal itemQtyInInv= 0;
        public Decimal qtyForInst= 0;
    }*/
    
    public class ReturnWrapper{
        @auraEnabled
        public String status {get;set;}
        
        @auraEnabled
        public String responseMsg {get;set;}
        
        @auraEnabled
        public String installationRecId {get;set;}
        
        @auraEnabled
        public List<Installation_line_Items__c> instLineItemList {get;set;}
        
        @auraEnabled
        public List<Customer_Inventory_Stock__c> custInvUpdatedList {get;set;}
    }
    
}