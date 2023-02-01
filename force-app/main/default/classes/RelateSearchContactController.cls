public with sharing class RelateSearchContactController {
    
    
    @AuraEnabled(Cacheable=true)
    public static List<Contact> SearchContacts( String idacc,Integer offSetCount){
        List<Contact> accContacts = [SELECT Id,Name, Phone, Email, AccountId FROM Contact WHERE AccountId  =: idacc limit 2 OFFSET :offSetCount];
        return (accContacts);
    }
 


    @AuraEnabled
    public static void CreateContacts(Contact con, String id1){
        system.debug(id1);
        Account acc = [SELECT Id, Name FROM Account WHERE Id =: id1 limit 1];
        con.AccountId = acc.Id;

        try{
            insert con;
        }
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
       
    }

    @AuraEnabled(cacheable=true)
    public static String getContentDetails(String recordId) {
        List<ContentDocumentLink> contentDocumentList = [SELECT ContentDocumentId, LinkedEntityId FROM   ContentDocumentLink   WHERE  LinkedEntityId =: recordId];
        Set<Id> contentDocumentId = new Set<Id>();
        for(ContentDocumentLink cdl : contentDocumentList){contentDocumentId.add(cdl.ContentDocumentId);
        }        
        List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,CreatedDate, ContentDocumentId, ContentDocument.FileType FROM   ContentVersion  WHERE  ContentDocumentId IN : contentDocumentId];
        return JSON.serialize(contentVersionList);
    }
}