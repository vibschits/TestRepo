@isTest
private class IntegrationTransactionHandlerTest{
    
    
    @isTest static void testMethod1() {
        Account Acc = New Account(name = 'Test Integration', Phone= '6767676767', Tel_No__c='5454545454');
        insert acc;
        
       
        Integration_Transaction__c It = new Integration_Transaction__c();
        it.Record_Id__c = acc.id;
        it.Status__c = 'Draft';
        it.operation__c = 'Create Customer';
        it.Request__c = 'Create Customer:0Q0Bl0000000IJVKA2';
        it.Response__c = 'this is customer code : cn065';
        insert it;
        List<Integration_Transaction__c> itlist = new List<Integration_Transaction__c> ();
        
        itlist.add(it);
        
        IntegrationTransactionHandler ithandler = new IntegrationTransactionHandler();
        ithandler.updateCustomer(itlist);
        if(it.Operation__c == 'Create Customer'){
            SAPCallout_Utility.updateCustomer(it.Record_Id__c, it.id);
            
        }

    }
    
    
}