public class ClassForAttachmentRead {
    /*
   public ClassForAttachmentRead(String recordId){
       String reqBody='';
        List<Attachment> att=   [select body from Attachment WHERE parentid in (select id from Log_API_Call__c)];
       for(Attachment attachment:att){
           reqBody=reqBody+attachment.body;
       }
       		Attachment attachment = new Attachment();
            attachment.Body = Blob.valueOf(reqBody);
            attachment.Name = String.valueOf('LogForAPI'+recordId+'.txt');
            attachment.ParentId = (Id)recordId; 
            insert attachment;
    }
*/
}