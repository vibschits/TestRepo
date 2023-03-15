public  with sharing  class LeadTriggerHelper {
    
    public static void assignrecordtouserORgroup(List<lead> newItems){
        List<Leadshare> shareleadstouserorGroup = new list<Leadshare>();
      //  system.debug('newMap.values()--'+newMap.values());
        for(Lead obj : newItems){
           // Lead ld  = (Lead)obj;
            if(obj.Regional_Manager__c!= null){
            Leadshare shareleads = new Leadshare();
            shareleads.LeadId = obj.Id;
            shareleads.UserOrGroupId = obj.Regional_Manager__c;
            shareleads.LeadAccessLevel = 'Edit';
            shareleads.RowCause = schema.Leadshare.Rowcause.manual;
            
            shareleadstouserorGroup.add(shareleads);
                
            }
            
            
        }
        Database.SaveResult[] leadShareInsertResult = Database.insert(shareleadstouserorGroup,false);
        Integer i=0;
        
        for(Database.SaveResult sr : leadShareInsertResult){
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  &&  err.getMessage().contains('AccessLevel'))){
                    trigger.oldMap.get(shareleadstouserorGroup[i].id).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            i++;
        }   
        
    }
    
}