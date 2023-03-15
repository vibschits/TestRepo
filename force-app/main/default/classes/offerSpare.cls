/*
Name : offerSpareWebService
Desc : THIS CLASS IS USED TO GET RESPONSE FROM SAP TO UPDATE SALESFORCE OFFER RECORD .
Author : NIKHIL
*/

global class offerSpare {
    
    public static string Gmatnr;
    public static string PDistrChan;
    public static string PDivision ;
    public static String pDocType;
    public static String PPurchNoC;
    public static String PQtValidF;
    public static String PQtValidT;
    public static String PReqDateH ;
    public static String PSalesOff;
    public static String PSalesOrg;
    public static String PSoldtoName;
    public static String SfOfferNo;
    public static String SalesGrp;
    public static OfferSpareWebServiceNew.TableOfZqtItemSf TItems;
    public static OfferSpareWebServiceNew.TableOfZvbOfrmsg TReturn ;
    public static  string responsemsg;
    
    @future(callout = true)
    public static void requestSapOfferId(String SAPOfferId, String ItId){
        
        Quote offer = [SELECT ID, SalesGrp__c,QuoteNumber,Opportunity.Customer_Branch_Assignment__r.Branch__r.Branch_Code__c,Status,Opportunity.Customer_Branch_Assignment__r.Branch__r.name,Branch__r.Name,Account.Name,SAP_Offer_Id__c, Delivery_Date__c, Division__c,Enquiry_Number__c, Part_List__r.name,
                       Distribution_Channel__c, Sales_Document_Type__c, Email, Quotation_Validity__c, Quotation_Date__c, Account.Sales_Organization__c,
                       Opportunity.Customer_Branch_Assignment__r.Customer_Code__c,Opportunity.Account.Name,Sales_Org__c,Sales_Org__r.Name,
                       Opportunity.Customer_Branch_Assignment__r.Division__c, Opportunity.Customer_Branch_Assignment__r.Distribution_Channel__c FROM QUOTE WHERE Id=: SAPOfferId  ];
        
        String userId = UserInfo.getUserId();
        User us = [Select Id,Sales_Group__c from User where Id =: userId];
        
        Gmatnr = offer.Part_List__r.name;
        system.debug('Gmatnr------'+Gmatnr);
        PDistrChan = offer.Opportunity.Customer_Branch_Assignment__r.Distribution_Channel__c;
        PDivision = offer.Opportunity.Customer_Branch_Assignment__r.Division__c; 
        pDocType = offer.Sales_Document_Type__c;
        PPurchNoC =offer.Enquiry_Number__c;
        PQtValidF = String.valueof(offer.Quotation_Date__c);
        PQtValidT =String.valueof(offer.Quotation_Validity__c);
        PReqDateH =String.valueof(offer.Delivery_Date__c);
        PSalesOff = String.valueof(offer.Opportunity.Customer_Branch_Assignment__r.Branch__r.Branch_Code__c);
        PSalesOrg = offer.Sales_Org__r.Name;//should come from opp branch assignment//take from opp
        PSoldtoName =String.valueof(offer.Opportunity.Customer_Branch_Assignment__r.Customer_Code__c);
        SfOfferNo =offer.QuoteNumber;
        //SalesGrp = us.Sales_Group__c;
        
        if(offer.SalesGrp__c != ''){
            SalesGrp = offer.SalesGrp__c;
        }else{
            User salesGrpUser = [Select Id,SalesGroupCode__c from User where Id =: offer.CreatedById];
            SalesGrp = salesGrpUser.SalesGroupCode__c;
        }
        
        
        OfferSpareWebServiceNew.TableOfZqtItemSf TItems = new OfferSpareWebServiceNew.TableOfZqtItemSf();
        TItems.item = new List<OfferSpareWebServiceNew.ZqtItemSf>();
        
        List<quotelineitem> qliList = [SELECT id, LineNumber, Product2.name,Quantity, Quote.Delivery_Date__c,Product_Quantity__c, 
                                       TotalPrice from QuoteLineItem WHERE QuoteId =:offer.id];
        system.debug('quoteline items----'+qliList);
        OfferSpareWebServiceNew.ZqtItemSf obj;
        
        for(QuoteLineItem qli :qliList ){
            obj=new OfferSpareWebServiceNew.ZqtItemSf();
            obj.ItmNumber = qli.LineNumber;
            obj.Material = qli.Product2.name;
            obj.ReqDate = string.valueOf(qli.Quote.Delivery_Date__c);
            obj.ReqQty = string.valueOf(qli.quantity);
            obj.CondType ='PR00';
            obj.CondRate = string.valueOf(qli.TotalPrice);
            system.debug('yyyyyyyy'+obj.ItmNumber);
            TItems.item.add(obj);
            system.debug('objTableOfZqtItemSf.item===='+TItems.item);
            
        }
        
        Integration_Transaction__c it = new Integration_Transaction__c(Id = ItId);
        system.debug('integration transaction details======='+it);
        try{
            //  Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
            OfferSpareWebServiceNew.ZWS_SPOFFER_CREATE_V1 authData = new OfferSpareWebServiceNew.ZWS_SPOFFER_CREATE_V1();
            system.debug('authData======='+authData);
            OfferSpareWebServiceNew.ZrfcSpareOfferCreateResponse_element mainfunction = new OfferSpareWebServiceNew.ZrfcSpareOfferCreateResponse_element();
            OfferSpareWebServiceNew.ZrfcSpareOfferCreate_element request = new OfferSpareWebServiceNew.ZrfcSpareOfferCreate_element();
            OfferSpareWebServiceNew.TableOfZvbOfrmsg  TReturn = new OfferSpareWebServiceNew.TableOfZvbOfrmsg();
            Blob headerValue = Blob.valueOf('rfcuser1'+ ':' + 'Pass@1234');
            //Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + sapOrg.Password__c);
            system.debug('headerValue--------'+headerValue);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            system.debug('authorizationHeader--------'+authorizationHeader);
            authData.inputHttpHeaders_x = new map<String,String>();
            authData.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            system.debug(' authData.inputHttpHeaders_x --------'+ authData.inputHttpHeaders_x ); 
            
            
            
            mainfunction = authData.ZrfcSpareOfferCreate(Gmatnr, PDistrChan, PDivision, PDocType, PPurchNoC, PQtValidF, PQtValidT, 
                                                         PReqDateH, PSalesOff, PSalesOrg, PSoldtoName, SalesGrp, SfOfferNo, TItems, TReturn);
            system.debug('mainfunction---'+mainfunction);
            
            OfferSpareWebServiceNew.ZrfcSpareOfferCreateResponse_element ResponsesapOffer = mainfunction; 
            string sapofferno = ResponsesapOffer.SapOfferNo;
            string responsetitems  = string.valueof(ResponsesapOffer.TItems.item);
            responsemsg = string.valueOf(ResponsesapOffer.TReturn.item);
            
            
            //  updateSAPofferidSFDC(sapofferno,offer.Id);
            if(String.isNotEmpty(sapofferno)){
                it.Status__c = 'Success';
                it.Response__c = String.valueOf(mainfunction);
                
            }else if(String.isEmpty(sapofferno)){
                it.Status__c = 'fail';
                it.Error__c = responsemsg;
               // it.Error__c = string.valueOf(ResponsesapOffer.TReturn.item);
  
            }
            //it.Response__c = sapofferno +'<br/>'+responsetitems+'<br/>'+ responsemsg;
            System.debug('====rc=='+sapofferno);
            
            system.debug('AK STATUS ===>'+offer.Status);
            // AK Change 05 Sept 2022
            if(offer.Status != 'Pricing accepted but SLA pending'){
                offer.SAP_Offer_Id__c = sapofferno;
            }
            
            NonSpareOfferAcknowledgementHelper.SendAcknowledgementToSAP(offer.Id, it.Id);
           	
            if(it.Status__c == 'Success'){
            	update offer;
            	system.debug('offer.SAP_Offer_Id__c'+offer.SAP_Offer_Id__c);
            }
            
            
        }
        catch(exception e){
            it.Status__c = 'fail';
            it.Error__c = e.getMessage() + e.getLineNumber();
            TegaUtility.trackLogs( e,  'offerSpare',  'requestSapOfferId');
            system.debug('error line===='+e.getLineNumber()+'====error type-----------'+e.getCause()+'-------error message-------'+e.getMessage()+
                         '-------error gettype-------'+e.getTypeName()+'-------error getStackTraceString-------'+e.getStackTraceString());
            
        }
        update it;
        
    }
}