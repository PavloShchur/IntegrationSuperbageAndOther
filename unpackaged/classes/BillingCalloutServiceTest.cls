@isTest
private class BillingCalloutServiceTest {
    
    @testSetup static void setupProject(){
        
        Opportunity oppo = new Opportunity(
            Name = 'TestOpp',
            CloseDate = Date.today(),
            StageName = 'Prospecting'
        );
        
        insert oppo;
        
        Project__c proj = new Project__c(
            Name = 'TestProj',
            Billable_Amount__c = 1000,       
            ProjectRef__c = 'TestRef',
            Status__c = 'Running',
            Opportunity__c = oppo.Id
        );
        
        
        insert proj;
        
        ServiceCredentials__c serviceCredentials = new ServiceCredentials__c(
            
            Name = 'BillingServiceCredential',
            Username__c = 'user1',
            Password__c = 'pass1'
        );
        
        insert serviceCredentials;
        
    }
    
    @isTest static void testCalloutSuccess(){
        
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMock()); 
        
        List<Project__c> prof = [SELECT Status__C 
                                 FROM Project__c 
                                 WHERE ProjectRef__c = 'TestRef'];
        
        System.assertEquals(1, prof.size());
        
        Test.startTest(); 
        
        prof[0].Status__c = 'Billable';
        
        update prof;
        
        Test.stopTest();
        
        prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        
        System.assertEquals(1, prof.size());   
        
        System.assertEquals('Billed', prof[0].Status__C);
    }
    
    @isTest static void testCalloutFailure(){
        
        Test.setMock(WebServiceMock.class, new BillingCalloutServiceMockFailure()); 
        List<Project__c> prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        System.assertEquals(1, prof.size());
        Test.startTest(); 
        prof[0].Status__c = 'Running';
        update prof;
        Test.stopTest();
        prof = [SELECT Status__C FROM Project__c WHERE ProjectRef__c = 'TestRef'];
        System.assertEquals(1, prof.size());   
        System.assertEquals('Running', prof[0].Status__C);
    }
    
}