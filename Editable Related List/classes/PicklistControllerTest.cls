@isTest
public class PicklistControllerTest {

    @isTest static void test_lookup_values_returned(){
        
        List<Map<String, String>> pickListValues = new List<Map<String, String>>();

        Test.startTest();
        pickListValues = PicklistController.getPickListValues('Portfoilio__c', 'Revenue_Source__c');
        Test.stopTest();

        System.debug('****options'+pickListValues);
    }
}
