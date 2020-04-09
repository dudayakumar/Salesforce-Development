@isTest
public class OppPortfoliosControllerTest {

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
        
        Account custodian = new Account();
        custodian.Name = 'Test Custodian'+dateString+randomInt;
        custodian.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Custodian').getRecordTypeId();
        custodian.Household_Type__c = 'Active';
        insert custodian;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = custodian.Id;
        opp.CloseDate = System.today()+3;
        opp.StageName = 'Proposal';
        opp.Discretionary__c = 'Yes';
        opp.Revenue_Source__c = 'Chioffi';
        opp.Proxy_Voting_by_Us__c = 'Yes';
        opp.Billing_In__c = 'Arrears';
        opp.Custodian__c = custodian.Id;
        opp.Counselor__c = u.Id;
        insert opp;
        
        Portfolio__c portfolio = new Portfolio__c();
        portfolio.Equity_Target__c = 10;
        portfolio.Bond_Target__c = 80;
        portfolio.Cash_Target__c = 10;
        portfolio.RecordTypeId = Schema.SObjectType.Portfolio__c.getRecordTypeInfosByName().get('New Account').getRecordTypeId();
        portfolio.Request__c = 'Test Request';
        portfolio.Name = 'Test Portfolio';
        portfolio.Fee_Type__c = 'Pro bono' ;
        portfolio.Fee_Schedule__c = 'Monthly';
        portfolio.Discretionary__c = 'Yes';
        portfolio.ManagedNew__c = 'Retail';
        portfolio.Estimated_Value__c = 123;
        portfolio.Billing_In__c = 'Arrears';
        portfolio.Proxy_Voting_by_Us__c = 'Yes';
        portfolio.Revenue_Source__c = 'Chioffi';
        portfolio.Counselor__c = u.Id;
        portfolio.Portfolio_Manager__c = u.Id;
        portfolio.HouseholdFirm__c = custodian.Id;
        portfolio.Custodian__c = custodian.Id;
        portfolio.Opportunity__c = opp.Id;
        insert portfolio;
    }
    
    @isTest static void test_portfolios_returned_for_given_opportunityId(){

        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        List<Portfolio__c> portfolioList = new List<Portfolio__c>();

        Test.startTest();
        portfolioList = OppPortfoliosController.getPortfoliosForOpp(String.valueOf(opp.Id));
        Test.stopTest();

        System.assertEquals(1, portfolioList.size(), 'Error in returning portfolios');
    }

    @isTest static void test_portfolio_updated(){

        Portfolio__c portfolio = [SELECT Id, Request__c FROM Portfolio__c WHERE Name = 'Test Portfolio' LIMIT 1];

        portfolio.Request__c = 'Test New Request';
        List<Portfolio__c> portfolioList = new List<Portfolio__c>();
        portfolioList.add(portfolio);

        Test.startTest();
        OppPortfoliosController.savePortfolios(portfolioList);
        Test.stopTest();

        Portfolio__c updatedPortfolio = [SELECT Id, Request__c FROM Portfolio__c WHERE Name = 'Test Portfolio' LIMIT 1];

        System.assertEquals('Test New Request', updatedPortfolio.Request__c, 'Error in updating portfolios');
    }
}
