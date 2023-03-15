public class NonSpareOfferAcknowledgementHelper {
    @future (callout=true)
    public static void SendAcknowledgementToSAP(Id offerId, Id itId){
        Quote offer = [Select Id,Status,QuoteNumber,SAP_Offer_Id__c from Quote where Id =: offerId];
        Integration_Transaction__c it = [Select Id,Response__c,Status__c from Integration_Transaction__c where Id =: itId];
        Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
      
        NonSpareOfferUpdateV4.ZWS_SF_OFFER_UPDT_V1 offerUpdate = new NonSpareOfferUpdateV4.ZWS_SF_OFFER_UPDT_V1();

        NonSpareOfferUpdateV4.ZrfcSfofferUpdtResponse_element response = new NonSpareOfferUpdateV4.ZrfcSfofferUpdtResponse_element();

        Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + 'Tega@1234');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        offerUpdate.inputHttpHeaders_x = new Map<String, String>();
        offerUpdate.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        
        String offerStatus = '';
        
        String responseMsg = offerUpdate.ZrfcSfofferUpdt(offer.Status,offer.SAP_Offer_Id__c,offer.QuoteNumber,'','');

            if(responseMsg != ' '){
               
               it.Error__c =responseMsg;
               it.Status__c = 'Failed';
            }
            else{
             it.Status__c = 'Success';
             }


        it.Response__c +='\r\n\n Offer Acknowledgement Response: \r\n'+String.valueOf(responseMsg);
        update it; 
    }
}