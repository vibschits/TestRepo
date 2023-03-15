@isTest
global class PartListMock implements WebServiceMock {
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
        PartListWebServiceNew.ZPartlistSfResponse_element respElement =  new PartListWebServiceNew.ZPartlistSfResponse_element();

        Account acc = new Account (Name = 'My Test Account', Status__c ='Sync with SAP');
        insert acc;

        Sales_Org__c sOrg = new Sales_Org__c(Name = 'TGSO');
        insert sOrg;

        Branch__c br = new Branch__c(Name = 'Bokaro', Branch_Code__c = 'KKR12',
                                    Mark_Up__c = 1.5,
                                    Rate_PckFwd__c = 1.5,
                                    CIF_Factor__c = 1.5,
                                    Rate_Freight__c= 1.5,
                                    Rate_Insurance__c = 1.5,
                                    Rate_Interest__c = 1.5,
                                    Rate_Hedging__c = 1.5);
        insert br;
            
        PartListWebServiceNew.Zpltab1Sfdc[] itemtab1List = new PartListWebServiceNew.Zpltab1Sfdc[]{};
        PartListWebServiceNew.Zpltab1Sfdc zpTab1Obj = new PartListWebServiceNew.Zpltab1Sfdc();
        zpTab1Obj.ZGmatnr = 'PLM-01314-01';
        zpTab1Obj.Plifz = '12';
        zpTab1Obj.Revstatus = 'G';
        zpTab1Obj.Exrate = '121221';
        zpTab1Obj.LofVal = '121';
        zpTab1Obj.ZLabor = 'KKR12';
        zpTab1Obj.SalesOrg = 'TGSO';
        zpTab1Obj.SfdcId = acc.Id;

        
        itemtab1List.add(zpTab1Obj);


        PartListWebServiceNew.Zpltab2Sfdc[] itemtab2List = new PartListWebServiceNew.Zpltab2Sfdc[]{};
        PartListWebServiceNew.Zpltab2Sfdc zpTab2Obj = new PartListWebServiceNew.Zpltab2Sfdc();
        zpTab2Obj.Menge = '2';
        zpTab2Obj.Meins = 'ST';
        zpTab2Obj.ZGmatnr = 'PLM-01314-01';
        zpTab2Obj.ZMmatnr = 'PLM-01314-02-FEH';
        zpTab2Obj.Mdesc = 'FEH-BALL MILL DIA 2200 X 3500 MM LG';

        itemtab2List.add(zpTab2Obj);

        PartListWebServiceNew.Zpltab3Sfdc[] itemtab3List = new PartListWebServiceNew.Zpltab3Sfdc[]{};
        PartListWebServiceNew.Zpltab3Sfdc zpTab3Obj = new PartListWebServiceNew.Zpltab3Sfdc();
        zpTab3Obj.ZGmatnr = 'PLM-01314-01';
        zpTab3Obj.Ddesc  = 'LIFTER BAR 140-135 FLS, L = 765';
        zpTab3Obj.Meins = 'EA';
        zpTab3Obj.Mtart = 'FGML';
        zpTab3Obj.Matkl = 'ML-LB-RBR';
        zpTab3Obj.Beskz = '';
        zpTab3Obj.Zeinr = 'M37-00085O010';
        zpTab3Obj.SalesOrg = 'TGSO';
        zpTab3Obj.Price = '12222';
        zpTab3Obj.Menge = '12';
        zpTab3Obj.ZDmatnr = 'M37-00085O010-0102';
        zpTab3Obj.ZMmatnr = 'PLM-01314-02-FEH';

        itemtab3List.add(zpTab3Obj);

        PartListWebServiceNew.ZweightSfdc[] itemWeightList = new PartListWebServiceNew.ZweightSfdc[]{};
        PartListWebServiceNew.ZweightSfdc weightObj = new PartListWebServiceNew.ZweightSfdc();
        weightObj.Maktx = 'HEAD PLATE 140 FL';
        weightObj.Matnr = 'M37-00085O010-0102';
        weightObj.Ntgew = '50';
        
        itemWeightList.add(weightObj);

        PartListWebServiceNew.ZplmspSfdc[] gtSpList = new PartListWebServiceNew.ZplmspSfdc[]{};
        PartListWebServiceNew.ZplmspSfdc gtSpObj = new PartListWebServiceNew.ZplmspSfdc();
        gtSpObj.ZDmatnr =  'M37-00085O010-0102';
        gtSpObj.SalesPrice = '122';
        gtSpObj.SalesOrg = 'TGSO';
        gtSpObj.SalesOrder = '121212';
        gtSpObj.OfferNo = '21212';
        gtSpObj.Audat = String.valueOf(Date.today().addDays(-90));

        gtSpList.add(gtSpObj);

        PartListWebServiceNew.TableOfZpltab1Sfdc GtTab1Obj = new PartListWebServiceNew.TableOfZpltab1Sfdc();
        GtTab1Obj.item  =itemtab1List;
        respElement.GtTab1 = GtTab1Obj;

        PartListWebServiceNew.TableOfZpltab2Sfdc GtTab2Obj = new PartListWebServiceNew.TableOfZpltab2Sfdc();
        GtTab2Obj.item = itemtab2List;
        respElement.GtTab2 = GtTab2Obj;

        PartListWebServiceNew.TableOfZpltab3Sfdc GtTab3Obj = new PartListWebServiceNew.TableOfZpltab3Sfdc();
        GtTab3Obj.item = itemtab3List; 
        respElement.GtTab3 = GtTab3Obj;

        PartListWebServiceNew.TableOfZweightSfdc gtWeightObj = new PartListWebServiceNew.TableOfZweightSfdc();
        gtWeightObj.item = itemWeightList; 
        respElement.GtWeight = gtWeightObj;

        PartListWebServiceNew.TableOfZplmspSfdc gtsp = new PartListWebServiceNew.TableOfZplmspSfdc();
        gtsp.item = gtSpList;
        respElement.GtSp = gtsp;
		
        respElement.ExMessage = '';
        response.put('response_x', respElement); 
    }
}