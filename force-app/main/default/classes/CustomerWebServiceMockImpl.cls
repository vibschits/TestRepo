global class CustomerWebServiceMockImpl implements WebServiceMock {
    CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element responseELE;
    CustomerWebserviceNewV3.ZstCustDtls custDtlsObj;
    
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
            
            //Account accid = new account(name = 'test Customer' );
            //insert accid;
            Account  accid =[select id from account where name='test Customer'];
            
            
            responseELE = new CustomerWebserviceNewV3.ZrfcCustDetailsResponse_element();
            String ExMessage = '';
            CustomerWebserviceNewV3.ZttCustDtls ExCustDtls=new CustomerWebserviceNewV3.ZttCustDtls();
            CustomerWebserviceNewV3.ZstCustDtls custDtlsObj=new CustomerWebserviceNewV3.ZstCustDtls();
            CustomerWebserviceNewV3.ZstCustDtls[] item=new CustomerWebserviceNewV3.ZstCustDtls[]{};
                
                custDtlsObj.Kunnr  = 'CN0005';
            custDtlsObj.SfdcId = accid.id;
            custDtlsObj.CompCode = 'TG01';
            custDtlsObj.SalesOrg = 'TGSO';
            custDtlsObj.DistChan = 'DS';
            custDtlsObj.Street1 ='MASAB TANK';
            custDtlsObj.Street2 ='10-3-311/A, KHANIJ BHAVAN';
            custDtlsObj.Street3 = 'CASTLE HILLS';
            custDtlsObj.Street4= '';
            custDtlsObj.Street5='hyderabad';
            custDtlsObj.Name= '"NATIONAL MINERAL DEV CORPN. LTD.';
            custDtlsObj.PostCode='500028';
            custDtlsObj.City='HYDERABAD';
            custDtlsObj.Region='1';
            custDtlsObj.IndustrySeg='4';
            custDtlsObj.Country ='IN';
            custDtlsObj.Langu ='';
            custDtlsObj.Telno='';
            custDtlsObj.Mobile='9831022222';
            custDtlsObj.Fax ='245788999';
            custDtlsObj.SalesOff='HYD';
            custDtlsObj.Currency_x='INR';
            custDtlsObj.Email='test@gmail.com';
            custDtlsObj.GstNo='';
            custDtlsObj.Pobox='';
            custDtlsObj.CustGrp='NALCO';
            
            
            item.add(custDtlsObj);
            ExCustDtls.item=item;
            responseELE.ExCustDtls=ExCustDtls;
             responseELE.ExMessage=ExMessage;
            
            system.debug('responseELE-------'+responseELE.ExCustDtls);
            response.put('response_x',responseELE ); 
            
        }
    
}