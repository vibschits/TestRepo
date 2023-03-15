public class X4E4DTriggerHelper {
    public static void updateOppStage(List<X4E_4D__c> newItems){
        
        system.debug('newItems =>'+newItems);
        Quote off = [Select Id,OpportunityId from Quote where Id =: newItems[0].SF_Offer__c];
        Id oppId = off.OpportunityId;
        
        List<Quote> offerList = [Select Id,OpportunityId,Status from Quote WHERE OpportunityId =: oppId];
        
        List<Quote> lostOfferList = new List<Quote>();
        
        Set<Id> offerIdSet = new Set<Id>();
        for(Quote offer : offerList){
            offerIdSet.add(offer.Id);
            if(offer.Status == 'LS'){
                lostOfferList.add(offer);
            }
        }
        
        List<X4E_4D__c> X4E4DList = [Select Id,SF_Offer__c from X4E_4D__c WHERE SF_Offer__c IN : offerIdSet];
        
        Map<Id, List<X4E_4D__c>> X4E4DMap = new Map<Id, List<X4E_4D__c>>();
        for(X4E_4D__c x4E4D : X4E4DList){
            if(!X4E4DMap.containsKey(x4E4D.SF_Offer__c)){
                X4E4DMap.put(x4E4D.SF_Offer__c, new List<X4E_4D__c>{x4E4D});
            }else{
                X4E4DMap.get(x4E4D.SF_Offer__c).add(x4E4D);
            }
        }
        system.debug('X4E4DMap => '+X4E4DMap);
        
        // Now we need to check whether the above Map has all the Opportunity's offers or not
        Boolean all4E4DRaised = true;
        
        for(Id offerId : offerIdSet){
            if(!X4E4DMap.containsKey(offerId)){
                all4E4DRaised = false;
            }
        }
        
        Opportunity opp = [Select Id,StageName from Opportunity WHERE Id =: oppId];
        if(all4E4DRaised == true){
            opp.StageName = 'Closed Won';
        }else if(offerList.size() == lostOfferList.size() && all4E4DRaised == false){
            opp.StageName = 'Closed Lost';
        }else if(lostOfferList.size() > 0 && X4E4DList.size() > 0 && all4E4DRaised == false && offerList.size() != lostOfferList.size()){
            opp.StageName = 'Closed Partially Won';
        }
        
        update opp;
    }
}