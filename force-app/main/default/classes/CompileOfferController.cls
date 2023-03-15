/*
Name : CompileOfferController
Desc : This class is for creating Compilte. 
Author : Kuhinoor
*/
public with sharing class CompileOfferController {
   
    /*
    Name : getOffers
    Desc : This methed return offer based on selected opp.
    Param : oppId
    */
    @AuraEnabled(cacheable=true)
    public static List<offerWrapper>  getOffers(Id oppId){
        try {
            List<offerWrapper> offerWrapList = new List<offerWrapper>();
            Id combineRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Combine');
            List<Quote> offerList = [SELECT Id, Name,Offer_Name__c, QuoteNumber,Approval_Status__c,
                                    Quotation_Date__c,Quotation_Validity__c
                                    FROM Quote 
                                    WHERE Opportunity.Parent_Opportunity__c = : oppId AND recordTypeId= :combineRecordTypeId ];
            for(Quote ofr : offerList){  
                Boolean isDisable = false;
                if(ofr.Approval_Status__c != 'Price Accepted' && ofr.Approval_Status__c != 'Delivery SLA Accepted'){
                    isDisable = true;
                }                
                offerWrapList.add(new offerWrapper( ofr, false, isDisable));
            }
            return offerWrapList; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    Name : combineOffer
    Desc : This methed combine multiple offers into a single parent offer.
    Param : offerIds
    */
    @AuraEnabled
    public static Quote compileOffer(List<Id> offerIds){ 
      // try {
            List<QuoteLineItem> offerLineList = new List<QuoteLineItem>();
            List<QuoteLineItem> offerLineCloneList = new List<QuoteLineItem>();
            List<L1_L2_Offer_Line_Item__c> L1L2LineCloneList = new List<L1_L2_Offer_Line_Item__c>();

            Id compileRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Compile');
            Id combineRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Combine');

            String queryStr = 'SELECT Id, Name, QuoteNumber, Quotation_Date__c,Quotation_Validity__c,Approval_Status__c,  ';
            queryStr +=' Opportunity.Parent_Opportunity__c, ';
            queryStr +=' (SELECT '+AllFields('QuoteLineItem') +' FROM QuoteLineItems )';
            queryStr +=' FROM Quote ';
            queryStr += ' WHERE Id IN : offerIds AND recordTypeId= : combineRecordTypeId ORDER BY Quotation_Date__c,Quotation_Validity__c';
            system.debug('query-->>'+ queryStr);
            List<Quote> offerList = Database.query(queryStr);

            String l1l2QueryStr = 'SELECT '+AllFields('L1_L2_Offer_Line_Item__c') +' FROM L1_L2_Offer_Line_Item__c';
            l1l2QueryStr +=' WHERE Offer__c IN : offerIds ';
            List<L1_L2_Offer_Line_Item__c> L1L2LineList = Database.query(l1l2QueryStr);

            Pricebook2 pbCustom = new Pricebook2(Name = offerIds[0]+'-'+offerIds[1], IsActive = true);
            insert pbCustom;
        
            if(offerList != null && offerList.size() > 0 ){
            Quote combineFffer = offerList[0].clone(false, false);
            combineFffer.Quotation_Date__c = offerList[0].Quotation_Date__c;
            Integer lastIndx = offerList.size()-1 ;

            combineFffer.Quotation_Validity__c = offerList[lastIndx].Quotation_Validity__c;
            combineFffer.OpportunityId = combineFffer.Opportunity.Parent_Opportunity__c;
            combineFffer.Approval_Status__c = combineFffer.Approval_Status__c;
            combineFffer.recordtypeId = compileRecordTypeId;
            combineFffer.pricebook2Id = pbCustom.Id;

            insert combineFffer; // Insert parent/combine offer.

            for(Quote ofr : offerList){
                offerLineList.addAll(ofr.QuoteLineItems);
                ofr.Parent_Offer__c = combineFffer.Id;
            }

            Map<Id,PricebookEntry> pbEntryMap = new Map<Id,PricebookEntry>();

            for(QuoteLineItem ofLine : offerLineList){
                pbEntryMap.put(ofLine.Product2Id,new PricebookEntry(
                            Product2Id = ofLine.Product2Id, 
                            Pricebook2Id = pbCustom.Id, 
                            IsActive =true,
                            UnitPrice = 1234
                        ));
            }

            insert pbEntryMap.values();

            for(QuoteLineItem ofLine : offerLineList){
                QuoteLineItem cloneLine = ofLine.clone(false, false);
                cloneLine.QuoteId = combineFffer.Id;
                cloneLine.PricebookEntryId = pbEntryMap.get(ofLine.Product2Id).Id;
                offerLineCloneList.add(cloneLine);
            }

            if(offerLineCloneList.size() > 0 ){
                insert offerLineCloneList;
            }

            for(L1_L2_Offer_Line_Item__c l1l2  : L1L2LineList){
                L1_L2_Offer_Line_Item__c cloneL1L2 = l1l2.clone(false,false);
                cloneL1L2.Offer__c = combineFffer.Id;
                L1L2LineCloneList.add(cloneL1L2);
            }

            if(L1L2LineCloneList.size() > 0 ){
                insert L1L2LineCloneList;
            }

            if(offerList.size() > 0 ){
                update offerList;
            }

            return combineFffer;
        }                  
        return new Quote();
        //} catch (Exception e) {
          //  TegaUtility.trackLogs( e,  'CompileOfferController',  'compileOffer');
           // throw new AuraHandledException(e.getMessage());
       // }
    }

    /*
    Name : AllFields
    Desc : This is a generic method return all fields of an object.
    Param : ObjectName
    */
    public static String AllFields(String ObjectName) {
        List<String> fields = new List<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
        String fieldsStr  = String.join(fields, ',');
        return fieldsStr;
    }

    // Wrapper class
    public class offerWrapper{
        @AuraEnabled public Quote offer{get;set;}
        @AuraEnabled public Boolean selected{get;set;}
        @AuraEnabled public Boolean isDisable{get;set;}
        
        public offerWrapper(Quote offer, Boolean selected, Boolean isDisable){
            this.offer = offer;
            this.selected = selected;
            this.isDisable = isDisable;
        }
    }
}