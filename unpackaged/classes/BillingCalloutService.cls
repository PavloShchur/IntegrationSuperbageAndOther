public class BillingCalloutService {
    
    @future(callout = true)
    public static void callBillingService(String projectRef, Decimal billingAmount) {
        
        BillingServiceProxy.InvoicesPortSoap11 invoiceCall = 
            new BillingServiceProxy.InvoicesPortSoap11();
       
        // Billing Service user credentials that you previously configured in a custom setting
         
        ServiceCredentials__c servCred = ServiceCredentials__c.getValues('BillingServiceCredential');
        
        BillingServiceProxy.project project = new BillingServiceProxy.project();
        
        project.username = servCred.Username__c;
        project.password = servCred.Password__c;
        project.projectRef = projectRef;
        project.billAmount = billingAmount;
        
        String httpResponse = invoiceCall.billProject(project);
        
        // If the outbound call is successful, the project record's status is updated to Billed,
        // and the external billing system generates a project invoice.
        
        
    List<Project__c> projects;
        
        if (httpResponse.equalsIgnoreCase('OK')){

            projects = [SELECT Status__c FROM Project__c WHERE ProjectRef__c =: projectRef];

            if(projects.size() > 0){

                projects[0].Status__c = 'Billed';

            }

            update projects;

        }
        
    }
}