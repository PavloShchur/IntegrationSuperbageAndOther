public class GeneralService {
    
    private static final Map<Schema.SObjectType, List<Schema.sObjectField>> sObjType2fieldNames 
        = new Map<Schema.SObjectType, List<Schema.sObjectField>>{
            Account.sObjectType => new List<Schema.sObjectField>{Scanned_Business_Cards__c.Account_Name__c},
                Contact.sObjectType => new List<Schema.sObjectField>{Scanned_Business_Cards__c.First_Name__c, Scanned_Business_Cards__c.Last_Name__c} 
        };
            
   private static final Map<Schema.SObjectType, List<Schema.sObjectField>> sObjType2fieldNames_2 
            = new Map<Schema.SObjectType, List<Schema.sObjectField>>{
                Account.sObjectType => new List<Schema.sObjectField>{Account.Name},
                    Contact.sObjectType => new List<Schema.sObjectField>{Contact.FirstName, Contact.LastName} 
            };
    
    public static boolean run = true;
    
    public static Boolean isValid(String stringValue, Schema.SObjectType sObjectType) {
        
        Id sObjectId;
        
        if(isId(stringValue)) {
            
            sObjectId = (Id)stringValue;
            
        }
        
        return isValid(sObjectId, sObjectType);
        
    }
    
    public static Boolean isValid(Id sObjectId, Schema.SObjectType sObjectType) {
        
        return !(sObjectId == null || sObjectId.getSObjectType() != sObjectType);
        
    }
    
    public static Boolean isId(String stringValue) {
        
        return stringValue instanceOf Id;
        
    }
    
    
    public static List<String> getValuesOfPicklist_ScannedBusinessCard () {
        
        List<String> myPicklist = new List<String>();
        
        Schema.DescribeFieldResult field = Scanned_Business_Cards__c.Status__c.getDescribe();
        
        for (Schema.PicklistEntry f :field.getPicklistValues()) {
            
            myPicklist.add( f.getLabel() );
            
        }
        
        return myPicklist;          
    }
    
    public static Boolean listContains(Object[] source, Object target) {
        
        return (new Set<Object>(source)).contains(target);
        
    }
    
    public static boolean runOnce() {
        
        if(run) {
            run = false;
            return true;
        }
        else {
            return run;
        }
        
    }
    
    public static String generateFullName(Schema.SObjectType objType, Scanned_Business_Cards__c card) {
        
        List<String> partialResult = new List<String>();
        for(Schema.SObjectField fieldName :sObjType2fieldNames.get(objType)) {
            partialResult.add((String)card.get(fieldName));
        }
        return String.join(partialResult, ' ');
    }
    
    public static String generateFullNameFromSObject(Schema.SObjectType objType, sObject obj) {
        
        List<String> partialResult = new List<String>();
        for(Schema.SObjectField fieldName :sObjType2fieldNames_2.get(objType)) {
            System.debug('75 fieldName = '+ fieldName);
            partialResult.add((String)obj.get(fieldName));
        }
        return String.join(partialResult, ':');
    }
    
    public static List<Sobject> removeDuplicates(List<SObject> originalList) {
        
        Set<sObject> myset = new Set<sObject>();
        List<sobject> result = new List<sobject>();
        for (sobject s : originalList) {
            if (myset.add(s)) {
                result.add(s);
            }
        }
        
        return result;
    }
    
    public static Map<String, Id> getUniqueSObjects(Map<Schema.SObjectType, List<sObject>> sObjects) {
        
        if( sObjects.isEmpty() ) return new Map<String, Id>();
        
        SObjectWrapper[] sObjectList = new List<SObjectWrapper>();
        
        Map<String, Id> name2sObjectId = new Map<String, Id>();
        
         String fullName = '';
        
        for( Schema.SObjectType sObjType :sObjects.keySet() ) {
            
            for(sObject obj :sObjects.get( sobjType ) ) {
                
                fullName = GeneralService.generateFullNameFromSObject( sObjType, obj );
                System.debug('fullName = ' + fullName);
                
                sObjectList.add( new SObjectWrapper(obj));               
            }
            
        }
        
        sObjectList.sort();
        
        for(Integer i = 0; i <sObjectList.size(); i++) {
            name2sObjectId.put(fullName, sObjectList[i].obj.Id);
        } 
        
        return name2sObjectId;
        
    }
    
    
}