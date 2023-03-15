/**
* @author      :   Rahul Chitkara(TCS)
* @Description :   Apex controller for BPG AppInsight component. This Controller is used to return Domain URL. 
* @CreatedDate :   23th October 2019
**/
public without sharing class BPG_appInsightControlller{
   public static string lightningDomain;
   @AuraEnabled
    public static String getVisualforceDomain(){
        
        return getMyDomain() + '--c.' +  + 'visualforce.com';
        //return getMyDomain() + '--c.' + getInstance() + '.visual.force.com';

    }

    public static String getLightningDomain(){
        lightningDomain = 'https://'+ getMyDomain() + '.lightning.force.com';
        return lightningDomain;
    }

    public static String getMyDomain(){
        return URL.getOrgDomainUrl().getHost().split('\\.')[0].toLowerCase();
    }

    private static String instance = '';

    public static String getInstance(){
        if(String.isBlank(instance)){
            instance = [SELECT InstanceName FROM Organization LIMIT 1].InstanceName.toLowerCase();
        }
        return instance;
    }


}