public class Invoice_PDF_Controller {
    
    public Id invoiceId {get;set;}
    public String Address{get;set;}
    public String PDFCompanyName{get;set;}
    public String Footer_Address{get;set;}
    public String Footer_Declaration{get;set;}
    public String Footer_Contact_Us{get;set;}
    public List<wrapperproductdetails> wrapperlst {get;set;}
    public Decimal Total{get;set;}
    public String PreCarriage {get;set;}
    public String PlaceReceipt {get;set;}
    public String VesselFlightNo {get;set;}
    public String PortLoading {get;set;}
    public String PortDischarge {get;set;}
    public String FinalDestination {get;set;}
    public String CountryOrigin {get;set;}
    public String CountryFinalDestination {get;set;}
    public String DeliveryTerm {get;set;}
    public String PaymentTerm {get;set;}
    public String AmountInWords {get;set;}
    public Decimal isBuyerSameAsConsignee {get;set;}
    public Decimal isManualLineItem {get;set;}
    public String InvCurrency {get;set;}
    public List<SapInvoiceDetails> sapList {get; set;}
        
    ApexPages.StandardController sc;
    
    public Invoice_PDF_Controller(ApexPages.StandardController sc){
        this.sc = sc; 
        isBuyerSameAsConsignee = 0;
        isManualLineItem = 0;
        invoiceId = sc.getId();
        getPIDetails();
        getproductdetails();
    }
    
   @TestVisible
    private void getPIDetails(){
        PDFCompanyName = getContent('Company_Name');
        Address = getContent('Address');
        Footer_Address = getContent('Footer_Address');
        Footer_Declaration = getContent('Footer_Declaration');
        Footer_Contact_Us = getContent('Footer_Contact_Us');
    }
    
    @TestVisible
    private String getContent(String infoType){
        Static_Contents__mdt contentObj = Static_Contents__mdt.getInstance(infoType);
        return contentObj?.Content__c;
    }
    
    public void getproductdetails(){
        System.debug('invoiceId'+invoiceId);
        wrapperlst = new List<wrapperproductdetails>();
        
        Invoice__c inv = [Select Id,Pre_carriage__c,Place_of_Receipt_by_Pre_Carrier__c,Vessel_Flight_No__c,Port_of_Loading__c,Port_of_Discharge__c,
                          Final_Destination__c,Country__c,Country_of_Final_Destination__c,Delivery_Term__c,Payment_Terms__c,Commercial_Invoice_Date__c,
                          Consignee__c,Buyer__c,is_Manual_Line_Item_Applicable__c,CurrencyIsoCode,Bank_Name__c,Account_Number__c,Beneficiary__c,Swift_Code__c
                          FROM Invoice__c 
                          Where Id =: invoiceId];
        
        InvCurrency = inv.CurrencyIsoCode;
        
        if(inv.Consignee__c == inv.Buyer__c){
            isBuyerSameAsConsignee = 1;
        }
        
        Map<String,String> countryMap = new Map<String,String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get('Invoice__c') ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get('COuntry__c').getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            countryMap.put(pickListVal.getValue(),pickListVal.getLabel());
            //System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
        }   
                
        PreCarriage = inv.Pre_carriage__c;
        PlaceReceipt = inv.Place_of_Receipt_by_Pre_Carrier__c;
        VesselFlightNo = inv.Vessel_Flight_No__c;
        PortLoading = inv.Port_of_Loading__c;
        PortDischarge = inv.Port_of_Discharge__c;
        FinalDestination = inv.Final_Destination__c;
        CountryOrigin = countryMap.get(inv.Country__c);
        CountryFinalDestination = countryMap.get(inv.Country_of_Final_Destination__c);
        DeliveryTerm = inv.Delivery_Term__c;
        PaymentTerm = inv.Payment_Terms__c;

        //SK:030123 Getting the SAP Invoice details
        sapList = new List<SapInvoiceDetails>();
        List<Invoice__c> sapInvList = [SELECT ID, SAP_Invoice_Number__c, SAP_Invoice_Date__c FROM Invoice__c  Where Id =: invoiceId];
        System.debug('@SapInvoiceDetails'+sapInvList);
        if (sapInvList.size()>0){
            for (Invoice__c invoice : sapInvList){
                SapInvoiceDetails details = new SapInvoiceDetails();
                details.SapInvoice = invoice.SAP_Invoice_Number__c;
                details.SapDate = invoice.SAP_Invoice_Date__c;
                sapList.add(details);
                }
            }
        
        if(inv.is_Manual_Line_Item_Applicable__c){
            isManualLineItem = 1;
            List<Manual_Invoice_Line_Item__c> manualLineItemList = [Select Id,Invoice__c,Item_Description__c,Item_Quantity__c,Total_Price__c,Unit__c
                                                                   FROM Manual_Invoice_Line_Item__c
                                                                   WHERE Invoice__c =: invoiceId];
            if(manualLineItemList.size()>0){
                Total =0.00;
                for(Manual_Invoice_Line_Item__c manLineItem : manualLineItemList){
                    wrapperproductdetails invLineItemdetail = new wrapperproductdetails();
                    invLineItemdetail.ItemDescription = manLineItem.Item_Description__c;
                    invLineItemdetail.Quantity = manLineItem.Item_Quantity__c;
                    invLineItemdetail.Rate = manLineItem.Unit__c;
                    invLineItemdetail.Amount = manLineItem.Total_Price__c;
                    Total+=elide(invLineItemdetail.Amount);
                    wrapperlst.add(invLineItemdetail);
                }
            }
        }else{
            List<Invoice_Line_Item__c> invoiceLineItemlist = [SELECT Id, Name, CurrencyIsoCode, Invoice__c, Item_Number__c, Item_Code__c, HSN_Code__c, Item_Description__c, 
                                                              Product_Type__c, Product_Group__c, Item_Quantity__c, SO_Item_Quantity__c, UOM__c,Item_Value__c, 
                                                              Drawing_Number__c FROM Invoice_Line_Item__c 
                                                              Where Invoice__c =: invoiceId];
            
             if(invoiceLineItemlist.size()>0){
                Total =0.00;
                for(Invoice_Line_Item__c invLineItem : invoiceLineItemlist){
                    wrapperproductdetails invLineItemdetail = new wrapperproductdetails();
                    invLineItemdetail.ItemCode = invLineItem.Item_Code__c;
                    invLineItemdetail.HSNCode = invLineItem.HSN_Code__c;
                    invLineItemdetail.ItemDescription = invLineItem.Item_Description__c;
                    invLineItemdetail.Quantity = invLineItem.Item_Quantity__c;
                    invLineItem.CurrencyIsoCode = InvCurrency;
                    invLineItemdetail.Rate = invLineItem.Item_Value__c;
                    invLineItemdetail.Amount = invLineItem.Item_Quantity__c * invLineItem.Item_Value__c;
                    Total+=elide(invLineItemdetail.Amount);
                    wrapperlst.add(invLineItemdetail);
                }
            }
         }
        Integer myintval = Total.intValue();
        AmountInWords = ConvertNumberToWords.getNumberWord(myintval);
    }
    
     public class wrapperproductdetails{
        public String ItemCode{get;set;}
        public String HSNCode{get;set;}
        public String ItemDescription{get;set;}
        public Decimal Quantity{get;set;}
        public Decimal Rate{get;set;}
        public Decimal Amount{get;set;}
    }
    
    public static Decimal elide(Decimal input){
        return (input == null) ? 0 : input;
    } 
    
    public class SapInvoiceDetails{
        public String SapInvoice{get;set;}
        public String SapDate{get;set;}
    }

}