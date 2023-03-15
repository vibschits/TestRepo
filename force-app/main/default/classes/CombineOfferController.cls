/*
Name : CombineOfferController
Desc : This class use for combining multiple offer into a single offer in child Opp. level.
Author : Kuhinoor
Date : 28-04-2022
*/
public with sharing class CombineOfferController {

    /*
    Name : getOffers
    Desc : This methed return offer based on selected opp.
    Param : oppId
    */
    @AuraEnabled(cacheable=true)
    public static List<offerWrapper> getOffers(Id oppId, String type){
        try {
            List<offerWrapper> offerWrapList = new List<offerWrapper>();
            Id individualRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
            Id nonSpareRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer_Non_Spare');
            // List<Quote> offerList = [SELECT Id, Name, QuoteNumber,Approval_Status__c,
            //                         Quotation_Date__c,Quotation_Validity__c, recordType.DeveloperName
            //                         FROM Quote 
            //                         WHERE OpportunityId = : oppId 
            //                         AND (recordTypeId= :individualRecordTypeId OR recordTypeId=: nonSpareRecordTypeId )];

            String queryStr = 'SELECT Id,QuoteNumber, Name, Quotation_Date__c, Quotation_Validity__c, Approval_Status__c, Approval_Required__c,SAP_Offer_Id__c,';
            queryStr +=' recordType.DeveloperName, recordType.Name ';
            queryStr +=' FROM Quote ';
            queryStr += '  WHERE OpportunityId = : oppId AND recordTypeId= :individualRecordTypeId';
            //if(type == 'All'){
            //    queryStr += ' AND (recordTypeId= :individualRecordTypeId OR recordTypeId=: nonSpareRecordTypeId )';
            //}
            //if(type == 'Spare'){
             //   queryStr += '  AND recordTypeId= :individualRecordTypeId ';
            //}
            //if(type == 'Non Spare'){
            //    queryStr += '  AND recordTypeId=: nonSpareRecordTypeId ';
            //}


            system.debug('query-->>'+ queryStr);
            List<Quote> offerList = Database.query(queryStr);
            
            
            for(Quote ofr : offerList){  
                Boolean isDisable = false;
                if((ofr.Approval_Status__c != 'Price Accepted' && ofr.Approval_Status__c != 'Delivery SLA Accepted' )|| ofr.SAP_Offer_Id__c != NULL){
                    
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
    public static Quote combineOffer(List<Id> offerIds){
      try {
            List<QuoteLineItem> offerLineList = new List<QuoteLineItem>();
            List<QuoteLineItem> offerLineCloneList = new List<QuoteLineItem>();
            List<L1_L2_Offer_Line_Item__c> L1L2LineCloneList = new List<L1_L2_Offer_Line_Item__c>();

            Quote offer = [Select Id,Name,recordTypeId,Is_Partlist_Same__c from Quote where Id =: offerIds[0]];
            system.debug('#Offer:'+offer);

            Id offerRecordTypeId = offer.recordTypeId;
            system.debug('offerRecordTypeId'+offerRecordTypeId);

            Id individualRecordTypeId =  TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer');
            Id nonSpareRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer_Non_Spare');
            Id combineRecordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Combine');

            String queryStr = 'SELECT Id, Name, Quotation_Date__c, Quotation_Validity__c, OpportunityId, Approval_Status__c,Approval_Required__c,Is_Partlist_Same__c,Part_List__c,Sales_Document_Type__c,Delivery_Date__c,Sales_Org__r.Name,Part_List__r.name,Opportunity.Customer_Branch_Assignment__r.Distribution_Channel__c,Opportunity.Customer_Branch_Assignment__r.Division__c,Enquiry_Number__c,Opportunity.Customer_Branch_Assignment__r.Branch__r.Branch_Code__c,Opportunity.Customer_Branch_Assignment__r.Customer_Code__c,';
            queryStr +=' (SELECT '+AllFields('QuoteLineItem') +' FROM QuoteLineItems )';
            queryStr +=' FROM Quote ';

            if(offerRecordTypeId == individualRecordTypeId){
                queryStr += ' WHERE Id IN : offerIds AND recordTypeId= : individualRecordTypeId ORDER BY Quotation_Date__c,Quotation_Validity__c';
            }

            if(offerRecordTypeId == nonSpareRecordTypeId){
                queryStr += ' WHERE Id IN : offerIds AND recordTypeId= : nonSpareRecordTypeId ORDER BY Quotation_Date__c,Quotation_Validity__c';
            }

            system.debug('*query-->>'+ queryStr);
            
            List<Quote> offerList = Database.query(queryStr);
            system.debug('#Selected offerList: '+offerList);

            String l1l2QueryStr = 'SELECT '+AllFields('L1_L2_Offer_Line_Item__c') +' FROM L1_L2_Offer_Line_Item__c';
            l1l2QueryStr +=' WHERE Offer__c IN : offerIds ' ;

            List<L1_L2_Offer_Line_Item__c> L1L2LineList = Database.query(l1l2QueryStr);
            List<Pricebook2> pb = [Select name,id from Pricebook2 where  IsStandard = true  LIMIT 1];
            system.debug('#########'+pb);
            system.debug('offerList 99--------'+offerList);

            if(offerList != null && offerList.size() > 0){
            system.debug('#offerList 107: '+offerList);

            Quote combineFffer = offerList[0].clone(false, false);
            system.debug('#combineFffer 112: '+combineFffer);
            combineFffer.Quotation_Date__c = combineFffer.Quotation_Date__c;

            Integer lastIndx = offerList.size()-1 ;
            system.debug('#lastIndx 116: '+lastIndx);


            combineFffer.Quotation_Validity__c = offerList[lastIndx].Quotation_Validity__c;
            system.debug('#combineFffer.Quotation_Validity__c: '+combineFffer.Quotation_Validity__c);
            system.debug('#offerList[lastIndx].Quotation_Validity__c: '+offerList[lastIndx].Quotation_Validity__c);
            combineFffer.OpportunityId = combineFffer.OpportunityId;
            combineFffer.Approval_Status__c = combineFffer.Approval_Status__c;
            combineFffer.Approval_Required__c = combineFffer.Approval_Required__c;
            //combineFffer.PartList_Name__c = combineFffer.Part_List__c;
            combineFffer.recordtypeId = combineRecordTypeId;

              if(offerRecordTypeId == individualRecordTypeId){
                //List<Pricebook2> pb = [Select name,id from Pricebook2 where  IsStandard = true  LIMIT 1];
                  combineFffer.pricebook2Id  = pb[0].Id;
              }
            
            Boolean isSameChildParams = true;
            if (((combineFffer.Approval_Status__c == 'Price Accepted' || combineFffer.Approval_Status__c == 'Delivery SLA Accepted')  && combineFffer.Approval_Required__c == true) || (combineFffer.Approval_Required__c == false) && (combineFffer.Is_Partlist_Same__c == true )){
                // AK SK Fix 03/02/2023
                String partListName = offerList[0].Part_List__r.name;
                String distChannel = offerList[0].Opportunity.Customer_Branch_Assignment__r.Distribution_Channel__c;
                String division = offerList[0].Opportunity.Customer_Branch_Assignment__r.Division__c; 
                String docType = offerList[0].Sales_Document_Type__c;
                String enqNumber = offerList[0].Enquiry_Number__c;
                Date quotationDate = offerList[0].Quotation_Date__c;
                Date quotationVal =offerList[0].Quotation_Validity__c;
                Date delvDate = offerList[0].Delivery_Date__c;
                String branchCode = offerList[0].Opportunity.Customer_Branch_Assignment__r.Branch__r.Branch_Code__c;
                String salesOrgName = offerList[0].Sales_Org__r.Name;
                String custCode =offerList[0].Opportunity.Customer_Branch_Assignment__r.Customer_Code__c;
				
                
                for(Quote ofr : offerList){
                    if(partListName == ofr.Part_List__r.name 
                       && distChannel == ofr.Opportunity.Customer_Branch_Assignment__r.Distribution_Channel__c 
                       && division == ofr.Opportunity.Customer_Branch_Assignment__r.Division__c 
                       && docType == ofr.Sales_Document_Type__c 
                       && enqNumber == ofr.Enquiry_Number__c 
                       && quotationDate == ofr.Quotation_Date__c 
                       && quotationVal == ofr.Quotation_Validity__c 
                       && delvDate == ofr.Delivery_Date__c 
                       && branchCode == ofr.Opportunity.Customer_Branch_Assignment__r.Branch__r.Branch_Code__c 
                       && salesOrgName == ofr.Sales_Org__r.Name 
                       && custCode == ofr.Opportunity.Customer_Branch_Assignment__r.Customer_Code__c){
                        
                       }else{
                           isSameChildParams = false;
                           System.debug('#isSameChildParams'+isSameChildParams);
                       }
                }
                if(isSameChildParams){
                    System.debug('#isSameChildParams'+isSameChildParams);
                    insert combineFffer; // Insert parent/combine offer.
                	system.debug('@Combine Offer =>'+combineFffer);
                }
                
                //Offer ki kahani khatam aur qli ki chalu

                for(Quote ofr : offerList){
                    offerLineList.addAll(ofr.QuoteLineItems);
                    ofr.Parent_Offer__c = combineFffer.Id;
                }
    
                for(QuoteLineItem ofLine : offerLineList){
                    QuoteLineItem cloneLine = ofLine.clone(false, false);
                    cloneLine.QuoteId = combineFffer.Id;
                    offerLineCloneList.add(cloneLine);
                }

                Map<Id, QuoteLineItem> offerMap ;
                
                if(offerLineCloneList.size() > 0 ){
                    //Offer Line Items
                    //insert offerLineCloneList;
                    system.debug('@Clone List:'+offerLineCloneList);
                    system.debug('@Offer List:'+offerLineList);

                    //Workspace - merge
                    offerMap = new Map <Id, QuoteLineItem>();
                        System.debug('$OfferMap Initiallized:'+offerMap);

                        for (QuoteLineItem objQli : offerLineCloneList){
                            System.debug('@Id:'+objQli.Product2Id);
                            
                            if (!offerMap.containsKey(objQli.Product2Id)){
                                offerMap.put(objQli.Product2Id,objQli);
                                system.debug('#');
                                System.debug('$offerMap:'+offerMap);
                            }
                            else{
                                system.debug('##');
                                QuoteLineItem qli = offerMap.get(objQli.Product2Id);
                                //if (qli.PartList_Name__c == objQli.PartList_Name__c){

                                    system.debug('% QLI w/ same partlist ');
                                    qli.Combined_Quantity__c = qli.Quantity + objQli.Quantity;
                                    qli.UnitPrice += objQli.UnitPrice;
                                    offerMap.put(qli.Product2Id,qli);
                                    system.debug('##Quantityqli'+qli.Quantity);
                                    system.debug('##QuantityObjqli'+objQli.Quantity);
                                    system.debug('##UnitPrice'+objQli.UnitPrice);//}

                                /*else if (qli.PartList_Name__c != objQli.PartList_Name__c){
                                    system.debug('% QLI w/o same partlist ');
                                    List<Quote> offerLst = Database.query(queryStr);
                                    insert offerLst;
                                    
                                }*/
                            }
                        }
                }
               
                insert offerMap.values();
                system.debug('===offerMap=='+offerMap.values()); 
               
                   
                
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
            else{
                insert combineFffer; // Insert parent/combine offer.
                system.debug('@Combine Offer =>'+combineFffer);
                //Offer ki kahani khatam aur qli ki chalu

                for(Quote ofr : offerList){
                    offerLineList.addAll(ofr.QuoteLineItems);
                    ofr.Parent_Offer__c = combineFffer.Id;
                }
    
                for(QuoteLineItem ofLine : offerLineList){
                    QuoteLineItem cloneLine = ofLine.clone(false, false);
                    cloneLine.QuoteId = combineFffer.Id;
                    offerLineCloneList.add(cloneLine);
                }
                
                if(offerLineCloneList.size() > 0 ){
                    //Offer Line Items
                    insert offerLineCloneList;
                    system.debug('@Clone List:'+offerLineCloneList);
                    system.debug('@Offer List:'+offerLineList);                       
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
        }                  
        return new Quote();
        } catch (Exception e) {
            TegaUtility.trackLogs( e,  'CombineOfferController',  'combineOffer');
            system.debug('error on =========='+e.getMessage()+ e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
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