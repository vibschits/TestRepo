@isTest
public class IntegrationUtilities_Test
{
    @TestSetup
    public static void testDataSetup()
    {
        Test.startTest();
        Test.stopTest();
        Account accountObj= new Account();
        accountObj.Name = 'test';
        insert accountObj; 

        Integration_Transaction__c it = IntegrationUtility.InsertIntegrationTransaction('Customer',String.valueOf(accountObj.Id), 'draft', 'test', '','Create Customer'); 
        IntegrationUtility.UpdateIntegrationTransaction('Customer',String.valueof(accountObj.Id),'Success','Error','test','Response','Update Customer',it);
    }
    
    
    
    @isTest
    public static void test_for_getSummaryFields()
    {
        Test.startTest();
        String fields=IntegrationUtility.getSummaryFields('Account');
        system.assert(fields!=null);
        Test.stopTest();                 
    }       
        
    @isTest
    public static void test_for_stripJsonNulls()
    {
        Test.startTest();
        String jsonString='{"Response":{"Id":"TestID, "Name":"Test Response"}}';
        String returnedJsonString=IntegrationUtility.stripJsonNulls(jsonString);
        system.assertEquals(jsonString, returnedJsonString);
        Test.stopTest();                 
    }         
}