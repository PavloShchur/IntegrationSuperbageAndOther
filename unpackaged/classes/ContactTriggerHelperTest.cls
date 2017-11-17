@isTest
public class ContactTriggerHelperTest {
    
    @testSetup static void setup() {
        
        List<Scanned_Business_Cards__c> listOfCards = new List<Scanned_Business_Cards__c>();
        
        List<Contact> contacts = new List<Contact>();
        
        List<Contact> checkCreatedDate = new List<Contact>();
        
        for(Integer i = 0; i < 100; i++) {
            
            listOfCards.add(
                
                new Scanned_Business_Cards__c(
                    
                    Account_Name__c = 'accountName' + i,
                    First_Name__c = 'firstName' + i,
                    Last_Name__c = 'lastName' + i,
                    Created_By_Id__c = '0050O000006eb3n'
                    
                ));  
            
        }
        
        insert listOfCards;
        
        for(Integer i = 0; i < 100; i++) {
            
            contacts.add(
                new Contact(                    
                    FirstName = 'firstName' + i,
                    LastName = 'lastName' + i
                ));      
            
            contacts.add(
                new Contact(                    
                    FirstName = 'custom@id.com' ,
                    LastName = 'custom@id.com'
                ));            
        }
        
        insert contacts;
        
        for(Integer i = 0; i < 100; i++) {
            
            checkCreatedDate.add(
                new Contact(                    
                    FirstName = 'name' ,
                    LastName = 'lastName'
                ));            
        }
        
        insert checkCreatedDate;
        
    } 
    
    @isTest static void createContact_FirstNameMatches_CardNotFound() {
        
        Contact newContact = new Contact(FirstName = 'firstName0', LastName = 'noMatchingCard');
        
        Test.startTest();
        insert newContact;
        Test.stopTest();
        
        System.assertNotEquals(newContact.Id, [SELECT Contact__c 
                                               FROM Scanned_Business_Cards__c 
                                               WHERE First_Name__c = 'firstName0'].Contact__c);     
        
    }
    
    @isTest static void ceateContact_LastNameMatches_CardNotFound() {
        
        Contact newContact = new Contact(FirstName = 'noMatchingCard', LastName = 'lastName0');
        
        Test.startTest();
        insert newContact;
        Test.stopTest();
        
        System.assertNotEquals(newContact.Id, [SELECT Contact__c 
                                               FROM Scanned_Business_Cards__c 
                                               WHERE First_Name__c = 'firstName0'].Contact__c);    
        System.assertEquals(null, [SELECT Contact__c 
                                               FROM Scanned_Business_Cards__c 
                                               WHERE First_Name__c = 'firstName0'].Contact__c);  
        
    }
    
    
    @isTest static void createContact_FirstNameAndLastNameMatches_CardFound() {
        
        Contact newContact = new Contact(FirstName = 'firstName0', LastName = 'lastName0');
        
        Test.startTest();
        insert newContact;
        Test.stopTest();
        
        System.assertEquals(newContact.Id, [SELECT Contact__c 
                                               FROM Scanned_Business_Cards__c 
                                               WHERE First_Name__c = 'firstName0'
                                               AND Last_Name__c = 'lastName0'].Contact__c);     
        
    }
    
    @isTest static void updateContact_FirstNameAndLastNameMatches_CardFound() {
        
        insert new Scanned_Business_Cards__c(First_Name__c = 'firstName_115',
                                             Last_Name__c = 'lastName_116',
                                             Created_By_Id__c = '0050O000006eb3n');
        
        Contact newContact = [SELECT FirstName, LastName 
                              FROM Contact 
                              WHERE FirstName = 'custom@id.com' 
                              AND LastName = 'custom@id.com' 
                              LIMIT 1];
        
        newContact.FirstName = 'firstName_115';
        newContact.FirstName = 'lastName_116';
        
        Test.startTest();
        update newContact;
        Test.stopTest();
        
        System.assertNotEquals(newContact.Id, [SELECT Contact__c 
                                               FROM Scanned_Business_Cards__c 
                                               WHERE First_Name__c = 'firstName_115' 
                                               AND  Last_Name__c = 'lastName_116'].Contact__c);     
        
    }
    
    @isTest static void checkWhetherLookupWasPopulatedWithRightContactId() {
        
        insert new Scanned_Business_Cards__c(First_Name__c = 'firstName144',
                                             Last_Name__c = 'lastName145',
                                             Created_By_Id__c = '0050O000006eb3n');
        
        Test.startTest();
        insert new Contact(FirstName = 'firstName144', LastName = 'lastName145');
        ContactTestUtilities.sleep(2000);
        insert new Contact(FirstName = 'firstName144', LastName = 'lastName145');
        ContactTestUtilities.sleep(2000);
        insert new Contact(FirstName = 'firstName144', LastName = 'lastName145', Email = 'theYoungest@contact.com');  
        Test.stopTest();
        
        System.assertEquals([SELECT Contact__c 
                                           FROM Scanned_Business_Cards__c 
                                           WHERE First_Name__c = 'firstName144' 
                                           AND Last_Name__c = 'lastName145'].Contact__c, 
                            [SELECT Id 
                             FROM Contact 
                             WHERE Email = 'theYoungest@contact.com'].Id ); 
    }
    
    @isTest public static void deleteRelatedContact_ContactLookupEmpty() {
        
		Test.startTest();
		Database.delete([SELECT Id FROM Contact WHERE FirstName = 'firstName0' AND LastName = 'lastName0']);
		Test.stopTest();
        
        System.assertEquals(null, 
                                [SELECT Contact__c FROM Scanned_Business_Cards__c 
                                 WHERE First_Name__c = 'firstName0' AND Last_Name__c = 'lastName0'].Contact__c);

    }
    
    @isTest public static void deleteRelatedContact_ContactLookupNotEmpty() {        
        
        Test.startTest();
        insert new Contact(FirstName = 'firstName0', LastName = 'lastName0', Email = 'theYoungest@contact.com');
        Database.delete([SELECT Id FROM Contact WHERE Email = 'theYoungest@contact.com']);
        Test.stopTest();
        
        System.assertEquals([SELECT Contact__c FROM Scanned_Business_Cards__c 
                             WHERE First_Name__c = 'firstName0' AND Last_Name__c = 'lastName0'].Contact__c, 
                            [SELECT Id FROM Contact 
                             WHERE FirstName = 'firstName0' AND LastName = 'lastName0' ORDER BY CreatedDate DESC LIMIT 1].Id
                           ); 
        
    }
}