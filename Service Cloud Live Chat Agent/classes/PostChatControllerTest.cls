@isTest
public class PostChatControllerTest {
    
    public static testMethod void test_Case_is_Updated(){
        
        Id RecordTypeIdStoreContacts = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        Id RecordTypeIdCxGeneral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();

        Account accRec = new Account();
        accRec.LastName = 'Test Acc';
        insert accRec;

        Case caseRec = new Case();
        caseRec.RecordTypeId = RecordTypeIdCxGeneral;
        caseRec.Status = 'New';
        caseRec.Talkdesk_Number__c = '1234567890';
        insert caseRec;

        String attRec = '{"Account":"'+accRec.Id+'","CaseId":"'+caseRec.Id+'"}';

        Test.startTest();
            ApexPages.currentPage().getParameters().put('attachedRecords', attRec);
            PostChatController postChatController = new PostChatController();
            postChatController.updateCase();
        Test.stopTest();
    }
}
