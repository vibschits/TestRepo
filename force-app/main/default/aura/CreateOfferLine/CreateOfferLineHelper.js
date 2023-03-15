({
    /* getProductType: function (component, event, helper) {
          var action = component.get("c.getProductType");
          action.setCallback(this, function (response) {
              var state = response.getState();
              if (state === "SUCCESS") {
                  var resultdata = response.getReturnValue();
                  var prodTypelist = [];
                  for (var key in resultdata.keySet()) {
                      prodTypelist.push({
                          key: key,
                          value: resultdata[key]
                      });
                  }
                  component.set("v.selectKeyword", prodTypelist);
                  var obj = prodTypelist.data;
                  console.log('---------------'+obj);
                  console.log(JSON.stringify(resultdata));
              } else if (state === "ERROR") {
                  var errors = response.getError();
              }
          });
          $A.enqueueAction(action);
      },*/
  
      getl2l3products: function (component, event, helper) {
          var pickselected ="";
          component.set("v.isLoad", true);
          var offerId = component.get("v.recordId");
          var action = component.get("c.getl2l3Products");
          var l2Mapupdate = new Map();
          action.setParams({
              offerId: offerId
          });
          action.setCallback(this, function (response) {
              var state = response.getState();
              console.log('update state--->>' +state);
              if (state === "SUCCESS") {
                  component.set("v.isLoad", false);
                  component.set("v.isUpdate",true);
                  var resultdata = response.getReturnValue();
                  console.log('resultdata' + JSON.stringify(resultdata));
                  var obj = resultdata.data;
                  console.log('obj------'+obj)
                   console.log('resultdata.BTP------'+JSON.stringify(resultdata.BTP))
                  if(obj == undefined){
                      return;
                  }
                  var wrp = resultdata.wrp;
                  console.log('--wrp--',wrp);
                  var l1l2 = resultdata.l1l2;
                  console.log('l1l2========'+JSON.stringify(l1l2));
                  let parListId = resultdata.partListId;
                  component.set("v.BTPMap", resultdata.BTP);
                  console.log(' resultdata.BTP==========='+ JSON.stringify(resultdata.BTP))
                  component.set("v.partId", parListId);
                  component.set("v.offCurrency", resultdata.offerCurrency);
                  component.set("v.totalBTPPrice", resultdata.totalBTPPrice);
                  console.log('resultdata.totalBTPPrice--------'+JSON.stringify(resultdata.totalBTPPrice))
                  component.set("v.totalSalesPrice", resultdata.totalSalesPrice);
                  console.log('resultdata.totalSalesPrice--------'+JSON.stringify(resultdata.totalSalesPrice))
                  // SK - 211122 : Adding the Overall Percentage calculation
                  component.set("v.totalSalesPer",resultdata.totalSalesPer);
                  console.log('resultdata.totalSalesPer ----'+JSON.stringify(resultdata.totalSalesPer))
  
  
                  component.set("v.fullSet", resultdata.isFullSet);
                  component.set("v.fullSetQuantity", resultdata.fullSetQty);
                  component.set("v.wos", resultdata.isWos);
                  component.set("v.derivedSOfactor", resultdata.SOFactor);
                  
                  // AK 02/12/22 Changes
                  component.set("v.directCustomer", resultdata.isDirectCustomer);
                  
                  console.log("AK AK salesOrgId=>",resultdata.sOrgId);
                  component.set("v.sOrgId", resultdata.sOrgId);
                  console.log('L3ProdQtyMap load');
                  console.log(resultdata.L3ProdQtyMap);
                  component.set("v.L3ProductQty", resultdata.L3ProdQtyMap);
                  
                  // console.log('========'+JSON.stringify(wrp));
                  // console.log('l1l2========'+JSON.stringify(l1l2));
  
                  // console.log('obje sales price---------',obj);
                  var result = obj.products;
                  console.log('obj'+obj.products)
                  var sapPriceMap = obj.sapPriceMap;
                  var salesprice = sapPriceMap;
                  var sapDateMap = obj.sapDateMap;
                  let fixedPrice = obj.fixedPriceMap;
                  // console.log('salesprice-------'+salesprice)
                  console.log('recordsFromServer-->>'+JSON.stringify(result));
                  console.log(recordsFromServer);
                   var recordsFromServer = JSON.parse(JSON.stringify(result));
                   if (recordsFromServer != '' || recordsFromServer.length > 0) {
                      component.set('v.partlistnumber', false);
                      component.set('v.searchTable', false);
                  }
                  var productHeaders = new Set();
                  // console.log('productHeaders'+productHeaders)
                  var records = [];
                  var quantityMap = new Map();
                  for (var key in recordsFromServer) {
                      console.log('key-->>'+key);
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
                      console.log('record.ProductL2Name' + record.ProductL2Name)
                      console.log('record.ProductL2Name qty' + record.Quantity__c)
                      quantityMap.set(record.Product_L3__r.Name, mapRow);
                      console.log('record.Product_L3__r.Name' + record.Product_L3__r.Name)
                      console.log('AK prodName[3] =>',prodName[3]);
                      
                      // AK 09/12/22 Changes
                      /*if (!l2Mapupdate.has(prodName[3])) {
                          l2Mapupdate.set(prodName[3], record.Id);
                      }*/
                      
                      //AK Fixes 13/12/22
                      let text = record.Product_L2__r.Name;
                      const myArray = text.split("-");
                      let l2Level = myArray[3];
                      let result = record.Product_L3__c + "-" + l2Level;
                      
                      //AK Fixes 08/12/22 => L2Map has now all L2L3 Records from that PartList along with header name like FEH as key
                      l2Mapupdate.set(result, record.Id);
                  }
                  console.log('AK l2Mapupdate =>',JSON.stringify(l2Mapupdate));
                  console.log('AK 07/12/22 Headers')
                  console.log(productHeaders);
                  console.log(quantityMap);
                  console.log(recordsFromServer.length);
                  var uniqueL3 = new Set();
                  var uniqueRecords = new Array();
                  
                  for (var key in recordsFromServer) {
                      var record = recordsFromServer[key];
                      var quantityMapRecord = quantityMap.get(record.Product_L3__r.Name);
                      var columnsString = [];
                      var TotalQuantity = [];
                      var level2CustomQuantityValues = new Map();
                      var customQuantityValues = new Map();
                      const iterator1 = productHeaders.values();
                      var total = 0;
                      for (var i = 0; i < productHeaders.size; i++) {
                          var headerVal = iterator1.next().value;
                          var value = quantityMapRecord.get(headerVal) ? quantityMapRecord.get(headerVal) : 0;
                          var column = '<div class="slds-truncate">' + value + '</div>';
                          var total = total + value;
                          columnsString.push(column);
                          TotalQuantity.push(total);
                      }
                      console.log('total =>',total);
  
                      /*  
                          var columnsString = [];
                          var L2Customqty =[];
                          const iteratorl2 = productHeaders.values();
                          var customqtyl2 =0;
                          for (var i=0 ; i < productHeaders.size ; i++) {
                              var headerVal = iteratorl2.next().value;
                              var value = quantityMapRecord.get(headerVal) ? quantityMapRecord.get(headerVal) : 0;
                              var column = '<div class="slds-truncate">' + value  + '</div>';
                              var l2customqtty = customqtyl2 + value;
                              columnsString.push(column);
                              L2Customqty.push(l2customqtty);
                          }*/
  
                      console.log('product l3 name----' + record.Product_L3__r.Name);
  
                      record.product2Quantities = columnsString;
                      record.productquantities = total;
                      record.quantityMapRecord = quantityMapRecord;
                      
                      console.log("productquantities => ",record.productquantities);
                      console.log(record);
                      if(total > 0){
                          record.inputDisable = false;
                      }else{
                          record.inputDisable = true;
                      }
                      
                      record.headers = headers;
                      //console.log('header nikhjil==========' + headers);
                      record.level2customQuantity = component.get("v.l2values");
                      record.customQuantity = 0;
                      var prodName = record.Product_L2__r.Name.split('-');
                      record.partCode = prodName[3];
                      record.isLLP = false;
                      
                      console.log('AK 2 Dec inside init');
                      record.isDirectCustomer = component.get("v.directCustomer");
                      console.log('record.isDirectCustomer=>'+record.isDirectCustomer);
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
                      
                      if(fixedPrice[record.Product_L3__c]){
                          record.isFixedBTP = true;
                          record.isLLP = true;
                      }else{
                          record.isFixedBTP = false;
                      }
                      record.L2btpPrice = 0;
                      record.cusBtpPrice = 0;
                      record.margin = 0;
                      record.discount = 0;
                      for (var key in wrp) {
                          //console.log('wrp key-->>'+key);
                          if (key == record.Product_L3__r.Name) {
                              var wrpprds = wrp[key];
                              console.log('record till here',record);
                              record.QuotelineId = wrpprds.QuotelineId;
                              console.log("AK customQuantity",wrpprds.customQuantity);
                              record.customQuantity = wrpprds.customQuantity;
                              
                              // AK 19/12/22 Changes
                              if(record.customQuantity > 0){
                                  record.inputDisable = false;
                              }
                              
                              console.log("AK btpPrice",wrpprds.btpPrice);
                              record.btpPrice = wrpprds.btpPrice;
                              record.cusBtpPrice = wrpprds.cusBtpPrice;
                              record.L2btpPrice = wrpprds.L2btpPrice; 
                              record.margin = wrpprds.margin;
                              record.discount = wrpprds.discount;
                              record.mySalesPrice = wrpprds.salesPrice;
                              record.level2customQuantity = wrpprds.level2customQuantity;
                              console.log('record till here2',record);
                          }
                      }
                      // record.level2customQuantity =total*;
                      let lastSPrice = 0
                      if(sapPriceMap[record.Product_L3__c]){
                          lastSPrice = (sapPriceMap[record.Product_L3__c] * obj.conversionRate).toFixed(5);
                          record.isLLP = true;
                      }/* AK 07/12/22 Changes else{
                          if(!isNaN(record.btpPrice) ){
                              lastSPrice = record.btpPrice;
                          }                        
                      }*/
                      console.log('AK 07/12/22 lastSPrice-->>'+lastSPrice);
                      
                      if(sapDateMap[record.Product_L3__c]){
                        	record.SAP_Date = sapDateMap[record.Product_L3__c];
                      }  
                      
                      record.SAP_Price = lastSPrice;
                      record.SAP_PriceOld = sapPriceMap[record.Product_L3__c];
                      record.customQuantityValues = new Map(Object.entries(JSON.parse(JSON.stringify(quantityMapRecord)))); //customQuantityValues ;
                      record.level2CustomQuantityValues = new Map(Object.entries(JSON.parse(JSON.stringify(quantityMapRecord)))); //customQuantityValues ;
                      
                      let ProType = record.Product_L3__r.Product_Type__c;
                      if(ProType && ProType.slice(0,2) == 'FG'){
                          record.SAP_Price = Math.ceil(lastSPrice);
                      }
                       if(uniqueL3.has(record.Product_L3__r.Name))
                          {
                              continue;
                          }
                          else{
                          uniqueL3.add(record.Product_L3__r.Name);
                          uniqueRecords.push(record);    
                          }  
                      
                  }
                  console.log("unique rec => ",uniqueRecords);
                  component.set('v.record', total);
                  var headers = [];
                  const iterator1 = productHeaders.values();
                  let isFSet = component.get("v.fullSet");
                  console.log('productHeaders.size => '+productHeaders.size);
                  for (var i = 0; i < productHeaders.size; i++) {
                      var header = new Object();
                      header.Name = iterator1.next().value;
                      header.isSelected = false;
                     // if(isFSet === true){
                      //	header.isSelected = true;
                        //  header.value =  l1l2[i].Quantity__c;
                      //}
                      for (var j = 0; j < l1l2.length; j++) {
                          if (l1l2[j].Product_Description__c != undefined && l1l2[j].Product_Description__c.includes(header.Name)) {
                              header.value = l1l2[j].Quantity__c;
                              header.isSelected = true;
                              console.log('header.value========' + header.value);
                              // break;
                          }
                          console.log('l1l2.----------' + l1l2[j]);
                      }
                      headers.push(header);
  
                  }
                  console.log('headers======', headers);
                 // component.set("v.recordspartlist",record.level2customQuantity);
                  component.set('v.headers', headers);
                  console.log('recordsFromServer======', recordsFromServer);
                  component.set('v.recordspartlist', recordsFromServer);
                // component.set('v.records', recordsFromServer);
                 component.set('v.records', uniqueRecords);
                  //console.log('recordsFromServer-----121' + JrecordsFromServer));
                  console.log('productHeaders>' + productHeaders);
                  component.set('v.headersName', productHeaders);
                  // component.set('v.updateL2ProductMap', l2Mapupdate);
                  component.set('v.L2ProductMap', l2Mapupdate);
  
                  if (recordsFromServer != '') {
                      component.set('v.partlistnumber', false);
                      component.set('v.searchTable', false);
                  }
                  
              }else if (state === "ERROR") {
                  component.set("v.isLoad", false);
                  var errors = response.getError();
                  console.error(errors);
              }
              
              if (pickselected == '') {
                  component.set("v.isLoad", false); 
                 // component.set('v.recordspartlist', recordsFromServer);
                                 component.set('v.recordspartlist', uniqueRecords);
  
              } 
              /*else if (state === "ERROR") {
                  component.set("v.isLoad", false);
                  var errors = response.getError();
                  console.error(errors);
              }*/
          });
          $A.enqueueAction(action);
      },
  
     /* caluculateCustomQuantity: function (component, event, helper) {
          var records = component.get('v.records');
          let i = 0;
          for (var record of records) {
              let total = 0;
              for (var key of record.customQuantityValues.keys()) {
                  total += record.customQuantityValues.get(key) ? record.customQuantityValues.get(key) : 0;
              }
              record.customQuantity = total;
              //helper.fetchBTPPrice(component, i);
              helper.fetchBTPPrice(component, i, total, true, false).then(function (result) {
                  helper.totalBTPCalculate(component, event, helper);
                  helper.totalSalesPriceCalculate(component, event, helper);
              }).catch(err => {
                  console.log('err-->>' + err);
                  helper.showToast("Error", "Error", "Something went wrong. Contact your adim.");
              });
              i++;
          }
          component.set('v.records', records);
  
      },*/
  
      caluculateLevel2CustomQuantity: function (component, event, helper,isLast) {
          console.log('caluculateLevel2CustomQuantity is method calling')
          var records = component.get('v.records');
          console.log('records**',JSON.stringify(records));
          let i = 0;
          let L3ProdQtyMap =  component.get("v.L3ProductQty");
          console.log('L3ProdQty');
          console.log(JSON.stringify(L3ProdQtyMap));
          var productQuantity = {};
			  for (var record of records) {
				  console.log('Check- i->>>' + i);
				  let total = 0;
				  
				  var headers = component.get("v.headers");
				  console.log('headers',headers);
				  
				   for(var header of headers){
					   if(header.isSelected === true){
						   let key = record.Product_L3__c+header.Name;
						   console.log('key-->'+key);
						   console.log('qty MAP-->'+L3ProdQtyMap[key]);                     
						   let pQty =L3ProdQtyMap[key];   
						   console.log('pQty-->>'+pQty);
						   if(pQty != undefined && pQty != '') {
                               console.log('--headervalue---'+header.value);
							   total += header.value *pQty;                 
						   }
						   
					   }
				   }
				   if(total > 0){
					records[i].level2customQuantity = total;
				   }
                  else{
                      records[i].level2customQuantity = 0;
                  }
         		   productQuantity[records[i].Product_L3__c] =Number(total) + Number(records[i].customQuantity);	
				i++;									
			}
            
          	console.log('before last v.records ',JSON.stringify(records));
			component.set("v.records", records);

			if(isLast){
                console.log(productQuantity);
			console.log(' above product quantity');
				var records = component.get('v.records');
                 let count = 0;
				 for (var record of records) {             
				 let total = 0;
				
				 total = total + Number(record.level2customQuantity) + Number(record.customQuantity);
                 console.log('----total--quantity'+total);
				  if(total > 0){
						  // Added by Kuhinoor
						   helper.fetchBTPPrice(component, count, record.level2customQuantity, false, true,productQuantity).then(function (result) {
							  helper.totalBTPCalculate(component, event, helper);
							  helper.totalSalesPriceCalculate(component, event, helper);
                              
						  }).catch(err => {
							  console.log('err-->>' + err);
							  helper.showToast("Error", "Error", "Something went wrong. Contact your adim.");
						  });
					  
					  }else{
						   records[count].L2btpPrice = 0;
						   console.log('customQuantity-->>>'+records[count].customQuantity);
						   /*if(parseFloat(records[count].customQuantity) === 0){
							   records[count].SAP_Price = 0;
							   records[count].mySalesPrice = 0;
						   }*/
						  helper.priceRecalculation(component, event, helper);
					  }
				  //END Here...
				  count++;
			  }
              console.log('caluculateLevel2CustomQuantity method records ',records);
			  component.set("v.records", records);
			}
          
  
      },
     
      priceRecalculation :function(component, event, helper){
          
          var records = component.get('v.records');
          for (var record of records) {
              let tBtp = 0; 
              //if(record.customQuantity > 0 && record.SAP_Price >= record.cusBtpPrice){
              
              if(record.customQuantity > 0 && record.SAP_Price >= record.cusBtpPrice){
                  record.btpPrice = record.SAP_Price;
                  tBtp =  record.SAP_Price;
              }else if(record.customQuantity > 0){
                  record.btpPrice = record.cusBtpPrice;
                  tBtp =  record.cusBtpPrice;
              }else{
                  record.btpPrice = 0;
                  if(record.isLLP === false){
                      record.SAP_Price = 0;
                  }
              }
              let discount = 0;
              let margin = 0;
              margin = (tBtp * record.margin)/100;
              if(record.discount > 0 ){
                  discount = (tBtp * record.discount)/100;                
              }
              // AK Fix 5 sep 2022
              record.mySalesPrice = parseFloat(tBtp) + parseFloat(margin);
             // record.mySalesPrice = record.mySalesPrice - discount;
              
              
              
              
          }
          component.set("v.records", records);
          helper.totalBTPCalculate(component, event, helper);
          helper.totalSalesPriceCalculate(component, event, helper);
     },                
                      
  
      onChangeFullSet: function (component, event, helper, isFromCheckBox) {
          var fullset = component.get('v.fullSet');
          let isLast = false;
          //       var quantity = event.target.checked ? component.get('v.fullSetQuantity') : 0;//isFromCheckBox !== undefined && !isFromCheckBox ?  0 : 1;
          var quantity = isFromCheckBox !== undefined && !isFromCheckBox ? event.currentTarget.value : 1;
  
          component.set('v.fullSetQuantity', quantity);
          var records = component.get('v.records');
          console.log('fullset' + fullset);
          var headers = component.get('v.headers');
          //  var value = event.currentTarget.value;
          //var header = event.currentTarget.dataset.header;
          let iterations = headers.length;
          for (var record of headers) {
              //if (record.isSelected == fullset) {
              if (fullset === true) {
                  record.value = quantity;
                  record.isSelected =true;
                  component.set('v.isButtonActive', true);
              } else {
                  record.value = 0;
                  record.isSelected =false;
                  component.set('v.fullSetQuantity', 0);
                  component.set('v.isButtonActive', false);
                  
              }
              if(fullset === true) {
                 if(!(--iterations)){
                  	isLast = true;
                  }
                  console.log('===is Last 3'+isLast);
                  helper.calculateRecordCustomQuantity(component, event, helper, quantity, record.Name,isLast);
      
              }else{
                  console.log('INSIDE ELSE FULLSET')
                  helper.clearFullSet(component, event, helper);
              }
              
              
          }
          component.set('v.headers', headers);
  
      },
                      
                      clearFullSet :     function (component, event, helper) {       
                           var records = component.get('v.records');
                          let i=0;
                          for(let key of records){
                              records[i].L2btpPrice = 0;
                              records[i].btpPrice = 0;
                              records[i].cusBtpPrice = 0;
                              records[i].level2customQuantity = 0
                              records[i].customQuantity = 0
                              records[i].mySalesPrice = 0;
                              records[i].productquantities = 0;
                             
                              i++;
                          }
                          component.set('v.records',records );
                      },
  
      calculateRecordCustomQuantity: function (component, event, helper, value, header,isLast,quantity) {
          console.log('is method caling calculateRecordCustomQuantity')
          var records = component.get('v.records');
  
          console.log('REcords :', records);
          console.log(header);
          console.log(value);
          //console.log(quantity);
          for (var record of records) {
              let valueToupdate = record.quantityMapRecord.has(header) ? record.quantityMapRecord.get(header) * value : 0;
              console.log('value to update', valueToupdate);
              record.level2CustomQuantityValues.set(header, valueToupdate);
              record.level2customQuantity = valueToupdate;
          }
          // helper.caluculateLevel2CustomQuantity(component, event, helper, records);
          helper.caluculateLevel2CustomQuantity(component, event, helper,isLast);
          console.log("expected last l2 change records ",records);
  
      },
  
      changeCustomQty: function (component, event, helper) {
          var selectedIndx = event.target.dataset.index;
          console.log('selectedIndx---'+selectedIndx)
          var records = component.get("v.records");
          console.log('changeCustomQty rec ',records);
          // commented by Kuhnoor b/c this func. changes...we have to keep header if there are custom qty aslo
          // so no need to disable header on the input of custom qty.
          // var headers = component.get("v.headers");
          // for(var header of headers){
          //     header.isSelected = false;
          // }
          //component.set("v.headers", headers);
          console.log('record index---'+records[selectedIndx]);
          let qty = records[selectedIndx].customQuantity;
          console.log('qty-------'+qty)
		  console.log('---'+records[selectedIndx].level2customQuantity)
		  component.set("v.records", records); 
		  var records = component.get('v.records');
          console.log("records at cstm qty change",records);
          var productQuantity = {};
				 for (var record of records) {
				 let total = 0;
				 let count = 0;
                 let l2Quan = 0;    
                 let custQuan = 0;    
                 if(!isNaN(record.level2customQuantity))
                     l2Quan = Number(record.level2customQuantity);
                 if(!isNaN(record.customQuantity))  
                     custQuan = Number(record.customQuantity);
				 total = total + l2Quan + custQuan;				  
                 productQuantity[record.Product_L3__c] =total;       
			}
          console.log(productQuantity);
          console.log(' above product quantity');
          helper.fetchBTPPrice(component, selectedIndx, qty, true, false,productQuantity).then(function (result) {
              helper.totalBTPCalculate(component, event, helper);
              helper.totalSalesPriceCalculate(component, event, helper);
          });
          component.set("v.records", records); 
  
      },
  
      fetchBTPPrice: function (component, i, qty, isCustom, isL2,productQuantity) {
          component.set("v.isLoad", true);
          var offerId = component.get("v.recordId");
          var records = component.get("v.records");
          console.log('AK 1 Dec inside fetchPrice');
          console.log(JSON.stringify(records[i]));
          console.log('---level2--'+records[i].level2customQuantity);
          console.log('---custom quantity--'+records[i].customQuantity);
          let isWos = component.get("v.wos");
          console.log('isWos'+isWos)
          let prodId = records[i].Product_L3__c;
          let isFG = false;
          let ProType = records[i].Product_L3__r.Product_Type__c;
          console.log('ProType-->>'+ProType);
          if(ProType && ProType.slice(0,2) == 'FG'){
              isFG = true;
              console.log('ProType-->>Inside');
          }
          let isfixBTP = records[i].isFixedBTP;
          let l2BTPPriceMap = new Map();
          console.log('i-->>'+i);
          console.log('qty-->>'+qty);
          console.log('isfixBTP-->>'+isfixBTP);
          console.log('prodId-->>'+prodId);
          console.log('isWos-->>'+isWos);
          
          if (qty > 0) {
              console.log('isfixBTP-----'+isfixBTP)
              return new Promise(
                  $A.getCallback(function (resolve, reject) {
                      var action = component.get("c.getBTPPrice");
                      action.setParams({
                          offerId: offerId,
                          productId: prodId,
                          itemQty: qty,
                          productQuantity : productQuantity,
                          btpMap: component.get("v.BTPMap")                            
                      });
                      action.setCallback(this, function (response) {
                          var result = response.getReturnValue();
                          console.log('result => ',JSON.stringify(result));
                          var state = response.getState();
                          console.log('State from getBTPPrice => ',state);
                          if (state === "ERROR") {
                              component.set("v.isLoad", false);
                              var errors = response.getError();
                              console.error(errors);
                          }
                          
                          // AK 01/12/22 Changes
                          var originalBTP = result.btpPrice;
                          console.log('originalBTP =>'+originalBTP);
						
                          var btp = result.btpPrice;
                          if(isFG === true){
                              btp = Math.ceil(btp);
                          }
                          
                          var derivedSOFact = component.get('v.derivedSOfactor');
                          console.log('derivedSOFact =>'+derivedSOFact);
                          var lastSOPrice = result.lastSOPrice;
                          console.log('lastSOPrice =>'+lastSOPrice);
                          var incrementedRate = result.incrementRateByTime;
                          console.log('incrementedRate =>'+incrementedRate);
                          console.log('records[i].Product_L3__c =>'+records[i].Product_L3__c);
                          
                          console.log('AK RESULT PRINT==>',JSON.stringify(result));
                          if (state === "SUCCESS") {
                              if(isfixBTP === false){
                                  component.set("v.isLoad", false);
                                  records[i].error = result.errMsg;
                                  
                                  //AK 02/12/22 Changes
                                  records[i].RMCCost = result.RMCCost;
                                  records[i].branchRateOfInterest = result.branchRateOfInterest;
                                  records[i].offerpayment = result.offerpayment;
                                  records[i].branchHedging = result.branchHedging;
                                  records[i].basicPrice = result.basicPrice;
                                  records[i].costPackingForwarding = result.costPackingForwarding;
                                  records[i].CostFreight = result.CostFreight;
                                  records[i].costInsurance = result.costInsurance;
                                  records[i].costInterest = result.costInterest;
                                  records[i].costHedging = result.costHedging;
                                  records[i].exchangeRate = result.exchangeRate;
                                  
                                  console.log('AK Recheck 02/12/22');
                                  console.log(records[i]);
                                  
                                  console.log('err msg -->>' + result.errMsgs);
                                  if (result.errMsg === '' || result.errMsg == undefined) {
                                      if (records[i].customQuantity > 0) {
                                          //console.log("AK BTP PRICE",result.btpPrice);
                                          //console.log("AK cusBtpPrice PRICE",records[i].cusBtpPrice);
                                          records[i].cusBtpPrice = btp;
                                          console.log("AK after cusBtpPrice PRICE",JSON.stringify(records[i].cusBtpPrice));
                                      }
                                      // if (isL2 === true) {
                                      if(records[i].level2customQuantity > 0){
                                          //let existBTP = records[i].L2btpPrice
                                          console.log('prodId-->>'+prodId);
                                          if(!l2BTPPriceMap.has(prodId)){
                                              //console.log(' Inside l2BTPPriceMap-->>');
                                              l2BTPPriceMap.set(prodId , btp);
                                          }else{
                                              //console.log(' else l2BTPPriceMap-->>');
                                              let fPrice = l2BTPPriceMap.get(prodId) + btp;
                                              l2BTPPriceMap.set(prodId , fPrice);
                                          }     
                                          //console.log('l2BTPPriceMap-->>'+l2BTPPriceMap);
                                          records[i].L2btpPrice =l2BTPPriceMap.get(prodId); //result.btpPrice;
                                      }
                                      // }
                                      console.log('cust BTP PRICE ===>'+records[i].L2btpPrice);
                                      let totaBtpPrice = parseFloat(records[i].L2btpPrice) > parseFloat(records[i].cusBtpPrice) ? parseFloat(records[i].L2btpPrice) : parseFloat(records[i].cusBtpPrice); //result.btpPrice;
                                      console.log('totaBtpPrice---------'+totaBtpPrice)
                                      records[i].btpPrice = totaBtpPrice.toFixed(2);
                                      records[i].mySalesPrice = totaBtpPrice;
                                      if (result.btpPrice > 0) {
                                          records[i].inputDisable = false;
                                          records[i].margin = 0;
                                          records[i].discount = 0;
                                          component.set("v.allMarginDisc", false);
                                      }
                                      let lastSPrice = records[i].SAP_Price;
                                      console.log('lastSPrice i-->>>'+i);
                                      console.log('lastSPrice k-->>>'+lastSPrice);
                                      if (lastSPrice === 0) {
                                          console.log('Inside lastSPrice');
                                          let fact = component.get("v.derivedSOfactor");
                                          console.log('fact i-->>>'+fact);
                                          let LastSalesPrice = totaBtpPrice * fact;
                                          console.log('LastSalesPrice A fact -->>>'+LastSalesPrice);
                                          if (isWos === true) {
                                              LastSalesPrice = parseFloat(LastSalesPrice) * (100 / 75);
                                          }
                                          //records[i].SAP_Price = LastSalesPrice.toFixed(3);
                                      }
                                      if (parseFloat(records[i].SAP_Price) > parseFloat(totaBtpPrice)) {
                                          console.log('override');
                                          //if (parseFloat(records[i].SAP_Price) >= parseFloat(records[i].btpPrice) ) {
                                          let newBTPPrice =  parseFloat(records[i].SAP_Price); // * qty;
                                          records[i].btpPrice = newBTPPrice.toFixed(2);
                                          records[i].mySalesPrice = newBTPPrice.toFixed(2);
                                      }
                                  }
                                  if(isFG === true){
                                      console.log('inside isFG #746');
                                      records[i].btpPrice = Math.ceil(records[i].btpPrice);
                                      records[i].mySalesPrice = Math.ceil(records[i].mySalesPrice);
                                      //records[i].SAP_Price = Math.ceil(records[i].SAP_Price);
                                  }
                                  
                                  // AK 01/12/22 Changes
                                  if(records[i].SAP_Price > 0){
                                      console.log('inside lastSO #754');
                                      var newPrice = records[i].SAP_Price;
                                      console.log('newPrice before '+newPrice);
                                      /*if(records[i].isWos == true && records[i].isDirectCustomer != true){
                                          newPrice = newPrice + (100/75);
                                          console.log('newPrice after '+newPrice);
                                      }*/
                                     
                                      /*if(newPrice > originalBTP){
                                          records[i].btpPrice = newPrice;
                                          records[i].mySalesPrice = newPrice;
                                      }else{
                                          records[i].btpPrice = originalBTP;
                                          records[i].mySalesPrice = originalBTP;
                                      }
                                      records[i].SAP_Price = lastSOPrice;*/
                                  }else{
                                      var newPrice = btp * derivedSOFact;
                                      console.log("newPrice =>",newPrice);
                                      if(isFG === true){
                                          records[i].btpPrice = Math.ceil(newPrice);
                                          records[i].mySalesPrice = Math.ceil(newPrice);
                                      }else{
                                        records[i].btpPrice = newPrice.toFixed(2);
                                      	records[i].mySalesPrice = newPrice.toFixed(2);
                                      } 
                                      records[i].SAP_Price = 0;
                                  }
                                  console.log('resulttt 845',JSON.stringify(records));
                                  component.set("v.records", records);
                                  resolve(result);
                              }else if(isfixBTP === true){
                                  //AK 02/12/22 Changes
                                  records[i].RMCCost = result.RMCCost;
                                  records[i].branchRateOfInterest = result.branchRateOfInterest;
                                  records[i].offerpayment = result.offerpayment;
                                  records[i].branchHedging = result.branchHedging;
                                  records[i].basicPrice = result.basicPrice;
                                  records[i].costPackingForwarding = result.costPackingForwarding;
                                  records[i].CostFreight = result.CostFreight;
                                  records[i].costInsurance = result.costInsurance;
                                  records[i].costInterest = result.costInterest;
                                  records[i].costHedging = result.costHedging;
                                  records[i].exchangeRate = result.exchangeRate;
                                  
                                  console.log('AK Recheck 02/12/22');
                                  console.log(records[i]);
                                  return new Promise(
                                      $A.getCallback(function (resolve, reject) {
                                          if (isCustom === true) {
                                              console.log('Inside isCustom');
                                              //records[i].cusBtpPrice = qty * records[i].SAP_Price;
                                              let cBtpPrice =  parseFloat(records[i].SAP_Price);
                                              records[i].cusBtpPrice = cBtpPrice.toFixed(2);
                                              records[i].btpPrice = cBtpPrice.toFixed(2);
                                              records[i].mySalesPrice = cBtpPrice.toFixed(2);
                                          }
                                          if (isL2 === true && records[i].level2customQuantity > 0) {
                                              console.log('INSIDE L2 ********');
                                              let l2BtpPrice = parseFloat(records[i].SAP_Price);
                                              console.log('INSIDE L2 ********'+l2BtpPrice);
                                              //records[i].L2btpPrice = qty * records[i].SAP_Price;
                                              // AK Fix 01/12/22
                                              records[i].L2btpPrice = parseFloat(originalBTP);;
                                             
                                              records[i].btpPrice = l2BtpPrice
                                              records[i].mySalesPrice =  l2BtpPrice;
                                          }
                                          
                                          
                                          if(isFG === true){
                                              records[i].btpPrice = Math.ceil(records[i].btpPrice);
                                              records[i].mySalesPrice = Math.ceil(records[i].mySalesPrice);
                                          }                        
                                          if(records[i].btpPrice > 0){
                                              records[i].inputDisable = false;
                                              records[i].margin = 0;
                                              records[i].discount = 0;
                                          }
                                          console.log('resulttt 845',JSON.stringify(records));
                                          component.set("v.records", records);
                                          component.set("v.isLoad", false);
                                          var result = {};
                                          resolve(result);
                                      })
                                  );
                              }  
                          } else if (state === "ERROR") {
                              component.set("v.isLoad", false);
                              var errors = response.getError();
                              console.error(errors);
                          }
                      });
                      $A.enqueueAction(action);
                  })
              	);
          }else {
              return new Promise(
              $A.getCallback(function (resolve, reject) {
                  records[i].error = '';
                  if (isCustom === true) {
                      console.log('inside line 675 helper.js =>')
                      records[i].customQuantity = 0;
                      records[i].cusBtpPrice = 0;
                  }
                  if (isL2 === true) {
                      console.log('inside line 680 helper.js =>')
                      records[i].level2customQuantity = 0;
                      records[i].L2btpPrice = 0;
                  }               
                  
                  let totaBtpPrice = parseFloat(records[i].L2btpPrice);
                  console.log('totaBtpPrice =>'+totaBtpPrice);
                  if (parseFloat(records[i].SAP_Price) > parseFloat(totaBtpPrice)) {
                      console.log('inside line 688 helper.js =>')
                      let newBTPPrice =  parseFloat(records[i].SAP_Price); 
                      console.log('newBTPPrice =>'+newBTPPrice);
                      records[i].btpPrice = newBTPPrice.toFixed(2);
                      records[i].mySalesPrice = newBTPPrice.toFixed(2);
                      console.log('btpPrice =>'+records[i].btpPrice);
                      console.log('mySalesPrice =>'+records[i].mySalesPrice);
                  }
                  console.log('customQuantity POPOPO->'+records[i].customQuantity);
                  console.log(' level2customQuantity POPOPO->'+records[i].level2customQuantity);
                  if(records[i].customQuantity === 0){
                     console.log('Inside custom qty 0');
                      // AK 23/11 Changes
                      //records[i].mySalesPrice = 0;
                      //records[i].btpPrice  = 0;
                  }
                  if(records[i].customQuantity === 0 && records[i].level2customQuantity === 0){
                     console.log('Inside POPOPO');
                      if(records[i].isLLP === false){
                          records[i].SAP_Price = 0;
                      }                    
                      records[i].mySalesPrice = 0;
                      records[i].btpPrice  = 0;
                  }
                  records[i].margin  = 0;
                  records[i].discount  = 0;
                  
                  component.set("v.records", records);
                  component.set("v.isLoad", false);
                  var result = {};
                  resolve(result);
             }));
          }
          
      },
  
      onMarginChange: function (component, event, helper) {
          var selectedIndx = event.target.dataset.index;
          var records = component.get("v.records");
  
          let margin = records[selectedIndx].margin;
          if (margin == '') margin = 0;
          let btpPrice = records[selectedIndx].btpPrice;
          let marginAmount = (parseFloat(btpPrice) * parseFloat(margin)) / 100;
          let salesPrice = parseFloat(btpPrice) + parseFloat(marginAmount);
          records[selectedIndx].mySalesPrice = isNaN(salesPrice) ? 0 : salesPrice;
          component.set("v.records", records);
          helper.totalSalesPriceCalculate(component, event, helper);
      },
  
      onDiscountChange: function (component, event, helper) {
          component.set("v.isLoad", true);
          var selectedIndx = event.target.dataset.index;
          var records = component.get("v.records");
          let margin = records[selectedIndx].margin;
          let discount = records[selectedIndx].discount;
          if (discount == '') discount = 0;
          let btpPrice = records[selectedIndx].btpPrice;
          let marginAmount = (parseFloat(btpPrice) * parseFloat(margin)) / 100;
          let salesPrice = parseFloat(btpPrice) + parseInt(marginAmount);
          
          console.log('btpPrice-->>'+btpPrice);
          console.log('marginAmount-->>'+marginAmount);
          console.log('salesPrice-->>'+salesPrice);
          let discountedPrice = parseFloat(btpPrice)  * parseFloat(discount) / 100;
          console.log('discountedPrice-->>'+discountedPrice);
          records[selectedIndx].mySalesPrice = (salesPrice - discountedPrice).toFixed(2);
          component.set("v.records", records);
          helper.totalSalesPriceCalculate(component, event, helper);
          component.set("v.isLoad", false);
      },
  
      allMarginChange: function (component, event, helper) {
          component.set("v.isLoad", true);
          let marginAllVal = component.get("v.marginAllVal");
          let records = component.get("v.records");
          console.log("records in allMarginChange ",records);
          for (let ele of records) {
              let ProType = ele.Product_L3__r.Product_Type__c;
              let isFG = false;
              if(ProType && ProType.slice(0,2) == 'FG'){
                  isFG = true;
              }
              if (ele.btpPrice > 0) {
                  ele.margin = marginAllVal != '' ? marginAllVal : 0;
                  let marginAmount = (parseFloat(ele.btpPrice) * parseFloat(marginAllVal)) / 100;
                  let salesPrice = 0;
                  if(isFG === false){
                      salesPrice = parseFloat(ele.btpPrice) + parseFloat(marginAmount);
                  }else{
                      salesPrice = Math.ceil(parseFloat(ele.btpPrice) + parseFloat(marginAmount));
                  }
                  let discountPrice = salesPrice * parseFloat(ele.discount) / 100
                  let finalSalesPrice = (salesPrice - discountPrice).toFixed(2);
                  console.log('finalSalesPrice-->>' + finalSalesPrice);
                  ele.mySalesPrice = isNaN(finalSalesPrice) ? 0 : finalSalesPrice;
              }
          }
          component.set("v.records", records);
          helper.totalSalesPriceCalculate(component, event, helper);
          component.set("v.isLoad", false);
      },
  
      allDiscountChange: function (component, event, helper) {
          component.set("v.isLoad", true);
          let discountAllVal = component.get("v.discountAllVal");
          let records = component.get("v.records");
          for (let ele of records) {
              if (ele.btpPrice > 0) {
                  ele.discount = discountAllVal != '' ? discountAllVal : 0;
                  let marginAmount = (parseFloat(ele.btpPrice) * parseFloat(ele.margin)) / 100;
                  let salesPrice = parseFloat(ele.btpPrice) + parseFloat(marginAmount);
                  let discountPrice = parseFloat(ele.btpPrice)  * parseFloat(ele.discount) / 100
                  let finalSalesPrice = (salesPrice - discountPrice).toFixed(2);
                  ele.mySalesPrice = isNaN(finalSalesPrice) ? 0 : finalSalesPrice;
              }
          }
          component.set("v.records", records);
          helper.totalSalesPriceCalculate(component, event, helper);
          component.set("v.isLoad", false);
      },
  
      totalBTPCalculate: function (component, event, helper) {
          let records = component.get("v.records");
          console.log('records totalBTPCalculate method => ',records);
  
          let totalBtpPrice = 0;
          for (let ele of records) {
              if (parseFloat(ele.btpPrice) > 0) {
                  let totalQty = 0;
                  if(ele.level2customQuantity != '' && ele.level2customQuantity != undefined){
                      totalQty += parseFloat(ele.level2customQuantity);
                  }
                  if(ele.customQuantity != '' && ele.customQuantity != undefined){
                      //console.log("AK CUST QTY =>",ele.customQuantity);
                      totalQty += parseFloat(ele.customQuantity);
                      //console.log("AK TOTAL QTY =>",totalQty);
                  }
                  console.log("AK BEF Total BTP =>",totalBtpPrice);
                  totalBtpPrice += parseFloat(ele.btpPrice) * totalQty;
                  console.log("AK AFT Total BTP =>",totalBtpPrice);
              }
          }
          component.set("v.totalBTPPrice", totalBtpPrice.toFixed(2));
      },
  
      totalSalesPriceCalculate: function (component, event, helper) {
          let records = component.get("v.records");
          console.log('records totalSalesPriceCalculate method => ',records);
          let totalSalesPrice = 0;
          for (let ele of records) {
              
              let totalQty = 0;
              let isUpdateCheck = component.get("v.isUpdate");
              console.log("ele => ",JSON.stringify(ele));
              if(isUpdateCheck == true && ele.level2customQuantity != '' && ele.level2customQuantity != undefined){
                  console.log('inside 1010');
                  totalQty += parseFloat(ele.level2customQuantity);
              }
              /*if(isUpdateCheck == true && ele.productquantities != '' && ele.productquantities != undefined){
                  totalQty += parseFloat(ele.productquantities);
              }*/
              
              if(ele.customQuantity != '' && ele.customQuantity != undefined){
                  console.log('inside 1018');
                  totalQty += parseFloat(ele.customQuantity);
              } 
              
              if (parseFloat(ele.mySalesPrice) > 0) {
                  /*let marginPrice = 0;
                  if(ele.margin > 0){
                      console.log('marginPrice++++');
                      let percentPrice = parseFloat(ele.margin).toFixed(2) * parseFloat(ele.mySalesPrice).toFixed(2);
                      percentPrice = percentPrice/100;
                      percentPrice = percentPrice.toFixed(2);
                      marginPrice = parseFloat(ele.mySalesPrice).toFixed(2) + percentPrice;
                          
                  }else if(ele.margin < 0){
                      console.log('marginPrice----');
                      let percentPrice = parseFloat(ele.margin).toFixed(2) * parseFloat(ele.mySalesPrice).toFixed(2);
                      percentPrice = percentPrice/100;
                      percentPrice = percentPrice.toFixed(2) * -1;
                      marginPrice = parseFloat(ele.mySalesPrice).toFixed(2) - percentPrice;
                  }
                  console.log('marginPrice=>',marginPrice);*/
                  console.log('totalQty =>',totalQty);
                  //totalSalesPrice += parseFloat(marginPrice) * totalQty;
                  totalSalesPrice += parseFloat(ele.mySalesPrice) * totalQty;
                  console.log('totalSalesPrice =>',totalSalesPrice);
              }
          }
          component.set("v.totalSalesPrice", totalSalesPrice.toFixed(2));
      },
  
       //SK - 211122 : Overall Sales percentage over the BTP.
  
       totalSalesPerCalculate: function(component, event, helper){
          let records = component.get("v.records");
          let totalSalesPer = 0;
              for (let ele of records){
                  let totalBtpPrice =0;
                  let totalSalesPrice =0;
  
                  if (totalSalesPrice!= ''){
                      totalSalesPrice += parseFloat(totalSalesPrice);
                  }
                  if (totalBtpPrice != ''){
                      totalBtpPrice += parseFloat(totalBtpPrice);
                  }
                  if ((parseFloat (totalSalesPrice)> 0) && (parseFloat (totalBtpPrice)>0)){
                      totalSalesPer += parseFloat (totalSalesPrice / totalBtpPrice)*100;
                  }
              }
          
          component.set("v.totalSalesPer",totalSalesPer.toFixed(2));
      },
  
      createOffer: function (component, event, helper) {
  
          
          component.set("v.isLoad", true);
          component.set("v.showConfirmDialog", false);
          console.log('Called....');
          let offerId = component.get("v.recordId");
          var records = component.get("v.records");
          console.log('Helper records before save => ',records);
  			
         
          //var l2l3ProdMap = new Map();  // AK 08/12/22 Changes
          let l2Map = component.get("v.L2ProductMap");
          let headers = component.get("v.headers");
          
           // AK 08/12/22 Changes
          /*l2Map.forEach((value, key) => {
              console.log('Test AK 8/12');
              console.log(value, key); 
          });*/

          
          console.log('AK 08/12/22 headers => ',headers);
  		  
           // AK 08/12/22 Changes
          /*
          for (let obj of headers) {
              // AK 08/12/22 Changes
              if (obj.isSelected && l2Map.has(obj.Name)) {
                  l2l3ProdMap.set(l2Map.get(obj.Name), obj.value);
              }
          }
          var l2l3obj = Object.fromEntries(l2l3ProdMap);
          console.log('AK 08/12/22 Check');
  		  console.log(l2l3obj);	*/
          
          var l2l3obj = Object.fromEntries(l2Map);
          console.log(l2l3obj);
          
          let offerLine = [];
          for (let ele of records) {
              console.log('CQTY-->>' + ele.customQuantity);
              console.log('btpPrice-->>' + ele.btpPrice);
              //if (ele.customQuantity > 0 && ele.btpPrice === 0) {
              if ( (ele.level2customQuantity > 0 || ele.customQuantity > 0)  && (ele.btpPrice == undefined || ele.btpPrice === 0) ) {
                //  helper.showToast("Error", "Error", "Fix BTP price");
                 // component.set("v.isLoad", false);
                  // retun;
              }
              //if(ele.customQuantity > 0 && ele.btpPrice > 0){
             if (ele.customQuantity > 0 || ele.level2customQuantity > 0) {
                 let ProType = ele.Product_L3__r.Product_Type__c;
                 let isFG = false;
                 if(ProType && ProType.slice(0,2) == 'FG'){
                    isFG = true;
                 }
                 
                 let l2Map = new Map();
                 //AK 09/12/22
                 for (let obj of headers) {
                     if (obj.isSelected) {
                         l2Map.set(obj.Name, obj.value);
                     }
                 }
                 
                 let l2HeadersMap = ele.quantityMapRecord
                 let result = "";
                 l2Map.forEach(function(value, key) {
                     console.log(key + " = " + value);
                     result = result + "" + key.concat("-", l2HeadersMap.get(key));
                     result = result.concat(";");
                     console.log("result => ",result);
                 })
                 console.log("Final result => ",result);
				 
                  let recordObj = {
                      "discount": ele.discount,
                      "margin": ele.margin,
                      "salesPrice": ele.mySalesPrice,
                      "OriginalBTP" : ele.L2btpPrice,
                      "btpPrice": ele.btpPrice,
                      "l3ProductId": ele.Product_L3__c,
                      "l2ProductId": ele.Product_L2__c,
                      "customQuantity": ele.customQuantity,
                      "level2customQuantity" : ele.level2customQuantity,
                      "isFG" : isFG,
                      "RMCCost" : ele.RMCCost,
                      "branchRateOfInterest" : ele.branchRateOfInterest,
                      "offerpayment" : ele.offerpayment,
                      "branchHedging" : ele.branchHedging,
                      "basicPrice" : ele.basicPrice,
                      "costPackingForwarding" : ele.costPackingForwarding,
                      "CostFreight" : ele.CostFreight,
                      "costInsurance" : ele.costInsurance,
                      "costInterest" : ele.costInterest,
                      "costHedging" : ele.costHedging,
                      "exchangeRate" : ele.exchangeRate,
                      "quantityL2Wise" : result
                  }
                  offerLine.push(recordObj);
              }
          }
          console.log(offerLine);
          
          if (offerLine.length > 0) {
              var action = component.get("c.saveOffer");
              let fSetQty = component.get("v.fullSetQuantity");
              let isFullSet = component.get("v.fullSet");
              let sOrgId = component.get("v.sOrgId");
              let isWos = component.get("v.wos");
              if (isFullSet === false) {
                  fSetQty = 0;
              }
  
              let offCurrencyCode = component.get("v.offCurrency");
              let prtId = component.get("v.partId");
              action.setParams({
                  offerId: offerId,
                  currCode: offCurrencyCode,
                  partListId: prtId,
                  recordStr: JSON.stringify(offerLine),
                  l2l3MapStr: JSON.stringify(l2l3obj),
                  btpMap: component.get("v.BTPMap"),
                  fullSetQty: fSetQty,
                  sOrgId: sOrgId,
                  isWOS: isWos,
                  headerStr : JSON.stringify(headers)
              });
  
              action.setCallback(this, function (response) {
                  console.log(response);
                  var state = response.getState();
                  console.log(state);
                  if (state === "SUCCESS") {
                      component.set("v.isLoad", false);
                      helper.showToast("Success", "Success", "Offer Products are created successfully.");
                      $A.get("e.force:closeQuickAction").fire();
                  } else if (state === "ERROR") {
                      component.set("v.isLoad", false);
                      component.set("v.showConfirmDialog", false);
                      var errors = response.getError();
                      helper.showToast("Error", "Error", "Unknown error");
                  }
              })
              $A.enqueueAction(action);
          } else {
              helper.showToast("Error", "Error", "BTP/Sales price are missing");
              component.set("v.isLoad", false);
          }
      },
  
      showToast: function (title, type, message) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
              "title": title,
              "message": message,
              "type": type
          });
          toastEvent.fire();
      },

      showToast2: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
  })