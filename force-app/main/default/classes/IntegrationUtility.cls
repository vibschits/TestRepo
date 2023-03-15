/****************************************************************************************************
Name: IntegrationUtility
=============================================================================================
=============================================================================================
Purpose: Utility class to help in various integrations
=============================================================================================
=============================================================================================
History
---------------------------------------------------------------------------------------------
VERSION AUTHOR DATE DETAIL
1.0 - Rahul Chitkara
*****************************************************************************************************/ 

global class IntegrationUtility {

    public static List<SobjectField> mergeFields = null;
    
    /**********************************************************************************************************************************************************************************************
    Method: InsertLogwithResponse
    Description: 
    1. Creates a new record of Integration Transaction object with the passed values
     ***********************************************************************************************************************************************************************************************/        
    global static Integration_Transaction__c InsertIntegrationTransaction(string transactype,string sobjectid,string acktstatus,string RequestJson, string ResponseJSON,string EventName)
    {
        Integration_Transaction__c ReqDetails = new Integration_Transaction__c();
        try
        {        
            ReqDetails.Object_Name__c=transactype ;
            ReqDetails.record_id__c=sobjectid;
            ReqDetails.Request__c = RequestJson;
            ReqDetails.Response__c = ResponseJSON;
            Reqdetails.Status__c=acktstatus ;
            Reqdetails.Operation_Type__c=EventName ;
            insert(ReqDetails);
        }
        catch(Exception e)
        {
           // USE IBM Error logger
        }
        Return ReqDetails ;
    }

    /**********************************************************************************************************************************************************************************************
    Method: UpdateLogwithErrorResponse
    Description: 
    1. Creates a new record of Integration Transaction object with the passed values in case of a failure scenario
     ***********************************************************************************************************************************************************************************************/            
    global static void UpdateIntegrationTransaction(string transactype,string sobjectid,string acktstatus,string ErrorMessage,string RequestJson, string ResponseJSON,string EventName,Integration_Transaction__c IntegrationTransaction)
    {
        try
        {
            IntegrationTransaction.Object_Name__c=transactype ;
            IntegrationTransaction.record_id__c=sobjectid;
            IntegrationTransaction.Request__c = RequestJson;
            IntegrationTransaction.Status__c=acktstatus ;
            IntegrationTransaction.Response__c = ResponseJSON;
            IntegrationTransaction.Error_Message__c=ErrorMessage ;
            IntegrationTransaction.Operation_Type__c=EventName ; 
            Update(IntegrationTransaction);
        }
        catch(Exception e)
        {
           //Use IBM Error logger        
        }
    }

    /**********************************************************************************************************************************************************************************************
    Method: getSummaryFields
    Description: 
    1. Returns a string of comma separated object fields
     ***********************************************************************************************************************************************************************************************/                    
    public static String getSummaryFields(String sObjectName) {          
        String summarizedFields = '';
        try
        {
            for ( SobjectField field : getMergeFields(sObjectName) ) {              
                summarizedFields += ',' + field.getDescribe().getName();
            }    
        }
        catch(Exception e)
        {
            // Use IBM Error Logger 
        }
        return summarizedFields;
    }


    private static List<SobjectField> getMergeFields(String sObjectName) {
        try
        {
            if ( mergeFields == null ) {
                mergeFields = new List<SobjectField>();
                Map<String, Schema.SobjectField> fieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
                for ( Schema.SobjectField field : fieldMap.values() ) {
                    Schema.DescribeFieldResult f = field.getDescribe();
                    if ( f.isCustom() && !f.isCalculated() && f.getType() != Schema.DisplayType.Reference) {
                        mergeFields.add(field);
                    }
                }        
            }
        }
        catch(Exception e)
        {        
            // USE IBM Error Logger 
        }
        return mergeFields;
    }


    /**********************************************************************************************************************************************************************************************
    Method: stripJsonNulls
    Description: 
    1. Returns a formatted URL
     ***********************************************************************************************************************************************************************************************/                            
    public static string stripJsonNulls(string JsonString)
    {
        try
        {
            if(JsonString != null)      
            {
                JsonString = JsonString.replaceAll('\"[^\"]*\":null',''); //basic removeal of null values
                JsonString = JsonString.replace('{,}', ''); //prevent closing bracket from having a comma before it
                JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
                JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
                JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
                JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
                JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
                JsonString = JsonString.replaceAll('/[,/]', '/[/]'); //remove duplicate/multiple commas
                JsonString = JsonString.replace(':,', ':{},'); //prevent closing bracket from having a comma before 
                JsonString = JsonString.replace('https:/[/]', 'https://'); //corrects the URL                 
            }
        }
        catch(Exception e)
        {
          // Use IBM Error Logger
        }
        return JsonString;
    }
    


}