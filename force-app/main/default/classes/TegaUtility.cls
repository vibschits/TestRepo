/*
Name : TegaUtility
Desc : This is an utility class for Tega specific.
*/

public with sharing class TegaUtility {
    
	public static id trackLogs(Exception e, String className, String methodName){
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.Class_Name__c = className;
        errorLog.Method_Name__c = methodName;
        errorLog.Error_Message__c = e.getMessage();
        errorLog.Error_Type__c = e.getTypeName();
        errorLog.Line_Number__c = e.getLineNumber();
        try{
            insert errorLog;
           return errorLog.Id;
        }finally{
            
        }
    }
    
    @future
    public static void createL1L2OfferLine(String offerId, Decimal fullSetQty, String partListId, String headerStr2) {
        List<headersWrap> headersWrapList = (List<headersWrap>) JSON.deserialize(headerStr2, List<headersWrap>.class);
        system.debug('headersWrapList => '+headersWrapList);
        Map<String,L1_L2_Offer_Line_Item__c> L1L2LineMap = new Map<String,L1_L2_Offer_Line_Item__c>(); 
        Map<String,Decimal> L1L2QuantityMap = new Map<String,Decimal>();
        system.debug('offerId =>'+offerId);
        system.debug('fullSetQty =>'+fullSetQty);
        system.debug('partListId =>'+partListId);
        

        try{
        List<QuoteLineItem> lineList = [SELECT Id,TotalPrice, L2_L3_Product__c,Product2Id, L2_L3_Product__r.Product_L2__r.Name, 
                                        L2_L3_Product__r.Product_L2__c,L2_L3_Product__r.Product_L3__c,Quantity, Quote.Offer_Generation_at__c, 
                                        Quote.Part_List__c,Quote.TotalPrice, Quote.Part_List__r.Name, UnitPrice
                                        FROM QuoteLineItem 
                                        WHERE QuoteId =: offerId AND L2_L3_Product__c != Null];
        
        Integer lineListSize = lineList.size();
        system.debug('lineList => '+lineList);   
        system.debug('lineList size => '+lineListSize);
		
        if(lineList != null && lineList.size() > 0 ){
            String offerLevel = lineList[0].Quote.Offer_Generation_at__c;
           /// Id partListId = lineList[0].Quote.Part_List__c;
    
    
            List<L2_L3_product__c> L2L3ProdList = [SELECT Id,Product_L2__c, Product_L2__r.Name, Quantity__c, Product_L3__c 
                                                    FROM  L2_L3_product__c
                                                    WHERE Part_List__c =: partListId];
            
            system.debug('L2L3ProdList => '+L2L3ProdList);
    		
            /* AK 09/12/22
            for(L2_L3_product__c l2l3 : L2L3ProdList){
                // Filter Unique Product_L2__c
                if(!L1L2QuantityMap.containsKey(l2l3.Product_L2__c + '' + l2l3.Product_L3__c)){
                     
                    L1L2QuantityMap.put(l2l3.Product_L2__c + '' + l2l3.Product_L3__c,l2l3.Quantity__c);
                }
            }
            System.debug('L1L2QuantityMap-->>'+L1L2QuantityMap);	*/
            Decimal totalL1Price = 0;
            Map<Id, Decimal> totalPriceMap = new Map<Id, Decimal>();
            for(QuoteLineItem ofrLine : lineList) {
                system.debug('ofrLine => '+ofrLine);
                if(!totalPriceMap.containsKey(ofrLine.L2_L3_Product__r.Product_L2__c)){
                    //AK 13/12/22 Changes. It should take TotalPrice as that includes quantity as well and not UnitPrice as UnitPrice is per 1 qty
                    totalPriceMap.put(ofrLine.L2_L3_Product__r.Product_L2__c, ofrLine.TotalPrice);
                    system.debug('Inside if'+ totalPriceMap);
                }else{
                    Decimal tPrice =  totalPriceMap.get(ofrLine.L2_L3_Product__r.Product_L2__c) + ofrLine.TotalPrice;
                    totalPriceMap.put(ofrLine.L2_L3_Product__r.Product_L2__c, tPrice);
                    system.debug('Inside else');
                }
                totalL1Price += ofrLine.TotalPrice;
            }
    
    		system.debug('totalPriceMap => '+totalPriceMap);
            system.debug('totalL1Price => '+totalL1Price);
    		
            Map<String,Decimal> headerMap = new Map<String,Decimal>();
            // AK 09/12/22
            for(headersWrap wrp : headersWrapList){
                if(wrp.isSelected == true){
                    headerMap.put(wrp.Name,wrp.value);
                }
                
            }
            system.debug('headerMap'+headerMap);
            
            // create L2 record 
                Id L2RecordTypeId =  TegaUtilityWithoutSharing.getL1L2RecordTypeId('L2');
                for(QuoteLineItem ofrLine : lineList) {
                    system.debug('L2 AK 07/12/22 ofrLine'+ofrLine);
                    system.debug('ofrline.Product2Id => '+ofrline.Product2Id);
                    system.debug('ofrLine.L2_L3_Product__r.Product_L3__c => '+ ofrLine.L2_L3_Product__r.Product_L3__c);
                    if((!L1L2LineMap.containsKey(ofrLine.L2_L3_Product__r.Product_L2__c))){// && (ofrline.Product2Id == ofrLine.L2_L3_Product__r.Product_L3__c)){
                        System.debug('Qty-->>'+ofrLine.Quantity);
                        System.debug('Map qty-->>'+L1L2QuantityMap.get(ofrLine.L2_L3_Product__r.Product_L2__c));
                        
                        // AK 09/12/22
                        String fullDesc = ofrLine.L2_L3_Product__r.Product_L2__r.Name;
                        String[] splitDesc = fullDesc.split('-');
                        String L2Value = splitDesc[3];
                        system.debug('L2Value => '+L2Value);
                        
                        if(headerMap.get(L2Value) != null){
                                L1L2LineMap.put(ofrLine.L2_L3_Product__r.Product_L2__c,new L1_L2_Offer_Line_Item__c(//+ '' + ofrLine.L2_L3_Product__r.Product_L3__c, new L1_L2_Offer_Line_Item__c(
                                Product_Description__c = ofrLine.L2_L3_Product__r.Product_L2__r.Name,
                                Quantity__c =  headerMap.get(L2Value), //ofrLine.Quantity / L1L2QuantityMap.get(ofrLine.L2_L3_Product__r.Product_L2__c +  '' + ofrLine.L2_L3_Product__r.Product_L3__c),
                                Offer__c = offerId,
                                Amount__c = totalPriceMap.get(ofrLine.L2_L3_Product__r.Product_L2__c),
                                recordTypeId = L2RecordTypeId
                            ));
                        }
                        
                    }
                }
            
    			system.debug('L1L2LineMap for L2 => '+L1L2LineMap);
				            
    
            //Create L1 records
            if(fullSetQty > 0){
                Id L1RecordTypeId =  TegaUtilityWithoutSharing.getL1L2RecordTypeId('L1');
               
                for(QuoteLineItem ofrLine : lineList) {
                    system.debug('L1 AK 07/12/22 ofrLine'+ofrLine);
                    if(!L1L2LineMap.containsKey(ofrLine.Quote.Part_List__c)){
                        L1L2LineMap.put(ofrLine.Quote.Part_List__c, new L1_L2_Offer_Line_Item__c(
                            Product_Description__c = ofrLine.Quote.Part_List__r.Name,
                            Quantity__c = fullSetQty,
                            Offer__c = offerId,
                            recordTypeId = L1RecordTypeId,
                            Amount__c = totalL1Price
                        ));
                    }
                }
                system.debug('L1L2LineMap for L1 => '+L1L2LineMap);
            }
            
    
            System.debug('Final L1L2LineMap-->>'+L1L2LineMap.values());
            if(L1L2LineMap.values().size() > 0 ){
                insert L1L2LineMap.values();
                
    
            }
            
            
         
         }
            Quote ofr = new Quote(Id = offerId, Part_List__c = partListId);
            update ofr;
        } catch (Exception ex) {
            TegaUtility.trackLogs( ex,  'TegaUtility',  'createL1L2OfferLine');
            System.debug('Erorr-->>'+ ex);
        }
        
    }
    
    // AK 08/12/22 Changes
    public class headersWrap{
        public String Name;
        public Boolean isSelected;
        public decimal value;
    }

}