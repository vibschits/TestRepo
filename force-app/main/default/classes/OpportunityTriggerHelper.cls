/*
Name : OpportunityTriggerHelper
Desc : This is a handler class of OpportunityTriggerHandler
US :
*/
public class OpportunityTriggerHelper {
	
    public void checkChildOpp(List<Opportunity> newOppList){
        try{
            Set<Id> parentOppIds = new Set<Id>();
            
            // Taking all parent opportunity ids from new records.
            
            for(Opportunity Opp : newOppList){
                if(Opp.Parent_Opportunity__c != null){
                     parentOppIds.add(Opp.Parent_Opportunity__c);
                }
            }
            system.debug('parentOppIds '+parentOppIds);
             system.debug('parentOppIds '+parentOppIds.size());
            
            // Fetching all Opportunities linked with Parent Opportunity Ids
            
            List<Opportunity> relatedToParentOppList = new list<Opportunity>();
            if(parentOppIds.size() > 0){
                
                relatedToParentOppList = [SELECT Id, Name, RecordTypeId, Parent_Opportunity__c 
                                          FROM Opportunity where Parent_Opportunity__c IN :parentOppIds];
                system.debug('Inside If');
            }
            system.debug('relatedToParentOppList '+relatedToParentOppList);
            
            Map<Id,List<Opportunity>> relatedToParentOppMap = new Map<Id,List<Opportunity>>();
            
            /* Converting List to Map<Parent Opportunity Id, Opportunity> to later use this map 
             to compare new record and old related records with same parent opportunity id */
            
            for(Opportunity Opp : relatedToParentOppList){
                if(relatedToParentOppMap.containsKey(Opp.Parent_Opportunity__c)){
                    List<Opportunity> Opp2 = relatedToParentOppMap.get(Opp.Parent_Opportunity__c);
                    system.debug('Opp2 '+Opp2);
                    Opp2.add(Opp);
                    relatedToParentOppMap.put(Opp.Parent_Opportunity__c, Opp2);
                    system.debug('relatedToParentOppMap '+relatedToParentOppMap);
                }else{
                    relatedToParentOppMap.put(Opp.Parent_Opportunity__c,new List<Opportunity> { Opp });
                    system.debug('relatedToParentOppMap '+relatedToParentOppMap);
                }
            }
            
            // This set will store all record type ids for all related records.
            
            Set<Id> oldRecordTypeIds = new Set<Id>();
            
            // Comparing old related and new records for same record type id and throwing error.
            
            for(Opportunity Opp : newOppList){
                if(relatedToParentOppMap.containsKey(Opp.Parent_Opportunity__c)){
                    List<Opportunity> Opp2 = relatedToParentOppMap.get(Opp.Parent_Opportunity__c);
                    system.debug('Opp2 '+Opp2);
                    for(Opportunity Opp3 : Opp2){
                        oldRecordTypeIds.add(Opp3.RecordTypeId);
                        system.debug('oldRecordTypeIds '+oldRecordTypeIds);
                    }
                    Boolean result = oldRecordTypeIds.contains(Opp.RecordTypeId);
                    system.debug('result '+result);
                    if(result){
                        Opp.addError(System.Label.Child_Opportunity_Same_PMG_Error);
                    }
                }
            }
        }catch(exception e){
            TegaUtility.trackLogs(e, 'OpportunityTriggerHelper', 'checkChildOpp');
        }
    }
}