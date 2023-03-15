/*
Name : CreatePartListController
Desc : this class use  to get partLIst from SAP and create into salesforce.
Author : Kuhinoor
*/

public with sharing class CreatePartListController {
    
    /*
    Name : getPartList
    Desc : this method used authorize and get the data from SAP.
    */
    @future(callout = true)
     public static void getPartList(String partListNumner, String itId) {
        Integration_Transaction__c it = new Integration_Transaction__c(Id = itId); 
         try {
            Tega_SAP_Credential__c sapOrg = Tega_SAP_Credential__c.getOrgDefaults();
            PartListWebServiceNew.ZWSPARTLIST  zwPartList = new  PartListWebServiceNew.ZWSPARTLIST();
            PartListWebServiceNew.ZPartlistSfResponse_element response = new PartListWebServiceNew.ZPartlistSfResponse_element();
            //Blob headerValue = Blob.valueOf('rfcuser1'+ ':' + 'Tega@1234');
            Blob headerValue = Blob.valueOf(sapOrg.Username__c+ ':' + sapOrg.Password__c);
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
            zwPartList.inputHttpHeaders_x = new map<String,String>();
            zwPartList.inputHttpHeaders_x.put('Authorization', authorizationHeader);
            //
            PartListWebServiceNew.TableOfZplmsgSfdc GtMsg = new PartListWebServiceNew.TableOfZplmsgSfdc();
            PartListWebServiceNew.TableOfZplmspSfdc GtSp = new PartListWebServiceNew.TableOfZplmspSfdc();
            PartListWebServiceNew.TableOfZpltab1Sfdc GtTab1 = new PartListWebServiceNew.TableOfZpltab1Sfdc();
            PartListWebServiceNew.TableOfZpltab2Sfdc GtTab2 = new PartListWebServiceNew.TableOfZpltab2Sfdc();
            PartListWebServiceNew.TableOfZpltab3Sfdc GtTab3 = new PartListWebServiceNew.TableOfZpltab3Sfdc();
            PartListWebServiceNew.TableOfZweightSfdc GtWeight = new PartListWebServiceNew.TableOfZweightSfdc();
            //

            response = zwPartList.ZPartlistSf(' ',GtMsg,GtSp,GtTab1,GtTab2,GtTab3,GtWeight,' ',' ', ' ', ' ',' ', ' ', partListNumner);
            
            //AK Changes 06/12/2022
            String responseMsg = response.ExMessage;
            if(responseMsg != ''){
                it.Status__c = 'fail';
                it.Error__c = responseMsg;
                update it;
            }else{
                CreatePartList(response, it);
                it.Response__c +='\n'+ String.valueOf(response);      
                it.Status__c = 'Success';
                it.sync__c = true;
            }
        } catch (Exception ex) {
            it.Status__c = 'fail';
            it.Error__c = ex.getMessage()+ex.getLineNumber();
            TegaUtility.trackLogs( ex,  'CreatePartListController',  'getPartList');
     }

        update it;
       
    }

    /*
    Name : CreatePartList
    Desc : this method used to create part list and related products records.
    param : response
    */
    public static void CreatePartList(PartListWebServiceNew.ZPartlistSfResponse_element response, Integration_Transaction__c it) {
        Set<String> branchCodeSet = new Set<String>();
        Set<String> salesOrgSet = new Set<String>();
        Map<String, String> salesOrgMap = new Map<String,String>();
        Map<String, Id> branchMap = new Map<String,Id>();
        List<Sales_Organization_Part_List__c> salesOrgpartList = new List<Sales_Organization_Part_List__c>();

        PartListWebServiceNew.TableOfZplmsgSfdc GtMsgObj = response.GtMsg;

        PartListWebServiceNew.TableOfZpltab1Sfdc GtTab1 = response.GtTab1;
        PartListWebServiceNew.Zpltab1Sfdc[] GtTab1List = GtTab1.item;
        PartListWebServiceNew.Zpltab1Sfdc GtTab1Obj = GtTab1List[0];

        for(PartListWebServiceNew.Zpltab1Sfdc tab1 : GtTab1List){
            branchCodeSet.add(tab1.ZLabor);
            salesOrgSet.add(tab1.SalesOrg);
        }

        List<Sales_Org__c> salesOrgList = [SELECT Id,Name FROM Sales_Org__c WHERE Name IN :salesOrgSet ];
        List<Branch__c> branchList = [SELECT Id,Branch_Code__c FROM Branch__c WHERE Branch_Code__c IN :branchCodeSet ];

        if(salesOrgList.size() > 0 ){
            for(Sales_Org__c sOrg : salesOrgList){
                salesOrgMap.put(sOrg.Name, sOrg.Id);
            }
        }
        if(branchList.size() > 0 ){
            for(Branch__c br : branchList){
                branchMap.put(br.Branch_Code__c, br.Id);
            }
        }

        Map<String, Sales_Org_Currency_Mapping__mdt> salesOrgCurrencyMap = Sales_Org_Currency_Mapping__mdt.getAll();
        Map<String, PartList_Revision_Mapping__mdt  > revisionMap = PartList_Revision_Mapping__mdt.getAll();

        system.debug('GtTab1Obj => '+GtTab1Obj);
        system.debug('GtTab1Obj.SfdcId => '+GtTab1Obj.SfdcId);
        
        // Create partList
        Part_List__c partList = new Part_List__c( 
            Name = GtTab1Obj.ZGmatnr, 
            Description__c = GtTab1Obj.Gdesc,
            CurrencyIsoCode = GtTab1Obj.Waers,
            Customer__c = GtTab1Obj.SfdcId, //'001C1000002kaaP',
            BOM__c= GtTab1Obj.Ztext,
            Delivery_Req__c = Decimal.valueOf(GtTab1Obj.Plifz),
            Last_Offer_Number__c = GtTab1Obj.LofNum,
            Last_Offer_Value_Foreign_Currency__c = Decimal.valueOf(GtTab1Obj.LofVal),
            Version_Number_Component__c = GtTab1Obj.Revstatus,
            HSN_Code__c = GtTab1Obj.HsnCode,   // added by RC, 21-11-22
            Direct_Quoted_Exchange_Rate__c = Decimal.valueOf(GtTab1Obj.Exrate),
            Revision__c = String.isNotBlank(GtTab1Obj.Revstatus) ? revisionMap.get(GtTab1Obj.Revstatus).Revision_Number__c : 10
            );
        // Added by RC 21-11-22
         
        insert partList;

        // Create Sales org part List....
        if(GtTab1List != null && GtTab1List.size() > 0){
            for(PartListWebServiceNew.Zpltab1Sfdc tab1 : GtTab1List){
                salesOrgpartList.add( new Sales_Organization_Part_List__c( Part_List__c = partList.Id,
                    Sales_Org__c = salesOrgMap.get(tab1.SalesOrg) ,
                    Branch__c = branchMap.get(tab1.ZLabor)));
            }
        }
        

        if(salesOrgpartList.size() > 0 ){
            insert salesOrgpartList;
        }

        
        //Create L2 product..
        Map<String, Product2> L2ProductMap = new Map<String,Product2>();
        List<Sales_Organization_Product__c> salesorgProductList = new List<Sales_Organization_Product__c>();
        Id L2ProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product_Zone_L2').getRecordTypeId();
        PartListWebServiceNew.TableOfZpltab2Sfdc GtTab2 = response.GtTab2;
        PartListWebServiceNew.Zpltab2Sfdc[] GtTab2List = GtTab2.item;
        
        if(GtTab2List != null && GtTab2List.size() > 0){
            for(PartListWebServiceNew.Zpltab2Sfdc tab2 : GtTab2List){
                String key = tab2.ZMmatnr;
                if(!L2ProductMap.containsKey(key)){            
                    L2ProductMap.put(key ,new Product2( ProductCode = tab2.ZMmatnr,
                    Name = tab2.ZMmatnr,
                    Part_List__c = partList.Id,
                    recordTypeId = L2ProductRecordTypeId,
                    Description = tab2.Mdesc,
                    HSN_Code__c=tab2.HsnCode,
                    Quantity__c = Decimal.valueOf(tab2.Menge),
                    Product_Level__c = 'L2',
                    QuantityUnitOfMeasure = tab2.Meins)); 
                }
            }
        }

        if(L2ProductMap.values().size() > 0 ){
            insert L2ProductMap.values();
        }

        if(GtTab2List != null && GtTab2List.size() > 0){
            for(PartListWebServiceNew.Zpltab2Sfdc tab2 : GtTab2List){
                salesorgProductList.add(new Sales_Organization_Product__c( Product__c = L2ProductMap.get(tab2.ZMmatnr).Id,
                Sales_Org__c = salesOrgMap.get(tab2.SalesOrg)));
            }
        }
    

        if (salesorgProductList.size() > 0) {
        insert salesorgProductList;
        }

        //Create L3 product..
        Map<String, Sales_Organization_Product__c> L3SalesOrgProductMap = new Map<String, Sales_Organization_Product__c>();
        Map<String, Product2> L3ProductMap = new Map<String,Product2>();
        PartListWebServiceNew.TableOfZpltab3Sfdc GtTab3 = response.GtTab3;
        PartListWebServiceNew.Zpltab3Sfdc[] GtTab3List = GtTab3.item;
        
        it.Response__c += 'TAB3: '+GtTab3List.size();
        Id L3ProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product_L3').getRecordTypeId();

        if(GtTab3List != null && GtTab3List.size() > 0){
            for(PartListWebServiceNew.Zpltab3Sfdc tab3 : GtTab3List){
                if(!L3ProductMap.containsKey(tab3.ZDmatnr)){            
                    L3ProductMap.put(tab3.ZDmatnr ,new Product2( ProductCode = tab3.ZDmatnr,
                    Name = tab3.ZDmatnr,
                    recordTypeId = L3ProductRecordTypeId,
                    Description = tab3.Ddesc,
                    QuantityUnitOfMeasure = tab3.Meins,
                    Product_Type__c = tab3.Mtart,
                    HSN_Code__c=tab3.HsnCode,
                    Product_group__c = tab3.Matkl,
                    Procurement_Type__c = tab3.Beskz,
                    Document_Number__c = tab3.Zeinr,
                    Product_Level__c = 'L3'
                    )); 
                }
            }
        }
        

        if(L3ProductMap.values().size() > 0 ){
            insert L3ProductMap.values();
        }

        if(GtTab3List != null && GtTab3List.size() > 0){
            for(PartListWebServiceNew.Zpltab3Sfdc tab3 : GtTab3List){
                if(!L3SalesOrgProductMap.containsKey(tab3.ZDmatnr)){
                    L3SalesOrgProductMap.put( tab3.ZDmatnr,new Sales_Organization_Product__c( Product__c = L3ProductMap.get(tab3.ZDmatnr).Id,
                    Sales_Org__c = salesOrgMap.get(tab3.SalesOrg),
                    Price__c =  Decimal.valueOf(tab3.Price),
                    CurrencyIsoCode = salesOrgCurrencyMap.get(tab3.SalesOrg).Currency__c
                    ));
                }
            }
        }

        
        if(L3SalesOrgProductMap.values().size() > 0 ){
            insert L3SalesOrgProductMap.values();
        }      

        //Create L2L3 product..  
        Map<String, L2_L3_product__c> L2L3ProductMap = new Map<String, L2_L3_product__c>();

        if(GtTab3List != null && GtTab3List.size() > 0){
            for(PartListWebServiceNew.Zpltab3Sfdc tab3 : GtTab3List){
                if(!L2L3ProductMap.containsKey(tab3.ZDmatnr+tab3.ZMmatnr)){
                    L2L3ProductMap.put(tab3.ZDmatnr+tab3.ZMmatnr, new L2_L3_product__c(
                        Part_List__c = partList.Id,
                        Product_L2__c = L2ProductMap.get(tab3.ZMmatnr).Id,
                        Product_L3__c = L3ProductMap.get(tab3.ZDmatnr).Id,
                        Quantity__c = Decimal.valueOf(tab3.Menge)
                    ));
                }
            }
        }
        

        if(L2L3ProductMap.values().size() > 0 ){
            insert L2L3ProductMap.values();
        }

        /*List<Sales_Organization_L2_L3__c> salesOrgL2L3List = new List<Sales_Organization_L2_L3__c>();
        if(GtTab3List != null && GtTab3List.size() > 0){
            for(PartListWebServiceNew.Zpltab3Sfdc tab3 : GtTab3List){
                salesOrgL2L3List.add(new Sales_Organization_L2_L3__c( 
                    L2_L3_Product__c = L2L3ProductMap.get(tab3.ZDmatnr+tab3.ZMmatnr).Id,
                    Sales_Org__c =  salesOrgMap.get(tab3.SalesOrg),
                    Price__c = Decimal.valueOf(tab3.Price)
                    ));
            }
        }
    

        if(salesOrgL2L3List.size() > 0 ){
            insert salesOrgL2L3List;
        }*/

        // Create weight table
        List<Item_Weight__c> itemWeightList = new List<Item_Weight__c>();
        PartListWebServiceNew.TableOfZweightSfdc GtWeight = response.GtWeight;
        PartListWebServiceNew.ZweightSfdc[] GtWeightList = GtWeight.item;

        if(GtWeightList != null && GtWeightList.size() > 0){
            for(PartListWebServiceNew.ZweightSfdc wght : GtWeightList){
                itemWeightList.add(new Item_Weight__c(
                    Product_L3__c = L3ProductMap.get(wght.Matnr).Id,
                    Net_Weight__c = Decimal.valueOf(wght.Ntgew)
                ));
            }
        }
        

        if(itemWeightList.size() > 0 ){
            insert itemWeightList;
        }

        // Create last Sales Price
        Map<String, SAP_Last_Sale_Price__c> lastSalesPriceMap = new Map<String, SAP_Last_Sale_Price__c>();
        List<Sales_Org_Last_SAP_SO__c> salesOrglastSAPList = new List<Sales_Org_Last_SAP_SO__c>();
        
        PartListWebServiceNew.TableOfZplmspSfdc GtSp = response.GtSp;
        PartListWebServiceNew.ZplmspSfdc[] GtSpList = GtSp.item;
        System.debug('GtSpList-->>'+GtSpList);
        if(GtSpList != null && GtSpList.size() > 0){
            for(PartListWebServiceNew.ZplmspSfdc sp : GtSpList){
                System.debug('sp-->>'+sp);
                if(!lastSalesPriceMap.containsKey(sp.ZDmatnr)){
                    lastSalesPriceMap.put(sp.ZDmatnr,  new SAP_Last_Sale_Price__c(
                        Product_L3__c = L3ProductMap.get(sp.ZDmatnr).Id 
                        
                    ));
                }
            }
        }
        

        
        if(lastSalesPriceMap.values().size() > 0){
            insert lastSalesPriceMap.values();
        }

        if(GtSpList != null && GtSpList.size() > 0){
            for(PartListWebServiceNew.ZplmspSfdc sp : GtSpList){
                Sales_Org_Last_SAP_SO__c salesOrgLastSAPRec = new Sales_Org_Last_SAP_SO__c();
				salesOrgLastSAPRec.Sales_Org__c = salesOrgMap.get(sp.SalesOrg); 
                salesOrgLastSAPRec.SAP_Last_Sale__c = lastSalesPriceMap.get(sp.ZDmatnr).Id;
                salesOrgLastSAPRec.Last_Sales_Price__c = Decimal.valueOf(sp.SalesPrice);
                salesOrgLastSAPRec.CurrencyIsoCode = salesOrgCurrencyMap.get(sp.SalesOrg).Currency__c;
                salesOrgLastSAPRec.Sales_Order__c = sp.SalesOrder;
                salesOrgLastSAPRec.Offer_Number__c = sp.OfferNo;
                if(sp.Audat != '0000-00-00'){
                    salesOrgLastSAPRec.Last_Sales_Date__c = Date.valueOf(sp.Audat);
                }
                if(sp.OrderDate != '0000-00-00'){
                    salesOrgLastSAPRec.Order_date__c = Date.valueOf(sp.OrderDate);
                }
                if(sp.OfferDate != '0000-00-00'){
                    salesOrgLastSAPRec.OfferDate__c = Date.valueOf(sp.OfferDate);
                }
                salesOrglastSAPList.add(salesOrgLastSAPRec);
 
            }
        }        
        
        if(salesOrglastSAPList.size() > 0 ){
            insert salesOrglastSAPList;
        }
            
    }
   
}