@isTest
global class ProjectCalloutServiceMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
    
        System.assertEquals('callout:ProjectService/projects', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"opportunityId": "00641000004EKmFAAW",' + 
                    '"opportunityName": "Super-Duper Big Deal",' + 
                    '"accountName": "ACME Corp, Inc.",' + 
                    '"closeDate": "2016-10-30",' + 
                    '"amount": 150000}');
        res.setStatusCode(201);
        return res;
    }
}