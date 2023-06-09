//Generated by wsdl2apex

public class AsyncPartListWebServiceNew {
    public class ZPartlistSfResponse_elementFuture extends System.WebServiceCalloutFuture {
        public PartListWebServiceNew.ZPartlistSfResponse_element getValue() {
            PartListWebServiceNew.ZPartlistSfResponse_element response = (PartListWebServiceNew.ZPartlistSfResponse_element)System.WebServiceCallout.endInvoke(this);
            return response;
        }
    }
    public class AsyncZWSPARTLIST {
        public String endpoint_x = 'http://20.192.11.81:8000/sap/bc/srt/rfc/sap/zwspartlist/600/zwspartlist/zwspartlist';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:sap-com:document:sap:soap:functions:mc-style', 'PartListWebServiceNew', 'urn:sap-com:document:sap:rfc:functions', 'PartListWebServiceNew'};
        public AsyncPartListWebServiceNew.ZPartlistSfResponse_elementFuture beginZPartlistSf(System.Continuation continuation,String Division,PartListWebServiceNew.TableOfZplmsgSfdc GtMsg,PartListWebServiceNew.TableOfZplmspSfdc GtSp,PartListWebServiceNew.TableOfZpltab1Sfdc GtTab1,PartListWebServiceNew.TableOfZpltab2Sfdc GtTab2,PartListWebServiceNew.TableOfZpltab3Sfdc GtTab3,PartListWebServiceNew.TableOfZweightSfdc GtWeight,String NoLof,String NoSp,String NoTab1,String NoTab2,String NoTab3,String PLabor,String Plm) {
            PartListWebServiceNew.ZPartlistSf_element request_x = new PartListWebServiceNew.ZPartlistSf_element();
            request_x.Division = Division;
            request_x.GtMsg = GtMsg;
            request_x.GtSp = GtSp;
            request_x.GtTab1 = GtTab1;
            request_x.GtTab2 = GtTab2;
            request_x.GtTab3 = GtTab3;
            request_x.GtWeight = GtWeight;
            request_x.NoLof = NoLof;
            request_x.NoSp = NoSp;
            request_x.NoTab1 = NoTab1;
            request_x.NoTab2 = NoTab2;
            request_x.NoTab3 = NoTab3;
            request_x.PLabor = PLabor;
            request_x.Plm = Plm;
            return (AsyncPartListWebServiceNew.ZPartlistSfResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncPartListWebServiceNew.ZPartlistSfResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              '',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZPartlistSf',
              'urn:sap-com:document:sap:soap:functions:mc-style',
              'ZPartlistSfResponse',
              'PartListWebServiceNew.ZPartlistSfResponse_element'}
            );
        }
    }
}