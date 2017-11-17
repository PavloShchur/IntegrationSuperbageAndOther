trigger AccountTrigger on Account (after insert, after update, before delete, after delete) {
    
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
            AccountTriggerHelper.getRelatedCards(Trigger.old);    
        }
    }
    
    if(Trigger.isAfter){
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            AccountTriggerHelper.populateAccountIdOnCard(
                AccountTriggerHelper.getAccounts(Trigger.oldMap, Trigger.new));
        }
        
        if(Trigger.isDelete) {
            AccountTriggerHelper.populateAccountIdOnCardAfterDelete(
                AccountTriggerHelper.getAccounts(Trigger.oldMap, Trigger.new));
        }
   
    }
    
}