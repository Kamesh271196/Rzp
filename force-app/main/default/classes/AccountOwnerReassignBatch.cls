public with sharing class AccountOwnerReassignBatch implements Database.Batchable<Sobject>,Database.Stateful{
    List<String> accountstomail = new List<String>();
    
    public Database.QueryLocator Start(Database.Batchablecontext bc)
    {

        return Database.getQueryLocator([Select id,parentid,parent.parentid,merchant_id__c,Owner_Role__c,parent.Owner_Role__c,Enabler_POC__c,OwnerId,owner.userrole.RollupDescription,Enabler_POC__r.userrole.RollupDescription,parent.ownerid,parent.parent.ownerid from account 
                                         where parentid!=null and parent.parentid=null and parent.ownerid!='0056F000007jBNKQA2' 
                                         and Parent.Owner_Role__c in ('Hybrid - KAM','Hybrid - MM','IF - Startup','Hybrid - SAM','IF - SAM','IF - KAM')]);
    }
    public void execute(Database.Batchablecontext bc,List<Account> scope)
    {
        List<Account> accountsToUpdate  = new List<Account>();
        for(Account acc:scope)
        {
            if(acc.Enabler_POC__c != acc.OwnerId &&
               acc.parent.parentid == null && 
               acc.parent.ownerid!='0056F000007jBNKQA2' 
               && acc.merchant_id__c!=null && 
               acc.parent.ownerid!=acc.ownerid && 
               (acc.Owner_Role__c != 'Banking' && acc.Owner_Role__c != 'partnership' && acc.Owner_Role__c != 'partnerships') &&
               (acc.parent.Owner_Role__c != 'Banking' && acc.parent.Owner_Role__c != 'partnership' && acc.parent.Owner_Role__c != 'partnerships'))
            {
                String oldownerid=acc.OwnerId;
                acc.OwnerId = acc.parent.ownerId;
                accountsToUpdate.add(acc);
                accountstomail.add(acc.id + ',' + oldownerid + ',' + acc.OwnerId + '\n');       
            }
        }
        if(!accountsToUpdate.isEmpty()) {
            List<Database.SaveResult> updateResults = database.update(accountsToUpdate);
            for (Database.SaveResult r : updateResults)
            {
                if (!r.isSuccess())
                {
                    for (Database.Error e : r.getErrors())
                    {  
                        accountstomail.add(r.getId() + ',' +e.getMessage()+','+''+'\n');
                    }
                }
            }
        }
    }
    public void finish(Database.Batchablecontext bc)
    {
        String csv = 'Id,Old Value,New Value\n';
        for(String str:accountstomail) {         
            csv += str;    
        }
        //String csvContent = String.join(csv, '\n');
        Blob csvBlob = Blob.valueOf(csv);
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('BulkBackup_report.csv');
        attachment.setBody(csvBlob);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'kamesh.n@razorpay.com'};
        message.optOutPolicy = 'FILTER';
        message.subject = 'Subject Test Message';
        message.plainTextBody = 'This is the message body.';
        message.htmlBody = 'This is the HTML message body.'; 
        message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
    }
}