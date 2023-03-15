/*
Name : CreateOrdeLineItem
Description : This class used to fetch details from SAP to create order Line item
Author : Rahul
*/

public with sharing class CreateOrderLines implements Queueable, Database.allowscallouts{
    Order odr;
    Pricebook2 pb;
    SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element response;
    Integration_Transaction__c it;
    String localCurrency;
    public CreateOrderLines(Order odr, Pricebook2 pb,
                                    SAPOrderWebServiceV2.ZrfcSobomDtlsResponse_element response, 
                                    Integration_Transaction__c it,String localCurrency){
        this.odr = odr;
        this.pb = pb;
        this.response = response;
        this.it = it;
        this.localCurrency = localCurrency;
    }
    public void execute(QueueableContext qc){
            // get product details...
            SAPOrderWebServiceV2.ZtitemVbapTt Orderitem = response.GtItem;
            SAPOrderWebServiceV2.ZitemVbapStr[] ItemList = Orderitem.item;
            Map<String, SAPOrderWebServiceV2.ZitemVbapStr > productCodeMap = new Map<String, SAPOrderWebServiceV2.ZitemVbapStr >();
            List<String>productCodeList = new List<String>();
            Map<String, Product2> newProductMap = new Map<String, Product2>(); 
            Map<String, product2> existingProdCodeMap = new Map<String, product2>();

            for(SAPOrderWebServiceV2.ZitemVbapStr  item : ItemList){
                System.debug('item==>'+item);
                productCodeMap.put(item.Matnr,item);
            }
            System.debug('productCodeMap==>'+productCodeMap.keySet());
 // fetching existing product....
            List<product2> existingProductList = [SELECT Id,ProductCode  FROM product2 
                                                WHERE ProductCode IN: productCodeMap.keySet()];

            if(existingProductList != null && existingProductList.size() > 0 ){
                for (product2 pro : existingProductList) {
                    existingProdCodeMap.put(pro.ProductCode, pro); 
                }
            }
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
                    ProductServiceNew.ZmatCode  objMet = new ProductServiceNew.ZmatCode();
                   // objMet.item = productCodeList;
                   objMet.item = zmList;


                    // SOAP callout to get product details for new products code
                    ProductServiceNew.ZMAT_MAST_M zmatMaster = new ProductServiceNew.ZMAT_MAST_M();
                    ProductServiceNew.ZmatMastMResponse_element metResponse = new ProductServiceNew.ZmatMastMResponse_element();
                    Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
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
                    Map<String, String> plantMap = new Map<String, String>();
                    for(ProductServiceNew.ZmatPlant item : plantItems){
                        plantMap.put(item.MatCode, item.Plant);
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
                            Plant__c = plantMap.get(item.MatCode)
                        ));
                    }

                    if(newProductMap.values().size() > 0 ){
                        insert newProductMap.values(); // Inserting new products
                    }
                    System.debug('newProductList==>'+newProductMap);
                }
                Map<String, PricebookEntry> PbEntryMap = new Map<String, PricebookEntry>();
                List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
                
                //AK Changes 16/01/23
                List<PricebookEntry> pbEntryListStd = new List<PricebookEntry>();
        
                Set<String> existingPBCode = new Set<String>();
                Map<String, Product2> finalProductMap = new Map<String, Product2>();
                finalProductMap.putAll(newProductMap);
                finalProductMap.putAll(existingProdCodeMap);

                // Creating standard PB entry
                List<PricebookEntry> existingPBEntryList = [SELECT Id, Product2.ProductCode,CurrencyIsoCode,PriceBook2Id,PriceBook2.Id FROM PricebookEntry 
                                                            WHERE Pricebook2.Id =: pb.Id
                                                            AND Product2.ProductCode IN : finalProductMap.keySet()];

                Map<String,PricebookEntry> productPriceBookMap = new Map<String,PricebookEntry>();
                for(PriceBookEntry pbe : existingPBEntryList){
                    existingPBCode.add(pbe.Product2.ProductCode);
                    if(!productPriceBookMap.containskey(pbe.Product2.ProductCode+''+pbe.CurrencyIsoCode) && pbe.priceBook2.Id==pb.Id)
                    {                
                        productPriceBookMap.put(pbe.Product2.ProductCode+''+pbe.CurrencyIsoCode,pbe);
                    }
                }
                
                for(Product2 pro : finalProductMap.values()){
                    if(!existingPBCode.contains(pro.ProductCode)){
                        pbEntryListStd.add(new PricebookEntry(
                            Product2Id = pro.Id, 
                            Pricebook2Id = !Test.isrunningtest() ?  getStdPriceBook().Id : Test.getStandardPricebookId(),
                            IsActive =true,
                            UnitPrice = Decimal.valueOf(productCodeMap.get(pro.ProductCode).NETWR), 
                            CurrencyIsoCode = localCurrency
                        ));
                    }
                }
        
                if(pbEntryListStd.size() > 0 ){
                    insert pbEntryListStd;
                }
                        
                //New PricebookEntry for new product
                System.debug('newProductMap==>>'+newProductMap);
                if(newProductMap.values().size() > 0){
                    for(Product2 prod : newProductMap.values()){
                      if(!productPriceBookMap.containsKey(prod.ProductCode)){
                        pbEntryList.add(new PricebookEntry(
                            Product2Id = prod.Id, 
                            Pricebook2Id = pb.Id,
                            IsActive =true,
                            UnitPrice = Decimal.valueOf(productCodeMap.get(prod.ProductCode).NETWR), 
                            CurrencyIsoCode = localCurrency
                        ));
                     }
                    }
                }
                        
                // create pricebookentry for existing product...
                System.debug('existingProdCodeMap==>>'+existingProdCodeMap);
                if(existingProdCodeMap.values().size() > 0 ){
                    for(Product2 prod  : existingProdCodeMap.values()){
                       if(!productPriceBookMap.containsKey(prod.ProductCode)){
                        pbEntryList.add(new PricebookEntry(
                            Product2Id = prod.Id, 
                            Pricebook2Id = pb.Id,
                            IsActive =true,
                            UnitPrice = Decimal.valueOf(productCodeMap.get(prod.ProductCode).NETWR), 
                            CurrencyIsoCode = localCurrency
                        ));
                      }
                    }
                }
                
                for(PricebookEntry pbEnt : pbEntryList){
                    System.debug('pbEnt==>>'+pbEnt);
                }
                
        
                if(pbEntryList.size() > 0 ){
                    Database.SaveResult[] srList = Database.insert(pbEntryList, false);
                    
                    // Iterate through each returned result
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                            // Operation was successful, so get the ID of the record that was processed
                            System.debug('Successfully inserted record ID: ' + sr.getId());
                        }
                        else {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Record fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }    

                for(PricebookEntry pb : pbEntryList){
                    PbEntryMap.put(pb.Product2Id, pb);
                }
        		
        		//AK 14/02/2023 Fix
        		for(PricebookEntry pb : existingPBEntryList){
                    PbEntryMap.put(pb.Product2Id, pb);
                }
        
                 // Order item creation....
                 List<OrderItem> orderLineList = new List<OrderItem>();

                for(SAPOrderWebServiceV2.ZitemVbapStr  item : ItemList){
                    if(finalProductMap.containsKey(item.Matnr) && !(productPriceBookMap.containsKey(item.Matnr)) && item.HlItem == '000000'){
                        orderLineList.add(new OrderItem( 
                                OrderId = odr.Id, 
                                SAP_Offer_Line_item__c = item.OfferItemNo,
                                Sales_Document_Item__c = item.Posnr,
                                Short_Description__c=item.Arktx,
                                Amount_in_Doc_Currency__c = Decimal.valueOf(item.Netwr),
                                Doc_Currency__c = item.DocCurr,
                                Sales_Unit__c=item.Vrkme,
                                Taxes_in_Doc__c = Decimal.valueOf(item.Taxes),
                                Taxes__c = item.TaxesLc,
                                Base_Price_in_Doc__c = Decimal.valueOf(item.BasePrice),      
                               // Exworks_date__c = Date.valueOf(item.Zzexworks),
                               // PPC_Release_Date__c = Date.valueOf(item.Zzppcdate),
                                Base_Price__c = item.BasePriceLc,
                                Discount_in_Doc__c = Decimal.valueOf(item.Discount),
                                Discount__c = item.DiscountLc,
                                Freight_in_doc__c = Decimal.valueOf(item.Freight),
                                Freight__c = item.FreightLc,
                                Packing_frwd_in_Doc_Currency__c = Decimal.valueOf(item.PackingFrwd),
                                Packing_frwd__c = item.PackingFrwdLc,
                                Drawing_number__c = item.ItemDrawingNo,
                                PricebookEntryId = PbEntryMap.get(finalProductMap.get(item.Matnr).Id).Id,
                                Product2Id = finalProductMap.get(item.Matnr).Id,
                                Quantity = Decimal.valueOf(item.Kwmeng),
                                UnitPrice =  Decimal.valueOf(item.NETWR),
                                Mode_of_Dispatch__c = item.ShipTyp,
                                Reason_Code__c = item.Abgru,
                                Reason_Reject__c = item.ReasonReject,
                                Customer_Material__c = item.CustMaterial
                            ));
                        }
                    }
    
                    if(orderLineList.size() > 0 ){
                        insert orderLineList;
                    }
        
                    List<OrderItem> orderItemList = [Select Id,OrderId,Product2Id from OrderItem where OrderId =: odr.Id];
                    
                    // Map<Product2Id, BOM Id>
                    Map<Id,Id> existingBomMap = new Map<Id,Id>();
        
                    for(OrderItem ordItem : orderItemList){
                        existingBomMap.put(ordItem.Product2Id,ordItem.Id);
                    }
                    
                    List<OrderItem> orderLineListReference = new List<OrderItem>();
                    for(SAPOrderWebServiceV2.ZitemVbapStr  item : ItemList){
                        if(finalProductMap.containsKey(item.Matnr) && !(productPriceBookMap.containsKey(item.Matnr)) && item.HlItem != '000000'){
                            OrderItem ordItem = new OrderItem();
                            ordItem.OrderId = odr.Id; 
                            ordItem.SAP_Offer_Line_item__c = item.OfferItemNo;
                            ordItem.Sales_Document_Item__c = item.Posnr;
                            ordItem.Short_Description__c=item.Arktx;
                            ordItem.Amount_in_Doc_Currency__c = Decimal.valueOf(item.Netwr);
                            ordItem.Doc_Currency__c = item.DocCurr;
                            ordItem.Sales_Unit__c=item.Vrkme;
                            ordItem.Taxes_in_Doc__c = Decimal.valueOf(item.Taxes);
                            ordItem.Taxes__c = item.TaxesLc;
                            ordItem.Base_Price_in_Doc__c = Decimal.valueOf(item.BasePrice);
                            ordItem.Base_Price__c = item.BasePriceLc;
                            ordItem.Discount_in_Doc__c = Decimal.valueOf(item.Discount);
                            ordItem.Discount__c = item.DiscountLc;
                            ordItem.Freight_in_doc__c = Decimal.valueOf(item.Freight);
                            ordItem.Freight__c = item.FreightLc;
                            ordItem.Packing_frwd_in_Doc_Currency__c = Decimal.valueOf(item.PackingFrwd);
                            ordItem.Packing_frwd__c = item.PackingFrwdLc;
                            ordItem.Drawing_number__c = item.ItemDrawingNo;
                            ordItem.PricebookEntryId = PbEntryMap.get(finalProductMap.get(item.Matnr).Id).Id;
                            ordItem.Product2Id = finalProductMap.get(item.Matnr).Id;
                            ordItem.Quantity = Decimal.valueOf(item.Kwmeng);
                            ordItem.UnitPrice =  Decimal.valueOf(item.NETWR);
                            ordItem.Mode_of_Dispatch__c = item.ShipTyp;
                            ordItem.Reason_Code__c = item.Abgru;
                            ordItem.Reason_Reject__c = item.ReasonReject;
                            ordItem.Customer_Material__c = item.CustMaterial;
                            //system.debug(item.HlItem);
                            //system.debug(finalProductMap.get(item.HlItem));
                            //system.debug(existingBomMap.get(finalProductMap.get(item.HlItem).Id));
                            if(finalProductMap.get(item.HlItem) != null){
                                ordItem.BOM__c = existingBomMap.get(finalProductMap.get(item.HlItem).Id);
                            }
                            orderLineListReference.add(ordItem);
                        }
                    }
        
                    if(orderLineListReference.size() > 0 ){
                        insert orderLineListReference;
                    }
                    
    
                    it.Status__c = 'Success';
                    it.sync__c = true; 
                    update it; // Update the IT record        
   }
   public static Pricebook2 getStdPriceBook() {
        Pricebook2 stdPriceBook = [SELECT Id, name FROM Pricebook2 WHERE isStandard = true LIMIT 1];
        return stdPriceBook;    
    }
}