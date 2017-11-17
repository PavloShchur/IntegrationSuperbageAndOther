@RestResource(urlMapping='/Project/*')
global class ProjectCalloutService {
    
    static Id OppId;
    
    @future(callout=true)
    public static void doCallout(Id oid)
    {
        HttpRequest req = new HttpRequest();
        
        Opportunity opp = [SELECT Id,Name,Account.Name,CloseDate,Amount FROM Opportunity WHERE Id = :oid];
        
        String serviceToken = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
        
        String body = '{\n' +
            ' "opportunityId" : "'+opp.Id+'",\n'+
            ' "opportunityName" : "'+opp.Name+'",\n'+
            ' "accountName" : "'+opp.Account.Name+'",\n'+
            ' "closeDate" : "'+String.ValueOf(opp.CloseDate).mid(0,10)+'",\n'+   
            ' "amount" : "'+opp.Amount+'"\n}';
                    
        req.setEndpoint('callout:ProjectService/projects');
        
        req.setHeader('token', serviceToken);
        
        req.setHeader('Content-Type', 'application/json');
    
        req.setBody(body); 
        
        req.setMethod('GET');
        
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
    }
    
    @InvocableMethod
    public static void postOpportunityToPMS(List<Id> oids){
        
        OppId = oids[0];
        ID jobID = System.enqueueJob(new QueueablePMSCall(OppId));
        
    }
    global class QueueablePMSCall  implements System.Queueable, Database.AllowsCallouts
    {
        Id oId;
        public QueueablePMSCall(Id inOppId){            
            this.oId = inOppId;
        }
        
        public void execute(QueueableContext context)
        {                        
            ProjectCalloutService.doCallout(oId);
        }
    }
}