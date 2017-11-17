public class ContactTriggerHelper {
    
    public static Map<String, List<Scanned_Business_Cards__c>> cardsMapBeforeDelete = new Map<String, List<Scanned_Business_Cards__c>>();
    
    public static Map<Schema.sObjectType, List<Contact>> getContacts( Map<Id, Contact> oldMap, List<Contact> newList ){
                
        Map<Schema.sObjectType, List<Contact>> contacts = new Map<Schema.sObjectType, List<Contact>>();
        contacts.put(Contact.sObjectType, new List<Contact>());
        
        if( ( oldMap != null && newList != null ) || ( oldMap == null && newList != null )) {
            for(Contact contactNew :newList) {
                if( oldMap == null || ( newList != null && (oldMap.get( contactNew.Id ).LastName != contactNew.LastName  
                                                            || oldMap.get( contactNew.Id ).FirstName != contactNew.FirstName))) {
                if(oldMap != null) contacts.get(Contact.sObjectType).add(oldMap.get(contactNew.Id));
                contacts.get(Contact.sObjectType).add(contactNew);
                }
            }
        } else if(newList == null) {
            for(Contact cont :oldMap.values()) {
                if(cont.FirstName == null) continue;
                contacts.get(Contact.sObjectType).add(cont);
            }
            
        }
        return contacts;
    }
        
    public static void populateContactIdOnCard(Map<Schema.SObjectType, List<sObject>> sObjects) {
        
        if (sObjects.isEmpty()) return;
        
        System.debug('sObjects = ' + sObjects);
        Map<String, Id> fullName2ContacId = GeneralService.getUniqueSObjects(sObjects);
        System.debug('fullName2ContacId = ' + fullName2ContacId);
        
        Map<String, List<Id>> cardsMap = new Map<String, List<Id>>();
        
        List<String> names = new List<String>();
        List<String> surnames = new List<String>();
        
        for(String s :fullName2ContacId.keySet()) {
            names.add(s.split(':', 2)[0]);
            surnames.add(s.split(':', 2)[1]);
        }
        
        List<Scanned_Business_Cards__c> cardsToUpdate = new List<Scanned_Business_Cards__c>();
        
        for(Scanned_Business_Cards__c card  :[SELECT Id, First_Name__c, Last_Name__c
                                              FROM Scanned_Business_Cards__c 
                                              WHERE First_Name__c IN :names
                                              AND Last_Name__c IN :surnames]) {                                                   
                                                  
       if(cardsMap.get(card.First_Name__c + ':' + card.Last_Name__c) == null) {
              cardsMap.put(card.First_Name__c + ':' + card.Last_Name__c, new List<Id>());
       }
              cardsMap.get(card.First_Name__c + ':' + card.Last_Name__c).add(card.Id);
       }
        
        for(String fullName :cardsMap.keySet()) {
            for(Id cardId :cardsMap.get(fullName)) {
                cardsToUpdate.add(new Scanned_Business_Cards__c(
                    Id = cardId,
                    Contact__c = fullName2ContacId.get(fullName),
                    Status__c = (fullName2ContacId.get(fullName) != null) ? Constants.STATUS_COMPLETE : null
                ));
            }
        }
        update cardsToUpdate;
    }
    
    public static void populateContactIdOnCardAfterDelete(Map<Schema.SObjectType, List<sObject>> sObjects) {
        
        if(sObjects.isEmpty()) return;
        
        Map<String, Id> fullName2CardId = new Map<String, Id>();
        Map<String, Id> fullName2ContacId = GeneralService.getUniqueSObjects(sObjects);

        List<Scanned_Business_Cards__c> cardsToUpdate = new List<Scanned_Business_Cards__c>();
        
        List<String> names = new List<String>();
        List<String> surnames = new List<String>();
        
        for(String s :fullName2ContacId.keySet()) {
            names.add(s.split(':', 2)[0]);
            surnames.add(s.split(':', 2)[1]);
        }
        
        for(Scanned_Business_Cards__c card :[SELECT First_Name__c, Last_Name__c FROM Scanned_Business_Cards__c 
                                             WHERE First_Name__c IN :names
                                             AND Last_Name__c IN :surnames
                                             AND Id IN :cardsMapBeforeDelete.get(Constants.CONTACT)]) {
        fullName2CardId.put(card.First_Name__c + ':' + card.Last_Name__c, card.Id);
        }
        
        if(!fullName2CardId.isEmpty()) {
            
            List<Contact> contactList = ScannedBusinessCardDAO.getContact_ByFirstNameAndLastName(names, surnames);
            
            for(String fullName :fullName2CardId.keySet()) {
                if(!contactList.isEmpty()) {
                    cardsToUpdate.add(
                        new Scanned_Business_Cards__c(
                            Id = fullName2CardId.get(fullName),
                            Contact__c = contactList.get(0).Id,
                            Status__c = Constants.STATUS_COMPLETE)); 
                }  else { 
                    cardsToUpdate.add(
                        new Scanned_Business_Cards__c(
                            Id = fullName2CardId.get(fullName),
                            Contact__c = null));
                }
            }
            update cardsToUpdate; 
        }
        
    }
    
    public static Map<String, List<Scanned_Business_Cards__c>> getRelatedCards(List<Contact> oldList) {
        
        if(cardsMapBeforeDelete.get(Constants.CONTACT) == null) {
            cardsMapBeforeDelete.put(Constants.CONTACT, new List<Scanned_Business_Cards__c>());
        }
        cardsMapBeforeDelete.get(Constants.CONTACT).addAll(ScannedBusinessCardDAO.getCardByContactLookup(oldList));
        
        return cardsMapBeforeDelete;  
    }
    
}