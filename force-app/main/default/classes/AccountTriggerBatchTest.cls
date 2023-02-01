@isTest
public with sharing class AccountTriggerBatchTest {
    @TestSetup
    static void makeData(){

        Account acc = new Account (Name = 'TestAcc');

        insert acc;
        List<Contact> conMax = new List<Contact>();
        for(integer i=0; i<199; i++){
            Contact con2 = new Contact(FirstName ='Con#'+ i, LastName = 'Test', AccountId = acc.id, Push_Date__c = null);
            conMax.add(con2);
        }
        insert conMax;
    }
    @isTest
    static void BatchTest(){
        Date dToday = Date.today();
        String dateStr = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        List<Account> accList = [SELECT Id, Name From Account WHERE Name = 'TestAcc' limit 1];
        accList[0].PushToVendor__c = 'Yes';
        Map<Id,string> accountMap = new Map<Id,String>();
        Set<Id> contactSet = new Set <Id>();
        for(Account acc : accList){
            if(acc.PushToVendor__c == 'Yes'){
                accountMap.put(acc.Id, 'Yes');
                contactSet.add(acc.Id);
            }else if(acc.PushToVendor__c == 'No'){
                accountMap.put(acc.Id, 'No');
                contactSet.add(acc.Id);
            }
        }
	
        Test.startTest();
        AccountTriggerBatch batch = new AccountTriggerBatch(accountMap,contactSet,dt);
        Database.executeBatch(batch);
        Test.stopTest();
        System.assertEquals(199, [SELECT count() FROM contact WHERE AccountId =: accList[0].Id AND Push_Date__c =: dt ]);
       
    }

    @isTest
    static void BatchTestNull(){
        Date dToday = Date.today();
        String dateStr = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        List<Account> accList = [SELECT Id, Name From Account WHERE Name = 'TestAcc' limit 1];
        accList[0].PushToVendor__c = 'No';
        Map<Id,string> accountMap = new Map<Id,String>();
        Set<Id> contactSet = new Set <Id>();
        for(Account acc : accList){
            if(acc.PushToVendor__c == 'Yes'){
                accountMap.put(acc.Id, 'Yes');
                contactSet.add(acc.Id);
            }else if(acc.PushToVendor__c == 'No'){
                accountMap.put(acc.Id, 'No');
                contactSet.add(acc.Id);
            }
        }
	
        Test.startTest();
        AccountTriggerBatch batch = new AccountTriggerBatch(accountMap,contactSet,dt);
        Database.executeBatch(batch);
        Test.stopTest();
        System.assertEquals(199, [SELECT count() FROM contact WHERE AccountId =: accList[0].Id AND Push_Date__c =: dt ]);
       
    }

}