@IsTest(SeeAllData=false)
private class WebSvcCalloutTest {
    
    private static testMethod void sapcallouteupdatecustomerTest(){
        Test.setMock(WebServiceMock.class, new CustomerWebServiceMockImpl());
        Account accountObj = new Account (
            BillingCity = 'Hyderabad', 
            BillingPostalCode = '500038', 
            Phone = '1234567890', 
            Industry_segment__c ='0004', 
            Language__c = 'ENGLISH', 
            Tel_No__c = '1234567890',
            Fax_number__c = 'test value', 
            // Customer_Group__c = 'Here is reference id', 
            Status__c ='Pending at SAP', 
            Currency__c ='ADP', 
            GST_No__c = 'asdfqwer453fagjd', 
            Email_Id__c = 'testEmail@gmail.com', 
            Name = 'test Customer'
        );
        
        insert accountObj;
      
        Company__c company = new Company__c(Name= 'XYZ' , Company_Code__c = 'TG01');
		insert company;
        
        Sales_Region__c salesReg = new Sales_Region__c(Name = 'Test Sales Region', Manager__c = UserInfo.getUserId());
        insert salesReg;
        
         Branch__c branch = new Branch__c(Name = 'Test Branch', Sales_Region__c = salesReg.Id,Branch_Code__c = 'HYD');
        insert branch;
        
         Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;
        
        Customer_Sales_Organization__c custSalesOrg1 = new Customer_Sales_Organization__c( Customer__c = accountObj.Id ,Company__c= company.id,   status__c = 'Valid', Branch__c = branch.Id , CreatedFromAccount__c = true);
        insert custSalesOrg1;
        
        
        
        system.debug('accountObj id-------'+accountObj.id);
        Integration_Transaction__c ittr = new Integration_Transaction__c();
        ittr.Record_Id__c = accountObj.id;
        ittr.Request__c = 'Create Customer';
        ittr.Status__c = 'Draft';
        insert ittr;
        
        Test.setMock(WebServiceMock.class, new CustomerWebServiceMockImpl());
        SAPCallout_Utility.updateCustomer(ittr.Record_Id__c, ittr.Id);
    }
}