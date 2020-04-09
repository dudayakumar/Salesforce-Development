public class OpportunityTriggerHandler {
    public static void populateLoanNumber(List<Opportunity> oppList) {

        AutoNumberSettings__c ansRec = new AutoNumberSettings__c();
        ansRec = [SELECT Id, Number__c FROM AutoNumberSettings__c LIMIT 1];

        Integer latestNumber = Integer.valueOf(ansRec.Number__c);
        String currentYear = String.valueOf(System.today().year()).Right(2);

        for(Opportunity opp: oppList){ 
            String currentOppLoanNumber = String.valueOf(latestNumber).leftPad(4,'0');
            opp.Loan_Number__c = (currentYear + currentOppLoanNumber).replace(',', '');
            latestNumber++;
        }

        ansRec.Number__c = latestNumber;
        update ansRec;
    }
}
