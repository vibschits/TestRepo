/*
Name : OfferTriggerHelper 
Desc : This is a handler class of OfferTriggerHandler
US :
*/
public class OfferTriggerHelper {
    /*
Name : updateScopeWithOffer
Desc : this method use to update offer  in scope with selection.
*/
    public static void updateScopeWithOffer(Map<Id,SObject> newMap, Map<Id,SObject> oldMap){
        system.debug('---updateScopeWithOffer-->>');
        Map<String, Id> SAPOfferNumMap = new Map<String, Id>();
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
        for(SObject obj : newMap.values()){
            Quote offr = (Quote)obj;
            
            if(oldMap != null ){
                if(oldMap.get(offr.Id).get('SAP_Offer_Id__c') !=  offr.SAP_Offer_Id__c 
                   && String.isNotBlank(offr.SAP_Offer_Id__c) && offr.RecordTypeId == recordTypeId){
                       SAPOfferNumMap.put(offr.SAP_Offer_Id__c, offr.Id);
                   }                
            }else {
                if(String.isNotBlank(offr.SAP_Offer_Id__c) && offr.RecordTypeId == recordTypeId){
                    SAPOfferNumMap.put(offr.SAP_Offer_Id__c, offr.Id);
                }
            }
        }
        
        List<Scope_With_Selection__c> scopeSelList = [SELECT Id,Proposal_Form__r.SAP_Offer_Number__c,Offer__c  
                                                      FROM Scope_With_Selection__c 
                                                      WHERE Proposal_Form__r.SAP_Offer_Number__c IN : SAPOfferNumMap.keySet()];
        
        System.debug('scopeSelList-->>'+scopeSelList);
        if(scopeSelList != null && scopeSelList.size() > 0 ){
            for(Scope_With_Selection__c sc : scopeSelList){
                if(SAPOfferNumMap.containsKey(sc.Proposal_Form__r.SAP_Offer_Number__c)){
                    sc.Offer__c = SAPOfferNumMap.get(sc.Proposal_Form__r.SAP_Offer_Number__c);
                }
            }
            
            update scopeSelList;
        }
        
        
    }
    
    /*
Name : CreateOfferSpareMethod
Desc : this method use to update SapOfferId  in Offer.
*/
    public static void CreateSAPOfferId(Map<Id, SObject> newMap, Map<Id,SObject> oldMap) {
        Map <Id, Quote> offertoUpdate = new Map <Id, Quote>();
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();
        Id recordTypeIdNonSpare = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('Offer_Non_Spare').getRecordTypeId();
        Integration_Transaction__c IT = new Integration_Transaction__c();
        for(SObject Obj : newMap.values()) {
            Quote offer = (Quote)obj;
            if(oldMap != null ){
                if((Offer.Status == 'LS' && oldMap.get(offer.Id).get('Status') !=  'LS' || 
                   Offer.Status == 'HO' && oldMap.get(offer.Id).get('Status') !=  'HO' ||
                   Offer.Status == 'DF' && oldMap.get(offer.Id).get('Status') !=  'DF') &&
                   String.isNotBlank(Offer.Status) && Offer.RecordTypeId == recordTypeIdNonSpare){
                       	
                       IT.Record_Id__c=offer.Id;
                       IT.Status__c='Draft';
                       IT.Operation__c = 'Send Acknowledgement to SAP';
                       IT.Request__c = offer.QuoteNumber;
                       insert IT;
					   NonSpareOfferAcknowledgementHelper.SendAcknowledgementToSAP(offer.Id,IT.Id);
                        
                }else if(Offer.Status == 'Finalized' && oldMap.get(offer.Id).get('Status') !=  Offer.Status 
                   && String.isNotBlank(Offer.Status) && Offer.RecordTypeId == recordTypeId){
                       offertoUpdate.put(Offer.id, offer);
                       IT.Record_Id__c=offer.Id;
                       IT.Status__c='Draft';
                       IT.Operation__c = 'Create Offer Spare';
                       IT.Request__c = offer.QuoteNumber;
                       insert IT;
                   }
                
                
            }  
            
            
        }
        
    }

    /*
	Name : populatePriceBook
	Desc : this method populate Price book in offer.
	*/
    public static void populatePriceBook(List<Quote> newOfferList){
        Id offerSpareRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
        Id priceBookId;
        if(Test.isrunningtest()){
            priceBookId = Test.getStandardPricebookId();
        }else {
            Pricebook2 stdPriceBook = [SELECT Id FROM Pricebook2 WHERE isStandard = true LIMIT 1];
            priceBookId = stdPriceBook.Id;
        }
        
        for(Quote offer : newOfferList){
            if(offer.recordTypeId == offerSpareRecordTypeId){
            	offer.Pricebook2Id = priceBookId;
            }            
        }
    }
    
         /*
    Name : populateHead
    Desc : this method use to populate RM Sales Head and PMG Head
    */
    public static void populateHead(List<Quote> newList, Map<Id,SObject> oldMap, boolean isUpdate){
        Set<Id> brachIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Id> branchMap = new Map<Id, Id>();
        Map<Id, String> oppIdsMap = new Map<Id, String>();
        for(Quote offr : newList){
            system.debug('Branch__c-->>'+offr.Branch__c);
            if(isUpdate){
                //if(oldMap.get(offr.Id).get('Branch__c') !=  offr.Branch__c){
                    brachIds.add(offr.Branch__c);
                    oppIds.add(offr.OpportunityId);                    
               // }                
            }else {
                if(String.isNotBlank(offr.Branch__c)){
                    brachIds.add(offr.Branch__c);
                    oppIds.add(offr.OpportunityId);
                }
            }
        }
                         
        system.debug('brachIds-->>'+brachIds);
        if(brachIds.size() > 0){ 
            List<Branch__c> branchList = [SELECT Id,Sales_Region__r.Manager__c FROM Branch__c 
                                          WHERE Id IN : brachIds AND Sales_Region__c !=null ];
            
            if(branchList !=null && branchList.size() > 0 ){
                for(Branch__c br : branchList){
                    branchMap.put(br.Id, br.Sales_Region__r.Manager__c);
                }
            }  
        }
        if(oppIds.size() > 0){
            List<opportunity> oppList = [SELECT Id, recordType.Name FROM opportunity 
                                        WHERE Id IN : oppIds];
            
            if(oppList != null && oppList.size() > 0 ){
                for(opportunity opp : oppList){
                    oppIdsMap.put(opp.Id, opp.recordType.Name);
                } 
            }            
        }
        
        Map<String, PMG_user__mdt> PMGUserMap = PMG_user__mdt.getAll();
        Set<String> usernameSet = new Set<String>();
       for(Quote offr : newList){
            if(oppIdsMap.containsKey(offr.OpportunityId)){
                 if(PMGUserMap.containsKey(oppIdsMap.get(offr.OpportunityId))){
                  	usernameSet.add(PMGUserMap.get(oppIdsMap.get(offr.OpportunityId)).Username__c);
              }                
            }
        }
        system.debug('usernameSet-->>'+usernameSet);
        
        Map<String, User> userNameMap = new Map<String, User>();
        List<User> userList = [SELECT Id, username FROM user WHERE username IN : usernameSet];
        if(userList != null && userList.size() > 0 ){
            for(user usr : userList){             
                userNameMap.put(usr.username, usr);
            }
        }
		system.debug('branchMap-->>'+branchMap);
        system.debug('PMGUserMap-->>'+PMGUserMap);
        system.debug('userNameMap-->>'+userNameMap);
       for(Quote offr : newList){
            
            if(branchMap.containsKey(offr.Branch__c)){
                offr.Regional_Sales_Head__c = branchMap.get(offr.Branch__c);              
            }
             if(oppIdsMap.containsKey(offr.OpportunityId)){
                 if(PMGUserMap.containsKey(oppIdsMap.get(offr.OpportunityId))){
                     String testusername = PMGUserMap.get(oppIdsMap.get(offr.OpportunityId)).Username__c;
                     system.debug('testusername-->'+testusername);
                     if(!userNameMap.isEmpty()){
                        Id pmgId =  userNameMap.get(PMGUserMap.get(oppIdsMap.get(offr.OpportunityId)).Username__c).Id;
                        offr.PMG_Head__c = pmgId;  
                     }
              }                
            }
        }
        
       
    }
    
    public static void afterIDcreation(List<Quote> newList){
        Id userId = userinfo.getUserId();
        User user = [Select Id,SalesGroupCode__c from User where Id =: userId];
        for(Quote offer :newList){
        	system.debug('Check Value'+offer.CreatedBy.SalesGroupCode__c);
            offer.SalesGrp__c = user.SalesGroupCode__c;
        }
        
    }
}