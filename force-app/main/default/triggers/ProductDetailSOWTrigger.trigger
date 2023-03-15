trigger ProductDetailSOWTrigger on Product_Proposal_Form__c (before insert) {
    
    Set<id> LocationIdSet = new Set<Id>();
    for( Product_Proposal_Form__c pds :Trigger.new)
    {
        LocationIdSet.add(pds.Location__c);
        
    }
    system.debug('LocationIdSet =>'+LocationIdSet);
    List<Location__c> locationlist = [Select id , Customer_Equipment__c FROM Location__c where Id IN : LocationIdSet];
    system.debug('locationlist =>'+locationlist);
    
     Map<Id,Id> equipmentlocationMap = new Map<Id,Id>();  
    
    for(Location__c loc : locationlist){
        equipmentlocationMap.put(loc.id , loc.Customer_Equipment__c);
    }
    system.debug('equipmentlocationMap =>'+equipmentlocationMap);
    
    List<string> ListOfRecordtype = new List<string>{
        'Belt_tracker_roller','CeraDisc','Ceramic_Pully_Lagging','Hosch_Scraper',
            'Impact_Pad_Without_Frame_Impact_Bed_System','Skirt_Sealing_System'
    };
        
    /*ListOfRecordtype.add('Belt_tracker_roller');
    ListOfRecordtype.add('CeraDisc');
    ListOfRecordtype.add('Ceramic_Pully_Lagging');
    ListOfRecordtype.add('Hosch_Scraper');
    ListOfRecordtype.add('Impact_Pad_Without_Frame_Impact_Bed_System');
    ListOfRecordtype.add('Skirt_Sealing_System');*/
    
    

    /*List<Product_Installed__c> pilst =[Select ID , Present_Sway__c ,Location__c, Trough_Angle__c , Return_Belt_Condition__c 
                                     from Product_Installed__c where Location__c =: LocationIdSet and
                                     recordType.developername ='Belt_tracker_roller' order by createdDate DESC];*/
        
    
    List<Product_Installed__c> pilst =[Select ID ,recordType.developername, Present_Sway__c ,Location__c, Trough_Angle__c , Return_Belt_Condition__c ,
                                        Roller_Dia__c,Roller_Length__c,N_of_Rollers__c,Face_Width__c,Dia_of_Pulley__c,
                                       Type_of_Pulley__c,Crowning_of_Pulley__c,Belt_Run_Back__c ,Any_Special_Paint__c,
                                       Any_Other_Special_Requirement__c,RecordTypeId,Free_Fall_Height__c,Length_of_Impact_Bed__c,
                                       Gap_Between_Skirt_and_Belt_Edge__c  from Product_Installed__c where Location__c =: LocationIdSet and
                                     recordType.developername =: ListOfRecordtype  order by createdDate DESC];
    
    map<String,Product_Installed__c> piRecordTypeMap = new Map<String,Product_Installed__c>();
    map<String,String> protypeAndRecordTypemap = new map<String,string>();
    protypeAndRecordTypemap.put('Belt_tracker_roller','Belt Tracker Roller');
    protypeAndRecordTypemap.put('Hosch_Scraper','Belt Scrapers');
    protypeAndRecordTypemap.put('Skirt_Sealing_System','Side Skirt Sealing');
    protypeAndRecordTypemap.put('Skirt_Sealing_System','Rear Skirt Sealing');
  //  protypeAndRecordTypemap.put('Impact_Pad_Without_Frame_Impact_Bed_System','Impact Pad Without Frame');
   // protypeAndRecordTypemap.put('Impact_Pad_Without_Frame_Impact_Bed_System','Impact Bed System');
    protypeAndRecordTypemap.put('Ceramic_Pully_Lagging','Ceramic Pulley Lagging');
    protypeAndRecordTypemap.put('Impact_Pad_Without_Frame_Impact_Bed_System','Impact Pad With Frame');
    
    
    for(Product_Installed__c PI : pilst){
        if(!piRecordTypeMap.containskey(protypeAndRecordTypemap.get(pi.recordType.developername)+pi.Location__c))
            piRecordTypeMap.put(protypeAndRecordTypemap.get(pi.recordType.developername)+pi.location__c,pi);
    }
     //recordTypeId developername
         
    for(Product_Proposal_Form__c pdsow :Trigger.new){
        if(pdsow.Product_Type__c == 'Belt Tracker Roller'){
            pdsow.Trough_Angle_deg__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Trough_Angle__c;
            pdsow.Present_sway__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Present_Sway__c;
            pdsow.Return_Belt_Condition__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Return_Belt_Condition__c;
        }
        else if(pdsow.Product_Type__c =='Belt Scrapers'){
                pdsow.Type_of_Pulley__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Type_of_Pulley__c;
                pdsow.Crowning_of_Pulley__c =piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Crowning_of_Pulley__c;
                pdsow.Belt_Run_Back__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Belt_Run_Back__c;
                pdsow.Any_Special_Paint__c =piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Any_Special_Paint__c;
                pdsow.Any_Other_Special_Requirement__c =piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Any_Other_Special_Requirement__c;
                
            }
        else if(pdsow.Product_Type__c =='Side Skirt Sealing '){
                pdsow.Trough_Angle_deg__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Trough_Angle__c;
                pdsow.Gap_Between_Skirt_and_Belt_Edge__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Gap_Between_Skirt_and_Belt_Edge__c;
                
                
            }
            
            else if(pdsow.Product_Type__c =='Rear Skirt Sealing '){
               pdsow.Trough_Angle_deg__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Trough_Angle__c;
               pdsow.Gap_Between_Skirt_and_Belt_Edge__c =piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Gap_Between_Skirt_and_Belt_Edge__c;

                
            }
           else if(pdsow.Product_Type__c =='Impact Pad Without Frame'){
                pdsow.Trough_Angle_deg__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Trough_Angle__c;
                system.debug(pdsow.Trough_Angle_deg__c);
                pdsow.Free_Fall_Height__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Free_Fall_Height__c;
                system.debug(pdsow.Free_Fall_Height__c);
                pdsow.Length_of_Impact_Bed__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Length_of_Impact_Bed__c;
                system.debug(pdsow.Length_of_Impact_Bed__c);
                
            }
            else if(pdsow.Product_Type__c =='Impact Bed System'){
                pdsow.Trough_Angle_deg__c =  piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Trough_Angle__c;
                system.debug(pdsow.Trough_Angle_deg__c);
                pdsow.Free_Fall_Height__c =  piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Free_Fall_Height__c;
                pdsow.Length_of_Impact_Bed__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Length_of_Impact_Bed__c;
               
                
            }
            else if(pdsow.Product_Type__c =='Ceramic Pulley Lagging'){
                pdsow.Face_Width__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Face_Width__c;
                pdsow.Dia_of_Pulley__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Dia_of_Pulley__c;
              
            }
            else if(pdsow.Product_Type__c =='Impact Pad With Frame'){
                pdsow.Trough_Angle_deg__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Trough_Angle__c;
                pdsow.Free_Fall_Height__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Free_Fall_Height__c;
                pdsow.Length_of_Impact_Bed__c = piRecordTypeMap.get(pdsow.Product_Type__c+pdsow.location__c).Length_of_Impact_Bed__c;
                
            }
    }
       /*   
        for(Product_Installed__c pi : pilst){
        if(pdsow.Location__c == pi.Location__c) {
           if(pdsow.Product_Type__c =='Belt Tracker Roller')
                && pi.recordType.developername =='Belt_tracker_roller'){
                pdsow.Trough_Angle_deg__c = pi.Trough_Angle__c;
                pdsow.Present_sway__c = pi.Present_Sway__c;
                pdsow.Return_Belt_Condition__c = pi.Return_Belt_Condition__c;
                
            }
            else if(pdsow.Product_Type__c =='Belt Scrapers' && pi.recordType.developername =='Hosch_Scraper'){
                pdsow.Type_of_Pulley__c = pi.Type_of_Pulley__c;
                pdsow.Crowning_of_Pulley__c = pi.Crowning_of_Pulley__c;
                pdsow.Belt_Run_Back__c = pi.Belt_Run_Back__c;
                pdsow.Any_Special_Paint__c = pi.Any_Special_Paint__c;
                pdsow.Any_Other_Special_Requirement__c = pi.Any_Other_Special_Requirement__c;
                
            }
            else if(pdsow.Product_Type__c =='Side Skirt Sealing ' && pi.recordType.developername =='Skirt_Sealing_System'){
                pdsow.Trough_Angle_deg__c = pi.Trough_Angle__c;
                pdsow.Gap_Between_Skirt_and_Belt_Edge__c = pi.Gap_Between_Skirt_and_Belt_Edge__c;
                
                
            }
            
            else if(pdsow.Product_Type__c =='Rear Skirt Sealing ' && pi.recordType.developername =='Skirt_Sealing_System'){
               pdsow.Trough_Angle_deg__c = pi.Trough_Angle__c;
               pdsow.Gap_Between_Skirt_and_Belt_Edge__c = pi.Gap_Between_Skirt_and_Belt_Edge__c;

                
            }
            else if(pdsow.Product_Type__c =='Impact Pad Without Frame' && pi.recordType.developername =='Impact_Pad_Without_Frame_Impact_Bed_System'){
                pdsow.Trough_Angle_deg__c = pi.Trough_Angle__c;
                pdsow.Free_Fall_Height__c = pi.Free_Fall_Height__c;
                pdsow.Length_of_Impact_Bed__c = pi.Length_of_Impact_Bed__c;
                
            }
            else if(pdsow.Product_Type__c =='Impact Bed System'  && pi.recordType.developername =='Impact_Pad_Without_Frame_Impact_Bed_System'){
                pdsow.Trough_Angle_deg__c = pi.Trough_Angle__c;
                pdsow.Free_Fall_Height__c = pi.Free_Fall_Height__c;
                pdsow.Length_of_Impact_Bed__c = pi.Length_of_Impact_Bed__c;
                
            }
            else if(pdsow.Product_Type__c =='Ceramic Pulley Lagging' && pi.recordType.developername =='Ceramic_Pully_Lagging' ){
                pdsow.Face_Width__c = pi.Face_Width__c;
                pdsow.Dia_of_Pulley__c = pi.Dia_of_Pulley__c;
              
            }
            else if(pdsow.Product_Type__c =='Impact Pad With Frame' && pi.recordType.developername =='Impact_Pad_Without_Frame_Impact_Bed_System'){
                pdsow.Trough_Angle_deg__c = pi.Trough_Angle__c;
                pdsow.Free_Fall_Height__c = pi.Free_Fall_Height__c;
                pdsow.Length_of_Impact_Bed__c = pi.Length_of_Impact_Bed__c;
                
            }
        }
        }*/
    

    
    List<Operating_Parameters__c> listOfOp = [Select Id,Customer_Equipment__c From Operating_Parameters__c Where Customer_Equipment__c
                                              IN: equipmentlocationMap.values() order by createdDate DESC];
    system.debug('listOfOp =>'+listOfOp);
 
    map<Id,ID> equipmentTOLatestOP = new Map<Id,ID>();
   
        for(Operating_Parameters__c OP : listOfOp){
        if(!equipmentTOLatestOP.containsKey(OP.Customer_Equipment__c))
            equipmentTOLatestOP.put(OP.Customer_Equipment__c, OP.id);
            //here we got latest op of the equipment 
    }
    system.debug('equipmentTOLatestOP =>'+equipmentTOLatestOP);
    
    
    for(Product_Proposal_Form__c pdSOW : Trigger.new){
        if(pdsow.Product_Type__c =='Belt Tracker Roller'){
            if(pdsow.Location__c == pilst[0].Location__c){
                system.debug('equipmentlocationMap.get(pdsow.Location__c) =>'+equipmentlocationMap.get(pdsow.Location__c));
                 pdSOW.Operating_Parameters__c = equipmentTOLatestOP.get(equipmentlocationMap.get(pdsow.Location__c));

                
            }}
        
    }
}