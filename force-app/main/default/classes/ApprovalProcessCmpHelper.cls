/**

* Class Name  : ApprovalProcessCmpHelper

* Description : This class acts as a helper class for 3 LWC Components SalesRequestFlowHelper
,ApprovalClarificationCmp and ApprovalProcessComments to actually pass the processinstanceworkitem id 
from lwc and to share back the details like chatter comments, approval process comments .

* Created by  : Kamesh N

* Test Class  : ApprovalProcessCmpHelperTest

* Version     : 1.0 Created

* Created Date: 15/09/2023

**/ 
public without sharing class ApprovalProcessCmpHelper  {
    @InvocableMethod
    public static List<CommentsInput> GetFinalComments(List<CommentsInput> recid) {
        List<CommentsInput> lst = new List<CommentsInput>();
        CommentsInput cmnti = recid[0]; 
        CommentsInput cmi = new CommentsInput();
        List<processInstancestep> PS = [Select Id,Comments,StepStatus,Actor.Name,CreatedDate,StepNodeId  from processInstancestep where ProcessInstanceId=:cmnti.recId and StepStatus=:cmnti.Type order by createddate asc];
        Map<Id,ProcessInstanceNode> PIN = new Map<Id,ProcessInstanceNode>([Select Id,NodeStatus,ProcessNodeName from ProcessInstanceNode where ProcessInstanceId=:cmnti.recId]);
        Map<id,ProcessNode> PN = new Map<id,ProcessNode>([Select Id,Name from ProcessNode where id in (Select StepNodeId from processInstancestep where ProcessInstanceId=:cmnti.recId and StepStatus=:cmnti.Type)]);
        string comment='';
        /*Below Line actually checks the parameter if approved then get all the 
approved comments from processInstancestep excluding only latest comments if rejected same*/
        if(cmnti.type=='Approved')
        {
            for(processInstancestep PIS:PS)
            {
                if(PIS.StepNodeId!=null)
                {
                    if(PN.get(PIS.StepNodeId).Name != 'Step 1' )//|| PN.get(PIS.StepNodeId).Name != 'Step 2')
                    {
                        comment += 'Approved by '+PIS.Actor.Name+' Through Salesforce on '+PIS.CreatedDate+'\n'+'Comments :'+PIS.Comments+'\n'+'\n';   
                    }
                    
                }     
            }    
        }
        else
        {
            comment += 'Rejected by '+PS[0].Actor.Name+' Through Salesforce'+'\n'+'Comments :'+PS[0].Comments+'\n'; 
        }
        
        system.debug(comment);
        cmi.recid=comment;
        cmi.type=cmnti.type;
        lst.add(cmi);
        return lst;
    }
    public class CommentsInput {
        @InvocableVariable(required=true)
        public String recId;
        
        @InvocableVariable
        public String Type;
        
    }
    public class approvalwrapper
    {
        @AuraEnabled
        public account accnt;
        @AuraEnabled
        public String checkapprovalprocess ;
        @AuraEnabled
        public Boolean currectuser;
        @AuraEnabled
        public String Step;
    }
    
    public class CommentsWrapper
    {
        @AuraEnabled
        public List<ProcessInstanceStep> PIS;
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public Boolean checkapprovalprocess = false;
    }
    
    @AuraEnabled(Cacheable=true)
    public static approvalwrapper getAccount(string recId)
    {
        ProcessInstanceWorkitem PI = [Select id,ProcessInstanceId,ProcessInstance.ProcessDefinition.Name,ActorId from ProcessInstanceWorkitem where id=:recId];
        Account acc = [Select id,Approval_Status__c from account where Id IN (Select TargetObjectId from ProcessInstance where id=:PI.ProcessInstanceId) limit 1];
        ProcessInstanceNode PN=[Select id,ProcessNodeName from ProcessInstanceNode where ProcessInstanceId=:PI.ProcessInstanceId and NodeStatus='Pending'];
        
        approvalwrapper appw = new approvalwrapper();
        appw.Step=PN.ProcessNodeName;
        if(UserInfo.getUserId() == PI.ActorId)
        {
            appw.currectuser=true;
        }
        else
        {
            appw.currectuser=false;
        }
        if(acc.Approval_Status__c=='Approved - NR Impact Approval Pending' || acc.Approval_Status__c=='Approved - Double Decker Approval Pending')
        {
            appw.accnt = acc;
            appw.checkapprovalprocess=PI.ProcessInstance.ProcessDefinition.Name;
            return appw;
        }
        else
        {
            
            appw.accnt = acc;
            appw.checkapprovalprocess=PI.ProcessInstance.ProcessDefinition.Name;
            return appw;
        }
        
        
    }
    @AuraEnabled(Cacheable=true)
    public static CommentsWrapper getComments(string recId)
    {
        
        CommentsWrapper cmtwr = new CommentsWrapper();
        cmtwr.PIS = new List<ProcessInstanceStep>();
        try
        {
            
            ProcessInstanceWorkitem PI = [Select id,ProcessInstanceId from ProcessInstanceWorkitem where id=:recId];
            Task tsk=[Select id,Ops_Comments__c,Owner.Name,Ownerid from Task where ProcessInstanceId__c=:PI.ProcessInstanceId limit 1];
            List<processInstancestep> PS = [Select Id,Comments,StepStatus,Actor.Name,CreatedDate    from processInstancestep where processinstanceid=:PI.ProcessInstanceId order by createddate asc];
            List<ProcessInstanceNode> PIN = [Select Id,NodeStatus,ProcessNodeName from ProcessInstanceNode where ProcessInstanceId=:PI.ProcessInstanceId];
            Map<id,ProcessNode> PN = new Map<id,ProcessNode>([Select Id,Name from ProcessNode where id in (Select StepNodeId from processInstancestep where ProcessInstanceId=:PI.ProcessInstanceId)]);
            system.debug(PS);
            if(PIN.size()==1)
            {
                if(PIN[0].ProcessNodeName != 'Step 1')
                {
                    cmtwr.checkapprovalprocess = true;  
                }
                else if(PIN[0].ProcessNodeName!='Initial Step')
                {
                    cmtwr.checkapprovalprocess = true;
                }
                
            }
            Integer i=1;
            for(processInstancestep Pris:PS)
            {
                system.debug(Pris);
                if(PS.size()!=i)
                {
                    if(Pris.StepStatus == 'Started' || Pris.StepStatus == 'Approved')
                    {
                        cmtwr.PIS.add(Pris);
                    }  
                }
                i++; 
            }
            if(tsk!=null && cmtwr.PIS.size()>0){
                cmtwr.task=tsk;
            }
            system.debug('Test');
            return cmtwr;    
        }
        Catch(Exception e)
        {
            system.debug('exception'+e.getLineNumber());
            cmtwr.checkapprovalprocess = false;
            return cmtwr;
        }
    }
    
    
    @AuraEnabled
    public static Account updateAccount(string recId,string accountstatus,string comments)
    {
        String error;
        try
        {
            Approverdetails__c  settings= Approverdetails__c.getInstance();
            Boolean approvecheck=false;
            ProcessInstanceWorkitem PI = [Select id,ProcessInstanceId,ProcessInstance.ProcessDefinition.Name from ProcessInstanceWorkitem where id=:recId];
            List<processInstancestep> PS = [Select Id,Comments,StepNodeId from processInstancestep where processinstanceid=:PI.ProcessInstanceId order by createddate asc];
            ProcessInstanceNode PIN = [Select Id,NodeStatus,ProcessNodeName from ProcessInstanceNode where ProcessInstanceId=:PI.ProcessInstanceId  and NodeStatus='Pending' limit 1];
            if(PIN != null)
            {
                if(PIN.ProcessNodeName == 'Step 1' && PI.ProcessInstance.ProcessDefinition.Name == 'SF-Task Approval new')
                {
                    approvecheck = true;  
                }   
            }
            
            
            Account acc = [Select id,Approval_Status__c from account where Id IN (Select TargetObjectId from ProcessInstance where id=:PI.ProcessInstanceId) limit 1];
            if(accountstatus.contains('Approved - Double Decker Approval Pending'))
            {
                acc.Approval_Status__c='Approved - Double Decker Approval Pending';  
            }
            else
            {
                acc.Approval_Status__c= accountstatus.split(',')[0];
            }
            Database.SaveResult updateResult = Database.update(acc, false);
            if(updateResult.isSuccess())
            {
                if(approvecheck==true)
                {
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    if(comments!=null)
                    {
                        //PS[0].Comments+'\n'+
                        req2.setComments(comments);
                    }
                    else 
                    { 
                        req2.setComments('');  
                    }
                    req2.setAction('Approve');
                    req2.setWorkitemId(recId);
                    Approval.ProcessResult result = Approval.process(req2);  
                }
                return acc;
            }
            else 
            {
                for (Database.Error er : updateResult.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(er.getStatusCode() + ':' + er.getMessage());
                    error=er.getMessage();
                    throw new AuraHandledException(error);
                    
                }
                
            }
        }
        catch(Exception e)
        {
            // error='DUPLICATE_VALUE:'+error.split('DUPLICATE_VALUE:')[1].split('.')[0]; 
            throw new AuraHandledException(error);
            
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> GetCustomMetadata()
    {
        
        List<String> pickListValues = new List<String>();
        Schema.DescribeFieldResult pickList = ApprovalMethodSelection__mdt.Method_Name__c.getDescribe();
        for( Schema.PicklistEntry pickVal : pickList.getPicklistValues()){
            pickListValues.add(pickVal.getValue());
        }   
        system.debug(pickListValues);
        return pickListValues;
    } 
    @AuraEnabled(cacheable=true)
    public static List<ApprovalMethodSelection__mdt> GetCustomMetadataRecords()
    {
        
        
        List<ApprovalMethodSelection__mdt> cmdtlst =[Select Method_Name__c,Network__c,Pricing_Grid__c,Method_Pricing__c    from ApprovalMethodSelection__mdt];
        return cmdtlst;
    }
    @AuraEnabled
    public static List<FeedItem> getFeedItemsWithComments(string recId) {
        List<FeedItem> fdimlst = new List<FeedItem>();
        ProcessInstanceWorkitem PI = [Select id,ProcessInstanceId from ProcessInstanceWorkitem where id=:recId];
        Task tsk =[Select id from task where ProcessInstanceId__c=:PI.ProcessInstanceId limit 1];
        Account acc = [Select id,Approval_Status__c from account where Id IN (Select TargetObjectId from ProcessInstance where id=:PI.ProcessInstanceId) limit 1];
        List<FeedItem> feeditmlst= [SELECT Id, Body, (SELECT Id, CommentBody,createddate,InsertedBy.Name FROM FeedComments order by createddate asc),createddate,InsertedBy.Name FROM FeedItem where parentId=:acc.Id order by createddate desc];
        system.debug('feed'+feeditmlst);
        for(FeedItem fditem:feeditmlst)
        {
            if(fditem.Body!=null)
            {
                if(fditem.Body.contains(tsk.Id))
                {
                    fdimlst.add(fditem);
                }
            }                                  
        }
        
        if(!fdimlst.Isempty())
        {
            return fdimlst; 
        }
        else
        {
            return null;  
        }
        
    }    
    @Auraenabled
    public static string Approverecord(string recid,string action,string comment)
    {
        try
        {
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setAction(action);
            if(comment!=null)
            {
                req2.setComments(comment);
            }
            else 
            { 
                req2.setComments('');  
            }
            req2.setWorkitemId(recId);
            Approval.ProcessResult result = Approval.process(req2);
            
            if(result.isSuccess() == true)
            {
                String rslt = String.Valueof(result);  
                return rslt; 
            }
            else
            {
                return null;
            }
        }
        catch(Exception e)
        {
            string exc = String.valueOf(e);
            return exc;
        }
    }
    @AuraEnabled(Cacheable=true)
    public static taskWrapper getTask(string recId)
    {
        taskWrapper tskwrapper = new taskWrapper();
        
        tskwrapper.tskObj = [Select id,Owner.Name,Account.Name,IsClosed,Account.Approval_Submitter__c,Description,CreatedbyId,Createdby.Name,Approver__r.Name,Subject,Ops_Comments__c,ProcessInstanceId__c from Task where id=:recId limit 1];
        if(tskwrapper.tskObj.OwnerId==userinfo.getUserid() 
           && tskwrapper.tskObj.Subject=='Revamp Pricing'
           && tskwrapper.tskObj.IsClosed == false && tskwrapper.tskObj.ProcessInstanceId__c == null)
        {
            tskwrapper.userCheck=true;
        }
        return tskwrapper;
    }
    
    public class taskWrapper
    {
        @AuraEnabled
        public Boolean userCheck;
        @AuraEnabled
        public Task tskObj;
    }
    @Auraenabled
    public static Task updateTask(string recId,String opsComment,String cspChecklist,Task tskData,string type)
    {
        if(opsComment!=null && cspChecklist!=null && type=='Submit')
        {
            Task tsk = new Task();
            try{
                tsk.id=recId;
                tsk.Ops_Comments__c=opsComment;
                tsk.CSP_Checklist__c=cspChecklist;
                tsk.Status='Approved by CSP';
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();    
                req1.setObjectId(tskData.accountid);
                req1.setSubmitterId(tskData.CreatedbyId);
                req1.setComments(tskData.Description);
                req1.setProcessDefinitionNameOrId('SF_Task_Approval_Revamp_Pricing');
                req1.setSkipEntryCriteria(true);
                Approval.ProcessResult result = Approval.process(req1);
                Account acc = new Account();
                acc.Id=tskData.accountid;
                acc.Approval_Submitter__c=tskData.CreatedbyId;
                Database.update(acc);
                tsk.ProcessInstanceId__c=result.Instanceid;
                Database.update(tsk);
                return tsk;  
            }
            catch(exception e)
            {
                throw new AuraHandledException(e.getMessage()); 
            }
            
        }
        else if(type == 'Reject' && opsComment!=null)
        {
            Set<string>  recipientsIds = new  Set<string>();
            Task tsk = new Task();
            try{
                tsk.id=recId;
                tsk.Ops_Comments__c=opsComment;
                tsk.Status = 'Rejected';
                Database.update(tsk);
            }
            catch(Exception e)
            {
                throw new AuraHandledException(e.getMessage());
            }
            CustomNotificationType notificationType = 
                [SELECT Id, DeveloperName 
                 FROM CustomNotificationType 
                 WHERE DeveloperName='Approval_Process_Notification'];
            
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Sales Request Rejection for '+tskData.Account.Name);
            notification.setBody(opsComment);
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(tskData.accountid);
            recipientsIds.add(tskData.CreatedById);
            try {
                notification.send(recipientsIds);
            }
            catch (Exception e) {
                System.debug('Problem sending notification: ' + e.getMessage());
            }
            
            return tsk;
        }
        return null;
    }
}