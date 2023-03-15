@isTest
private class TestTegaUtility{
    
    @testSetup static void setup(){
        Try{           
            Error_Log__c errorLog = new Error_Log__c();
            List<Apexclass> Clsnames =  [SELECT ID, Name FROM Apexclass LIMIT 1];
            errorLog.Class_Name__c = Clsnames[0].Name;
            errorLog.Method_Name__c = 'UpdateCustomer';
            errorLog.Error_Message__c = 'Update failed. First exception on row 0 with id 001Bl000003MXLOIA4; first error: FIELD_INTEGRITY_EXCEPTION, Theres a problem with this country, even though it may appear correct. Please select a country/territory from the list of valid countries.: Billing Count	';
            errorLog.Error_Type__c = 'Update failed. First exception on row 0 with id 001Bl000003MXLOIA4';
            errorLog.Line_Number__c = 12;
            insert errorLog;
        }catch(exception e){
            
        }
    }
        @isTest static void testMethod1() {
             Error_Log__c errorLog = new Error_Log__c();
            List<Apexclass> Clsnames =  [SELECT ID, Name FROM Apexclass LIMIT 1];
            errorLog.Class_Name__c = Clsnames[0].Name;
            errorLog.Method_Name__c = 'UpdateCustomer';
            errorLog.Error_Message__c = 'Update failed. First exception on row 0 with id 001Bl000003MXLOIA4; first error: FIELD_INTEGRITY_EXCEPTION, Theres a problem with this country, even though it may appear correct. Please select a country/territory from the list of valid countries.: Billing Count	';
            errorLog.Error_Type__c = 'Update failed. First exception on row 0 with id 001Bl000003MXLOIA4';
            errorLog.Line_Number__c = 12;
            insert errorLog;
            Exception e =new System.DMLException();
            string className =errorLog.Class_Name__c;
            string methodName = errorLog.Method_Name__c;
            
            TegaUtility.trackLogs(e, className, methodName);
        }
        
        
        // 
        
    
    
    
}