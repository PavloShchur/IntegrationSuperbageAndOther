@isTest
private class ProjectRESTServiceTest {
    
    @testSetup static void setup() {
        
        Account account = new Account(
            
            Name = 'TestAccount'
            
        );
        
        insert account;
                
        Opportunity oppt_1 = new Opportunity(
            
            Name = 'Test Opportunity',
            
            AccountId = account.id,
            
            CloseDate = System.Today().addDays(5),
            
            Amount = 15000.00,
            
            Type = 'New Project',
            
            StageName='Qualification'
            
        );
        
        
        Opportunity oppt_2 = new Opportunity(
            
            Name = 'Test Opportunity',
            
            AccountId = account.id,
            
            CloseDate = System.Today().addDays(-5),
            
            Amount = 25000.00,
            
            Type = 'New Project',
            
            StageName='Qualification'
            
        );
        
        insert new List<Opportunity> {
            
            oppt_1,
            oppt_2
        };

        
    }
    
    
    @isTest static void postProjectDataSuccess() {
        
        Opportunity opportunity = [SELECT Id, CloseDate, Amount, Type
                                   FROM Opportunity 
                                   WHERE  Amount = 15000.00];
        
        Test.startTest();
        
        String httpResponse = ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', 
                                                                 opportunity.Id, opportunity.CloseDate, 
                                                                 opportunity.CloseDate, Double.valueOf(opportunity.Amount), 'Billable');
        
        Test.stopTest();
        
        System.assertEquals('OK', httpResponse);
        
    }
    
    @isTest static void postProjectDataFailure() {
        
        Opportunity opportunity = [SELECT Id, CloseDate, Amount, Type
                                   FROM Opportunity 
                                   WHERE  Amount = 25000.00];
        
        Test.startTest();
                
        String httpResponse = ProjectRESTService.postProjectData('ProjectRef', 'ProjectName', 
                                                                 opportunity.Id, opportunity.CloseDate, 
                                                                 opportunity.CloseDate, 
                                                                 Double.valueOf(opportunity.Amount), 'NotExistingStatus');
        
        Test.stopTest();
        
        System.assertEquals('Upsert failed', httpResponse);
        
    }
    
}