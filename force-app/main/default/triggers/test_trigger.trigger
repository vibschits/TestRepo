trigger test_trigger on Test__e (after insert) {
list<Contact> conList = new list<Contact>();
    for(Test__e t : Trigger.new){
        contact con = new Contact();
        con.LastName = 'conLast name';
        conList.add(con);
    }
    insert conList;
}