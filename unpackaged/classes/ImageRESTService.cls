global class ImageRESTService {
    
    public static void getAttachedPicture() {
        
        String cardId = RestContext.request.params.get('id');
        
        if(cardId != null && GeneralService.isValid(cardId, Scanned_Business_Cards__c.sObjectType) == false) 
        { 
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( new DTOScannedBusinessCard.StatusMessage( 
                    'Your request is invalid. ' + 
                    'Make sure that you specified the correct card Id. And try again.', '404' ) )); 
            
            return;
            
        } 
        
        if(cardId != null) {
            
            List<Attachment> a = [SELECT Body, ParentId FROM Attachment WHERE ParentId = :cardId];
            
            if(!a.isEmpty()) {
                
                RestContext.response.addHeader('Content-Type', 'application/json');
                
                RestContext.response.responseBody 
                    = Blob.valueOf(JSON.serialize( 
                        new DTOScannedBusinessCard.GeneralResponse(
                            'You have successfully retrieved ' + 
                            'the image for your card ' +
                            '(card id: ' + a.get(0).parentId + ')')));
                
            }
            else {
                
                RestContext.response.responseBody 
                    = Blob.valueOf(JSON.serialize( 
                        new DTOScannedBusinessCard.GeneralResponse( 
                            'By Id, which you specified, we coud not find any attachment' ) ));
                
            }
            
        }
        else {
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( 
                    new DTOScannedBusinessCard.GeneralResponse('The Id, which you specified, equals to NULL. Please, check the URL.') ));
            
        }
    }
    
    public static void attachPicture() {
        String cardId = RestContext.request.params.get('id');
        
        String contentType = RestContext.request.params.get('Content-Type');
        
        if(cardId != null && GeneralService.isValid(cardId, Scanned_Business_Cards__c.sObjectType) == false) 
        { 
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( new DTOScannedBusinessCard.StatusMessage( 
                    'Your request is invalid. ' + 
                    'Make sure that you specified the card Id. And try again.', '404' ) )); 
            
            return;
            
        } 
        else if(cardId == null) 
        {
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( new DTOScannedBusinessCard.GeneralResponse( 
                    'Your request is invalid. ' + 
                    'Please check the URL and whether you specified card Id. After that try again.' ) )); 
            
            return;
            
        }
        
        if(contentType == null) {
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( new DTOScannedBusinessCard.GeneralResponse( 
                    'Your request is invalid. ' + 
                    'Please check whether you specified the Content-Type. After that try again.' ) )); 
            
            return;
            
        }
        
        Blob imageBlob = RestContext.request.requestBody;
        
        RestContext.response.addHeader('Content-Type', 'image/' + contentType.split('/'));
        
        List<Attachment> attachment = [SELECT Id, ParentId, 
                                       Body, ContentType, Name  
                                       FROM Attachment 
                                       WHERE ParentId = :cardId];
        
        if(!attachment.isEmpty()) {
            
            ImageRESTService.performAttachmentUpdate(attachment, imageBlob);
            
        } 
        else {
            
            ImageRESTService.performAttachmentInsert(cardId, imageBlob, contentType.split('/').get(1), [SELECT Last_Name__c 
                                                                                                        FROM Scanned_Business_Cards__c 
                                                                                                        WHERE Id = :cardId].Last_Name__c);
            
        }
        
    }
    
    public static void performAttachmentUpdate(List<Attachment> attachmentList, Blob b) {
        
        List<Attachment> attachmentsToUpdate = new List<Attachment>();
        
        for(Attachment a :attachmentList) {
            
            a.Body = b;
            attachmentsToUpdate.add(a);
            
        }            
                    
            update attachmentsToUpdate;
            
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( 
                    new DTOScannedBusinessCard.GeneralResponse('Congratulations! You have just updated ' + 
                                                               'the image for your card ' +
                                                               '(card id: ' + attachmentsToUpdate.get(0).parentId + ')'))); 
     
    }
    
    public static void performAttachmentInsert(String cardId, Blob b, String fileExtension, String fileName) {
        
        Attachment a = new Attachment (
            
            ParentId = cardId,
            Body = b,
            ContentType = 'image/' + fileExtension,
            Name = fileName
            
        );
        
            insert a;
            
            RestContext.response.responseBody 
                = Blob.valueOf(JSON.serialize( new DTOScannedBusinessCard.GeneralResponse('Congratulations! You have just created ' + 
                                                                                          'the image with ' + fileName +
                                                                                          '(card id: ' + a.parentId + ')')) );            
    }
    
    
}