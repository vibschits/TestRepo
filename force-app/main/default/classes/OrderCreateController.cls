public with sharing class OrderCreateController implements Queueable, Database.allowscallouts{
    String orderNumber;
    Id itId;
    String operationType;
    
    public OrderCreateController( String orderNumber, Id it,String operationType){
        this.orderNumber = orderNumber;
        this.itId = it;
        this.operationType = operationType;
    }
    
    public void execute(QueueableContext qc){
        
        // Integration Credential 
        Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
        Integration_Transaction__c it = new Integration_Transaction__c(Id = itId); 
        SAPOrderWebServiceV2.ZWS_SO_BOM_DTLS_V1 soBOM =  new SAPOrderWebServiceV2.ZWS_SO_BOM_DTLS_V1();
        SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element response = new SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element();
        Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + 'Tega@1234');
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        soBOM.inputHttpHeaders_x = new Map<String,String>();
        soBOM.inputHttpHeaders_x.put('Authorization', authorizationHeader);
        response = soBOM.ZrfcSobomDtls(orderNumber);
        
        if(response.ExMessage != ''){
            it.Status__c = 'Fail';
            it.sync__c = false;
            it.Error__c = response.ExMessage;
        }else{
            SAPOrderWebServiceV2.ZstrcSono GwHeaderObj = response.GwHeader;
            
            System.debug('GwHeaderObj-->>'+GwHeaderObj);
            
            // fetch Sales org for offer
            List<Sales_Org__c> salesOrgList = [select Id from Sales_Org__c where Name =: GwHeaderObj.SalesOrg];
            Sales_Org_Currency_Mapping__mdt salesOrgCurr = Sales_Org_Currency_Mapping__mdt.getInstance(GwHeaderObj.SalesOrg);
            Pricebook2 pb;
            String localCurrency = salesOrgCurr.Currency__c;
            Order odr = new Order();
            odr.Name = GwHeaderObj.Vbeln;
            //odr.Incoterms__c = GwHeaderObj.Inco1;
            odr.Incoterm_City__c = GwHeaderObj.IncotermCity;
            odr.EffectiveDate = Date.valueOf(GwHeaderObj.Erdat);
            odr.Created_By_SAP__c = GwHeaderObj.Ernam;
            odr.Netwr__c = Decimal.valueOf(GwHeaderObj.Netwr);
            odr.Doc_Currency__c = GwHeaderObj.DocCurr;
            odr.Division__c = GwHeaderObj.Spart;
            odr.Sales_Org__c = salesOrgList[0].Id;
            odr.Sales_Office__c = GwHeaderObj.SalesOffice;
            odr.Sales_Group__c = GwHeaderObj.SalesGrp;
            odr.Payment_Terms__c = GwHeaderObj.Zterm;
            odr.Customer_PO_date__c = Date.valueOf(GwHeaderObj.Bstdk);
            odr.Net_Value__c = Decimal.valueOf(GwHeaderObj.NetwrLc);
            odr.Customer_PO_No__c = GwHeaderObj.Bstkd;
            odr.CurrencyIsoCode = localCurrency;
            //odr.AccountId = GwHeaderObj.SoldtoSf;
            odr.AccountId = '001Bl000003FXDFIA4';
            //odr.Ship_To__c = GwHeaderObj.ShiptoSf;
            odr.Status = 'Draft';
            
            odr.End_Customer_PO_No__c = GwHeaderObj.EndcustPo;
            if(GwHeaderObj.EndcustPoDt != '0000-00-00'){
                odr.End_Customer_PO_date__c = Date.valueOf(GwHeaderObj.EndcustPoDt);
            }
            odr.Payment_Term_Description__c = GwHeaderObj.PtermDesc;
		           
            if(operationType=='Update SO-BOM'){
                Order Ordr = [select Id,pricebook2.Id from Order where Name =:GwHeaderObj.Vbeln];
                odr.Id = Ordr.Id;
                update odr;
                pb = [select Id from priceBook2 where Id=:Ordr.pricebook2.Id];
            }
            else{ 
                pb = new Pricebook2(Name =GwHeaderObj.Vbeln, IsActive = true,Description = GwHeaderObj.Vbeln);
                insert pb;  
                odr.Pricebook2Id = pb.Id;  
                insert odr;
            }
            if(!test.isRunningTest()){
                system.enqueueJob(new CreateOrderlines(odr, pb, response, it,localCurrency)); }
            
        }
        
    }
}