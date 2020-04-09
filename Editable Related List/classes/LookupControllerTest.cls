@isTest
public class LookupControllerTest {
    
    @testSetup static void testDataSetUp(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(Alias = 'tUser', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');
        
        Account custodian1 = new Account();
        custodian1.Name = 'Test Custodian1';
        custodian1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        custodian1.Household_Type__c = 'Active';
        insert custodian1;

        Account custodian2 = new Account();
        custodian2.Name = 'Some other random custodian';
        custodian2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        custodian2.Household_Type__c = 'Active';
        insert custodian2;

        Account custodian3 = new Account();
        custodian3.Name = 'Some custodian who is happy';
        custodian3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        custodian3.Household_Type__c = 'Active';
        insert custodian3;
    }

    @isTest static void test_lookup_values_returned(){
        
        List<Account> accSearchList1 = new List<Account>();
        List<Account> accSearchList2 = new List<Account>();
        List<Account> accSearchList3 = new List<Account>();

        Test.startTest();
        accSearchList1 = LookupController.lookUp('Test', 'Account');
        accSearchList2 = LookupController.lookUp('Some', 'Account');
        accSearchList3 = LookupController.lookUp('', 'Account');
        Test.stopTest();
        
        System.assertEquals(1, accSearchList1.size(), 'Incorrect custodian search');
        System.assertEquals(2, accSearchList2.size(), 'Incorrect custodian search');
        System.assertEquals(3, accSearchList3.size(), 'Incorrect custodian search');
    }
}