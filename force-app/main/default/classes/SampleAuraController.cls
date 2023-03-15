public class SampleAuraController {
/*
    @AuraEnabled
     public static List < String > getselectOptions() {
      List < String > allOpts = new list < String > ();
      List<Group> groupList = new list<Group>();
      groupList = [select Name from Group];
      for(Group grp : groupList){
          allOpts.add(grp.name);
      }
      allOpts.sort();
      return allOpts;
     }
  */   
    @AuraEnabled
    public static String getUserslistValues(String groupName) {
    GroupMemberShip groupMembershipObj = new GroupMemberShip();
       set<id> gids =new set<id>();
        for(GroupMember  g :[SELECT Group.Name,UserOrGroupId FROM GroupMember WHERE Group.Name =:groupName]){
            gids.add(g.UserOrGroupId);
        }
     
        for(User avilableUser : [SELECT id, Name FROM User where IsActive = true AND id NOT IN:gids AND Name!='Chatter Expert' order by Name Asc]){
         groupMembershipObj.avilableUsers.add(avilableUser.Name);
        } 
        for(User selectedUser : [SELECT id, Name FROM User where IsActive = true AND id IN:gids AND Name!='Chatter Expert' order by Name Asc]){
         groupMembershipObj.selectedUsers.add(selectedUser.Name);
         groupMembershipObj.avilableUsers.add(selectedUser.Name);
        }
        return JSON.serialize(groupMembershipObj);
    }
     @AuraEnabled
    public static String getGrouplistValues(String userId) {
    UserMemberShip userMembershipObj = new userMemberShip();
        set<id> gids =new set<id>();
        for(GroupMember g: [SELECT Group.Name,UserOrGroupId,Group.Id FROM GroupMember WHERE UserOrGroupId =:userId]){
            gids.add(g.Group.Id);
        }

        for(Group avilableGrp :  [SELECT id, Name FROM Group where Name!='' AND Type = 'Regular' AND id NOT IN:gids order by Name Asc]){
         userMembershipObj.avilableGroups.add(avilableGrp.Name);
        } 
        for(Group selectedGrp : [SELECT id, Name FROM Group where  id IN:gids  order by Name Asc]){
         userMembershipObj.selectedGroups.add(selectedGrp.Name);
         userMembershipObj.avilableGroups.add(selectedGrp.Name);
        }

        return JSON.serialize(userMembershipObj);
    }
    @AuraEnabled
    public static list<String> updateMembershipConByGroupName(list<String> selectedRecords,String groupName) {  
      Set<String> selectedRecordsSet = new Set<String>(selectedRecords);
      list<String> existingUserIdSet = new list<String>();
      Set<String> existingUserNames = new Set<String>();
      for(GroupMember gm : [SELECT Group.Name,UserOrGroupId,Group.Id FROM GroupMember WHERE Group.Name=:groupName]){
        existingUserIdSet.add(gm.UserOrGroupId);
      }
      if(existingUserIdSet.size() > 0){    
          for(User usr : [SELECT id, Name FROM User where IsActive = true AND id IN:existingUserIdSet AND Name!='Chatter Expert' order by Name Asc]){
              existingUserNames.add(usr.Name);
          }
      }
      if(selectedRecords.size() > 0){
         selectedRecordsSet.removeAll(existingUserNames);   
         updateUsersMembership(selectedRecordsSet,'insert',groupName);  
      }
      if(existingUserNames.size() > 0)
      {
          selectedRecordsSet = new Set<String>(selectedRecords);
          existingUserNames.removeAll(selectedRecordsSet);
          updateUsersMembership(existingUserNames,'delete',groupName);
      }
      //  
      return new list<String>(selectedRecordsSet);
    }
     @AuraEnabled
    public static list<String> updateMembershipConByUserName(list<String> selectedRecords,String UserId) {
      Set<String> existingGroupNames = new Set<String>();
      Set<String> selectedRecordsSet = new Set<String>(selectedRecords);
      list<GroupMember> existingGroupMemberList = new list<GroupMember>();
      for(GroupMember gm :[select group.name from GroupMember where UserOrGroupId=:UserId]){
       existingGroupNames.add(gm.Group.Name);
      }
      if(selectedRecordsSet.size() > 0){
         selectedRecordsSet.removeAll(existingGroupNames);   
         updateGroupsMembership(selectedRecordsSet,'insert',UserId);  
      }
       if(existingGroupNames.size() > 0)
      {
          selectedRecordsSet = new Set<String>(selectedRecords);
          existingGroupNames.removeAll(selectedRecordsSet); 
          updateGroupsMembership(existingGroupNames,'delete',UserId);
      }
      return new list<String>(selectedRecordsSet);
    }
    public static void updateGroupsMembership(Set<String> selectedRecords,String operation,String UserId){
    list<GroupMember> insertGroupMembership = new list<GroupMember>();
    list<GroupMember> deleteGroupMembership = new list<GroupMember>();
    set<String> auditLogDetails = new set<String>();
    Map<Id,Group> groupMap = new Map<Id,Group>([select Id,Name from group where name in: selectedRecords]);  
      if(operation == 'delete'){
        for(GroupMember gm : [select Id,Group.Name,UserOrGroupId,Group.Id FROM GroupMember where Group.Name in: selectedRecords and UserOrGroupId = :UserId]){
            auditLogDetails.add(String.valueOf(gm.UserOrGroupId)+'-'+gm.Group.Name);
            deleteGroupMembership.add(gm);
        }
        delete deleteGroupMembership;
        insertAuditLogs('delete',auditLogDetails);
      }  
      auditLogDetails = new Set<String>();   
      if(operation == 'insert'){
       for(Id gId : groupMap.keySet()){
         GroupMember gm = new GroupMember(groupId=gId,UserOrGroupId=UserId);
         insertGroupMembership.add(gm);
       }
         
          if(insertGroupMembership.size() > 0){        
             insert insertGroupMembership;
             for(GroupMember gm : insertGroupMembership){
                 auditLogDetails.add(String.valueOf(gm.UserOrGroupId)+'-'+groupMap.get(gm.GroupId).Name);
             }
             insertAuditLogs('insert',auditLogDetails);            
          }   
      }
    }
    
    public static void updateUsersMembership(Set<String> selectedRecords,String operation,String groupName){
    list<GroupMember> insertGroupMembership = new list<GroupMember>();
 
      map<Id,User> userMap = new map<Id,User>([select Id from user where name in :selectedRecords]);
      list<Group> selectedGroup = new list<Group>([select Id,Name from Group where name=:groupName]);
      list<GroupMember> deleteGroupMembership = new list<GroupMember>();
      set<String> auditLogDetails = new set<String>();
      if(operation == 'delete'){
          for(GroupMember gm : [select Id,Group.Name,UserOrGroupId,Group.Id FROM GroupMember where Group.Name=:groupName and UserOrGroupId in:userMap.keyset()]){
            auditLogDetails.add(String.valueOf(gm.UserOrGroupId)+'-'+gm.Group.Name);
            deleteGroupMembership.add(gm);
          }
          delete deleteGroupMembership;
          insertAuditLogs('delete',auditLogDetails);        
      }
      auditLogDetails = new Set<String>();
      if(operation == 'insert'){
      
          for(User newMembership : userMap.values()){
             GroupMember gm = new GroupMember(groupId=selectedGroup[0].Id,UserOrGroupId=newMembership.Id);
             insertGroupMembership.add(gm); 
          }
          if(insertGroupMembership.size() > 0){            
             insert insertGroupMembership;
             for(GroupMember gm : insertGroupMembership){
               auditLogDetails.add(String.valueOf(gm.UserOrGroupId)+'-'+groupName);
             }
             insertAuditLogs('insert',auditLogDetails); 
          }   
      }
            
    }
    @future
    public static void insertAuditLogs(String operation,Set<String> auditLogDetails){
        
        list<BPG_GroupMembership_Audit_logs__c> auditLogList = new list<BPG_GroupMembership_Audit_logs__c>(); 
        for(String auditDetail : auditLogDetails){
           BPG_GroupMembership_Audit_logs__c auditLog = new BPG_GroupMembership_Audit_logs__c();
             if(auditDetail.contains('-')){              
               auditLog.BPG_User_Id__c = auditDetail.split('-')[0];
               auditLog.BPG_Operation_Name__c = operation;
               auditLog.BPG_Group_Name__c = auditDetail.split('-')[1];
               auditLogList.add(auditLog);   
              }        
        }
        if(auditLogList.size() > 0)
            insert auditLogList;
    
    }
    public class GroupMemberShip{
        List<String> avilableUsers;
        List<String> selectedUsers;
        GroupMemberShip(){
        this.avilableUsers = new List<String>();
        this.selectedUsers = new List<String>();
        }
    }
    public class UserMemberShip{
        List<String> avilableGroups;
        List<String> selectedGroups;
        UserMemberShip(){
        this.avilableGroups = new List<String>();
        this.selectedGroups = new List<String>();
        }
    }
}