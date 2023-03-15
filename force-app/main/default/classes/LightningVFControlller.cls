public class LightningVFControlller{
   public static string lightningDomain;
    @AuraEnabled
    public static String getVisualforceDomain(){
        return getMyDomain() + '--c.' + getInstance() + '.visual.force.com';
    }

    public static String getLightningDomain(){
        lightningDomain =  getMyDomain() + '.lightning.force.com';
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