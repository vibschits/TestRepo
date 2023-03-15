public class UploadAccountfromLEX {
    
    @AuraEnabled
    public static string insertData(String strfromlex)
    {
        String returnresponse ='';
        List<Account> AccoutnListtoInsert = new List<Account>();
        system.debug('@@@ strfromlex = ' + strfromlex);
        List<fieldWrapper> datalist = (List<fieldWrapper>) JSON.deserialize(strfromlex, List<fieldWrapper>.class);
        system.debug('@@@ datalist = ' + datalist);
        system.debug('@@@ datalistSize = ' + datalist.size());
        for(fieldWrapper wrapper: datalist)
        {
            Account acc =new  Account();
            acc.Name = wrapper.company;
            acc.Description = wrapper.Description;
            acc.Phone = wrapper.phone;
            AccoutnListtoInsert.add(acc);
        }
        if(AccoutnListtoInsert.size() > 0)
        {
            try {
                insert AccoutnListtoInsert;
                returnresponse = 'SUCCESS';
            }
            catch(Exception ex)
            {
                returnresponse = 'ERROR';
            }
        }
        return returnresponse;
    }
  
    public class fieldWrapper {

    public String Company;
        
    public String Description;

    public String phone;

  } 
}