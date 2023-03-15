/*
Name : CreateProductAndOfferLine
Description : This class used to fetch detail form SAP using SOAP API
              and create product and offerLInes in salesforce
Author : Kuhinoor
*/

public with sharing class CreateProductAndOfferLine implements Queueable, Database.allowscallouts{
    Quote offer;
    Pricebook2 pb;
    NonSparesServiceNewV2.ZofferDtlsSfdcResponse_element response;
    Integration_Transaction__c it;

    public CreateProductAndOfferLine(Quote offer, Pricebook2 pb, 
                                    NonSparesServiceNewV2.ZofferDtlsSfdcResponse_element response, 
                                    Integration_Transaction__c it){
        this.offer = offer;
        this.pb = pb;
        this.response = response;
        this.it = it;
    }
    public void execute(QueueableContext qc){
        try{
            // get product details...
            String responseMsg = '';
            NonSparesServiceNewV2.ZttitemVbapSf GTItemTab = response.GtItemtab;
            NonSparesServiceNewV2.ZitemVbapSf[] GTTabitemList = GTItemTab.item;
            Map<String, NonSparesServiceNewV2.ZitemVbapSf > productCodeMap = new Map<String, NonSparesServiceNewV2.ZitemVbapSf >();
            List<String>productCodeList = new List<String>();
            Map<String, Product2> newProductMap = new Map<String, Product2>(); 
            Map<String, product2> existingProdCodeMap = new Map<String, product2>();
            Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
            System.debug('GTTabitemList-->>'+GTTabitemList);
            
            for(NonSparesServiceNewV2.ZitemVbapSf  item : GTTabitemList){
                System.debug('item==>'+item);
                productCodeMap.put(item.Matnr,item);
            }
            System.debug('productCodeMap==>'+productCodeMap);

            // fetching existing product....
            List<product2> existingProductList = [SELECT Id,ProductCode,CurrencyIsoCode  FROM product2 
                                                WHERE ProductCode IN: productCodeMap.keySet()];

            if(existingProductList != null && existingProductList.size() > 0 ){
                for (product2 pro : existingProductList) {
                    existingProdCodeMap.put(pro.ProductCode, pro); 
                }
            }
            system.debug('existingProdCodeMap =>'+existingProdCodeMap);
            
            //NewChanges
            List<ProductServiceNew.ZmatCodeS> zmList = new List<ProductServiceNew.ZmatCodeS>();
            
            // Filtering existing product 
            if(existingProdCodeMap.keySet().size() > 0 ){
                for(String proCode : productCodeMap.keySet()){
                    if(!existingProdCodeMap.containsKey(proCode)){
                        ProductServiceNew.ZmatCodeS zmItem = new ProductServiceNew.ZmatCodeS();
                        productCodeList.add(proCode);
                        zmItem.MatCode = proCode;
                        zmList.add(zmItem);
                    }
                }
            }else {
                productCodeList = new List<String>(productCodeMap.keySet());
                for(String proCode : productCodeMap.keySet()){
                    ProductServiceNew.ZmatCodeS zmItem = new ProductServiceNew.ZmatCodeS();
                    zmItem.MatCode = proCode;
                    zmList.add(zmItem);
                }
            }       
            System.debug('productCodeList-->>'+productCodeList);
                if(productCodeList.size() > 0 ){
                    ProductServiceNew.ZmatCode objMet = new ProductServiceNew.ZmatCode();
                    //objMet.item = productCodeList;
                    objMet.item = zmList;

                    // SOAP callout to get product details for new products code
                    ProductServiceNew.ZMAT_MAST_M zmatMaster = new ProductServiceNew.ZMAT_MAST_M();
                    ProductServiceNew.ZmatMastMResponse_element metResponse = new ProductServiceNew.ZmatMastMResponse_element();
                    Blob metheaderValue = Blob.valueOf(sapOrg.Username__c+ ':' + 'Tega@1234');
                    String authorizationHeaderMet = 'BASIC ' + EncodingUtil.base64Encode(metheaderValue);
                    zmatMaster.inputHttpHeaders_x = new Map<String,String>();
                    zmatMaster.inputHttpHeaders_x.put('Authorization', authorizationHeaderMet);

                    metResponse = zmatMaster.ZmatMastM('',objMet,'');
                    System.debug('Product metResponse-->>'+metResponse);
                    it.Response__c +='\r\n\n Product Response: \r\n'+String.valueOf(metResponse);    
                    
                    ProductServiceNew.ZmatHeaderLn ExMatHeader = metResponse.ExMatHeader;
                    ProductServiceNew.ZmatHeader[] itemHdrList = ExMatHeader.item;

                    ProductServiceNew.ZmatPlantLn ExMatPlant = metResponse.ExMatPlant;
                    ProductServiceNew.ZmatPlant[] plantItems = ExMatPlant.item;
                    
                    //AK Changes 24/11/2022
                    responseMsg = metResponse.ExMessage;
                    
                    Map<String, String> plantMap = new Map<String, String>();
                    // AK Changes
                    Map<String, String> plantMap2 = new Map<String, String>();
                    if(plantItems != null){
                        for(ProductServiceNew.ZmatPlant item : plantItems){
                            plantMap.put(item.MatCode, item.Plant);
                            plantMap2.put(item.MatCode, item.HsnCode);
                        }
                        
                        for(ProductServiceNew.ZmatHeader item : itemHdrList){
                            newProductMap.put(item.MatCode, new product2(
                                Name = item.MatCode,
                                recordTypeId = TegaUtilityWithoutSharing.getProductRecordTypeId('Product_L3'),
                                ProductCode = item.MatCode,
                                Description = item.MatDesc,
                                Product_Type__c = item.MatType,
                                Product_Group__c = item.MatGroup,
                                DIVISION__c = item.Division,
                                Drawing_no__c = item.DrawingNo,
                                Basic_Material__c = item.BasicMaterial,
                                SAP_Creation_Date__c = item.CreatedOn,
                                HSN_Code__c = plantMap2.get(item.MatCode),
                                Plant__c = plantMap.get(item.MatCode)
                            ));
                        }
                    }
                    
                    

                    if(newProductMap.values().size() > 0 ){
                        insert newProductMap.values(); // Inserting new products
                    }
                    System.debug('newProductList==>'+newProductMap);
                }
                

            
                Map<String, PricebookEntry> PbEntryMap = new Map<String, PricebookEntry>();
                List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
                Set<String> existingPBCode = new Set<String>();
                Map<String, Product2> finalProductMap = new Map<String, Product2>();
                finalProductMap.putAll(newProductMap);
            	system.debug('finalProductMap new'+finalProductMap);
                finalProductMap.putAll(existingProdCodeMap);
            	system.debug('finalProductMap exist and new'+finalProductMap);

                // Creating standard PB entry
                List<PricebookEntry> existingPBEntryList = [SELECT Id, Product2.ProductCode,CurrencyIsoCode,Product2.CurrencyIsoCode FROM PricebookEntry 
                                                            WHERE Pricebook2.IsStandard = true
                                                            AND Product2.ProductCode IN : finalProductMap.keySet()];
            	system.debug('existingPBEntryList =>'+existingPBEntryList);

                for(PricebookEntry pb : existingPBEntryList){
                    existingPBCode.add(pb.Product2.ProductCode+pb.CurrencyIsoCode);
                }
            	system.debug('existingPBCode =>'+existingPBCode);
                
            	// Creating Standard Pricebook entry for all existing as well as new product whose standard pricebook entry is not created
                for(Product2 pro : finalProductMap.values()){
                    if(!existingPBCode.contains(pro.ProductCode+pro.CurrencyIsoCode)){
                        pbEntryList.add(new PricebookEntry(
                            Product2Id = pro.Id, 
                            Pricebook2Id = !Test.isrunningtest() ?  getStdPriceBook().Id : Test.getStandardPricebookId(),
                            IsActive =true,
                            UnitPrice = Decimal.valueOf(productCodeMap.get(pro.ProductCode).Price), 
                            CurrencyIsoCode = productCodeMap.get(pro.ProductCode).Waers
                        ));
                    }
                }
            	System.debug('pbEntryListStd==>>'+pbEntryList);
            
                //New PricebookEntry for new product
                if(newProductMap.values().size() > 0){
                    for(Product2 prod : newProductMap.values()){
                        pbEntryList.add(new PricebookEntry(
                            Product2Id = prod.Id, 
                            Pricebook2Id = pb.Id,
                            IsActive =true,
                            UnitPrice = Decimal.valueOf(productCodeMap.get(prod.ProductCode).Price), 
                            CurrencyIsoCode = productCodeMap.get(prod.ProductCode).Waers
                        ));
                        
                    }
                }
            
            System.debug('pbEntryListCustomNew==>>'+pbEntryList);

                // create pricebookentry for existing product...
                if(existingProdCodeMap.values().size() > 0 ){
                    for(Product2 prod  : existingProdCodeMap.values()){
                        pbEntryList.add(new PricebookEntry(
                            Product2Id = prod.Id, 
                            Pricebook2Id = pb.Id,
                            IsActive =true,
                            UnitPrice = Decimal.valueOf(productCodeMap.get(prod.ProductCode).Price), 
                            CurrencyIsoCode = productCodeMap.get(prod.ProductCode).Waers
                        ));
                    }
                }
				System.debug('pbEntryListCustomExist==>>'+pbEntryList);    
                if(pbEntryList.size() > 0 ){
                    insert pbEntryList;
                }
                

                for(PricebookEntry pb : pbEntryList){
                    PbEntryMap.put(pb.Product2Id, pb);
                }

                // Offer Line item creation....
                List<QuoteLineItem> offerLineList = new List<QuoteLineItem>();

                System.debug('PbEntryMap-->>'+PbEntryMap);
                System.debug('finalProductMap-->>'+finalProductMap);

                for(NonSparesServiceNewV2.ZitemVbapSf line : productCodeMap.values()){
                if(finalProductMap.containsKey(line.Matnr)){
                        offerLineList.add(new QuoteLineItem( 
                            QuoteId = offer.Id, 
                            PricebookEntryId = PbEntryMap.get(finalProductMap.get(line.Matnr).Id).Id,
                            Product2Id = finalProductMap.get(line.Matnr).Id,
                            Quantity = Decimal.valueOf(line.Kwmeng),
                            UnitPrice =  Decimal.valueOf(line.Price)
                        ));
                    }
                }

                if(offerLineList.size() > 0 ){
                    insert offerLineList;
                }
                
                //AK Changes 24/11/2022
                if(responseMsg != ''){
                    it.Status__c = 'fail';
                    it.Error__c = responseMsg;
                    update it;
                }else{
                    it.Status__c = 'Success';
                    it.sync__c = true;   
                    update it;
                    // Invoke acknowledgement jon
                    system.enqueueJob(new NonSpareOfferAcknowledgementController(offer, it));
                }
                
                
                
                
        } catch (Exception ex) {
            System.debug('exception e '+ ex.getMessage()+' Line:'+ex.getLineNumber());
            it.Status__c = 'fail';
            it.Error__c = 'Class Name : CreateProductAndOfferLine \r\n '+ ex.getMessage()+' Line:'+ex.getLineNumber();
            update it;
            delete offer; // Deleting offer if there is any exception in this job.
        }
        
    }

    public static Pricebook2 getStdPriceBook() {
        Pricebook2 stdPriceBook = [SELECT Id, name FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        return stdPriceBook;    
    }
}