//Generated by wsdl2apex

public class InvoiceQAS_WSDL_v2 {
    public class ZinvGetDetailsV3_element {
        public String ImFromDate;
        public String ImInvNo;
        public String ImToDate;
        private String[] ImFromDate_type_info = new String[]{'ImFromDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','1','false'};
        private String[] ImInvNo_type_info = new String[]{'ImInvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','1','false'};
        private String[] ImToDate_type_info = new String[]{'ImToDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ImFromDate','ImInvNo','ImToDate'};
    }
    public class ZinvItem {
        public String InvNo;
        public String ItemNo;
        public String SoNo;
        public String SoItemNo;
        public String ItemCode;
        public String ItemDesc;
        public String ProductType;
        public String ProductGroup;
        public String ItemQty;
        public String SoItemQty;
        public String Uom;
        public String ItemValue;
        public String DrawingNo;
        private String[] InvNo_type_info = new String[]{'InvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemNo_type_info = new String[]{'ItemNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SoNo_type_info = new String[]{'SoNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SoItemNo_type_info = new String[]{'SoItemNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemCode_type_info = new String[]{'ItemCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemDesc_type_info = new String[]{'ItemDesc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ProductType_type_info = new String[]{'ProductType','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ProductGroup_type_info = new String[]{'ProductGroup','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemQty_type_info = new String[]{'ItemQty','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SoItemQty_type_info = new String[]{'SoItemQty','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Uom_type_info = new String[]{'Uom','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemValue_type_info = new String[]{'ItemValue','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DrawingNo_type_info = new String[]{'DrawingNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'InvNo','ItemNo','SoNo','SoItemNo','ItemCode','ItemDesc','ProductType','ProductGroup','ItemQty','SoItemQty','Uom','ItemValue','DrawingNo'};
    }
    public class ZinvGetDetailsV3Response_element {
        public InvoiceQAS_WSDL_v2.ZinvBankLn ExBankInfo;
        public InvoiceQAS_WSDL_v2.ZinvDelvItemLn ExDelvTab;
        public InvoiceQAS_WSDL_v2.ZinvHdrLn ExHeader;
        public InvoiceQAS_WSDL_v2.ZinvItemLn ExItemTab;
        public String ExMessage;
        private String[] ExBankInfo_type_info = new String[]{'ExBankInfo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExDelvTab_type_info = new String[]{'ExDelvTab','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExHeader_type_info = new String[]{'ExHeader','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExItemTab_type_info = new String[]{'ExItemTab','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExMessage_type_info = new String[]{'ExMessage','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ExBankInfo','ExDelvTab','ExHeader','ExItemTab','ExMessage'};
    }
    public class ZinvBank {
        public String InvNo;
        public String BankName;
        public String Beneficery;
        public String AccNo;
        public String SwiftCode;
        private String[] InvNo_type_info = new String[]{'InvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] BankName_type_info = new String[]{'BankName','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Beneficery_type_info = new String[]{'Beneficery','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] AccNo_type_info = new String[]{'AccNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SwiftCode_type_info = new String[]{'SwiftCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'InvNo','BankName','Beneficery','AccNo','SwiftCode'};
    }
    public class ZinvDelvItem {
        public String InvNo;
        public String DelvNo;
        public String DelvDate;
        public String ItemNo;
        public String ItemCode;
        public String ItemDesc;
        public String ItemQty;
        public String Uom;
        public String Plant;
        public String HlItemNo;
        public String HlItemCode;
        private String[] InvNo_type_info = new String[]{'InvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DelvNo_type_info = new String[]{'DelvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DelvDate_type_info = new String[]{'DelvDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemNo_type_info = new String[]{'ItemNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemCode_type_info = new String[]{'ItemCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemDesc_type_info = new String[]{'ItemDesc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ItemQty_type_info = new String[]{'ItemQty','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Uom_type_info = new String[]{'Uom','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Plant_type_info = new String[]{'Plant','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] HlItemNo_type_info = new String[]{'HlItemNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] HlItemCode_type_info = new String[]{'HlItemCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'InvNo','DelvNo','DelvDate','ItemNo','ItemCode','ItemDesc','ItemQty','Uom','Plant','HlItemNo','HlItemCode'};
    }
    public class ZinvHdrLn {
        public InvoiceQAS_WSDL_v2.ZinvHdr[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZinvItemLn {
        public InvoiceQAS_WSDL_v2.ZinvItem[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZinvBankLn {
        public InvoiceQAS_WSDL_v2.ZinvBank[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZinvHdr {
        public String InvNo;
        public String InvoiceDate;
        public String BillingType;
        public String SalesOrg;
        public String DistChannel;
        public String Division;
        public String CustomerSf;
        public String ConsigneeSf;
        public String InvNetAmtDc;
        public String DocCurrency;
        public String ExchangeRate;
        public String BasicPrice;
        public String PackingChg;
        public String ForwardingChg;
        public String Discount;
        public String Freight;
        public String Cgst;
        public String Sgst;
        public String Igst;
        public String TotalValue;
        public String DispatchMode;
        public String PaymentTerms;
        public String PayTermDesc;
        public String TegaBankAcCode;
        public String GstNo;
        public String VatNo;
        public String OriginalInvNo;
        private String[] InvNo_type_info = new String[]{'InvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] InvoiceDate_type_info = new String[]{'InvoiceDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] BillingType_type_info = new String[]{'BillingType','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SalesOrg_type_info = new String[]{'SalesOrg','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DistChannel_type_info = new String[]{'DistChannel','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Division_type_info = new String[]{'Division','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] CustomerSf_type_info = new String[]{'CustomerSf','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ConsigneeSf_type_info = new String[]{'ConsigneeSf','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] InvNetAmtDc_type_info = new String[]{'InvNetAmtDc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DocCurrency_type_info = new String[]{'DocCurrency','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExchangeRate_type_info = new String[]{'ExchangeRate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] BasicPrice_type_info = new String[]{'BasicPrice','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PackingChg_type_info = new String[]{'PackingChg','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ForwardingChg_type_info = new String[]{'ForwardingChg','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Discount_type_info = new String[]{'Discount','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Freight_type_info = new String[]{'Freight','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Cgst_type_info = new String[]{'Cgst','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Sgst_type_info = new String[]{'Sgst','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] Igst_type_info = new String[]{'Igst','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TotalValue_type_info = new String[]{'TotalValue','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DispatchMode_type_info = new String[]{'DispatchMode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PaymentTerms_type_info = new String[]{'PaymentTerms','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PayTermDesc_type_info = new String[]{'PayTermDesc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] TegaBankAcCode_type_info = new String[]{'TegaBankAcCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] GstNo_type_info = new String[]{'GstNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] VatNo_type_info = new String[]{'VatNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] OriginalInvNo_type_info = new String[]{'OriginalInvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'InvNo','InvoiceDate','BillingType','SalesOrg','DistChannel','Division','CustomerSf','ConsigneeSf','InvNetAmtDc','DocCurrency','ExchangeRate','BasicPrice','PackingChg','ForwardingChg','Discount','Freight','Cgst','Sgst','Igst','TotalValue','DispatchMode','PaymentTerms','PayTermDesc','TegaBankAcCode','GstNo','VatNo','OriginalInvNo'};
    }
    public class ZinvDelvItemLn {
        public InvoiceQAS_WSDL_v2.ZinvDelvItem[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZWS_INV_GET_DETAILS_V3 {
        public String endpoint_x = 'http://20.192.11.81:8000/sap/bc/srt/rfc/sap/zws_inv_get_details_v3/600/zws_inv_get_details_v3/zws_inv_get_details_v3';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style', 'InvoiceQAS_WSDL_v2', 'urn:sap-com:document:sap:rfc:functions', 'InvoiceQAS_WSDL_v2'};
        public InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element ZinvGetDetailsV3(String ImFromDate,String ImInvNo,String ImToDate) {
            InvoiceQAS_WSDL_v2.ZinvGetDetailsV3_element request_x = new InvoiceQAS_WSDL_v2.ZinvGetDetailsV3_element();
            request_x.ImFromDate = ImFromDate;
            request_x.ImInvNo = ImInvNo;
            request_x.ImToDate = ImToDate;
            InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element response_x;
            Map<String, InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element> response_map_x = new Map<String, InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZinvGetDetailsV3',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZinvGetDetailsV3Response',
              'InvoiceQAS_WSDL_v2.ZinvGetDetailsV3Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}