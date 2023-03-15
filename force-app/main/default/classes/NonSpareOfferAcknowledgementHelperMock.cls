/* 
Class Name : NonSpareOfferAcknowledgementHelperTest
Author : Pavan
Description : Mock Class for NonSpareOfferAcknowledgementHelper and NonSpareOfferAcknowledgementController
*/

@isTest
global class NonSpareOfferAcknowledgementHelperMock implements WebServiceMock {
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            
            NonSpareOfferUpdateV4.ZrfcSfofferUpdt_element testZrfcSfofferUpdt_element= new NonSpareOfferUpdateV4.ZrfcSfofferUpdt_element();
            testZrfcSfofferUpdt_element.OfferStatus  = 'test';
            testZrfcSfofferUpdt_element.SapOfferNo = '1234';
            testZrfcSfofferUpdt_element.SfOfferNo  = '1234';
            testZrfcSfofferUpdt_element.SfdcOfferFlag = 'true';
            testZrfcSfofferUpdt_element.StatusFlag = 'true';
            NonSpareOfferUpdateV4.ZrfcSfofferUpdtResponse_element testZrfcSfofferUpdtResponse_element = new NonSpareOfferUpdateV4.ZrfcSfofferUpdtResponse_element();
            testZrfcSfofferUpdtResponse_element.ExMessage = '';
            NonSpareOfferUpdateV4.ZWS_SF_OFFER_UPDT_V1 testZWS_SF_OFFER_UPDT_V1 = new NonSpareOfferUpdateV4.ZWS_SF_OFFER_UPDT_V1();
            
            response.put('response_x',testZrfcSfofferUpdtResponse_element);
        }
}