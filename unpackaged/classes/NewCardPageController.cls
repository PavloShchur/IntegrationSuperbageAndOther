public class NewCardPageController {
    
    public Scanned_Business_Cards__c card { 
        get; set;
    }
    
    public NewCardPageController() { 
        card = new Scanned_Business_Cards__c();
    }
    
    public PageReference save() {
        insert card;
        return listOfCards();
    }
    
    public static PageReference listOfCards(){
        PageReference pr = new PageReference(Constants.LIST_OF_CARDS_PAGE);
        pr.setRedirect(true);
        return pr;
    }
    
}