public class  AccountTriggerQueueable implements Queueable {
    Map<Id,string> accountMap;
    Set<Id> contactSet;
    Datetime dt;
    public AccountTriggerQueueable(Map<Id,string> accountMap, Set<Id> contactSet, Datetime dt){
        this.accountMap = accountMap;
        this.contactSet = contactSet;
        this.dt = dt;
    }

    public void execute(QueueableContext context) {
        List<Contact>conToUpdate = [SELECT ID,Name, Push_Date__c,AccountId FROM Contact WHERE AccountId IN :contactSet];
        
        for(Contact con : conToUpdate){
            if(accountMap.get(con.AccountId) == 'Yes'){
                con.Push_Date__c = dt;
            }else{
                con.Push_Date__c = null;
            }
        }
        update conToUpdate;      
    }
}