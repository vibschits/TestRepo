public with sharing class FinalizeOfferController {
    @AuraEnabled
    public static Void finalOffer(Id offerId){
        try {
            Quote offer = new Quote(Id = offerId, status='Finalized', Approval_Status__c = 'Submitted');
            update offer;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
// SK - 211122 : Passing custom label in finalize offer component
    @AuraEnabled
    public static string customLabelItem(){
       List <String> custmValP = new List <String>();
       String custmLbl = Label.Offer_Finalize_lable;
       String custmLblMsg = String.format(custmlbl,custmValP);
       System.debug('CustomLabelValue'+custmLblMsg);
       return custmLblMsg;
    }
}