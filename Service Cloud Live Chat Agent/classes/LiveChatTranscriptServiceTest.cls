/**                                                             
 *  This is a test class for LiveChatTranscriptService class                                            
 */
@isTest(SeeAllData = true)
public class LiveChatTranscriptServiceTest {
     
    public static testMethod void test_customizeBody_for_correctBodyFormat() {

        List<Id> liveChatTranscriptIds = new List<Id>();

        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript lct = new LiveChatTranscript();
        lct.Body = '<p align="center">Chat Started: Wednesday, March 17, 2020, 12:07:00 (+0000)</p><p align="center">Chat Origin: Chat Agents</p><p align="center">Agent Shobhit A</p>( 1m 13s ) Shobhit A: Hello, qwe! One moment while I review your inquiry, please.<br>( 1h 1m 15s ) qwe: hi<br>';
        lct.LiveChatVisitorId = lcv.Id;
        lct.Email__c = 'projects@accelerize360.com';
        lct.StartTime = datetime.newInstance(2020, 03, 17, 12, 07, 0);
        insert lct;

        liveChatTranscriptIds.add(lct.Id);

        Test.startTest();
        LiveChatTranscriptService.customizeBody(LiveChatTranscriptIds);
        Test.stopTest();

        List<LiveChatTranscript> lctList = [SELECT Id, BodyCustom__c FROM LiveChatTranscript WHERE Id IN: liveChatTranscriptIds];
        System.assertEquals('[12:08pm] Shobhit A: Hello, qwe! One moment while I review your inquiry, please.<br>[1:08pm] qwe: hi<br>', lctList[0].BodyCustom__c, 'CustomBody is incorrect');
    }

    public static testMethod void test_getChatDuration_for_correctTimeFormat(){
        DateTime startTime = datetime.newInstance(2020, 03, 17, 12, 07, 0);
        String timeInfo = '1h 2m 49s';

        String formattedTime = LiveChatTranscriptService.getChatDuration(startTime, timeInfo);

        System.assertEquals('[1:09pm]', formattedTime);
    }
}