public with sharing class CardsListPageController {
    
    public Scanned_Business_Cards__c card {get; set; }
    public List<ScannedBusinessCards> cardList {get;set;}
    public String selectedField {get;set;}
    public String searchString {get;set;}
    
    
    private String sortDirection = 'ASC';
    private String sortExp = 'Name';   
    
    public CardsListPageController() { card = new Scanned_Business_Cards__c(); }
    
    public List<ScannedBusinessCards> getCards() {
        if(cardList == null) {
            cardList = new List<ScannedBusinessCards>();
            for(Scanned_Business_Cards__c c: ScannedBusinessCardDAO.getCard()) {
                cardList.add(new ScannedBusinessCards(c));
            }
        }
        return cardList;
    }    
    
    public PageReference save() {
        List<Scanned_Business_Cards__c> listToInsert = new List<Scanned_Business_Cards__c>();
        for(ScannedBusinessCards cardItem :cardList) {
            listToInsert.add(cardItem.card);
        }
        upsert listToInsert;
        return null;
    }
    
    public PageReference processSelected() {
        
        List<Scanned_Business_Cards__c> selectedCards = new List<Scanned_Business_Cards__c>();
        
        for(ScannedBusinessCards cardItem :getCards()) {
            
            if(cardItem.selected != true) continue;
            
            selectedCards.add(cardItem.card);
            
        }
        
        if(!selectedCards.isEmpty()) { delete selectedCards; }
        return listOfCards();
    }
    public class ScannedBusinessCards {
        
        public Scanned_Business_Cards__c card {get; set;}
        public Boolean selected {get; set;}
        
        public ScannedBusinessCards(Scanned_Business_Cards__c c) {
            card = c;
            selected = false;
        }
    }
    
    public void sortMethod(){
        cardList.clear();
        if(selectedField == 'External Id') {
            for(Scanned_Business_Cards__c cardItem :ScannedBusinessCardDAO.getCard_SortByCreatorId()) {
                cardList.add(new ScannedBusinessCards(cardItem));
            }
        } else if(selectedField == 'Account Name') {
            for(Scanned_Business_Cards__c cardItem :ScannedBusinessCardDAO.getCard_SortByAccountName()) {
                cardList.add(new ScannedBusinessCards(cardItem));
            }
        } else if(selectedField == 'Contact LastName') {
            for(Scanned_Business_Cards__c cardItem :ScannedBusinessCardDAO.getCard_SortByContactLastName()) {
                cardList.add(new ScannedBusinessCards(cardItem));
            }
        }
    }
    
    public String sortExpression
    {
        get
        {
            return sortExp;
        }
        set
        {
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection()
    {
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value) { sortDirection = value; }   
    
    public PageReference ViewData() {
        cardList.clear();
        string sortFullExp = sortExpression  + ' ' + sortDirection;
        
        for(Scanned_Business_Cards__c cardItem :ScannedBusinessCardDAO.getCard_DynamicSort(sortFullExp)) {
            cardList.add(new ScannedBusinessCards(cardItem));
        }
        return null;
    }
    
    public void searchCard() {
        cardList.clear();
        for(Scanned_Business_Cards__c cardItem :ScannedBusinessCardDAO.getCard_DynamicSearch(searchString)) {
            cardList.add(new ScannedBusinessCards(cardItem));
        }
    }
    
    public void clear(){ cardList.clear(); } 
    
    public static PageReference listOfCards(){
        PageReference pr = new PageReference(Constants.LIST_OF_CARDS_PAGE);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference newCard(){
        PageReference pr = new PageReference(Constants.NEW_CARD_PAGE);
        pr.setRedirect(true);
        return pr;
    }
    

    public String renderingService { get; private set; }
    public String renderedFileName {
        get;
        set { renderedFileName = this.sanitizeFileName(value); }
    }

    public String renderedContentType {
        get {
            String renderedContentType = 'text/html'; // the default
            if( ! this.renderingAsHtml() ) {
                renderedContentType = 'application/pdf';
                    if( this.renderedFileName != null) {
                        renderedContentType += '#' + this.renderedFileName;
                        // This is a work-around to set the file name
                        ApexPages.currentPage().getHeaders().put(
                            'content-disposition', 'attachment; filename=' +
                            this.renderedFileName);
                    }
            }
            return renderedContentType;
        }
    }
    public Boolean renderingAsHtml() {
        return ( (renderingService == null) ||
                ( ! renderingService.startsWith('PDF')) );
    }
    public PageReference saveToPdf() {
        renderingService = 'PDF';
        return null;
    }
    private String sanitizeFileName(String unsafeName) {
        String allowedCharacters = '0-9a-zA-Z-_.';
        String sanitizedName =
            unsafeName.replaceAll('[^' + allowedCharacters + ']', '');
        return(sanitizedName);
    }
    
}