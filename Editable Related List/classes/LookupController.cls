public class LookupController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> lookUp(String searchTerm, string myObject) {
        String myQuery = null;
        Id custodianRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();

        if(searchTerm == null || searchTerm == ''){
            myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL AND RecordTypeId = \''+custodianRecTypeId+'\' ORDER BY LastViewedDate DESC LIMIT  5'; 
        }
        else {
            myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND RecordTypeId = \''+custodianRecTypeId+'\' LIMIT  5 ';
        }
        
        List<sObject> lookUpList = database.query(myQuery);

        return lookUpList;  
    }
}