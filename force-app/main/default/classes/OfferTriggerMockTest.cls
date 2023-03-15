@isTest
global class OfferTriggerMockTest implements WebServiceMock {
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
               
              NonSpareOfferUpdateV4.ZrfcSfofferUpdtResponse_element testElement = new NonSpareOfferUpdateV4.ZrfcSfofferUpdtResponse_element();
              testElement.ExMessage  = '';
              response.put('response_x',testElement);
       
   }
}