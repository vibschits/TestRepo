public with sharing class InstallationPDFController {
    public string installationId {get;set;}
    public List<wrapperdetails> wrapperlst {get;set;}
    public boolean isLineItem {get;set;}
    public List<Installation__c> instListObj{get;set;}
    ApexPages.StandardController sc;
    public Installation__c instObj;
    public Id instObjId;
    public integer total_size;
    public integer list_size=1;
    public integer counter=0;
    public String recordTypeId { get; set; }
    public String recordTypeName { get; set; } 
    public Id ccRecordTypeId;
    public boolean ccRec {get; set; }
    public boolean nonCCRec {get; set; }
    
    
    
    
    
    public InstallationPDFController(ApexPages.StandardController sc) {
        this.sc = sc;
        System.debug('SC:'+sc);
        installationId = sc.getId();
        getInstallationlineItemsDetails();
        isLineItem = false;
        instObj = (Installation__c)sc.getRecord();
        System.debug('#instObj:'+instObj);
        instObjId = instObj.Id;
        System.debug('#instObjId:'+instObjId);
        instListObj = new List<Installation__c>();
        //List<Installation__c> instListObj1 = [Select id from Installation__c where Id =: instObjId];
        getInstallationDetails();
        getInstallationlineItemsDetails();
        this.instListObj = getInstallation();
        
    }
    
    
    public List<Schema.FieldSetMember> getFields(){
        if (ccRec == true){
            return SObjectType.Installation__c.FieldSets.CC_Field_Set.getFields();
        }else{
            return SObjectType.Installation__c.FieldSets.Installation_Field_Set.getFields();
        }
        
        
    }
    
    public List<Installation__c> getInstallation() {
        String query = 'SELECT '; 
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
            System.debug('#query1:'+query);
        }
        query += 'Id FROM Installation__c where Id =: instObjId limit :list_size offset :counter';
        System.debug('#query:'+query);
        return Database.query(query);
        
        
        
    }
    
    public void currentInstallation(){
        instListObj = new List<Installation__c>();
        instListObj = getInstallation();
        System.debug('#instListObj:'+instListObj);
    }
    
    public void getInstallationDetails(){
        System.debug('@Inside getInstallationDetails');
        ccRecordTypeId= Schema.SObjectType.Installation__c.getRecordTypeInfosByDeveloperName().get('Conveyor_Component').getRecordTypeId();
        System.debug('#ccRecordTypeId1:'+ccRecordTypeId);
        
        for (Installation__c objInst : [SELECT Id, Name, RecordTypeId,Conveyor_ID__c,Product_Description__c FROM Installation__c WHERE Id =: installationId]){
            if(objInst.RecordTypeId == ccRecordTypeId){
                ccRec = true;
                system.debug('#ccRec:'+ccRec);
            }else{
                nonCCRec = true;
                system.debug('#nonCCRec:'+nonCCRec);
            }
        }
    }
    
    public void getInstallationlineItemsDetails(){
        System.debug('installationId'+installationId);
        wrapperlst = new List<wrapperdetails>();
        
        
        List<Installation_line_Items__c> installationLineItemList = [SELECT Id, Name, Installation__r.Name,Installation__r.Conveyor_ID__c, Installation__r.Product_Description__c, Equipment_has_been_Installed_at__r.Name, Installation_Date__c, Item__c, Installed_Quantity__c, Who_has_installted__c, Referenced_Part_List__c, Other_Tega_Members_That_Attended__c, Part_List__c, Product__c, Installation_Montitored_at_Site__c, Supervisor_s_Name__c, Starting_Date_of_Job__c, 
                                                                     Ending_Date_of_Job__c, Comments__c, Installer_Company_Name__c, Number_of_Employees__c, Number_of_Shifts__c, Name_of_Supervisor_In_Charge__c, Supervisor_s_Phone__c, Supervisor_s_Email__c, Name_of_Safety_In_Charge__c, Safety_In_Charge_s_Phone__c, Safety_In_Charge_s_Email__c, Customer_Inventory_Line_Stock__c, Operating_Parameter__c, 
                                                                     Inspection_Comments__c FROM Installation_line_Items__c Where Installation__c =: installationId];
        
        
        
        if(installationLineItemList.size()>0){
            isLineItem = true;
            System.debug('#Size:'+isLineItem);
            for (Installation_line_Items__c instLine : installationLineItemList){
                wrapperDetails installationLineItemDetail = new wrapperDetails();
                installationLineItemDetail.installationName = instLine.Installation__r.Name;
                installationLineItemDetail.installationLineItem = instLine.Name;
                installationLineItemDetail.installationDate = instLine.Installation_Date__c;
                installationLineItemDetail.installedQuantity = instLine.Installed_Quantity__c;
                installationLineItemDetail.installedAt = instLine.Equipment_has_been_Installed_at__r.Name;
                installationLineItemDetail.startingDate = instLine.Starting_Date_of_Job__c;
                installationLineItemDetail.endingDate = instLine.Ending_Date_of_Job__c;
                wrapperlst.add(installationLineItemDetail);
            }
        }   
    }
    public class wrapperdetails{
        public String installationName{get;set;}
        public String installationLineItem{get;set;}
        public Date installationDate{get;set;}
        public Decimal installedQuantity{get;set;}
        public String installedAt{get;set;}
        public Date startingDate{get;set;}
        public Date endingDate{get;set;}
    }
}