public with sharing class AccountTriggerBatch implements Database.Batchable<sObject>{


    Map<Id,string> accountMap;
    Set<Id> contactSet;
    Datetime dt;
    public AccountTriggerBatch(Map<Id,string> accountMap, Set<Id> contactSet, Datetime dt){
        this.accountMap = accountMap;
        this.contactSet = contactSet;
        this.dt = dt;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT ID,Name, Push_Date__c,AccountId FROM Contact WHERE AccountId IN :contactSet';
       
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope){

        for(Contact con : scope){
            if(accountMap.get(con.AccountId) == 'Yes'){
                con.Push_Date__c = dt;
            }else{
                con.Push_Date__c = null;
            }
        }
        update scope;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}