public class ScannedBusinessCardDAO {
    
    public static List<Scanned_Business_Cards__c> getBusinessCardByCreatedByIdAndStatus(String userId, String status) {
        
        List<Scanned_Business_Cards__c> result = new List<Scanned_Business_Cards__c>();
        
        result = [SELECT Created_By_Id__c,
                  Account_Name__c,
                  Full_Name__c, Status__c,
                  Title__c
                  FROM Scanned_Business_Cards__c
                  WHERE Status__c = :status
                  AND Created_By_Id__c = :userId];
        
        return result;
        
    }
    
    public static List<Scanned_Business_Cards__c> getCardByCardId(String cardId) {
        
        List<Scanned_Business_Cards__c> result = new List<Scanned_Business_Cards__c>();
        
        result = [SELECT Id, Salutation__c,
                  First_Name__c, Last_Name__c,
                  Account_Name__c,
                  Title__c, Phone__c,
                  Mobile__c, Fax__c, Email__c, 
                  Website__c, Street1__c, Street2__c, 
                  City__c, State_Country__c, Country__c, 
                  Postcode__c, Notes__c, Created_By_Id__c,
                  Status__c
                  FROM Scanned_Business_Cards__c
                  WHERE Id = :cardId];
        
        return result;
        
    }
    
    public static List<Scanned_Business_Cards__c> getCard() {
        return new List<Scanned_Business_Cards__c>([SELECT Name, Account_Name__c,
                                                    Created_By_Id__c, First_Name__c, Last_Name__c,
                                                    Contact__c, Account__c
                                                    FROM Scanned_Business_Cards__c]);
    }
    
    public static List<Scanned_Business_Cards__c> getCardByContactLookup(List<Contact> oldList) {
        return new List<Scanned_Business_Cards__c>([SELECT Contact__c FROM Scanned_Business_Cards__c WHERE Contact__c IN :oldList]);
    }
                                                    
    public static List<Scanned_Business_Cards__c> getCardByAccountLookup(List<Account> oldList) {
        return new List<Scanned_Business_Cards__c>([SELECT Account__c FROM Scanned_Business_Cards__c WHERE Account__c IN :oldList]);
    }
    
    public static List<Scanned_Business_Cards__c> getCard_SortByCreatorId() {
        return new List<Scanned_Business_Cards__c>([SELECT Name, Account_Name__c,
                                                    Created_By_Id__c, First_Name__c, Last_Name__c,
                                                    Contact__c, Account__c
                                                    FROM Scanned_Business_Cards__c
                                                    ORDER BY Created_By_Id__c LIMIT 20]);
    }
    
    public static List<Scanned_Business_Cards__c> getCard_SortByAccountName() {
        return new List<Scanned_Business_Cards__c>([SELECT Name, Account_Name__c,
                                                    Created_By_Id__c, First_Name__c, Last_Name__c,
                                                    Contact__c, Account__c
                                                    FROM Scanned_Business_Cards__c
                                                    ORDER BY Account_Name__c DESC LIMIT 20]);
    }
    
    public static List<Scanned_Business_Cards__c> getCard_SortByContactLastName() {
        return new List<Scanned_Business_Cards__c>([SELECT Name, Account_Name__c,
                                                    Created_By_Id__c, First_Name__c, Last_Name__c,
                                                    Contact__c, Account__c
                                                    FROM Scanned_Business_Cards__c
                                                    ORDER BY Last_Name__c DESC LIMIT 20]);
    }
    
    public static List<Scanned_Business_Cards__c> getCard_DynamicSort(String sortFullExp) {
        List<Scanned_Business_Cards__c> sortedCards = new List<Scanned_Business_Cards__c>();
        
        for(Scanned_Business_Cards__c cardItem :Database.query('SELECT Name, Account_Name__c,' + 
                                                               ' Created_By_Id__c, First_Name__c, Last_Name__c,' + 
                                                               ' Contact__c, Account__c FROM Scanned_Business_Cards__c' +
                                                               ' ORDER BY ' +  sortFullExp + ' LIMIT 20')) {
            sortedCards.add(cardItem);
      }
        return sortedCards;
    }
    
    public static List<Scanned_Business_Cards__c> getCard_DynamicSearch(String searchString) {
        List<Scanned_Business_Cards__c> foundCards = new List<Scanned_Business_Cards__c>();
        
        for(Scanned_Business_Cards__c cardItem :Database.query('SELECT Name, Account_Name__c,' + 
                                                               ' Created_By_Id__c, First_Name__c, Last_Name__c,' + 
                                                               ' Contact__c, Account__c FROM Scanned_Business_Cards__c' +
                                                               ' WHERE  Account_Name__c LIKE \'%' 
                                                               + searchString + '%\' LIMIT 20')) {
          foundCards.add(cardItem);
        }
        return foundCards;
    }
    
    public static List<Contact> getContact_ByFirstNameAndLastName(List<String> names, List<String> surnames) {
        return [SELECT Id FROM Contact WHERE FirstName IN :names AND LastName IN :surnames
                                         ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    public static List<Account> getAccount_ByName(Map<String, Id> accountName2cardId) {
        return [SELECT Id FROM Account WHERE Name IN :accountName2cardId.keySet() ORDER BY CreatedDate DESC LIMIT 1];
    }
}