@isTest(SeeAllData=true)
private class  CreateContactFrmEmailTest {
    static testMethod void validatedata()
    {
        Account acc = new account();
        acc.Name = 'testEMail';
        //acc.Mobile_number__c ='7878787878';
        //acc.Phone = '7878787878';
        //acc.Tel_No__c = '7878787878';
        insert acc;
        try{
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
            List<Account> accList = [Select Id from Account WHERE id  =:acc.id];
            UpdateCustomerFromEmail upc=new UpdateCustomerFromEmail();
            email.subject = 'Create Customer:' + accList[0].id;
            email.plainTextBody = 'FromEmail';
            //env.fromAddress = 'abcd@test.com';
           // Messaging.InboundEmailResult result = upc.handleInboundEmail(email, env);
                       upc.handleInboundEmail(email, env );

            Integration_Transaction__c It = new Integration_Transaction__c();
            It.Record_Id__c = accList[0].id;
            It.Status__c = 'Draft';
            It.Request__c = email.subject;
            It.Operation__c = 'Create Customer';
            insert It;
           // System.assertEquals( result.success  ,true);
            
            
        }
        catch(exception e){
            
            
        }
    }
    
    /*  @testSetup static void setup() {
// Create common test accounts
List<Account> testAccts = new List<Account>();
for(Integer i=0;i<100;i++) {
testAccts.add(new Account(Name = 'TestAcct'+i,Status__c='Customer created in SAP'));
}
update testAccts;
}*/
}