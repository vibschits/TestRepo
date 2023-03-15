public class ProformaInvoicePDF_Controller {
    
    public Id invoiceId {get;set;}
    ApexPages.StandardController sc;
    public String Footer_Address{get;set;}
    public String Footer_Declaration{get;set;}
    public String Footer_Contact_Us{get;set;}
    public List<wrapperproductdetails> wrapperlst {get;set;}
    public Decimal Total{get;set;}
    public Decimal discountTotal{get;set;}
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
    public Decimal UnitPrice{get;set;}
    public Decimal isManualLineItem {get;set;}
    public String InvCurrency {get;set;}
    Public Integer roundOffTotal {get;set;}
    public Decimal isBuyerSameAsConsignee {get;set;}
    public String BankDetails{get;set;}
    public String PDFCompanyName{get;set;}
    public String Address{get;set;}
    
    public ProformaInvoicePDF_Controller(ApexPages.StandardController sc){
        this.sc = sc; 
        isBuyerSameAsConsignee = 0;
        isManualLineItem = 0;
        roundOffTotal = 0;
        invoiceId = sc.getId();
        getPIDetails();
        getproductdetails();
    }
    
    @TestVisible
    private void getPIDetails(){
        PDFCompanyName = getContent('Company_Name');
        Address = getContent('Address');
        Footer_Address = getContent('Footer_Address');
        BankDetails = getContent('Proforma_Bank_Details');
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
                          Consignee__c,Buyer__c,is_Manual_Line_Item_Applicable__c,Total_Due__c,CurrencyIsoCode,Item_Unit_Price__c,Bank_Name__c,Account_Number__c,Beneficiary__c,Swift_Code__c
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

        CountryOrigin = countryMap.get(inv.Country__c);
        CountryFinalDestination = countryMap.get(inv.Country_of_Final_Destination__c);
        
        if(inv.is_Manual_Line_Item_Applicable__c){
            isManualLineItem = 1;
            List<Manual_Invoice_Line_Item__c> manualLineItemList = [Select Id,Invoice__c,Item_Description__c,Item_Quantity__c,Total_Price__c,Unit__c, Unit_Price__c
                                                                   FROM Manual_Invoice_Line_Item__c
                                                                   WHERE Invoice__c =: invoiceId];
            if(manualLineItemList.size()>0){
                Total =0.00;
                for(Manual_Invoice_Line_Item__c manLineItem : manualLineItemList){
                    wrapperproductdetails invLineItemdetail = new wrapperproductdetails();
                    invLineItemdetail.Description = manLineItem.Item_Description__c;
                    invLineItemdetail.Quantity = manLineItem.Item_Quantity__c;
                    invLineItemdetail.Unit = manLineItem.Unit__c;
                    invLineItemdetail.TotalPrice = manLineItem.Total_Price__c;
                    invLineItemdetail.UnitPrice = manLineItem.Unit_Price__c;
                    Total+=elide(invLineItemdetail.TotalPrice);
                    if(inv.Total_Due__c != null){
                        discountTotal = (inv.Total_Due__c / 100) * Total;
                        roundOffTotal = Math.round(discountTotal);
                    }
                    
                    
                    wrapperlst.add(invLineItemdetail);
                }
            }
        }else{
            List<Invoice_Line_Item__c> invoiceLineItemlist = [SELECT Id, Name, CurrencyIsoCode, Invoice__c, HSN_Code__c, Item_Number__c, Item_Code__c, Item_Description__c, 
                                                              Product_Type__c, Product_Group__c, Item_Quantity__c, SO_Item_Quantity__c, UOM__c,Item_Value__c, 
                                                              Drawing_Number__c, Unit_Price__c FROM Invoice_Line_Item__c 
                                                              Where Invoice__c =: invoiceId];
            
             if(invoiceLineItemlist.size()>0){
                Total =0.00;
                for(Invoice_Line_Item__c invLineItem : invoiceLineItemlist){
                    wrapperproductdetails invLineItemdetail = new wrapperproductdetails();
                    invLineItemdetail.HSNCode = invLineItem.HSN_Code__c;
                    invLineItemdetail.Description = invLineItem.Item_Code__c;
                    invLineItemdetail.Quantity = invLineItem.Item_Quantity__c;
                    invLineItem.CurrencyIsoCode = InvCurrency;
                    invLineItemdetail.TotalPrice = invLineItem.Item_Value__c;
                    invLineItemdetail.UnitPrice = invLineItem.Unit_Price__c;
                    Total+=elide(invLineItemdetail.TotalPrice);
                     if(inv.Total_Due__c != null){
                    discountTotal = (inv.Total_Due__c / 100.00) * Total; 
                    roundOffTotal = Math.round(discountTotal);
                     }
                    wrapperlst.add(invLineItemdetail);
                     
                }
            }
         }
        
        if(roundOffTotal != 0){
            AmountInWords = ConvertNumberToWords.getNumberWord(roundOffTotal);
        }
        
    }
    
    public class wrapperproductdetails{
        public String HSNCode{get;set;}
        public String Description{get;set;}
        public Decimal Quantity{get;set;}
        public Decimal Unit{get;set;}
        public Decimal UnitPrice{get;set;}
        public Decimal TotalPrice{get;set;}
    }
    
    public static Decimal elide(Decimal input){
        return (input == null) ? 0 : input;
    } 
}