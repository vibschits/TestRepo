trigger AssociateEmail on EmailMessage (after insert) {
System.debug('===== emg  111 ==='); 
    for(EmailMessage eMsg : Trigger.new) {
       System.debug('===== emg==='+eMsg); 
       //eMsg.ParentId = '0017F00001LkUll';
    }

}