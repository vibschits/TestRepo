//Generated by wsdl2apex

public class PaymentQASWSDL {
    public class ZrevDoc {
        public String CompCode;
        public String ReversePmtDocNo;
        public String ReverseDate;
        public String RevEntryDate;
        public String RevEntryTime;
        public String PmtDocNo;
        public String PmtDocPostDate;
        public String PmtDocEntryDate;
        private String[] CompCode_type_info = new String[]{'CompCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ReversePmtDocNo_type_info = new String[]{'ReversePmtDocNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ReverseDate_type_info = new String[]{'ReverseDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] RevEntryDate_type_info = new String[]{'RevEntryDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] RevEntryTime_type_info = new String[]{'RevEntryTime','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PmtDocNo_type_info = new String[]{'PmtDocNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PmtDocPostDate_type_info = new String[]{'PmtDocPostDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PmtDocEntryDate_type_info = new String[]{'PmtDocEntryDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'CompCode','ReversePmtDocNo','ReverseDate','RevEntryDate','RevEntryTime','PmtDocNo','PmtDocPostDate','PmtDocEntryDate'};
    }
    public class ZpayDoc {
        public String CompCode;
        public String PmtDocNo;
        public String PostingDate;
        public String FiscalYear;
        public String InvNo;
        public String SoNo;
        public String SoItemNo;
        public String AdvPmtInd;
        public String PayAmtDc;
        public String DocCurrency;
        private String[] CompCode_type_info = new String[]{'CompCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PmtDocNo_type_info = new String[]{'PmtDocNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PostingDate_type_info = new String[]{'PostingDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FiscalYear_type_info = new String[]{'FiscalYear','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] InvNo_type_info = new String[]{'InvNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SoNo_type_info = new String[]{'SoNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] SoItemNo_type_info = new String[]{'SoItemNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] AdvPmtInd_type_info = new String[]{'AdvPmtInd','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PayAmtDc_type_info = new String[]{'PayAmtDc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] DocCurrency_type_info = new String[]{'DocCurrency','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'CompCode','PmtDocNo','PostingDate','FiscalYear','InvNo','SoNo','SoItemNo','AdvPmtInd','PayAmtDc','DocCurrency'};
    }
    public class ZinvPayDetails_element {
        public String FromDate;
        public String FromTime;
        public String ToDate;
        public String ToTime;
        private String[] FromDate_type_info = new String[]{'FromDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FromTime_type_info = new String[]{'FromTime','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','1','false'};
        private String[] ToDate_type_info = new String[]{'ToDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','1','false'};
        private String[] ToTime_type_info = new String[]{'ToTime','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'FromDate','FromTime','ToDate','ToTime'};
    }
    public class ZpayHdrLn {
        public PaymentQASWSDL.ZpayHdr[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZpayHdr {
        public String CompCode;
        public String PmtDocNo;
        public String PostingDate;
        public String FiscalYear;
        public String EntryDate;
        public String EntryTime;
        public String BankName;
        public String BankRefNo;
        private String[] CompCode_type_info = new String[]{'CompCode','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PmtDocNo_type_info = new String[]{'PmtDocNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] PostingDate_type_info = new String[]{'PostingDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] FiscalYear_type_info = new String[]{'FiscalYear','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] EntryDate_type_info = new String[]{'EntryDate','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] EntryTime_type_info = new String[]{'EntryTime','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] BankName_type_info = new String[]{'BankName','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] BankRefNo_type_info = new String[]{'BankRefNo','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'CompCode','PmtDocNo','PostingDate','FiscalYear','EntryDate','EntryTime','BankName','BankRefNo'};
    }
    public class ZpayDocLn {
        public PaymentQASWSDL.ZpayDoc[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZrevDocLn {
        public PaymentQASWSDL.ZrevDoc[] item;
        private String[] item_type_info = new String[]{'item','urn:sap-com:document:sap:soap:functions:mc-style',null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'item'};
    }
    public class ZinvPayDetailsResponse_element {
        public String ExMessage;
        public PaymentQASWSDL.ZpayHdrLn ExPayHdr;
        public PaymentQASWSDL.ZpayDocLn ExPayItm;
        public PaymentQASWSDL.ZrevDocLn ExReverseDoc;
        private String[] ExMessage_type_info = new String[]{'ExMessage','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExPayHdr_type_info = new String[]{'ExPayHdr','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExPayItm_type_info = new String[]{'ExPayItm','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] ExReverseDoc_type_info = new String[]{'ExReverseDoc','urn:sap-com:document:sap:soap:functions:mc-style',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style','false','true'};
        private String[] field_order_type_info = new String[]{'ExMessage','ExPayHdr','ExPayItm','ExReverseDoc'};
    }
    public class ZWS_INV_PAY_DETAILS_V2 {
        public String endpoint_x = 'http://20.192.11.81:8000/sap/bc/srt/rfc/sap/zws_pay_details_v2/600/zws_inv_pay_details_v2/zws_inv_pay_details_v2';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style', 'PaymentQASWSDL', 'urn:sap-com:document:sap:rfc:functions', 'PaymentQASWSDL'};
        public PaymentQASWSDL.ZinvPayDetailsResponse_element ZinvPayDetails(String FromDate,String FromTime,String ToDate,String ToTime) {
            PaymentQASWSDL.ZinvPayDetails_element request_x = new PaymentQASWSDL.ZinvPayDetails_element();
            request_x.FromDate = FromDate;
            request_x.FromTime = FromTime;
            request_x.ToDate = ToDate;
            request_x.ToTime = ToTime;
            PaymentQASWSDL.ZinvPayDetailsResponse_element response_x;
            Map<String, PaymentQASWSDL.ZinvPayDetailsResponse_element> response_map_x = new Map<String, PaymentQASWSDL.ZinvPayDetailsResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZinvPayDetails',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZinvPayDetailsResponse',
              'PaymentQASWSDL.ZinvPayDetailsResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x;
        }
    }
}