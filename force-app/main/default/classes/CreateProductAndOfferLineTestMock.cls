/*
Name : CreateProductAndOfferLineTestMock
Description : Mock Test class for CreateProductAndOfferLine.
Author : Pavan
*/
@isTest
global class CreateProductAndOfferLineTestMock implements WebServiceMock {
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
            
            ProductServiceNew.ZmatAltuomLn testZmatAltuomLn = new ProductServiceNew.ZmatAltuomLn();
            ProductServiceNew.ZmatAltuom testZmatAltuom = new ProductServiceNew.ZmatAltuom();
            ProductServiceNew.ZmatHeader testZmatHeader = new ProductServiceNew.ZmatHeader();
            testZmatHeader.MatCode = 'PLM-03960-02-FEH';
            testZmatHeader.MatDesc = 'D-SHACKLE 2-TON INSISE LG.-150 PIN 20';
            testZmatHeader.MatType = 'Test';
            testZmatHeader.MatGroup = 'Test';
            testZmatHeader.Division = 'Test';
            testZmatHeader.DrawingNo = 'Test';
            testZmatHeader.BasicMaterial = 'Test';
            testZmatHeader.CreatedOn ='2021-07-03';
            testZmatHeader.MatCode ='1234';
            
            List<ProductServiceNew.ZmatHeader> lstZmatHeader = new List<ProductServiceNew.ZmatHeader>();
            lstZmatHeader.add(testZmatHeader);
            
            ProductServiceNew.ZmatHeaderLn testZmatHeaderLn = new ProductServiceNew.ZmatHeaderLn();
            testZmatHeaderLn.item = lstZmatHeader;
            
            ProductServiceNew.ZmatPlant testZmatPlant = new ProductServiceNew.ZmatPlant();
            testZmatPlant.MatCode = 'Test';
            testZmatPlant.Plant = '1234';
            testZmatPlant.HsnCode ='1234';
            
            List<ProductServiceNew.ZmatPlant> lstZmatPlant = new List<ProductServiceNew.ZmatPlant>();
            lstZmatPlant.add(testZmatPlant);
            
            ProductServiceNew.ZmatPlantLn testZmatPlantLn = new ProductServiceNew.ZmatPlantLn();
            testZmatPlantLn.item = lstZmatPlant;
            
            ProductServiceNew.ZmatMastMResponse_element testElemnt =new ProductServiceNew.ZmatMastMResponse_element();
            testElemnt.ExMessage = '';
            testElemnt.ExMatHeader = testZmatHeaderLn;
            testElemnt.ExMatPlant = testZmatPlantLn;
            
            response.put('response_x',testElemnt);
            
        }
}