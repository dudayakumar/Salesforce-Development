@isTest(seealldata=false)
public with sharing class AutoNumberReset_BatchTest {
    
    @isTest static void test_AutoNumberCustomSettingUpdated(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(Alias = 'tUser', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');

        AutoNumberSettings__c ans = new AutoNumberSettings__c(Name='Loan Number', Number__c=7);
        insert ans;
        
        Account acc = new Account();
        acc.Name = 'Test Acc'+dateString+randomInt;
        insert acc;

        Opportunity opp = new Opportunity();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Stronghill').getRecordTypeId();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+30;
        opp.StageName = 'Inquiry';
        insert opp;

        Test.startTest();
        //Annual batch on AutoNumberSettings__c 12:00 AM
        String sch5 = '00 00 00 1 1 ?';
        String jobID5 = system.schedule('Revenue Batch Job', sch5, new AutoNumberReset_Batch());
        Database.executeBatch(new AutoNumberReset_Batch(), 10);
        Test.stopTest();

        AutoNumberSettings__c updatedAnsRec = [SELECT Id, Number__c FROM AutoNumberSettings__c LIMIT 1];

        System.assertEquals(0, updatedAnsRec.Number__c, 'Custom setting is not updated');
    }
}
