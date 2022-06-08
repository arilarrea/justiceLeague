@isTest
public with sharing class AllocationServiceTest {
    @isTest
    private static void test1() {
        
        String userRole = 'Developer';
        generateUser();
        Test.startTest();
        	List <User> userTested = AllocationService.getResourcesByRole(userRole);
        Test.stopTest();
        System.debug('users ->' + userTested);
        System.assert(userTested != null);
        System.assertEquals('Developer', userTested[0].Role__c);
    }
    
    @isTest
    private static void generateUser(){
        // Info del usuario
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Perez', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, Role__c = 'Developer',
            TimeZoneSidKey='America/Los_Angeles', UserName='standarU@testorg.com');

        insert u;
    }
    
    
}