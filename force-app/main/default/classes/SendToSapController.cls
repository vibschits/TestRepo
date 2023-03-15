public class SendToSapController {
    @AuraEnabled
    Public static Void OfferSendToSap(Id offerId){
        try {
            Quote offer = new Quote(Id = offerId, status='Trigger to SAP');
            update offer;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}