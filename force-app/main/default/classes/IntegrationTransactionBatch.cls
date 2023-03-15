/****************************************************************************************************
Name: IntegrationTransactionBatch
=============================================================================================
=============================================================================================
Purpose: Batch class to perform callouts for records that failed earlier callouts
=============================================================================================
=============================================================================================
History
---------------------------------------------------------------------------------------------
VERSION AUTHOR DATE DETAIL
1.0 - Rahul Chitkara (IBM)
*****************************************************************************************************/ 

global class IntegrationTransactionBatch implements Database.Batchable <sObject>, Database.AllowsCallouts{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator( [select id,Status__c,Error_Message__c,
                                          Operation_Type__c,No_of_Retries__c,Object_Name__c,Request__c,Response__c,
                                          record_id__c
                                          from  Integration_Transaction__c where  Status__c='Fail' and (No_of_Retries__c<3 or No_of_Retries__c=null)                                           
                                          order by lastmodifieddate                                                                                                                                                                                                                                                                                 
                                         ]);
    }
    
    /**********************************************************************************************************************************************************************************************
    Method: execute
    Description: Performs callouts for each of the failed Integration Transaction records and updates their retry values
    ***********************************************************************************************************************************************************************************************/        
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Integration_Transaction__c intTransactionObj;
        try{
          list<Integration_Transaction__c> integrationTransactionList = (list<Integration_Transaction__c>) scope;
          map<Id,Integration_Transaction__c> mapOfIntegrationTransactionrecords = new map<Id,Integration_Transaction__c>(integrationTransactionList);    
          //This loop will run only once as the batch size in batch-schedular has been fixed to 1
          for(Integration_Transaction__c temp: integrationTransactionList)
          {
            intTransactionObj=temp;                  
          }                       
          if(intTransactionObj.Operation_type__c==' Specific Operation Name') {
            // Creata a utility class for specific Opertaion type and callout the integration  
          }
          else if (intTransactionObj.Operation_type__c==' Another  Operation Name'){
            // Creata a utility class for specific Opertaion type and callout the integration  

          }
          // Basis on above, all operation type can be entered here and specific utility/handler class can be called to integrate    
           intTransactionObj.No_of_Retries__c++ ; 
                
           update intTransactionObj;
        }    
        catch(exception e)
        {                            
            intTransactionObj.Status__c='Fail'; intTransactionObj.No_of_Retries__c++ ; Update intTransactionObj;
                                    
            // Use IBM error logger
        }                
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    
}