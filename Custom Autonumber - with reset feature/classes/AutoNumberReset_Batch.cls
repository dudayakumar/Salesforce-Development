global class AutoNumberReset_Batch implements Database.Batchable<sObject>, Schedulable {
   
    global void execute(SchedulableContext context) {
        Database.executeBatch(new AutoNumberReset_Batch(), 10);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Number__c FROM AutoNumberSettings__c]);
    }

    global void execute(Database.BatchableContext bc, List<AutoNumberSettings__c> ansList){

        ansList[0].Number__c = 0;
        update ansList;
    }

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}
