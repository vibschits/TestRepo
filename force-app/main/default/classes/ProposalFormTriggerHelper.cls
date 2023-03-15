/*
Name : ProposalFormTriggerHelper 
Desc : This is a handler class of ProposalFormTriggerHandler
US :
*/
public class ProposalFormTriggerHelper {
    
    public void checkEquipmentType(List<Proposal_Form__c> newOppEquipList){
        try{        
            Set<Id> oppFromOppEquipSet = new Set<Id>();
            Set<Id> custEquipFromOppEquipSet = new Set<Id>();
            Set<Id> custIdFromOppEquipSet = new Set<Id>();
            
            // Adding values in Set for Trigger Bulkification Purpose
            for(Proposal_Form__c oppEquip : newOppEquipList){
                oppFromOppEquipSet.add(oppEquip.Opportunity__c);
                custEquipFromOppEquipSet.add(oppEquip.Customer_Equipment__c);
            }
            
            // All Opportunities which are related to upcoming Opportunities Equipment records
            List<Opportunity> oppFromOppEquipRecordList = [Select Id, RecordType.Name,AccountId from Opportunity where Id IN: oppFromOppEquipSet];
            
            // All Customer Equipment which are related to upcoming Opportunities Equipment records
            List<Customer_Equipments__c> custEquipFromOppEquipRecordList = [Select Id, RecordType.Name,Customer__c from Customer_Equipments__c where Id IN: custEquipFromOppEquipSet];
            
            // Getting Customer Ids from all related Opportunities which are linked to Opportunity Equipments
            for(Opportunity opp : oppFromOppEquipRecordList){
                custIdFromOppEquipSet.add(opp.AccountId);
            }
            
            // All Customer Equipments who have customer id which was retrieved in last step
            List<Customer_Equipments__c> custEquipList = [Select Id,RecordType.Name,Customer__c from Customer_Equipments__c where Customer__c IN: custIdFromOppEquipSet];
            
            Map<Id,List<Customer_Equipments__c>> custEquipMap = new Map<Id,List<Customer_Equipments__c>>();
            
            // Converting List to Map<Id, List<Customer_Equipments__c>> to save same customer equipment in one list 
            for(Customer_Equipments__c custEquip : custEquipList){
                if(custEquipMap.containsKey(custEquip.Id)){
                    List<Customer_Equipments__c> custEquip2 = custEquipMap.get(custEquip.Id);
                    custEquip2.add(custEquip);
                    custEquipMap.put(custEquip.Id, custEquip2);
                }else{
                    custEquipMap.put(custEquip.Id,new List<Customer_Equipments__c> { custEquip });
                }
            }
            
            // Below object will store that Customer Equipment which is being modified
            Customer_Equipments__c custEquipToCompare = new Customer_Equipments__c();
            
            // Checking if Id which is coming in new customer equipment exists in map of all equip related to customer.
            for(Customer_Equipments__c custEquip : custEquipFromOppEquipRecordList){
                if(custEquipMap.containsKey(custEquip.Id)){
                    List<Customer_Equipments__c> custEquip2 = custEquipMap.get(custEquip.Id);
                    for(Customer_Equipments__c custEquip3 : custEquip2){
                        if(custEquip3.Customer__c == custEquip.Customer__c){
                            custEquipToCompare = custEquip;
                        }
                    }
                }
            }
            
            // Throw error message if Equipment which is being selected while creating Opportunity Equipment record doesnot belong to same customer which is linked with Opportunity
            If(custEquipToCompare.Id != null){  
                Proposal_Form__c oppEquip = new Proposal_Form__c();
                for(Proposal_Form__c oppEquipLoop : newOppEquipList){
                    if(oppEquipLoop.Customer_Equipment__c == custEquipToCompare.Id){
                        oppEquip = oppEquipLoop;
                    }
                }
                String custEquipFromOppEquip_RecordType = custEquipToCompare.RecordType.Name;
                Id OpportunityId = oppEquip.Opportunity__c;
                Opportunity opp = [Select Id, RecordType.Name,AccountId from Opportunity where Id =: OpportunityId];
                String oppFromOppEquip_RecordType = opp.RecordType.Name;
                if(custEquipFromOppEquip_RecordType != oppFromOppEquip_RecordType){
                    oppEquip.addError(System.Label.Equipment_of_different_PMG);
                }
            }else{
                for(Proposal_Form__c oppEquipLoop : newOppEquipList){
                    if(oppEquipLoop.Customer_Equipment__c != null){
                        oppEquipLoop.addError(System.Label.Equipment_belongs_to_different_customer);
                    }
                }
            }
        }catch(exception e){
            TegaUtility.trackLogs(e, 'ProposalFormTriggerHelper', 'defaultDesignParameter');
        }
    }

    public void defaultDesignParameter(List<Proposal_Form__c> newOppEquipList){
        try{    
            Set<Id> custEquipIdSet = new Set<Id>();
            //Opportunity_Equipment__c oppEquip = newOppEquipList[0];
            for(Proposal_Form__c oppEquip : newOppEquipList){
                if(oppEquip.Customer_Equipment__c != null){
                    custEquipIdSet.add(oppEquip.Customer_Equipment__c);
                }
            }
            
            // All Design Parameters linked with coming Equipments of OE.
            List<Design_Parameter__c> desParamList = [SELECT Id, CreatedDate, LastModifiedDate, Customer_Equipment__c 
                                                        FROM Design_Parameter__c 
                                                        Where Customer_Equipment__c IN: custEquipIdSet ORDER BY CreatedDate DESC];
            
            // This Map Links Customer_Equipment ID with all it's Design Parameters.
            Map<Id,List<Design_Parameter__c>> desParamMap = new Map<Id,List<Design_Parameter__c>>();
            for(Design_Parameter__c dP : desParamList){
                if(desParamMap.containsKey(dP.Customer_Equipment__c)){
                    List<Design_Parameter__c> dpParam2 = desParamMap.get(dP.Customer_Equipment__c);
                    dpParam2.add(dP);
                    desParamMap.put(dP.Customer_Equipment__c,dpParam2);
                }else{
                    desParamMap.put(dP.Customer_Equipment__c,new List<Design_Parameter__c> { dP });
                }
            }
            
            for(Proposal_Form__c oppEquip : newOppEquipList){
                if(desParamMap.containsKey(oppEquip.Customer_Equipment__c)){
                    if(oppEquip.Design_Parameter__c == null){
                        // Since we are already fetching OP based on Desc Created Date therefore we can take [0] as first value is recently created.
                        Design_Parameter__c dP = desParamMap.get(oppEquip.Customer_Equipment__c)[0];
                        oppEquip.Design_Parameter__c = dP.Id;
                    }
                }
            }
        }catch(exception e){
            TegaUtility.trackLogs(e, 'ProposalFormTriggerHelper', 'defaultDesignParameter');
        }
    }

}