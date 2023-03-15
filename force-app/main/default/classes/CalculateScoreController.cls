public with sharing class CalculateScoreController implements Queueable, Database.allowscallouts{
	
    List<Inventory_Score_Relationship__c> invPartRelList;
    Integer iterator;
    
    public CalculateScoreController(List<Inventory_Score_Relationship__c> invPartRelList, Integer iterator){
        this.invPartRelList = invPartRelList;
        this.iterator = iterator;
    }
    
    public void execute(QueueableContext qc){
        
        List<Virtual_Inventory_Line__c> virtualInvLineList = [SELECT Id, Name, Customer_Inventory_Line_Stock__c,Used_Quantity__c, 
                                                              Residual_Quantity__c, Zone_Priority_Selection__c, Score__c, Customer_Inventory_Line_Stock__r.Item__r.Name, 
                                                              Customer_Inventory_Line_Stock__r.Quantity__c,Inventory_Score_Simulation__c ,Original_Quantity__c
                                                              FROM Virtual_Inventory_Line__c 
                                                              WHERE Inventory_Score_Simulation__c =: invPartRelList[iterator].Inventory_Score_Simulation__c AND 
                                                              Zone_Priority_Selection__c = ''];
        system.debug('virtualInvLineList => '+virtualInvLineList);
        
        List<Zone_Priority_Selection__c> zpsList = [SELECT Id, Name, Zone_L2__c, Priority__c, Inventory_Part_List_Relationship__c, Part_List__c, Score__c, 
                                              Zone_L2Name__c, Zone_L2__r.Name, No_of_Set__c FROM Zone_Priority_Selection__c 
                                              WHERE Inventory_Part_List_Relationship__c =: invPartRelList[iterator].Id];
        system.debug('zpsList => '+zpsList);
        
        Set<Id> zpsIds = new Set<Id>();
        for(Zone_Priority_Selection__c zps : zpsList){
            zpsIds.add(zps.Id);
        }
        
        List<L2_L3_product__c> l2l3ProdList = [SELECT Id, Name, Product_L2__c, Product_L2__r.Name, Product_L3__c, Product_L3__r.Name, Quantity__c, Part_List__c 
                                               FROM L2_L3_product__c 
                                               WHERE Part_List__c =: invPartRelList[iterator].Part_List__c];
        system.debug('l2l3ProdList => '+l2l3ProdList);
        
        Integer sizeOfPriorityMap = 0;
        Integer sizeOfPriorityMap2 = 0;
        Map<Decimal,String> priorityMap = new Map<Decimal,String>();
        Map<String,Zone_Priority_Selection__c> zonePriorityMap = new Map<String,Zone_Priority_Selection__c>();
        for(Zone_Priority_Selection__c zps : zpsList){
            priorityMap.put(zps.Priority__c,zps.Zone_L2Name__c);
            zonePriorityMap.put(zps.Zone_L2__r.Name,zps);
            sizeOfPriorityMap++;
            sizeOfPriorityMap2++;
        }
        system.debug('priorityMap => '+priorityMap);
        
        List<L2_L3_product__c> sortedl2l3ProdList = new List<L2_L3_product__c>();
        
        Integer tempValue = 1;
        while(sizeOfPriorityMap != 0){
            for(L2_L3_product__c l2l3Item : l2l3ProdList){
                if(l2l3Item.Product_L2__r.Name == priorityMap.get(tempValue)){
                    sortedl2l3ProdList.add(l2l3Item);
                }
            }
            tempValue++;
            sizeOfPriorityMap--;
        }
        system.debug('sortedl2l3ProdList => '+sortedl2l3ProdList);
        
        //Example : L3item, list<{(FEH, 10), (DEH,11), (Shell,29)}
        Map<String,List<Wrapper>> wrapperMap = new Map<String,List<Wrapper>>();
        Map<String,Decimal> totalPresentItemMap = new Map<String,Decimal>();
        
        for(L2_L3_product__c l2l3Item : sortedl2l3ProdList){
            if(!totalPresentItemMap.containsKey(l2l3Item.Product_L2__r.Name)){
                Decimal item = 1;
                totalPresentItemMap.put(l2l3Item.Product_L2__r.Name,item);
            }else if(totalPresentItemMap.containsKey(l2l3Item.Product_L2__r.Name)){
                Decimal item = totalPresentItemMap.get(l2l3Item.Product_L2__r.Name);
                item += 1;
                totalPresentItemMap.put(l2l3Item.Product_L2__r.Name,item);
            }
            
            if(!wrapperMap.containsKey(l2l3Item.Product_L3__r.Name)){
                List<Wrapper> tempWrapperList = new List<Wrapper>();
                Wrapper wrp = new Wrapper();
                wrp.L2Level = l2l3Item.Product_L2__r.Name;
                wrp.Quantity = l2l3Item.Quantity__c;
                tempWrapperList.add(wrp);
                wrapperMap.put(l2l3Item.Product_L3__r.Name,tempWrapperList);
            }else{
                List<Wrapper> tempWrapperList = wrapperMap.get(l2l3Item.Product_L3__r.Name);
                Wrapper wrp = new Wrapper();
                wrp.L2Level = l2l3Item.Product_L2__r.Name;
                wrp.Quantity = l2l3Item.Quantity__c;
                tempWrapperList.add(wrp);
                wrapperMap.put(l2l3Item.Product_L3__r.Name,tempWrapperList);
            }
        }
        system.debug('wrapperMap => '+wrapperMap);
        system.debug('totalPresentItemMap => '+totalPresentItemMap);
        
        // This map will have L3ProdName as key so that later we can update residualQty at ISS Level for each entry
        Map<String,Virtual_Inventory_Line__c> virtualInventoryMap = new Map<String,Virtual_Inventory_Line__c>();
        for(Virtual_Inventory_Line__c virInv : virtualInvLineList){
        	virtualInventoryMap.put(virInv.Customer_Inventory_Line_Stock__r.Item__r.Name,virInv);
        }
        system.debug('virtualInventoryMap => '+virtualInventoryMap);
        
        Map<String,Decimal> virtualInventoryMap2 = new Map<String,Decimal>();
        
        Map<String,List<Wrapper2>> wrapper2Map = new Map<String,List<Wrapper2>>();
        
        // To insert virtual inventory lines at ZPS Level
        List<Virtual_Inventory_Line__c> zoneVirtualInvLineList = new List<Virtual_Inventory_Line__c>();
        
        
        //Example : L3item, list<{(FEH, 10), (DEH,11), (Shell,29)}
        // Will traverse on above example and Virtual Inventory List at ISS Level
        Decimal L2SetQty = invPartRelList[iterator].L2_Set_Qty__c;
        for(String l3Name : wrapperMap.keySet()){
        	if(virtualInventoryMap.containsKey(l3Name)){
                // Match found
        		Virtual_Inventory_Line__c virInv = virtualInventoryMap.get(l3Name);
                Decimal inventoryItemQty;
                if(virInv.Used_Quantity__c != null){
                	inventoryItemQty = virInv.Original_Quantity__c - virInv.Used_Quantity__c;    
                }else{
                    inventoryItemQty = virInv.Original_Quantity__c;
                }
                
                
                List<Wrapper> wrpList = wrapperMap.get(l3Name);
                while(inventoryItemQty > 0){
                    for(Wrapper wrp : wrpList){
                        // This will traverse one by one on Feh, deh, shell etc.
                        Decimal wrpPerL2L3Qty = wrp.Quantity * L2SetQty;
                        if(inventoryItemQty > 0 && inventoryItemQty > wrpPerL2L3Qty){
                            
                            // ISS LEVEL QUANTITY DEDUCT
                            inventoryItemQty = inventoryItemQty - wrpPerL2L3Qty;
							system.debug('inventoryItemQty =>'+inventoryItemQty);
                            
                            if(!wrapper2Map.containsKey(l3Name)){
                                system.debug('Inside if loop of 111');
                                List<Wrapper2> tempWrapper2List = new List<Wrapper2>();
                                Wrapper2 wrp2 = new Wrapper2();
                                wrp2.L2Level = wrp.L2Level;
                                wrp2.ScorePerL3 = L2SetQty*100;
                                if(wrp.Quantity > 0){
                                    wrp2.Existance = 1;
                                }
                                tempWrapper2List.add(wrp2);
                                wrapper2Map.put(l3Name,tempWrapper2List);
                                
                                // Adding in a list to create all zone level virtual inventory at one go with residual quantity and score as well
                                Virtual_Inventory_Line__c zoneVirInv = new Virtual_Inventory_Line__c();
                                Zone_Priority_Selection__c zps = zonePriorityMap.get(wrp.L2Level);
                                zoneVirInv.Id = null;
                                //zoneVirInv.Inventory_Score_Simulation__c = virInv.Inventory_Score_Simulation__c;
                                zoneVirInv.Customer_Inventory_Line_Stock__c = virInv.Customer_Inventory_Line_Stock__c;
                                zoneVirInv.Zone_Priority_Selection__c = zps.Id;
                                zoneVirInv.Score__c = (wrp2.ScorePerL3/wrp2.Existance);
                                zoneVirInv.Residual_Quantity__c = inventoryItemQty;
                                zoneVirInv.Used_Quantity__c = wrpPerL2L3Qty;
                                //zoneVirInv.Original_Quantity__c = virInv.Original_Quantity__c;
                                zoneVirtualInvLineList.add(zoneVirInv);
								system.debug('zoneVirtualInvLineList =>'+zoneVirtualInvLineList);
                                
                                if(!virtualInventoryMap2.containsKey(l3Name)){
                                    if(virInv.Used_Quantity__c == null){
                                        virtualInventoryMap2.put(l3Name,wrpPerL2L3Qty);
                                    }else{
                                        Decimal calculateUsedInv = virInv.Used_Quantity__c + wrpPerL2L3Qty;
                                    }
                                    
                                }else if(virtualInventoryMap2.containsKey(l3Name)){
                                    Decimal existInvValue = virtualInventoryMap2.get(l3Name);
                                    if(virInv.Used_Quantity__c == null){
                                        existInvValue = existInvValue + wrpPerL2L3Qty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }else{
                                        existInvValue = existInvValue + virInv.Used_Quantity__c + wrpPerL2L3Qty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }
                                    
                                }
                            
                            }else{
                                List<Wrapper2> tempWrapper2List = wrapper2Map.get(l3Name);
                                Boolean isAlreadyExist = false;
                                for(Wrapper2 wrpTemp : tempWrapper2List){
                                    if(wrpTemp.L2Level == wrp.L2Level){
                                        isAlreadyExist = true;
                                    }
                                }
                                Wrapper2 wrp2;
                                if(isAlreadyExist == false){
                                    wrp2 = new Wrapper2();
                                }else{
                                    for(Wrapper2 wrpTemp : tempWrapper2List){
                                        if(wrpTemp.L2Level == wrp.L2Level){
                                            wrp2 = wrpTemp;
                                        }
                                    }
                                }
                                wrp2.L2Level = wrp.L2Level;
                                wrp2.ScorePerL3 = L2SetQty*100;
                                if(wrp.Quantity > 0){
                                    wrp2.Existance = 1;
                                }
                                tempWrapper2List.add(wrp2);
                                wrapper2Map.put(l3Name,tempWrapper2List);
                                
                                // Adding in a list to create all zone level virtual inventory at one go with residual quantity and score as well
                                Virtual_Inventory_Line__c zoneVirInv = new Virtual_Inventory_Line__c();
                                Zone_Priority_Selection__c zps = zonePriorityMap.get(wrp.L2Level);
                                zoneVirInv.Id = null;
                                //zoneVirInv.Inventory_Score_Simulation__c = virInv.Inventory_Score_Simulation__c;
                                zoneVirInv.Customer_Inventory_Line_Stock__c = virInv.Customer_Inventory_Line_Stock__c;
                                zoneVirInv.Zone_Priority_Selection__c = zps.Id;
                                zoneVirInv.Score__c = (wrp2.ScorePerL3/wrp2.Existance);
                                zoneVirInv.Residual_Quantity__c = inventoryItemQty;
                                zoneVirInv.Used_Quantity__c = wrpPerL2L3Qty;
                                //zoneVirInv.Original_Quantity__c = virInv.Original_Quantity__c;
                                zoneVirtualInvLineList.add(zoneVirInv);
								system.debug('zoneVirtualInvLineList =>'+zoneVirtualInvLineList);
                                
                                if(!virtualInventoryMap2.containsKey(l3Name)){
                                    if(virInv.Used_Quantity__c == null){
                                        virtualInventoryMap2.put(l3Name,wrpPerL2L3Qty);
                                    }else{
                                        Decimal calculateUsedInv = virInv.Used_Quantity__c + wrpPerL2L3Qty;
                                    }
                                    
                                }else if(virtualInventoryMap2.containsKey(l3Name)){
                                    Decimal existInvValue = virtualInventoryMap2.get(l3Name);
                                    if(virInv.Used_Quantity__c == null){
                                        existInvValue = existInvValue + wrpPerL2L3Qty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }else{
                                        existInvValue = existInvValue + virInv.Used_Quantity__c + wrpPerL2L3Qty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }
                                    
                                }
                            }
                        }else if(inventoryItemQty > 0 && inventoryItemQty < wrpPerL2L3Qty){
                            // This case will happen when Inventory Item is less available than required quantities
                            if(!wrapper2Map.containsKey(l3Name)){
                                List<Wrapper2> tempWrapper2List = new List<Wrapper2>();
                                Wrapper2 wrp2 = new Wrapper2();
                                wrp2.L2Level = wrp.L2Level;
                                wrp2.ScorePerL3 = (inventoryItemQty/wrp.Quantity)*100;
                                if(wrp.Quantity > 0){
                                    wrp2.Existance = 1;
                                }
                                tempWrapper2List.add(wrp2);
                                wrapper2Map.put(l3Name,tempWrapper2List);
                                
                                // Adding in a list to create all zone level virtual inventory at one go with residual quantity and score as well
                                Virtual_Inventory_Line__c zoneVirInv = new Virtual_Inventory_Line__c();
                                Zone_Priority_Selection__c zps = zonePriorityMap.get(wrp.L2Level);
                                zoneVirInv.Id = null;
                                //zoneVirInv.Inventory_Score_Simulation__c = virInv.Inventory_Score_Simulation__c;
                                zoneVirInv.Customer_Inventory_Line_Stock__c = virInv.Customer_Inventory_Line_Stock__c;
                                zoneVirInv.Zone_Priority_Selection__c = zps.Id;
                                zoneVirInv.Score__c = (wrp2.ScorePerL3/wrp2.Existance);
                                //zoneVirInv.Residual_Quantity__c = wrpPerL2L3Qty - inventoryItemQty;
                                zoneVirInv.Residual_Quantity__c = 0;
                                zoneVirInv.Used_Quantity__c = inventoryItemQty;
                                //zoneVirInv.Original_Quantity__c = virInv.Original_Quantity__c;
                                zoneVirtualInvLineList.add(zoneVirInv);
								system.debug('zoneVirtualInvLineList =>'+zoneVirtualInvLineList);
                                
                                if(!virtualInventoryMap2.containsKey(l3Name)){
                                    if(virInv.Used_Quantity__c == null){
                                        virtualInventoryMap2.put(l3Name,inventoryItemQty);
                                    }else{
                                        Decimal calculateUsedInv = virInv.Used_Quantity__c + inventoryItemQty;
                                        virtualInventoryMap2.put(l3Name,calculateUsedInv);
                                    }
                                    
                                }else if(virtualInventoryMap2.containsKey(l3Name)){
                                    Decimal existInvValue = virtualInventoryMap2.get(l3Name);
                                    if(virInv.Used_Quantity__c == null){
                                        existInvValue = existInvValue + inventoryItemQty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }else{
                                        existInvValue = existInvValue + virInv.Used_Quantity__c + inventoryItemQty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }
                                    
                                }
                                
                                inventoryItemQty = 0;
                                
                            }else{
                                List<Wrapper2> tempWrapper2List = wrapper2Map.get(l3Name);
                                Boolean isAlreadyExist = false;
                                for(Wrapper2 wrpTemp : tempWrapper2List){
                                    if(wrpTemp.L2Level == wrp.L2Level){
                                        isAlreadyExist = true;
                                    }
                                }
                                Wrapper2 wrp2;
                                if(isAlreadyExist == false){
                                    wrp2 = new Wrapper2();
                                }else{
                                    for(Wrapper2 wrpTemp : tempWrapper2List){
                                        if(wrpTemp.L2Level == wrp.L2Level){
                                            wrp2 = wrpTemp;
                                        }
                                    }
                                }
                                wrp2.L2Level = wrp.L2Level;
                                wrp2.ScorePerL3 =(inventoryItemQty/wrp.Quantity)*100;
                                if(wrp.Quantity > 0){
                                    wrp2.Existance = 1;
                                }
                                tempWrapper2List.add(wrp2);
                                wrapper2Map.put(l3Name,tempWrapper2List);
                                
                                // Adding in a list to create all zone level virtual inventory at one go with residual quantity and score as well
                                Virtual_Inventory_Line__c zoneVirInv = new Virtual_Inventory_Line__c();
                                Zone_Priority_Selection__c zps = zonePriorityMap.get(wrp.L2Level);
                                zoneVirInv.Id = null;
                                //zoneVirInv.Inventory_Score_Simulation__c = virInv.Inventory_Score_Simulation__c;
                                zoneVirInv.Customer_Inventory_Line_Stock__c = virInv.Customer_Inventory_Line_Stock__c;
                                zoneVirInv.Zone_Priority_Selection__c = zps.Id;
                                zoneVirInv.Score__c = (wrp2.ScorePerL3/wrp2.Existance);
                                //zoneVirInv.Residual_Quantity__c = wrpPerL2L3Qty - inventoryItemQty;
                                zoneVirInv.Residual_Quantity__c = 0;
                                zoneVirInv.Used_Quantity__c = inventoryItemQty;
                                //zoneVirInv.Original_Quantity__c = virInv.Original_Quantity__c;
                                zoneVirtualInvLineList.add(zoneVirInv);
								system.debug('zoneVirtualInvLineList =>'+zoneVirtualInvLineList);
                                
                                if(!virtualInventoryMap2.containsKey(l3Name)){
                                    if(virInv.Used_Quantity__c == null){
                                        virtualInventoryMap2.put(l3Name,inventoryItemQty);
                                    }else{
                                        Decimal calculateUsedInv = virInv.Used_Quantity__c + inventoryItemQty;
                                    }
                                    
                                }else if(virtualInventoryMap2.containsKey(l3Name)){
                                    Decimal existInvValue = virtualInventoryMap2.get(l3Name);
                                    if(virInv.Used_Quantity__c == null){
                                        existInvValue = existInvValue + inventoryItemQty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }else{
                                        existInvValue = existInvValue + virInv.Used_Quantity__c + inventoryItemQty;
                                        virtualInventoryMap2.put(l3Name,existInvValue);
                                    }
                                    
                                }
                                
                                inventoryItemQty = 0;
                            } 
                        }else if(inventoryItemQty <= 0){
                            break;
                        }
                    }
                    
                    //AK 19/01/22 Fix
                    if(inventoryItemQty > 0){
                        inventoryItemQty = 0;
                    }
                }
            }else if(!virtualInventoryMap.containsKey(l3Name)){
                List<Wrapper> wrpList = wrapperMap.get(l3Name);
                for(Wrapper wrp : wrpList){
                    if(!wrapper2Map.containsKey(l3Name)){
                        List<Wrapper2> tempWrapper2List = new List<Wrapper2>();
                        Wrapper2 wrp2 = new Wrapper2();
                        wrp2.L2Level = wrp.L2Level;
                        wrp2.ScorePerL3 = 0;
                        wrp2.Existance = 1;
                        tempWrapper2List.add(wrp2);
                        wrapper2Map.put(l3Name,tempWrapper2List);
                    }else{
                        List<Wrapper2> tempWrapper2List = wrapper2Map.get(l3Name);
                        Boolean isAlreadyExist = false;
                        for(Wrapper2 wrpTemp : tempWrapper2List){
                            if(wrpTemp.L2Level == wrp.L2Level){
                                isAlreadyExist = true;
                            }
                        }
                        Wrapper2 wrp2;
                        if(isAlreadyExist == false){
                            wrp2 = new Wrapper2();
                        }else{
                            for(Wrapper2 wrpTemp : tempWrapper2List){
                                if(wrpTemp.L2Level == wrp.L2Level){
                                    wrp2 = wrpTemp;
                                }
                            }
                        }
                        wrp2.L2Level = wrp.L2Level;
                        wrp2.ScorePerL3 = 0;
                        wrp2.Existance = 1;
                        tempWrapper2List.add(wrp2);
                        wrapper2Map.put(l3Name,tempWrapper2List);
                    }
                }
            }
        }
        
        system.debug('wrapper2Map => '+wrapper2Map);
        system.debug('zoneVirtualInvLineList => '+zoneVirtualInvLineList);
        
        // Inserting Virtual Lines at ZPS Level for one Inventory PartList Relationship
        insert zoneVirtualInvLineList;
        
        // This final list of map will have L2 as key and then total score for each L2 as value
        List<Map<String,Wrapper3>> totalScoreList = new List<Map<String,Wrapper3>>();
        
        Integer tempValue2 = 1; 
        while(sizeOfPriorityMap2 != 0){
        	Map<String,Wrapper3> scoreMap = new Map<String,Wrapper3>();
        	for(String l3Name : wrapper2Map.keySet()){
        		List<Wrapper2> wrp2List = wrapper2Map.get(l3Name);
                for(Wrapper2 wrp2 : wrp2List){
        			if(wrp2.L2Level == priorityMap.get(tempValue2)){
        				if(!scoreMap.containsKey(wrp2.L2Level) && wrp2.ScorePerL3 != 0){   
        					Wrapper3 wrp3 = new Wrapper3();
        					wrp3.L2Level = wrp2.L2Level;
                            wrp3.totalScorePerL2 += (wrp2.ScorePerL3 * wrp2.Existance)/100;
                            wrp3.totalExistance += wrp2.Existance;
                            scoreMap.put(wrp3.L2Level,wrp3);
                        }else if(scoreMap.containsKey(wrp2.L2Level) && wrp2.ScorePerL3 != 0){
                            Wrapper3 wrp3 = scoreMap.get(wrp2.L2Level);
                            wrp3.L2Level = wrp2.L2Level;
                            wrp3.totalScorePerL2 += (wrp2.ScorePerL3 * wrp2.Existance)/100;
                            wrp3.totalExistance += wrp2.Existance;
                            scoreMap.put(wrp3.L2Level,wrp3);
                        }else if(!scoreMap.containsKey(wrp2.L2Level) && wrp2.ScorePerL3 == 0){
                            Wrapper3 wrp3 = new Wrapper3();
        					wrp3.L2Level = wrp2.L2Level;
                            wrp3.totalScorePerL2 += 0;
                            wrp3.totalExistance += wrp2.Existance;
                            wrp3.absentItems += 1;
                            scoreMap.put(wrp3.L2Level,wrp3);
                        }else if(scoreMap.containsKey(wrp2.L2Level) && wrp2.ScorePerL3 == 0){
                            Wrapper3 wrp3 = scoreMap.get(wrp2.L2Level);
                            wrp3.L2Level = wrp2.L2Level;
                            wrp3.totalScorePerL2 += 0;
                            wrp3.totalExistance += wrp2.Existance;
                            wrp3.absentItems += 1;
                            scoreMap.put(wrp3.L2Level,wrp3);
                        }
                    }/*else if(wrp2.ScorePerL3 == 0){
                        if(totalScoreList.size() == 0){   
        					Wrapper3 wrp3 = new Wrapper3();
        					wrp3.L2Level = wrp2.L2Level;
                            wrp3.totalScorePerL2 += 0;
                            wrp3.totalExistance += wrp2.Existance;
                            wrp3.absentItems += 1;
                            scoreMap.put(wrp3.L2Level,wrp3);
                        }else{
                            Wrapper3 wrp3 = scoreMap.get(wrp2.L2Level);
                            wrp3.L2Level = wrp2.L2Level;
                            wrp3.totalScorePerL2 += 0;
                            wrp3.totalExistance += wrp2.Existance;
                            wrp3.absentItems += 1;
                            scoreMap.put(wrp3.L2Level,wrp3);
                        }
                    }*/
                }
            }
            if(!scoreMap.isEmpty()){
                totalScoreList.add(scoreMap);
            }
            tempValue2++;
            sizeOfPriorityMap2--;
        }
        
        system.debug('totalScoreList => '+totalScoreList);
        
        List<Virtual_Inventory_Line__c> virtualInvLineListZoneLevel = [SELECT Id, Name, Customer_Inventory_Line_Stock__c, 
                                                              Residual_Quantity__c, Zone_Priority_Selection__c, Score__c, Customer_Inventory_Line_Stock__r.Item__r.Name, 
                                                              Customer_Inventory_Line_Stock__r.Quantity__c,Inventory_Score_Simulation__c ,Original_Quantity__c
                                                              FROM Virtual_Inventory_Line__c 
                                                              WHERE Zone_Priority_Selection__c IN: zpsIds];
        
        Map<Id,Decimal> virtualInvLinePerZoneMap = new Map<Id,Decimal>();
        for(Virtual_Inventory_Line__c virInv : virtualInvLineListZoneLevel){
            if(!virtualInvLinePerZoneMap.containsKey(virInv.Zone_Priority_Selection__c)){
                Decimal listSize = 1;
                virtualInvLinePerZoneMap.put(virInv.Zone_Priority_Selection__c,listSize);
            }else if(virtualInvLinePerZoneMap.containsKey(virInv.Zone_Priority_Selection__c)){
                Decimal listSize = virtualInvLinePerZoneMap.get(virInv.Zone_Priority_Selection__c);
                listSize++;
                virtualInvLinePerZoneMap.put(virInv.Zone_Priority_Selection__c,listSize);
            }
        }
        system.debug('virtualInvLinePerZoneMap => '+virtualInvLinePerZoneMap);
        
        // This ZPS is calculating at ISS Level
        for(Zone_Priority_Selection__c zps : zpsList){
            Decimal score = 0;
            for(Integer i=0;i<totalScoreList.size();i++){
                Map<String,Wrapper3> finalMapIterator = totalScoreList[i];
                Wrapper3 wrp = finalMapIterator.get(zps.Zone_L2Name__c);
                if(wrp != null && wrp.L2Level != ''){
                    score = (wrp.totalScorePerL2/wrp.totalExistance)*100;
                    Decimal presentItems = virtualInvLinePerZoneMap.get(zps.Id);
                    if(presentItems != null){
                        system.debug('zps.Zone_L2Name__c =>'+zps.Zone_L2Name__c);
                        Decimal totalItems = totalPresentItemMap.get(zps.Zone_L2Name__c);
                        zps.No_of_Absent_Items__c = totalItems - presentItems;
                    }
                    
                }
            }
            zps.Score__c = score;
            
        }
        
        //Add logic to update residualQty in Virtual Inventory Lines ISS Level
        
        system.debug('zpsList => '+zpsList);
        
        update zpsList;
        
        for(Virtual_Inventory_Line__c virInv : virtualInvLineList){
            if(virtualInventoryMap2.containsKey(virInv.Customer_Inventory_Line_Stock__r.Item__r.Name)){
                Decimal usedQtyPerL3 = virtualInventoryMap2.get(virInv.Customer_Inventory_Line_Stock__r.Item__r.Name);
                Decimal totalInventoryPerL3 = virInv.Customer_Inventory_Line_Stock__r.Quantity__c;
                system.debug('usedQtyPerL3 =>'+usedQtyPerL3);
                system.debug('totalInventoryPerL3 =>'+totalInventoryPerL3);
                if(totalInventoryPerL3 > usedQtyPerL3){
                    virInv.Used_Quantity__c = usedQtyPerL3;
                	virInv.Residual_Quantity__c = totalInventoryPerL3 - usedQtyPerL3;
                }else{
                    virInv.Used_Quantity__c = usedQtyPerL3;
                    virInv.Residual_Quantity__c = 0;
                }
				system.debug('virInv =>'+virInv);                
            }
        }
        
        update virtualInvLineList;
        
        iterator++;
        if(iterator < invPartRelList.size()){
            if(!test.isRunningTest()){
                system.enqueueJob(new CalculateScoreController(invPartRelList, iterator));}
        }
    }
    
    public class Wrapper{
        public String L2Level;
        public Decimal Quantity;
    }
    public class Wrapper2{
        public String L2Level;
        public Decimal ScorePerL3;
        public Decimal Existance = 0;
    }
    public class Wrapper3{
        public String L2Level;
        public Decimal totalScorePerL2 = 0;
        public Decimal totalExistance = 0;
        public Decimal absentItems = 0;
    }
}