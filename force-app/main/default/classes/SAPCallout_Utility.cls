/*
Name : SAPCallout_Utility
Desc : This class used to call SOAP api and get customer data and update customer.
Author : 
*/
public class SAPCallout_Utility{
    
    /*
Name : updateCustomer
Desc : This method is used for updating customer with response. 
Params : customerId,itId
*/
    @Future(callout=true)
    public static void updateCustomer(String customerId, String itId){
        system.debug('updateCustomer is Calling');
        Set<String> salesOrgSet = new Set<String>();
        Set<String> salesOffcSet = new Set<String>();
        Set<String> salesCompcode = new set<String>();
        //This map contains key as SalesOff
        Map<String, String> cusSalesOrgMap = new Map<String,String>();
        
        Map<String, List<Customer_Sales_Organization__c>> cusSalesOrgListMap = new Map<String, List<Customer_Sales_Organization__c>>();
        
        Map<String, String> allcusSalesOrgMap = new Map<String,String>();
        
        Map<String, String> salesOrgMap = new Map<String,String>();
        Map<String, Id> branchMap = new Map<String,Id>();
        Map<String, Id> compCodeMap = new Map<String,Id>();
        
        Integration_Transaction__c it = new Integration_Transaction__c(Id = itId); 
        
        
        try {
            Account acc;
            Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
            CustomerWebserviceNewV3.ZWSCUST_DETAILS_V1 responseMethod = new CustomerWebserviceNewV3.ZWSCUST_DETAILS_V1();
            CustomerWebserviceNewV3.ZttCustDtls listItemsMethod = new CustomerWebserviceNewV3.ZttCustDtls();
            CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element response = new CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element();
            List<CustomerWebserviceNewV3.ZstCustDtls> itemList = new List<CustomerWebserviceNewV3.ZstCustDtls>();
            
            // MAKING CONNECTION
            // Blob headerValue = Blob.valueOf('rfcuser1'+ ':' + 'Pass@1234');
            Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + sapOrg.Password__c);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            responseMethod.inputHttpHeaders_x = new map<String,String>();
            responseMethod.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            response = responseMethod.ZrfcCustDetails(customerId);
            it.Response__c = String.valueOf(response); 
            
            // Fetch data
            listItemsMethod = response.ExCustDtls;
            itemList = listItemsMethod.item;
            System.debug('itemList-->>'+itemList);
            
            String exMessage = response.ExMessage;
            if(exMessage != ''){
                it.Status__c = 'Fail';
                it.Error__c = exMessage;
                it.sync__c = false;
            }else{
                it.Status__c = 'Success';
                it.sync__c = true;
                // Here we are getting Response in listData updating in SF 
                if(itemList !=null && itemList.size() > 0 ){
                    CustomerWebserviceNewV3.ZstCustDtls data = itemList[0];
                    //Store Data in Customer (Account)
                    acc = [Select Id,Name,Status__c,BillingPostalCode,BillingCity,Industry_segment__c,Language__c,Tel_No__c,Phone,Fax_number__c,Currency__c,Email_Id__c,GST_No__c,Customer_Group__c 
                           from Account WHERE ID =: data.SfdcId];
                    system.debug('acc');
                    acc.Name = data.Name;
                    acc.BillingPostalCode = data.PostCode;
                    acc.BillingCity = data.City;
                    acc.Language__c = data.Langu;
                    acc.Phone = data.Telno;
                    acc.Fax_number__c = data.Fax;
                    acc.Currency__c = data.Currency_x;
                    acc.Email_Id__c = data.Email;
                    acc.GST_No__c = data.GstNo;
                    acc.BillingStreet = data.Street1 + ',' + data.Street2 + ',' + data.Street3 + ',' + data.Street4 + ',' + data.Street5;
                    acc.Po_Box__c = data.Pobox;
                    acc.Industry_segment__c = data.IndustrySeg;
                    //acc.Mobile_number__c = data.Mobile;
                    acc.Currency__c = data.Currency_x;
                    acc.BillingCountryCode = data.Country;
                    //  update acc;
                    //Added By Kuhinoor..
                    for(CustomerWebserviceNewV3.ZstCustDtls data1 : itemList){
                        salesOrgSet.add(data1.SalesOrg);
                        salesOffcSet.add(data1.SalesOff);
                        salesCompcode.add(data1.CompCode);
                    }
                    //Querying the CSO which are mapping with the Response data 
                    List<Customer_Sales_Organization__c> customerSalesList = [SELECT Id,Branch__r.Branch_Code__c,Sales_Organizations__c,Sales_Organizations__r.Name
                                                                              FROM Customer_Sales_Organization__c
                                                                              WHERE Customer__c =: acc.Id 
                                                                              AND Branch__r.Branch_Code__c IN : salesOffcSet];           
                    
                    for(Customer_Sales_Organization__c cs : customerSalesList){
                        system.debug('cs========'+cs);
                        // cusSalesOrgMap.put(cs.Sales_Organizations__r.Name, cs.Id);
                        cusSalesOrgMap.put(cs.Branch__r.Branch_Code__c, cs.Id);
                        system.debug('cusSalesOrgMap========'+cusSalesOrgMap);
                        
                        if(cusSalesOrgListMap.containsKey(cs.Branch__r.Branch_Code__c)){
                            List<Customer_Sales_Organization__c> csoTempList = cusSalesOrgListMap.get(cs.Branch__r.Branch_Code__c);
                            csoTempList.add(cs);
                            cusSalesOrgListMap.put(cs.Branch__r.Branch_Code__c,csoTempList);
                        }else if(!cusSalesOrgListMap.containsKey(cs.Branch__r.Branch_Code__c)){
                            List<Customer_Sales_Organization__c> csoTempList = new List<Customer_Sales_Organization__c>();
                            csoTempList.add(cs);
                            cusSalesOrgListMap.put(cs.Branch__r.Branch_Code__c,csoTempList);
                        }
                        
                    }
                    //Here We are Query the BRANCH, COMPANY &  Sales Org with the Response Data
                    List<Sales_Org__c> salesOrgList = [SELECT Id,Name FROM Sales_Org__c WHERE Name IN :salesOrgSet ];
                    List<Branch__c> branchList = [SELECT Id,Branch_Code__c FROM Branch__c WHERE Branch_Code__c IN :salesOffcSet ];
                    List<Company__c> companyList = [SELECT Id,Name,Company_Code__c FROM Company__c WHERE company_code__c IN :salesCompcode ];
                    system.debug('companyList---'+companyList);
                    //Here we are Storing the Data to update the values 
                    if(salesOrgList.size() > 0 ){
                        for(Sales_Org__c sOrg : salesOrgList){
                            salesOrgMap.put(sOrg.Name, sOrg.Id);
                        }
                    }
                    if(branchList.size() > 0 ){
                        for(Branch__c br : branchList){
                            system.debug('branchList====='+branchList+'------br.Branch_Code__c, br.Id------'+br.Branch_Code__c+br.Id);
                            branchMap.put(br.Branch_Code__c, br.Id);
                            system.debug('branchMap-----'+branchMap);
                        }
                    }
                    if(companyList.size() > 0 ){
                        for(Company__c cmpName : companyList){
                            compCodeMap.put(cmpName.company_code__c, cmpName.Id);
                        }
                    }
                    List<Customer_Sales_Organization__c> csalesorginsertList = new List<Customer_Sales_Organization__c>();
                    List<Customer_Sales_Organization__c> cSalesOrgUpdateList = new List<Customer_Sales_Organization__c>();
                    //Here we are fetching all CSO from SFDC 
                    List<Customer_Sales_Organization__c> allcustomerSalesList = [SELECT Id,Customer_Code__c,Branch__r.Branch_Code__c,Sales_Organizations__c,status__c,Sales_Organizations__r.Name
                                                                                 FROM Customer_Sales_Organization__c WHERE Customer__c =: acc.Id ];   
                    // system.debug('Invalid cSalesOrgUpdateList========='+cSalesOrgUpdateList);
                    // Here we are updating the CSO if we arehaving the record in sf then it will update with Customer code
                    for(CustomerWebserviceNewV3.ZstCustDtls data2 : itemList){
                        if (cusSalesOrgMap.containsKey(data2.SalesOff) ){
                            system.debug('cusSalesOrgMap----'+cusSalesOrgMap+'-----data2.SalesOff-----'+data2.SalesOff);
                            //  cSalesOrgUpdateList.add( new Customer_Sales_Organization__c(
                            Customer_Sales_Organization__c csoForUpd = new Customer_Sales_Organization__c();
                            List<Customer_Sales_Organization__c> tempCSOList = cusSalesOrgListMap.get(data2.SalesOff);
                            for(Customer_Sales_Organization__c cso : tempCSOList){
                                if(data2.SalesOrg == cso.Sales_Organizations__r.Name){
                                    csoForUpd = cso;
                                }
                            }
                                
                            Customer_Sales_Organization__c updatecso = new Customer_Sales_Organization__c(
                                //Id = cusSalesOrgMap.containsKey(data2.SalesOff) ? cusSalesOrgMap.get(data2.SalesOff) : null,
                                Id = csoForUpd.Id,
                                Customer__c = acc.Id,
                                Company__c = compCodeMap.get(data2.CompCode),
                                Sales_Organizations__c = salesOrgMap.get(data2.SalesOrg),
                                Customer_Code__c = data2.Kunnr,
                                Distribution_channel__c = data2.DistChan,
                                //Division__c = data2.Division,
                                status__c = 'Valid',
                                CreatedFromAccount__c = true,
                                Branch__c = branchMap.containsKey(data2.SalesOff) ? branchMap.get(data2.SalesOff) : null
                            );
                            cSalesOrgUpdateList.add(updatecso);
                            System.debug('cSalesOrgUpdateList========'+cSalesOrgUpdateList);
                            
                        }
                        //Here we are checking the response which does not contains in sf then we doing insert
                        if(!cusSalesOrgMap.containsKey(data2.SalesOff) ){
                            Customer_Sales_Organization__c insertcso = new Customer_Sales_Organization__c(
                                Customer__c = acc.Id,
                                Company__c = compCodeMap.get(data2.CompCode),
                                Sales_Organizations__c = salesOrgMap.get(data2.SalesOrg),
                                Customer_Code__c = data2.Kunnr,
                                Distribution_channel__c = data2.DistChan,
                                CreatedFromAccount__c = true,
                                Branch__c = branchMap.containsKey(data2.SalesOff) ? branchMap.get(data2.SalesOff) : null
                            );
                            csalesorginsertList.add(insertcso);
                   }
                    }
                  
                    for(Customer_Sales_Organization__c cso : allcustomerSalesList){
                        system.debug('inside for loop before 2 insert---');
                        if(!salesOffcSet.contains(cso.Branch__r.Branch_Code__c)){
                            system.debug('inside before if ---');
                            cSalesOrginsertList.add(new Customer_Sales_Organization__c(Id= cso.Id, company_code__c =cso.Company_Code__c, status__c = 'Invalid'));             
                        }
                    }
                      //Inserting list of response
                    if(csalesorginsertList.size()>0){
                        insert csalesorginsertList;
                    }
                    //Updating the list of response with Existing Record
                    if(cSalesOrgUpdateList.size()>0){
                        System.debug('cSalesOrgUpdateList========'+cSalesOrgUpdateList);
                        update cSalesOrgUpdateList;
                    }
                    
                    
                    it.Status__c = 'Success';
                    it.sync__c = true;
                    If(It.Status__c == 'Success'){
                        acc.Status__c = 'Sync with SAP';
                    }
                    update acc;
                    //END HERE..
                }
                
            }            
            
        }catch (Exception ex) {
            it.Status__c = 'fail';
            it.Error__c = ex.getMessage();
            TegaUtility.trackLogs( ex,  'SAPCallout_Utility',  'updateCustomer');
            system.debug('error line===='+ex.getLineNumber()+'====error type-----------'+ex.getCause()+'-------error message-------'+ex.getMessage()+
                         '-------error gettype-------'+ex.getTypeName()+'-------error getStackTraceString-------'+ex.getStackTraceString());
            
        }
        
        update it;
        
        
    }
    
}