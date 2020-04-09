public class OppPortfoliosController {
    
    @AuraEnabled(cacheable = true)
    public static List<Portfolio__c> getPortfoliosForOpp(String recordId){
        
        return [SELECT Id, RecordTypeId, Equity_Target__c, Bond_Target__c, Cash_Target__c, Registration_Type__c, Fee_Type__c, 
                Fee_Schedule__c, Discretionary__c, Billing_In__c, Proxy_Voting_by_Us__c, Revenue_Source__c, Custodian__c, Custodian__r.Id, 
                Custodian__r.Name, Custodian__r.CustodianUrl__c, ManagedNew__c, PortfolioUrl__c, Who_Receives_Reporting__c, Restricted_Data__c 
                FROM Portfolio__c WHERE Opportunity__c =: recordId];
    }

    @AuraEnabled
    public static void savePortfolios(List<Portfolio__c> records){

        if(!records.isEmpty()){
            update records;
        }
    }
}
