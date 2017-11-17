trigger ContactTrigger on Contact (after insert, after update, before delete, after delete) {
    
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
            ContactTriggerHelper.getRelatedCards(Trigger.old);    
        }
    }
    
    if(Trigger.isAfter){
        
        if(Trigger.isInsert || Trigger.isUpdate)
            ContactTriggerHelper.populateContactIdOnCard(
                ContactTriggerHelper.getContacts(Trigger.oldMap, Trigger.new));        
        
        if(Trigger.isDelete) {
            ContactTriggerHelper.populateContactIdOnCardAfterDelete(
                ContactTriggerHelper.getContacts(Trigger.oldMap, Trigger.new));
        }
    }
    
}