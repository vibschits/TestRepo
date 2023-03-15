/*	 @isTest
private class TestCustomerWebserviceNew{

  @testSetup static void setup(){
        
        Account accountObj = new Account (
            BillingCity = 'test value', 
            BillingPostalCode = 'test value', 
            Phone = '1234567890', 
            Industry_segment__c ='0004', 
            Language__c = 'test value', 
            Tel_No__c = '1234567890', 
            Fax_number__c = 'test value', 
            Customer_Group__c = 'Here is reference id', 
            Status__c ='New', 
            Currency__c ='ADP', 
            GST_No__c = 'test value', 
            Email_Id__c = 'testEmail@gmail.com', 
            Name = 'test value'
        );
        insert accountObj;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales']; 
        
        user usr = new user();
        usr.Alias = 'sales';
        usr.Email = 'sales@testorg.com';
        usr.EmailEncodingKey = 'UTF-8'; 
        usr.firstname = 'Test'; 
        usr.LastName = 'Manager';
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US'; 
        usr.ProfileId = p.Id; 
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.UserName = 'salesuser1@testorg.com';
        
        insert usr;
        
        
        Sales_Org__c salesorgcObj = new Sales_Org__c(
            Name = 'TGSO',
            CurrencyIsoCode = 'INR',
            Company_code__c = 'TG01');
        insert salesorgcObj;
        
        Sales_Region__c salesregionObj = new Sales_Region__c(
            Name = 'East-1',
            CurrencyIsoCode = 'USD',
            Manager__c = usr.id);
        insert salesregionObj;
        
        Sales_Country__c salescountryobj = new Sales_Country__c(
            Name = 'India',
            CurrencyIsoCode = 'USD');
        insert salescountryobj;
        
        
        Branch__c branchcObj = new Branch__c(
            Name = 'Bokaro',
            CurrencyIsoCode = 'USD',
            Branch_Code__c = 'BOK',
            Is_WOS__c = false,
            Sales_Country__c = salescountryobj.id,
            Sales_Region__c = salesregionObj.id
        );
        
        insert branchcObj;
        
        Company__c company = new Company__c(
            Name = 'TEGA INDUSTRIES BOKARO',
            CurrencyIsoCode = 'USD',
            Sales_Organization__c = salesorgcObj.id);
        
        
        Customer_Sales_Organization__c customersalesorganizationcObj = new Customer_Sales_Organization__c(
            CurrencyIsoCode = 'INR',
            Sales_Organizations__c = salesorgcObj.id,
            Branch__c = branchcObj.id,
            Customer_Code__c = 'CC0240',
            Distribution_Channel__c = 'DS',
            Division__c = 'CC',
            Company__c = 'a0lBl0000001qJ7IAI',
            isChecked__c = false,
            Status__c = 'Valid',
            isDuplicate__c = false);
        insert customersalesorganizationcObj;
        
        
        
    }
	 @isTest
    static void testCustomerWebService() {
      Account accountObj = new Account (
            BillingCity = 'test value', 
            BillingPostalCode = 'test value', 
            Phone = '1234567890', 
            Industry_segment__c ='0004', 
            Language__c = 'test value', 
            Tel_No__c = '1234567890', 
            Fax_number__c = 'test value', 
            Customer_Group__c = 'Here is reference id', 
            Status__c ='New', 
            Currency__c ='ADP', 
            GST_No__c = 'test value', 
            Email_Id__c = 'testEmail@gmail.com', 
            Name = 'test value'
        );
        insert accountObj;
        CustomerWebserviceNew obj = new CustomerWebserviceNew();
        obj.ZrfcCustDetails(accountObj.id);
        obj.ZrfcCustDetailsResponse_element(accountObj.id);
        obj.ZWSCUST_DETAILS(accountObj.id);
        
    }

	@isTest static void testMethod2() {
		// code_block	
	}*/
@isTest
global class TestCustomerWebserviceNew implements WebServiceMock{
    global void doInvoke(
    Object stub,
    Object request,
    Map<String,Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
        String responseType) {
            CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element response_x = new  CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element();
           // response_x.return_x = new List<String>{'Garner State Park', 'Fowler Park', 'Hoosier National Forest Park'};
              //  response.put('response_x',response_x);
        }

}