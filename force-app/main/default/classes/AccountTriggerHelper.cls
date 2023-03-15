/*
Name : AccountTriggerHelper 
Desc : this class is a helper class of AccountTriggerHandler and contains logic for trigger conditions
Author : Ayush/Kuhinoor
*/
public class AccountTriggerHelper { 
    
    /*
Name : typeUpdateOnInsert
Desc : This Method is for updating account Type According to Parent Account Type,If Account Type is Null
Author : NIKHIL
*/
    
    public void typeUpdateOnInsert(List<account> newItems){
        Try{       
            List<id> Idlist = new List<Id>();
            for(Account acc : newItems) {
                Idlist.add(acc.ParentId);
            }
            List<Account> acclists = [SELECT id, name, parentId,Type from Account WHERE Id =:Idlist];
            Map<id, Account> accId = new  Map<id, Account>();
            for(Account a : acclists) {
                accId.Put(a.id, a);
            }
            for(Account acc : newItems) {
                if(acc.type == NULL && acc.ParentId != NUll) {
                    Account ac = accid.get(acc.parentId);
                    if(ac.Type != NULL)
                        acc.Type = ac.Type; 
                }
            }
        }
        catch(exception e){
            TegaUtility.trackLogs(e,'AccountTriggerHelper','insertaccount');
        }
    }
    
    /*
Name : updatechildType(after Update)
Desc : This Method is for updating type of the related childs of the customer in the context 
Author : NIKHIL
*/
    
    public void updateChildType(Map<id, Account> newMap, Map<id, Account> oldMap){
                system.debug('acclist=========');

        List<Account> acclists = [SELECT id, name, parentId,Type from Account WHERE parentId =:newMap.keySet()];
        system.debug('acclist'+acclists);
        if(acclists.size() > 0 ) {
            for(Account acc : acclists) {
                if(acc.type == NULL) {
                    Account ac = newMap.get(acc.parentId);
                    acc.Type = ac.Type; 
                }
            }
        }
        try{
            update acclists;
        }catch(exception e){
            TegaUtility.trackLogs(e,'AccountTriggerHelper','getAccountId');
        }
    }
    
    /*
Name : UpdatechildTypebefore(before Update)
Desc : This Method is for updating account Type According to Parent Account Type,If Account Type is Null
Author : NIKHIL
*/
    
    public void UpdatechildTypebefore(Map<id, Account> newMap, Map<id, Account> oldMap){
        Map<Id, Account> newMapParentid = new Map<Id, Account>();
        List<id> parentRecordID = new List<id>();
        for(Account act : newMap.values()){
            parentRecordID.add(act.ParentId);
        }
        System.debug('parentRecordID size'+parentRecordID.size()+parentRecordID);
        if(!parentRecordID.isEmpty()) {
            
            List<Account> parentlists = [SELECT id, name, parentId,Type from Account WHERE Id IN:parentRecordID];
            if(parentlists.size()> 0){
                
                for(account ParentId : parentlists ){
                    newMapParentid.put(ParentId.Id ,ParentId ); 
                }
                for(Account a : newMap.values()){
                    Account ac = newMapParentid.get(a.parentId);
                    system.debug('ac type-------'+ac);
                    if(a.Type == NULL  && ac.Type != NULL) {
                        a.Type = ac.Type;
                        
                    }
                    
                }
            }
        }
        
    }
    
    //public static void currencyValidation(Map<Id, Account> newMap, Map<Id,Account> OldMap){

        // Set<Id> customerIds = new Set<Id>();
        // List<Quote>  offerList= [SELECT Id, Opportunity.AccountId FROM Quote 
        //                         WHERE Opportunity.AccountId IN : newMap.keySet()];

        // for(Quote ofr : offerList){
        //     customerIds.add(ofr.Opportunity.AccountId);
        // }

        // for(Account acc : newMap.values()){
        //     if( acc.CurrencyIsoCode != OldMap.get(acc.Id).CurrencyIsoCode  && customerIds.contains(acc.Id)){
        //         acc.addError(label.Customer_Currency);
        //     }
        // }

    //}


    //public static void opportunityCurrUpdate(Map<Id, Account> newMap, Map<Id,Account> OldMap){

        // List<Opportunity> updateOppList = new List<Opportunity>();

        // List<Opportunity> oppList = [SELECT Id, AccountId, CurrencyIsoCode FROM Opportunity
        //                             WHERE AccountId IN : newMap.keySet()];
        
        // for(Opportunity opp : oppList){
        //     if(newMap.containsKey(opp.AccountId) && opp.CurrencyIsoCode != newMap.get(opp.AccountId).CurrencyIsoCode){
        //         updateOppList.add(new Opportunity(
        //             Id = opp.Id, 
        //             CurrencyIsoCode = newMap.get(opp.AccountId).CurrencyIsoCode
        //         ));
        //     }
        // }

        // if(updateOppList.size() > 0 ){
        //     update updateOppList;
        // }

    //}
}