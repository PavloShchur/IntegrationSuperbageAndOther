@isTest
private class ProjectCalloutServiceTest {
    
    @testSetup static void testSetupData(){
        
        
        Opportunity opp_1 = new Opportunity(
        
        Name = 'Test Opp1',
        Type = 'New Project',
        Amount = 100,
        CloseDate = Date.today(),
        StageName = 'Submitted Project' 
        ); 
            
        insert opp_1 ;
        
        Opportunity opp_2 = new Opportunity(
        
        Name = 'Test Opp2',
        Type = 'New Project',
        Amount = 200,
        CloseDate = Date.today(),
        StageName = 'Resubmit Project' 
        );  
        
        insert opp_2;    
                          
            
        ServiceTokens__c servToken = new ServiceTokens__c();
        servToken.Name = 'ProjectServiceToken';
        servToken.Token__c = 'XXXXXXXX';
        
        insert servToken;
    }
    
    
    @isTest
    static void testSuccessMessage(){
        Opportunity opp = [Select Id, Name 
                           FROM Opportunity 
                           WHERE Name = 'Test Opp1'];
                           
        List<Id> ids = new List<id>();
        ids.add(opp.Id);
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());

        Test.startTest();
        
        ProjectCalloutService.postOpportunityToPMS(ids);
        
        Test.stopTest(); 
        
        System.assertEquals('Submitted Project', [SELECT StageName 
                                                     FROM Opportunity 
                                                     WHERE id =: opp.Id].StageName); 
        
    }
    
    @isTest
    static void testFailureMessage(){
        Opportunity opp = [Select Id, Name FROM Opportunity WHERE Name = 'Test Opp2' Limit 1];
        
        List<Id> ids = new List<id>();
        ids.add(opp.Id);
        
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMockFailure());

        Test.startTest();
        
        ProjectCalloutService.postOpportunityToPMS(ids);
        
        Test.stopTest();    

        System.assertEquals('Resubmit Project', [SELECT StageName 
                                                     FROM Opportunity 
                                                     WHERE id =: opp.Id].StageName);
    }
    
    
    
}