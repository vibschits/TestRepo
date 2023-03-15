/*Email Service class to update customer code into salesforce from SAP. 
Customer codesent in subject of the email 
*/
global class UpdateCustomerFromEmail implements Messaging.InboundEmailHandler  {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope ) {
        system.debug('Email service called');
        system.debug('Emai--------'+email);
        system.debug('envelope service called------'+envelope);
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();    
        String subToCompare = email.subject;                                   
        String accid1=subToCompare.substringAfterLast(':');
        String oppType=subToCompare.substringBefore(':');
        String accid= accid1.trim();  
        String emailBody = email.plainTextBody;
        // String custCode1 = emailBody.substringAfterLast(':');
        // String custCode = custCode1.substringBefore('Thank');
        // custCode = custCode.trim();
        system.debug('Customer ID: '+ accid);
        system.debug('oppType-->> '+ oppType);
        
        Integration_Transaction__c it = new Integration_Transaction__c(
            Record_Id__c = accid,
            Status__c = 'Draft',
            Operation__c = oppType,
            Request__c = subToCompare +'\r\n'+emailBody
        );
        
        insert it;
        return result;  
    }
}