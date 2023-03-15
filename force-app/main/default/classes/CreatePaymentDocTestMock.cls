/*
Name : CreatePaymentDocTestMock
Description : Mock Test class for CreatePaymentDoc.
Author : Pavan
*/
@isTest
global class CreatePaymentDocTestMock implements WebServiceMock {
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
            
            PaymentQASWSDL.ZpayHdr ExPayHdr = new PaymentQASWSDL.ZpayHdr();
            ExPayHdr.CompCode = '12345'; 
            ExPayHdr.PmtDocNo = '12345';
            ExPayHdr.PostingDate = '2021-12-12';
            ExPayHdr.FiscalYear= '2023';
            ExPayHdr.BankName= 'ICICI';
            ExPayHdr.BankRefNo= 'test';
            ExPayHdr.EntryTime= '13:59';
            ExPayHdr.EntryDate= '2021-12-12';
            
            List<PaymentQASWSDL.ZpayHdr> lstExPayHdr = new List<PaymentQASWSDL.ZpayHdr>();
            lstExPayHdr.add(ExPayHdr);
            
            PaymentQASWSDL.ZpayHdrLn itemExPayHdr = new PaymentQASWSDL.ZpayHdrLn();
            itemExPayHdr.item =lstExPayHdr;
            
            PaymentQASWSDL.ZpayDoc ZpayDoc = new PaymentQASWSDL.ZpayDoc();
            
            ZpayDoc.CompCode = '12345';
            ZpayDoc.PmtDocNo= '12345';
            ZpayDoc.PostingDate= '2021-12-12';
            ZpayDoc.AdvPmtInd= 'X';
            ZpayDoc.FiscalYear= '2023';
            ZpayDoc.CompCode= '12345'; 
            ZpayDoc.DocCurrency= 'INR';
            ZpayDoc.PayAmtDc ='12345';
            ZpayDoc.PmtDocNo= '12345';
            ZpayDoc.InvNo = '12345';
            ZpayDoc.SoNo = '1223';
            
            List<PaymentQASWSDL.ZpayDoc> lstZpayDoc = new List<PaymentQASWSDL.ZpayDoc>();
            lstZpayDoc.add(ZpayDoc);
            
            PaymentQASWSDL.ZpayDocLn itemExPayItm = new PaymentQASWSDL.ZpayDocLn();
            itemExPayItm.item = lstZpayDoc;
            
            
            PaymentQASWSDL.ZrevDoc ZrevDoc = new PaymentQASWSDL.ZrevDoc();  
            ZrevDoc.CompCode = 'test';
            ZrevDoc.PmtDocNo = '12345';
            ZrevDoc.PmtDocPostDate = '2021-12-12';
            ZrevDoc.ReverseDate= '2021-12-12';
            ZrevDoc.ReversePmtDocNo = '1234';
            ZrevDoc.RevEntryDate= '2021-12-12';
            
            List<PaymentQASWSDL.ZrevDoc> reverseDocFieldsList = new List<PaymentQASWSDL.ZrevDoc>();  
            reverseDocFieldsList.add(ZrevDoc);
            PaymentQASWSDL.ZrevDocLn reverseDocFields = new PaymentQASWSDL.ZrevDocLn();
            reverseDocFields.item = reverseDocFieldsList;
            
            PaymentQASWSDL.ZinvPayDetailsResponse_element response_x = new PaymentQASWSDL.ZinvPayDetailsResponse_element();
            response_x.ExPayHdr = itemExPayHdr;
            response_x.ExPayItm = itemExPayItm;
            response_x.ExReverseDoc = reverseDocFields;
            response_x.ExMessage = '';
            
            response.put('response_x',response_x);
            
        }
}