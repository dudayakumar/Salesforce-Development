public without sharing class PostChatController {
	
    public String attRec {get; set;}
    public Id caseId {get;set;}
    public Case caseRec {get;set;}
    
    /**
     * constructor reads the VF page attachedRecords parameter and parses it to obtain case id
     * @param none
     */
	public PostChatController(){
        if(ApexPages.currentPage().getParameters().get('attachedRecords') != null){
            attRec = ApexPages.currentPage().getParameters().get('attachedRecords');

            JSONParser parser = JSON.createParser(attRec);
            parser.nextToken();
            parser.nextValue();
            parser.nextToken();
            parser.nextValue();

            caseId = parser.getIdValue();

            caseRec = [SELECT Id, ChatTranscriptRequested__c FROM Case WHERE Id =: caseId];
        }
    }

	/**
     * method to update case record corresponding to the chat transcript with Chat Transcript Requested = true
     * @param none
     */   
    public void updateCase(){
        if(caseRec != null){
            caseRec.ChatTranscriptRequested__c = true;
            update caseRec;
        }
    }
}