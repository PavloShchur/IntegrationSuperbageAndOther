trigger ProjectTrigger on Project__c (after update) {
    
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        
        for(Project__c projectItem :Trigger.new) {
            
            if(projectItem.Status__c == 'Billable') {
                
                BillingCalloutService.callBillingService(
                    
                    projectItem.ProjectRef__c, 
                    projectItem.Billable_Amount__c
                    
                );
            }
            
            
            
        }
        
    }
    
    
    
}