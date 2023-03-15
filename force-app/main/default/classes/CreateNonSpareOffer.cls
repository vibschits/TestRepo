/*
Name : CreateNonSpareOffer
Description : This class used to create offer from SAP.
Author : Kuhinoor
*/

public with sharing class CreateNonSpareOffer implements Queueable, Database.allowscallouts{
    String offerNumber;
    Id itId;
    public CreateNonSpareOffer(String offerNumber, Id itId){
        this.offerNumber = offerNumber;
        this.itId = itId;
    }
    public void execute(QueueableContext qc){
        Integration_Transaction__c it = new Integration_Transaction__c(Id = itId); 
        try {           
            List<Quote> offerList = new List<Quote>();
            Quote newOffer;
            Id pbId;

            // Integration Credential 
            Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();

            //SOAP callout to get offer Details...
            NonSparesServiceNewV2.ZWSNSOFFER_DTLS_V1 zwnonSpareOfr = new NonSparesServiceNewV2.ZWSNSOFFER_DTLS_V1();
            NonSparesServiceNewV2.ZofferDtlsSfdcResponse_element response = new NonSparesServiceNewV2.ZofferDtlsSfdcResponse_element();
            Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + 'Tega@1234');
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            zwnonSpareOfr.inputHttpHeaders_x = new Map<String,String>();
            zwnonSpareOfr.inputHttpHeaders_x.put('Authorization', authorizationHeader);

            response = zwnonSpareOfr.ZofferDtlsSfdc('','',offerNumber);
            System.debug('response-->>'+response);
            it.Response__c ='Offer Response: \r\n'+ String.valueOf(response);    

            NonSparesServiceNewV2.ZttNspOffer GtHeader = response.GtHeader;
            NonSparesServiceNewV2.ZttitemVbapSf GtItem = response.GtItemtab;
            //AK Changes 24/11/2022
            String responseMsg = response.ExMessage;

            NonSparesServiceNewV2.ZstNspOffer[] itemList = GtHeader.item;
            System.debug('itemList-->>'+itemList);
            
            NonSparesServiceNewV2.ZitemVbapSf[] lineItemList = GtItem.item;
            System.debug('lineItemList-->>'+lineItemList);
            
            String getCurrencyFromLineItem = lineItemList[0].Waers;
            system.debug('getCurrencyFromLineItem=>'+getCurrencyFromLineItem);

            if(itemList != null && itemList.size() > 0 ){
                String sapOfferNumber = itemList[0].Vbeln;
                String branchCode = itemList[0].Vkbur;
                String salesOrgCode = itemList[0].Vkorg;

                // Query PRF to get related opportunity...
                List<Proposal_Form__c>proFormList =[SELECT Id,Opportunity__c,Opportunity__r.CurrencyIsoCode FROM Proposal_Form__c 
                                                    WHERE SAP_Offer_Number__c =:sapOfferNumber];
                system.debug('proFormList=>'+proFormList);
                
                // fetch Branch for offer
                List<Branch__c> branchList = [SELECT Id FROM Branch__c WHERE Branch_Code__c =: branchCode]; 
                
                // fetch Sales org for offer
                List<Sales_Org__c> salesOrgList = [select Id from Sales_Org__c where Name =: salesOrgCode];

                Map<String, Non_Spare_Type__mdt > nonSpareTypeMap = Non_Spare_Type__mdt.getAll();

                if(proFormList != null && proFormList.size() > 0){
                        NonSparesServiceNewV2.ZstNspOffer item = itemList[0];
                        system.debug('item=>'+item);
                        // Revised Offer
                        Id parentOfferId;

                        List<Quote> existingOfferList = [SELECT Id FROM Quote 
                                                        WHERE SAP_Offer_Id__c =: item.Vbeln 
                                                        Order By Parent_Offer__c];     
                           system.debug('existingOfferList =>'+existingOfferList);
                           
                        List<Pricebook2> pbList = [SELECT Id FROM Pricebook2 WHERE Name =: item.Vbeln];
                        /*
                        Creating price book for every offer with the name of Offer
                        */
                        Pricebook2 pb = new Pricebook2(Name = item.Vbeln, IsActive = true,
                                                        Description = pbList != null && pbList.size()> 0 ? 'Rev-'+pbList.size(): '');
                        insert pb;

                        Quote offer = new Quote();
                        offer.recordTypeId = TegaUtilityWithoutSharing.getOfferRecordTypeId('Offer_Non_Spare'); 
                        offer.Pricebook2Id = pb.Id;
                        offer.OpportunityId = proFormList[0].Opportunity__c;
                        offer.Name = item.Vbeln;
                        offer.SAP_Offer_Id__c = item.Vbeln;
                        offer.Quotation_Date__c = date.valueOf(item.ValidFrom);
                        offer.Quotation_Validity__c = date.valueOf(item.ValidTo);   

                        offer.Offer_Type__c =  nonSpareTypeMap.get(item.OfferType).Value__c;
                        offer.Inquiry_Type__c = nonSpareTypeMap.get(item.InquiryTyp).Value__c;
                    	if(nonSpareTypeMap.containsKey(item.OrderType))
                        	offer.Order_Type__c =  nonSpareTypeMap.get(item.OrderType).Value__c;
                        offer.status = nonSpareTypeMap.get(item.Status).Value__c;

                        offer.Division__c =  item.Spart;
                        offer.Distribution_Channel__c =  item.Vtweg;
                        offer.Sales_Document_Type__c = item.Auart;
                        offer.Customer_Code__c = item.Kunnr;
                        offer.Branch__c = branchList[0].Id;
                        offer.Sales_Org__c = salesOrgList[0].Id;
                        //offer.Requested_Delivery_Date__c =Date.valueOf(item.Vdatu);
                        //offer.Schedule_Line_Date__c = Date.valueOf(item.Edatu);
                        if(existingOfferList != null && existingOfferList.size() > 0){
                            offer.Revision__c = existingOfferList.size();
                            offer.Parent_Offer__c = existingOfferList[0].Id;
                        }
                        
                    if(proFormList[0].Opportunity__r.CurrencyIsoCode == getCurrencyFromLineItem){
                        system.debug('Offer ==>'+offer);
                        insert offer;
                        system.debug('2nd Job will begin');
                        // Invoke product and line creation JOB
                        
                        //AK Changes 24/11/2022
                        if(responseMsg != ''){
                            it.Status__c = 'fail';
                            it.Error__c = responseMsg;
                            update it;
                        }else{
                            system.enqueueJob(new CreateProductAndOfferLine(offer, pb, response, it));
                        }
                    }else{
                        it.Status__c = 'fail';
                        it.Error__c = 'Currency Mismatch in Opportunity and Offer Line Item. Please make sure both currency remains same';
                        update it;
                    }
                }
            }
        } catch (Exception ex) {
            it.Status__c = 'fail';
            it.Error__c ='Class Name : CreateNonSpareOffer \r\n '+ ex.getMessage()+' Line:'+ex.getLineNumber();
            update it;
        }

    }
}