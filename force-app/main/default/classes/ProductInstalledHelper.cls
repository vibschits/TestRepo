/*
Name : ProductInstalledHelper
Desc : This is a helper class of ProductInstalledHandler
US :
*/
public class ProductInstalledHelper {
    
    public void updateProductInstalled(List<Product_Installed__c> newPIRec){
        try{
            
            List<Product_Installed__c>  updatingrec = new List<Product_Installed__c>();
            Set<Id> locationids= new Set<Id>();
            for(Product_Installed__c prod: newPIRec){
                locationids.add(prod.Location__c);
            }
            Map<Id,Location__c> maplocationids= new Map<Id,Location__c>();
            for(Location__c loc : [select id,Reference_Structure__c from Location__c where id in : locationids]){
                for(Product_Installed__c prod : newPIRec){
                    if(loc.id == prod.Location__c){
                        maplocationids.put(prod.Id, loc);
                    }
                }
            }
            
            List<LocRefStruct__mdt> lstLocRef = [SELECT Id, RTID__c, Type__c, Values__c, Label FROM LocRefStruct__mdt];
            for(Product_Installed__c prod : newPIRec){
                for(LocRefStruct__mdt objLocMdt:  lstLocRef){
                    
                    String Recordtpelabel = Schema.getGlobalDescribe().get('Product_Installed__c').getDescribe().getRecordTypeInfosById().get(prod.RecordTypeId).getName();
                    //  Schema.getGlobalDescribe().get(Product_Installed__c).getDescribe().getRecordTypeInfosById().get(prod.RecordTypeId).getName();
                    
                    if(Recordtpelabel == objLocMdt.Label){
                        
                        Location__c loc  = maplocationids.get(prod.id);
                        String parentRefStructure = loc.Reference_Structure__c;
                        List<String> lstParentValues = parentRefStructure.split(';');
                        String childmetadatavalues = objLocMdt.Values__c;
                        List<String> lstmetadataValues = childmetadatavalues.split(',');
                        String finalStr = '';
                        for(String element: lstParentValues){
                            if(lstmetadataValues.contains(element)){
                                finalStr = finalStr + ',' + element;
                            }
                        }
                        String tempstr = finalStr.removeStart(',');
                        prod.Reference_Structure__c = tempstr;
                        System.debug('final prod '+prod);
                    }
                }
                updatingrec.add(prod);
            }
            System.debug('reference list  '+ updatingrec[0].Reference_Structure__c + '1' +updatingrec[0].Reference_Structure__c );
         //   Database.SaveResult[] result= Database.update(updatingrec,false);
            
        }
        catch(exception e){
            System.debug('exception e '+e.getMessage() + ' '+e.getLineNumber());
            TegaUtility.trackLogs(e, 'ProductInstalledHelper', 'updateProductInstalled');
        }
    }
}