({
    doInit : function(component, event, helper) {
        
    // SK-061222 : Check if product prices is updated - True : Show Error - False : continue to TOP Screen
       var action = component.get("c.getProdUpdate");
        action.setCallback(this,function(response){
            var isTOPVisible = response.getReturnValue();
            var state = response.getState();
                if (state === 'SUCCESS'){
                    component.set('v.isTOPScreen', response.getReturnValue());
                    console.log('@ProdValue from custom label :'+response.getReturnValue());     
                    console.log('@Value at isTOPVisible :'+isTOPVisible);
                }    
                if (isTOPVisible === "true"){
                    helper.showToast2("Error", "Error", "The product prices are Updated.");
                    console.log('@insideIF');
                    $A.get("e.force:closeQuickAction").fire();
                    }
                else{
                    //helper.showToast("Success","Success","The product prices aren't Updated.");
                    helper.getl2l3products(component, event, helper);
                    console.log('@insideELSE');
                }
        });
        $A.enqueueAction(action);
        
    //helper.getProductType(component, event, helper); 
    //helper.getl2l3products(component, event, helper);

     // SK - 221122 : Sort 
       /* var sortBy = component.get("v.sortBy");
        var sortOrder = component.get("v.sortOrder");
        var action = component.get("c.getl2l3Products");
        action.setParams({"sortby" : sortBy,
                        "sortorder" : sortOrder
                        });
        action.setCallback(this, function(response){
            var state = response.getState();

            if (state == "SUCCESS"){
                var record = response.getReturnValue();
                component.set('v.records',record);
            }
        });
        $A.enqueueAction(action);*/
        
    },
    
    search : function(component, event, helper) {
        
        component.set("v.isLoad", true);
        var offerId = component.get("v.recordId");
        var InputSearchKeyword = component.get("v.searchKeyword");
        console.log('InputSearchKeyword'+JSON.stringify(InputSearchKeyword));
        var pickselected = component.find("PicklistId").get("v.value");
        var l2Map = new Map();


        console.log('pickselected'+pickselected)
        
        var action = component.get("c.searchPartList");
        
        action.setParams({ 
            offerId : offerId,	
            SearchProducts : InputSearchKeyword,
            picklistProductType : pickselected
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isLoad", false);
                var resultdata = response.getReturnValue();
                if(resultdata.isErr === false){
                    console.log('resultdata'+JSON.stringify(resultdata));
                    var obj = resultdata.data; // response.getReturnValue(); 
                    console.log('--BTP--');
                    console.log(resultdata.BTP);
                    component.set("v.BTPMap", resultdata.BTP);
                    component.set("v.offCurrency", resultdata.offerCurrency);
                    component.set("v.derivedSOfactor", resultdata.SOFactor);
                    component.set("v.sOrgId", resultdata.sOrgId);
                    component.set("v.wos", resultdata.isWos);
                    component.set("v.directCustomer", resultdata.isDirectCustomer);
                    component.set("v.partId", obj.partListId);
                    component.set("v.L3ProductQty", resultdata.L3ProdQtyMap);
                    
                    var result = obj.products;
                    var sapPriceMap = obj.sapPriceMap;
                    var sapDateMap = obj.sapDateMap;
                    var salesprice = sapPriceMap;
                    let fixedPrice = obj.fixedPriceMap;
                    console.log('sapPriceMap-------'+JSON.stringify(sapPriceMap) );
                    var recordsFromServer = JSON.parse(JSON.stringify(result));
                    console.log('recordsFromServer'+JSON.stringify(result));
                    var productHeaders = new Set();
                    var records = [];
                    var quantityMap = new Map();

                    

                    for( var key in recordsFromServer) {
                        var record = recordsFromServer[key];
                        console.log(record.Product_L2__r.Name);
                        var prodName = record.Product_L2__r.Name.split('-');
                        recordsFromServer[key].ProductL2Name = prodName[3];
                        productHeaders.add(prodName[3]);
                        var mapRow = new Map();
                        if (quantityMap.has(record.Product_L3__r.Name)) {
                            mapRow = quantityMap.get(record.Product_L3__r.Name);                   
                        }                    
                        mapRow.set(record.ProductL2Name, record.Quantity__c);
                        console.log('record.ProductL2Name'+record.ProductL2Name)
                        quantityMap.set(record.Product_L3__r.Name, mapRow);
                        console.log('record.Product_L3__r.Name'+record.Product_L3__r.Name);
                        console.log('AK prodName[3] =>',prodName[3]);
                        // Sending 1 l2l3 for each header in l2Map
                        /*if (!l2Map.has(prodName[3])){
                            console.log('Inside l2Map IF');
                            l2Map.set(prodName[3], record.Id);
                            console.log('After 117',l2Map);
                        }*/
                        
                        //AK Fixes 13/12/22
                        let text = record.Product_L2__r.Name;
                        const myArray = text.split("-");
                        let l2Level = myArray[3];
                        let result = record.Product_L3__c + "-" + l2Level;
                        
                        //AK Fixes 08/12/22 => L2Map has now all L2L3 Records from that PartList along with header name like FEH as key
                        l2Map.set(result, record.Id);
                    }
                    console.log('AK l2Map =>',JSON.stringify(l2Map));
                    console.log(l2Map);
                    console.log(productHeaders);
                    console.log(quantityMap);
                    var uniqueL3 = new Set();
                    var uniqueRecords = new Array();
                    for (var key in recordsFromServer) {
                        var record = recordsFromServer[key]; 
                       
                        var quantityMapRecord = quantityMap.get(record.Product_L3__r.Name);
                        var columnsString = [];
                        var TotalQuantity =[];
                        var level2CustomQuantityValues = new Map();
                        var customQuantityValues = new Map();
                        const iterator1 = productHeaders.values();
                        var total =0; 
                        for (var i=0 ; i < productHeaders.size ; i++) {
                            var headerVal = iterator1.next().value;
                            var value = quantityMapRecord.get(headerVal) ? quantityMapRecord.get(headerVal) : 0;
                            var column = '<div class="slds-truncate">' + value  + '</div>';
                            var total = total + value;
                            columnsString.push(column);
                            TotalQuantity.push(total);
                            
                        }
                        record.product2Quantities = columnsString;
                        record.productquantities = total;
                        record.quantityMapRecord = quantityMapRecord;
                        record.customQuantity = 0;
                        record.level2customQuantity = 0;
                        record.isLLP = false;
                        
                        //AK 02/12/22 Changes
                        record.isDirectCustomer = component.get("v.directCustomer");
                        record.isWos = component.get("v.wos");
                        record.RMCCost = 0;
                        record.branchRateOfInterest = 0;
                        record.offerpayment = 0;
                        record.branchHedging = 0;
                        record.basicPrice = 0;
                        record.costPackingForwarding = 0;
                        record.CostFreight = 0;
                        record.costInsurance = 0;
                        record.costInterest = 0;
                        record.costHedging = 0;
                        record.exchangeRate = 0;
                        
                        console.log('fixedPrice Map -->>'+JSON.stringify(fixedPrice));
                        console.log('Product_L3__c ID -->>'+record.Product_L3__c);
                        console.log('record.btpPrice => ',record.btpPrice);
                        //record.btpPrice = fixedPrice[record.Product_L3__c];
                        console.log('get-->>'+fixedPrice[record.Product_L3__c]);
                        if(fixedPrice[record.Product_L3__c]){
                            console.log('inside Fixed');
                            record.isFixedBTP = true;
                            record.isLLP = true; 
                        }else{
                            console.log('else Fixed');
                            record.isFixedBTP = false;
                        }
                        
                        record.margin =  0;
                        record.discount = 0;
                        record.mySalesPrice = 0;
                        record.cusBtpPrice = 0;
                        record.L2btpPrice = 0;
                       

                        record.inputDisable = true;
                        // console.log('conversionRate-->>', obj.conversionRate);
                        let lsalesPrice = 0;
                        if(sapPriceMap[record.Product_L3__c]){
                            console.log('SAP Price before conversion rate ',sapPriceMap[record.Product_L3__c]);
                            lsalesPrice = (sapPriceMap[record.Product_L3__c] * obj.conversionRate).toFixed(5);
                        	record.isLLP = true;
                        }
                        
                        console.log('lsalesPrice-->>'+lsalesPrice);
                        record.SAP_Price = lsalesPrice;
                        
                        if(sapDateMap[record.Product_L3__c]){
                        	record.SAP_Date = sapDateMap[record.Product_L3__c];
                        }  
                        

                        record.SAP_PriceOld = sapPriceMap[record.Product_L3__c];
                        record.customQuantityValues = new Map(Object.entries(JSON.parse(JSON.stringify(quantityMapRecord))));//customQuantityValues ;
                        record.level2CustomQuantityValues = new Map(Object.entries(JSON.parse(JSON.stringify(quantityMapRecord))));//customQuantityValues ;
                        record.headers = headers ;
                        record.errMsg = '';
                        
                                               
                        let ProType = record.Product_L3__r.Product_Type__c;
                        if(ProType && ProType.slice(0,2) == 'FG'){
                            record.SAP_Price = Math.ceil(lsalesPrice);
                        }
                        
                        if(uniqueL3.has(record.Product_L3__r.Name)){
                            continue;
                        }
                        else{
                            console.log('Unique Records Else Push');
                            uniqueL3.add(record.Product_L3__r.Name);
                            console.log('record pushed =>',JSON.stringify(record));
                            uniqueRecords.push(record);    
                        }    
                    }
                    console.log('Unique Records 1 Dec => ');
                    console.log(uniqueRecords)
                    console.log(uniqueL3);
                    component.set('v.record',total);
                    var headers = [];
                    const iterator1 = productHeaders.values();
                    for (var i=0 ; i < productHeaders.size ; i++) {
                        var header = new Object();
                        header.Name = iterator1.next().value;
                        header.isSelected = false;
                        header.value = 0;
                        headers.push(header);
                    }
                    
                    component.set('v.records', uniqueRecords);
                    component.set('v.headers', headers);
                    component.set('v.headersName', productHeaders);
                    component.set('v.L2ProductMap', l2Map);
                }else{
                    helper.showToast("Error", "Error", resultdata.ErrorMsg); 
                } 
            } 
            if(pickselected=='') { 
                component.set('v.records', uniqueRecords);
            }  
            
            else if (state ==="ERROR") {
                component.set("v.isLoad", false);
                var errors = response.getError();
                console.error(errors);
            }
        });
        $A.enqueueAction(action);
        
    },  
    
    
    onClickHandleChange : function(component, event, helper){
      
        var headers  = component.get('v.headers');
        var fullSet = component.get('v.fullSet');
       	
        let isSpareselected = false;
        let allChk = 0;
        for (var header of headers) { 
            
            if(header.Name === 'SPARE' && header.isSelected === true){
                if(fullSet === false){
                    isSpareselected  =true;
                    var errMsg = $A.get("$Label.c.No_Spare_W_O_Full_Set");
                    header.isSelected = false;
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Cannot Select Spare',
                        message: errMsg,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
            }
            
            if(header.isSelected === false){
                header.value = 0;
            } else{
                console.log('---rc1--'+header.value);
                if(header.value <= 1 || header.value === undefined)
                header.value = 1;
                allChk ++;
            }          
         }
        
        console.log('HDR length'+headers.length);
        console.log('allChk'+allChk);
        
        if(headers.length === allChk){
           // component.set("v.fullSet", true);
        }else{
            component.set("v.fullSet", false);
            for (var header of headers){
                if(header.Name === 'SPARE'){
                    header.value = 0;
                    header.isSelected = false;
                }
            } 
        }
         component.set('v.headers', headers);
         if(isSpareselected === false){
         helper.caluculateLevel2CustomQuantity(component, event, helper,true);    
        }  
    },
    
    handleOnChange : function(component, event, helper) {
        let headerList = component.get("v.headers");
        var value = event.currentTarget.value;
        var header = event.currentTarget.dataset.header;
        var index = event.currentTarget.dataset.index;
        headerList[index].value = value;

        helper.calculateRecordCustomQuantity(component, event, helper, value, header,true);
    },
    
    
    onFullSetCheckBox : function(component, event, helper) { 
        helper.onChangeFullSet(component, event, helper, true);
    },
    
    onCheckFullSet : function(component, event, helper) {
        helper.onChangeFullSet(component, event, helper, false);
    },
    
    onChange: function(component, event, helper) {
        window.setTimeout( function(){
            helper.changeCustomQty(component, event, helper)
        }, 1500)
    },
    
    onChangeMargin: function(component, event, helper) {
        helper.onMarginChange(component, event, helper);
    },
    
    onChangeDiscount: function(component, event, helper) {
        helper.onDiscountChange(component, event, helper);
    },
    
    onChangeMarginAll: function(component, event, helper) {
        helper.allMarginChange(component, event, helper);
    },
    
    onChangeDiscountAll: function(component, event, helper) {
        helper.allDiscountChange(component, event, helper);
    },
    
    showSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner : function(component,event,helper){
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
    handleConfirmDialogNo : function(component, event, helper){
        component.set("v.showConfirmDialog", false); 
    },
    
    validate : function(component, event, helper){
        let totalSalesPrice =  component.get("v.totalSalesPrice");
        let totalBTPPrice =  component.get("v.totalBTPPrice");
        let totalSalesPer = component.get("v.totalSalesPer");
        let discount = (parseFloat(totalSalesPrice)/parseFloat(totalBTPPrice))*100;
        console.log('discount-->>',discount);
        let percent = 100 - discount;
        console.log('percent-->>',percent);
        if(percent > 1){
            console.log('inside discount if-->>',discount);
            component.set("v.showConfirmDialog", true); 
        }else{
            console.log('inside Else-->>',discount);
            helper.createOffer(component, event, helper);
           
        }
    },
    offerLinesave : function(component, event, helper) {
        helper.createOffer(component, event, helper);
    },
    
    handleExit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    //SK - 221122 : Sort

    /*handleSorting : function(component, event, helper){

        var sortBtn = event.currentTarget;
        $A.util.toggleClass(sortBtn,'sort-btn');
        $A.util.addClass(sortBtn,'selected-btn');
        var sortByclicked = event.getSource().get("v.pNameSort");
        var currentSortBy = component.get('v.sortBy');
        if(sortByclicked != currentSortBy){
            component.set('v.sortBy', sortByclicked);
            component.set('v.sordOrder', 'desc');
        }
        else{
            if(sortOrder == 'desc')
                component.set('v.sortOrder', 'asc');
            else if(sortOrder == 'asc')
                component.set('v.sortOrder', 'desc');
        }

    },*/

})