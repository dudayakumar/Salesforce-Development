@isTest(seealldata=false)
public with sharing class OpportunityTriggerHandlerTest {
    
    @isTest static void test_LoanNumberPopulated(){

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

        Test.startTest();
        insert opp;
        Test.stopTest();

        String currentYear = String.valueOf(System.today().year()).Right(2);
        Opportunity updatedOpp = [SELECT Id, Loan_Number__c FROM Opportunity LIMIT 1];
        AutoNumberSettings__c updatedAnsRec = [SELECT Id, Number__c FROM AutoNumberSettings__c LIMIT 1];

        System.assertEquals(currentYear + '0007', updatedOpp.Loan_Number__c, 'Loan number is not populated');
        System.assertEquals(8, updatedAnsRec.Number__c, 'Custom setting did not update');
    }

    @isTest static void test_LoanNumberPopulated_ForMultipleOppRecs(){

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User u = new User(Alias = 'tUser', Email=uniqueName + '@test' + orgId + '.org', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');

        AutoNumberSettings__c ans = new AutoNumberSettings__c(Name='Loan Number', Number__c=0);
        insert ans;            
        
        Account acc = new Account();
        acc.Name = 'Test Acc'+dateString+randomInt;
        insert acc;

        List<Opportunity> oppList = new List<Opportunity>();
        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Stronghill').getRecordTypeId();

        for(Integer i = 0; i < 200; i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opportunity'+i;
            opp.RecordTypeId = oppRecTypeId;
            opp.AccountId = acc.Id;
            opp.CloseDate = System.today()+30+i;
            opp.StageName = 'Inquiry';
            oppList.add(opp);
        }

        Test.startTest();
        insert oppList;
        Test.stopTest();

        String currentYear = String.valueOf(System.today().year()).Right(2);
        List<Opportunity> insertedOppList = [SELECT Id, Loan_Number__c FROM Opportunity];
        AutoNumberSettings__c updatedAnsRec = [SELECT Id, Number__c FROM AutoNumberSettings__c LIMIT 1];

        for(Integer i = 0; i < 200; i++){
            System.assertEquals(currentYear + String.valueOf(i).leftPad(4,'0'), insertedOppList[i].Loan_Number__c, 'Loan number is not populated');
        }
        System.assertEquals(200, updatedAnsRec.Number__c, 'Custom setting did not update');
    }
}
