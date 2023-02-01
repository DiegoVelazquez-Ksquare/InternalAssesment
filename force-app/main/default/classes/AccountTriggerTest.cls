@isTest
public with sharing class AccountTriggerTest {
         
    @TestSetup
    static void makeData(){
        List<Account>accList = new List <Account>();
        for(integer i=0; i<3; i++){
            Account acc = new Account (Name = 'TestAcc'+i);
            accList.add(acc);
        }
        insert accList;
        List<Contact> con = new List<Contact>();
        for(integer i=0; i<100; i++){
            Contact con1 = new Contact(FirstName ='Con#'+ i, LastName = 'Test', AccountId = accList[0].id);
            con.add(con1);
        }
        insert con;
        List<Contact> conMedium = new List<Contact>();
        for(integer i=0; i<400; i++){
            Contact con2 = new Contact(FirstName ='Con#'+ i, LastName = 'Test', AccountId = accList[1].id);
            conMedium.add(con2);
        }
        insert conMedium;
        List<Contact> conMax = new List<Contact>();
        for(integer i=0; i<1010; i++){
            Contact con2 = new Contact(FirstName ='Con#'+ i, LastName = 'Test', AccountId = accList[2].id);
            conMax.add(con2);
        }
        insert conMax;
    }
    @isTest
    static void lowBulkUpdate(){
        Date dToday = Date.today();
        String dateStr = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        Account acc =  [SELECT Id, Name, PushToVendor__c FROM Account WHERE Name = 'TestAcc0' limit 1];
        acc.PushToVendor__c = 'Yes';
        Test.startTest();
        Database.SaveResult result = Database.update(acc,true);
        Contact con = [SELECT Id, Name, Push_Date__c From Contact Limit 1];
        Test.stopTest();
        System.assert(result.isSuccess());
        System.assertEquals(100, [SELECT count() FROM contact WHERE AccountId =: acc.Id AND Push_Date__c =: dt ]);
       
    }
    @isTest
    static void HighBulkUpdate(){
        Date dToday = Date.today();
        String dateStr = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        Account acc =  [SELECT Id, Name, PushToVendor__c FROM Account WHERE Name = 'TestAcc2' limit 1];
        acc.PushToVendor__c = 'Yes';
        Test.startTest();
        Database.SaveResult result = Database.update(acc,true);
        Contact con = [SELECT Id, Name, Push_Date__c From Contact Limit 1];
        Test.stopTest();
        System.assert(result.isSuccess());
    }
}