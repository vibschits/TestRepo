@isTest
public class IntegrationTransactionBatch_Test
{
    @isTest
    public static void testIntegrationTransactionBatch()
    {
        //Contact contactObj=[select id, name,Oracle_CRM_Number__c from Contact];
        
        Integration_Transaction__c intTransactObj = new Integration_Transaction__c();                                    
        intTransactObj.Operation_type__c='Create Customer';  
        intTransactObj.Status__c='Fail';    
        intTransactObj.request__c='test request';    
        intTransactObj.No_of_Retries__c=2;
        insert intTransactObj;        
        
        //Test.stopTest();
        system.assert(intTransactObj!=null);                                      
        Test.startTest();     
        IntegrationTransactionBatch batchObj=new IntegrationTransactionBatch();
        Database.executeBatch(batchObj,1);
        Test.stopTest();           
    }    
    
   @isTest
    public static void testNegativeIntegrationTransactionBatch()
    {
        //Contact contactObj=[select id, name,Oracle_CRM_Number__c from Contact];
        
        Integration_Transaction__c intTransactObj = new Integration_Transaction__c();                                    
        intTransactObj.Operation_type__c='Create Customer';  
        intTransactObj.Status__c='Fail';    
        intTransactObj.request__c='test request';    
        intTransactObj.No_of_Retries__c=2;
        insert intTransactObj;        
        
        //Test.stopTest();
        system.assert(intTransactObj!=null);                                      
        Test.startTest();     
        IntegrationTransactionBatch batchObj=new IntegrationTransactionBatch();
        Database.executeBatch(batchObj,1);
        Test.stopTest();           
    }    
    
}