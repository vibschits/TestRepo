@isTest
public class SAPCalloutTestClass{
    
    @testSetup static void setup(){
        
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
       // insert accountObj;
        
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
            //CurrencyIsoCode = 'INR',
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
        insert company;
        
        
        Customer_Sales_Organization__c customersalesorganizationcObj = new Customer_Sales_Organization__c(
            CurrencyIsoCode = 'INR',
            Sales_Organizations__c = salesorgcObj.id,
            Branch__c = branchcObj.id,
            Customer_Code__c = 'CC0240',
            Distribution_Channel__c = 'DS',
            Division__c = 'CC',
            Company__c = company.id,
            isChecked__c = false,
            Status__c = 'Valid',
            isDuplicate__c = false
          //  customer__c =accountObj.id
        );
      //  insert customersalesorganizationcObj;        
        
        
    }
    
    
    static testmethod void updateCustomerTest() {
        Account acc = new Account (
            BillingCity = 'Hyderabad', 
            BillingPostalCode = '500039', 
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
            Name = 'test Customer12'
        );
        insert acc;
        
        Integration_Transaction__c ittr = new Integration_Transaction__c();
        ittr.Record_Id__c = '001C1000002PgpJIAS';
        ittr.Request__c = 'Create Customer';
        ittr.Status__c = 'Draft';
        insert ittr;
        sapcallout_utility.updateCustomer(ittr.Record_Id__c,ittr.Id);
        
        Test.startTest();  
        
        Test.setMock(WebServiceMock.class, new CustomerWebServiceMockImpl());
         string responsesap = '{  "Kunnr": "CN0005",  "SfdcId": "001C1000002PgpJIAS", "CompCode": "TG01", "SalesOrg": "TGSO","DistChan": "DS","Street1": "MASAB TANK","Street2": "10-3-311/A, KHANIJ BHAVAN,","Street3": "CASTLE HILLS","Street4": "", "Street5": "hyderabad","Name": "NATIONAL MINERAL DEV CORPN. LTD.","PostCode": 500028, "City": "HYDERABAD","Region": 1,"IndustrySeg":"","Country": "", "Langu": "E","Telno": "","Mobile": 9831022222,"Fax": 245788999,"SalesOff": "HYD","Currency": "INR","Currency": "INR","Email": "test@gmail.com","GstNo": "","Pobox": "","CustGrp": "NALCO"}';
        
        Map<String, object> m = (Map<String, object>)JSON.deserializeUntyped(responsesap);
      
        CustomerWebserviceNewV3.ZttCustDtls custobj = new CustomerWebserviceNewV3.ZttCustDtls();
        CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element response = new  CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element();
        //CustomerWebserviceNew.ZttCustDtls zstcustdestails = new CustomerWebserviceNew.ZttCustDtls();
        
        CustomerWebserviceNewV3.ZWSCUST_DETAILS_V1 zcustObj = new CustomerWebserviceNewV3.ZWSCUST_DETAILS_V1();
     //  custobj = zcustObj.ZrfcCustDetails(ittr.Record_Id__c);
      //  system.debug('custobj-----'+custobj);
                Test.stopTest();

        String Kunnr;
        String SfdcId;
        String CompCode;
        String SalesOrg;
        String DistChan;
        String Street1;
        String Street2;
        String Street3;
        String Street4;
        String Street5;
        String Name;
        String PostCode;
        String City;
        String Region;
        String IndustrySeg;
        String Country;
        String Langu;
        String Telno;
        String Mobile;
        String Fax;
        String SalesOff;
        String Currency_x;
        String Email;
        String GstNo;
        String Pobox;
        String CustGrp;
         List<Account> acclis = new List<Account>();
        acclis = [Select Id,Name,Status__c,BillingPostalCode,BillingCity,Industry_segment__c,Language__c,Tel_No__c,Phone,Fax_number__c,Currency__c,Email_Id__c,GST_No__c,Customer_Group__c 
                  from Account WHERE ID =: acc.Id ];
        for(Account ac :acclis){
            ac.Name =string.valueof( m.get('Name'));
            ac.BillingPostalCode = string.valueof(m.get('PostCode'));
            ac.BillingCity = string.valueof(m.get('City'));
            ac.Language__c = string.valueof(m.get('Langu'));
            ac.Phone = string.valueof(m.get('Telno'));
            ac.Fax_number__c =string.valueof( m.get('Fax'));
            ac.Currency__c = string.valueof(m.get('Currency_x'));
            ac.Email_Id__c =string.valueof( m.get('Email'));
            ac.GST_No__c =string.valueof( m.get('GstNo'));
            ac.BillingStreet = string.valueof(m.get('Street1'));
            ac.Po_Box__c = string.valueof(m.get('Pobox'));
            ac.Industry_segment__c =string.valueof( m.get('IndustrySeg'));
            ac.Currency__c = string.valueof(m.get('Currency_x'));
            ac.BillingCountryCode =string.valueof( m.get('Country'));
            update ac;
        }
        ittr.Response__c = responsesap;
        ittr.Status__c ='success';
        update ittr;
    }
    
    
}