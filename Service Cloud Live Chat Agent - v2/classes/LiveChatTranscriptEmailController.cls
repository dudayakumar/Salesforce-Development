public class LiveChatTranscriptEmailController {
    
    public Id cId {get;set;}
    private LiveChatTranscript lct;
    private String agent;
    private String logoUrl;
    private String bodyCustom;
    public String timeStamp{
        get{
            if (timeStamp == null) {
                timeStamp = processBody();
            }
            return timeStamp;
        }
        private set;
    }

    /**                                                             
     *  Returns agent first name and first initial of last name - formatted in processBody()                 
     *  @param none                      
     */
    public String getAgent(){
        return agent;
    }

    /**                                                             
     *  Returns custom chat body - formatted in processBody()                    
     *  @param none                      
     */
    public String getBodyCustom(){
        return bodyCustom;
    }

    /**                                                             
     *  Gets URL of Saje logo from documents                    
     *  @param none                      
     */ 
    public String getLogoUrl(){
        
        String sfInstance = System.URL.getSalesforceBaseUrl().getHost();
        Organization org = [SELECT Id FROM Organization];
        Document sajelogo = [SELECT id, Keywords FROM Document WHERE DeveloperName =: 'SajeLogo'];

        //populate logoURL
        logoUrl = 'https://'+sfInstance+'/servlet/servlet.ImageServer?id='+sajelogo.id+'&oid='+org.id;

        return logoUrl;
    }

    // constructor
    public LiveChatTranscriptEmailController() {}

    /**                                                             
     *  Formats occurences of time information on chat body, generates time stamp from start time                    
     *  @param none                      
     */ 
    public String processBody(){

        // LiveChatTranscript lct = new LiveChatTranscript();
        lct = [SELECT Id, Body, StartTime, Owner.FirstName, Owner.LastName 
                                    FROM LiveChatTranscript WHERE Id =: cId];

        //timestamp customization - day, month date, year. hour:min am/pm timezone
        timeStamp = lct.StartTime.format('EEEE, MMMM dd, yyyy. h:mm') 
                            + lct.StartTime.format('a').toLowerCase() 
                            + ' ' + lct.StartTime.format('z');

        //capture agent first name and first intial of last name
        agent = lct.Owner.FirstName + ' ' + lct.Owner.LastName.left(1);

        //copy body text into custom body field
        bodyCustom = lct.Body;
        
        //split the chat body by new line
        List<String> splitBodyList = bodyCustom.split('<br>');
        
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
                        bodyCustom = bodyCustom.replace(partFirstLine+'</p>','');
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
            bodyCustom = bodyCustom.replace('('+timeInfo+')', formattedChatTime);
        }

        return timeStamp;
    }

    /**                                                             
     *  Gets each chat duration in seconds                    
     *  @param DateTime: Start time of chat, String: Time duration of each chat                      
     */ 
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