public with sharing class AccountTriggerHandler {
    public static void updateField(List<Account> updaccount) {
        Date dToday = Date.today();
        String dateStr = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());

        Map<Id,string> accountMap = new Map<Id,String>();
        Set<Id> contactSet = new Set <Id>();
        for(Account acc : updaccount){
            if(acc.PushToVendor__c == 'Yes'){
                accountMap.put(acc.Id, 'Yes');
                contactSet.add(acc.Id);
            }else if(acc.PushToVendor__c == 'No'){
                accountMap.put(acc.Id, 'No');
                contactSet.add(acc.Id);
            }
        }
        List<Contact>conToUpdate = [SELECT ID,Name, Push_Date__c,AccountId FROM Contact WHERE AccountId IN :contactSet];
        
        for(Contact con : conToUpdate){
            if(accountMap.get(con.AccountId) == 'Yes'){
                con.Push_Date__c = dt;
            }else{
                con.Push_Date__c = null;
            }
        }
        
        if(conToUpdate.size()<=200){ //add condition for empty list or Execute either of three if they are not empty
            update conToUpdate;
            system.debug(conToUpdate.size());
            

        }else if(updaccount.size()>1000){
            AccountTriggerBatch batch = new AccountTriggerBatch(accountMap,contactSet,dt);
            Id batchId = Database.executeBatch(batch,150);
            system.debug(conToUpdate.size());

        }else{
            System.enqueueJob(new AccountTriggerQueueable(accountMap,contactSet,dt));
            system.debug(conToUpdate.size());
        }
        
    }

}