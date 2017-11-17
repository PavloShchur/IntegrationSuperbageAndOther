public class AccountTriggerHelper { 
    
    public static Map<String, List<Scanned_Business_Cards__c>> cardsMapBeforeDelete = new Map<String, List<Scanned_Business_Cards__c>>();
    
    public static Map<Schema.sObjectType, List<Account>> getAccounts( Map<Id, Account> oldMap, List<Account> newList ){
        
        Map<Schema.sObjectType, List<Account>> accounts = new Map<Schema.sObjectType, List<Account>>();
        accounts.put(Account.sObjectType, new List<Account>());
        
        if( ( oldMap != null && newList != null ) || ( oldMap == null && newList != null )) {
            
            for(Account accountNew : newList){
                if( oldMap == null || ( newList != null && oldMap.get( accountNew.Id ).Name != accountNew.Name )) {
                    if(oldMap != null) accounts.get(Account.sObjectType).add(oldMap.get(accountNew.Id));
                    accounts.get(Account.sObjectType).add(accountNew);
                }
                
            }
        }
        if (newList == null) {
            accounts.get(Account.sObjectType).addAll(oldMap.values());
        }

        return accounts;
    }

    public static void populateAccountIdOnCard(Map<Schema.SObjectType, List<sObject>> sObjects) {
        
        if ( sObjects.isEmpty() ) return;
        
        Map<String, Id> name2AccountIdMap = GeneralService.getUniqueSObjects(sObjects);
        
        Map<String, List<Id>> cardsMap = new Map<String, List<Id>>();
        
        List<Scanned_Business_Cards__c> cardsToUpdate = new List<Scanned_Business_Cards__c>();
        
        for(Scanned_Business_Cards__c card  :[SELECT Id, Account_Name__c
                                              FROM Scanned_Business_Cards__c 
                                              WHERE Account_Name__c IN :name2AccountIdMap.keySet()]) 
        { 
            if(cardsMap.get(card.Account_Name__c)  == null) {
                cardsMap.put(card.Account_Name__c, new List<Id>());
            }
            cardsMap.get(card.Account_Name__c).add(card.Id);
        }
        
        for(String accountName :cardsMap.keySet()) {
            for(Id cardId :cardsMap.get(accountName)) {
                
                if(name2AccountIdMap.get(accountName) == null) continue;
                cardsToUpdate.add(
                    new Scanned_Business_Cards__c(
                        Id = cardId,
                        Account__c = name2AccountIdMap.get(accountName),
                        Status__c = Constants.STATUS_COMPLETE
                    ));
            }
        }
        
        update cardsToUpdate;
        
    } 
    
    public static void populateAccountIdOnCardAfterDelete(Map<Schema.SObjectType, List<sObject>> sObjects) {
        
        if ( sObjects.isEmpty() ) return;
        
        Map<String, Id> name2AccountId = GeneralService.getUniqueSObjects(sObjects);
        
        Map<String, Id> accountName2cardId = new Map<String, Id>();
        
        List<Scanned_Business_Cards__c> cardsToUpdate = new List<Scanned_Business_Cards__c>();
        
        for(Scanned_Business_Cards__c card  :[SELECT Id, Account_Name__c
                                              FROM Scanned_Business_Cards__c 
                                              WHERE Account_Name__c IN :name2AccountId.keySet()
                                              AND Id IN :cardsMapBeforeDelete.get(Constants.Account)]) 
        { 
            accountName2cardId.put(card.Account_Name__c, card.Id);
        }
        
        if(!accountName2cardId.isEmpty()) {
            
            List<Account> accountID = ScannedBusinessCardDAO.getAccount_ByName(accountName2cardId);
            
            for(String accountName :accountName2cardId.keySet()) {
                
                if(!accountID.isEmpty()) {
                    cardsToUpdate.add(
                        new Scanned_Business_Cards__c(
                            Id = accountName2cardId.get(accountName),
                            Account__c = accountID.get(0).Id,
                            Status__c = Constants.STATUS_COMPLETE));
                } else {
                    cardsToUpdate.add(
                        new Scanned_Business_Cards__c(
                            Id = accountName2cardId.get(accountName),
                            Account__c = null));
                }
            }
        } 
        
        update cardsToUpdate;
    }
    
    public static Map<String, List<Scanned_Business_Cards__c>> getRelatedCards(List<Account> oldList) {
        
        if(cardsMapBeforeDelete.get(Constants.ACCOUNT) == null) {
            cardsMapBeforeDelete.put(Constants.ACCOUNT, new List<Scanned_Business_Cards__c>());
        }
        cardsMapBeforeDelete.get(Constants.ACCOUNT).addAll(ScannedBusinessCardDAO.getCardByAccountLookup(oldList));
        
        return cardsMapBeforeDelete;  
    }
    
}