public class LiveChatTranscriptService {
    
    /**                                                             
     *  Formats occurences of time information from chat body, sends email to visitors                     
     *  @param liveChatTranscriptList List of LiveChatTranscript                       
     */ 
    @InvocableMethod
    public static void customizeBody(List<Id> LiveChatTranscriptIds){

        List<LiveChatTranscript> liveChatTranscriptList = 
            [SELECT Id, Body, BodyCustom__c, StartTime, Timestamp__c, Owner.FirstName, Owner.LastName, Agent__c, Email__c, LogoURL__c 
            FROM LiveChatTranscript WHERE Id IN: LiveChatTranscriptIds];
        List<LiveChatTranscript> liveChatTranscriptListToUpdate = new List<LiveChatTranscript>();
        
        String sfInstance = System.URL.getSalesforceBaseUrl().getHost();
        Organization org = [SELECT Id FROM Organization];
        Document sajelogo = [SELECT id, Keywords FROM Document WHERE DeveloperName =: 'SajeLogo'];

        for(LiveChatTranscript lct: liveChatTranscriptList){

            //populate logoURL
            lct.LogoURL__c = 'https://'+sfInstance+'/servlet/servlet.ImageServer?id='+sajelogo.id+'&oid='+org.id;

            //timestamp customization - day, month date, year. hour:min am/pm timezone
            lct.Timestamp__c = lct.StartTime.format('EEEE, MMMM dd, yyyy. h:mm') 
                                + lct.StartTime.format('a').toLowerCase() 
                                + ' ' + lct.StartTime.format('z');

            //capture agent first name and first intial of last name
            lct.Agent__c = lct.Owner.FirstName + ' ' + lct.Owner.LastName.left(1);

            //copy body text into custom body field
            lct.BodyCustom__c = lct.Body;
            
            //split the chat body by new line
            List<String> splitBodyList = lct.BodyCustom__c.split('<br>');
            
            //initialize a list to capture time duration information to be deleted
            List<String> timeInfoList = new List<String>();

            Integer firstLine = 1;
            
            //iterate through each line of chat body
            for(String splitBody: splitBodyList){
                //capture the first occurrence of characters between () before first <br>
                if(firstLine == 1){
                    List<String> splitfirstLine = splitBody.split('</p>');
                    firstLine++;

                    for(String partFirstLine: splitfirstLine){
                        String stringBetweenBraces = partFirstLine.substringBetween('(', ')');
                        if((stringBetweenBraces != null) && (stringBetweenBraces.contains('m') || stringBetweenBraces.contains('s'))){
                            timeInfoList.add(stringBetweenBraces);
                            break;
                        }
                        //remove first three lines before actual chat
                        else
                            lct.BodyCustom__c = lct.BodyCustom__c.replace(partFirstLine+'</p>','');
                    }
                }

                //capture the first occurrence of characters between ()
                else {
                    String stringBetweenBraces = splitBody.substringBetween('(', ')');
                    if((stringBetweenBraces != null) && (stringBetweenBraces.contains('m') || stringBetweenBraces.contains('s'))){
                        timeInfoList.add(stringBetweenBraces);
                    }
                }
            }
            
            //iterate through the timeInfo list and replace the time information on the chat body(custom) with formatted time
            for(String timeInfo: timeInfoList){
                String formattedChatTime = getChatDuration(lct.StartTime, timeInfo);//'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'+
            	lct.BodyCustom__c = lct.BodyCustom__c.replace('('+timeInfo+')', formattedChatTime);
            }

            liveChatTranscriptListToUpdate.add(lct);
        }

        if(!liveChatTranscriptListToUpdate.isEmpty())
            update liveChatTranscriptListToUpdate;

        //send email
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject FROM EmailTemplate where DeveloperName = 'LiveChatTranscriptEmail'];
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress where Address = 'dummyemail.saje@gmail.com'];
        Messaging.SingleEmailMessage [] emailsForVisitors = new Messaging.SingleEmailMessage[]{};

        for(LiveChatTranscript lct: [SELECT Id, ContactId, BodyCustom__c, Timestamp__c, Agent__c, Email__c 
            FROM LiveChatTranscript WHERE Id IN: LiveChatTranscriptIds]){

            String userEmail = lct.Email__c;
            Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(lstEmailTemplates[0].Id, lct.ContactId, lct.Id);
            
            if(owea != Null){
                mail.setOrgWideEmailAddressId(owea.Id);
            }
            mail.setToAddresses(new list<string>{userEmail});
            emailsForVisitors.add(mail);
        }

        if(!emailsForVisitors.isEmpty()){
            Messaging.sendEmail(emailsForVisitors);
        }
    }

    //get each chat duration in seconds
    public static String getChatDuration(DateTime startTime, String timeInfo){
        List<String> timeDetailList = timeInfo.split(' ');
        Integer totalDurationInSeconds = 0;
        DateTime chatTime;
        String formattedChatTime = '';

        for(String timeDetail: timeDetailList){
            if(timeDetail.contains('h')){
                timeDetail = timeDetail.replace(' ', '');
                timeDetail = timeDetail.replace('h', '');
                totalDurationInSeconds += Integer.valueOf(timeDetail) * 60 * 60;
            }
            else if(timeDetail.contains('m')){
                timeDetail = timeDetail.replace(' ', '');
                timeDetail = timeDetail.replace('m', '');
                totalDurationInSeconds += Integer.valueOf(timeDetail) * 60;
            }
            else if(timeDetail.contains('s')){
                timeDetail = timeDetail.replace(' ', '');
                timeDetail = timeDetail.replace('s', '');
                totalDurationInSeconds += Integer.valueOf(timeDetail);
            }
        }

        chatTime = startTime.addSeconds(totalDurationInSeconds);
        formattedChatTime = '['+chatTime.format('h:mma').toLowerCase()+']';

        return formattedChatTime;
    }
}