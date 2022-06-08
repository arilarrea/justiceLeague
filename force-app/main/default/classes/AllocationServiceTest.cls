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
    
     private static void test2() {
        //se genera la data
        generateProjectData();
         
         // se llama el metodo
        Test.startTest();
        	//List <User> userTested = AllocationService.getResourcesByRole(userRole);
        Test.stopTest();
         
         // assert
        
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
    
    private static void generateProjectData(){
        //  Crear Un client
        //  Crear usuario
        //  Crear una opportunidad
        //  Crear un opportunity line item
        //  Crear un project
        //  Crear project lINE iTEM
    }
}