public class CustomSearchController {
    @AuraEnabled
    public static List<String> searchForIds(String searchText) {
    List<List<SObject>> results = [FIND :searchText IN ALL FIELDS  RETURNING Account(Name), Contact(Name), Lead(Name)];
    List<String> ids = new List<String>();
    for (List<SObject> sobjs : results) {
      for (SObject sobj : sobjs) {
        ids.add(sobj.Id);
      }
    }
    return ids;
}
}