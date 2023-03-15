public class AccountAll{

public list<Account> accountList{get;set;}

public AccountAll(){
 accountList = [select Id,name,Rating,industry from account limit 50];
 
}

}