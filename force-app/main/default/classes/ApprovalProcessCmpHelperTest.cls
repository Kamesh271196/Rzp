@isTest
private class ApprovalProcessCmpHelperTest {
   
    
    @testsetup static void datafactory()
    {
        Account acc = new Account();
        acc.Name ='Test account';
        insert acc;
        FeedItem fdi = new FeedItem();
        fdi.ParentID = acc.Id;
        fdi.Body ='Test';
        insert fdi;
        FeedComment fdc = new FeedComment();
        fdc.feeditemid=fdi.id;
        fdc.CommentBody ='test';
        Task tsk = new Task();
        tsk.WhatId=acc.id;
        tsk.Subject='Revamp Pricing';
        insert tsk;
    }
    static testMethod void myTest() {
        Account acc = [Select id from Account limit 1];
        Task tsk1 = [Select id,AccountId,whatid,createddate,createdbyid,Description from Task where whatid=:acc.Id limit 1];
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        List<id> lstid = new List<id>();
        lstid.add('005C5000000KFECIA4');
        app.setNextApproverIds(lstid);
        app.setObjectId(acc.id);
        app.setProcessDefinitionNameOrId('SF_Task_Approval');
        
        Approval.ProcessResult result = Approval.process(app);
        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :acc.Id];
        ProcessInstanceWorkItem PWI = [Select id from ProcessInstanceWorkItem where ProcessInstanceId=:pi.Id order by createddate desc limit 1];
        List<ApprovalProcessCmpHelper.CommentsInput> inputList = new List<ApprovalProcessCmpHelper.CommentsInput>();
        ApprovalProcessCmpHelper.CommentsInput input = new ApprovalProcessCmpHelper.CommentsInput();
        input.recId = PWI.Id;
        input.Type = 'Approved';
        inputList.add(input);

        // Call the method
        List<ApprovalProcessCmpHelper.CommentsInput> result4 = ApprovalProcessCmpHelper.GetFinalComments(inputList);
        tsk1.processinstanceid__c=pi.Id;
        update tsk1;
        Test.StartTest();
        ApprovalProcessCmpHelper.GetFinalComments(result4);
        ApprovalProcessCmpHelper.getComments(PWI.Id);
        ApprovalProcessCmpHelper.updateAccount(PWI.Id,'Approved - Double Decker Approval Pending','Test');
        ApprovalProcessCmpHelper.GetCustomMetadata();
        ApprovalProcessCmpHelper.GetCustomMetadataRecords();
        ApprovalProcessCmpHelper.getFeedItemsWithComments(PWI.Id);
        ApprovalProcessCmpHelper.getAccount(PWI.Id);
        Test.StopTest();
    }
    static testmethod void test2()
    {
         
        List<id> lstid = new List<id>();
        lstid.add('005C5000000KFECIA4');
        Account acc = [Select id from Account limit 1];
        Task tsk1 = [Select id,AccountId,whatid,createddate,createdbyid,Description from Task where whatid=:acc.Id limit 1];
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(acc.id);
        app.setNextApproverIds(lstid);
        app.setProcessDefinitionNameOrId('SF_Task_Approval_new');
        Approval.ProcessResult result = Approval.process(app);
        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :acc.Id];
        ProcessInstanceWorkItem PWI = [Select id from ProcessInstanceWorkItem where ProcessInstanceId=:pi.Id order by createddate desc limit 1];
        ApprovalProcessCmpHelper.updateAccount(PWI.Id,'Approved - NR Impact Approval Pending','Test');
        ProcessInstanceWorkItem PWI2 = [Select id from ProcessInstanceWorkItem where ProcessInstanceId=:pi.Id order by createddate desc limit 1];
        ApprovalProcessCmpHelper.updateAccount(PWI2.Id,'Approved - Double Decker Approval Pending','Test');
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approve');
        req2.setAction('Approve');
        req2.setWorkitemId(PWI2.Id);
        Approval.ProcessResult result1 = Approval.process(req2);
        ProcessInstanceWorkItem PWI1 = [Select id from ProcessInstanceWorkItem where ProcessInstanceId=:pi.Id order by createddate desc limit 1];
        
        tsk1.ucid__c=pi.Id;
        update tsk1;
        Test.StartTest();
        ApprovalProcessCmpHelper.getComments(PWI.Id);
        ApprovalProcessCmpHelper.Approverecord(PWI.Id,'approve','Comment');
        ApprovalProcessCmpHelper.GetCustomMetadata();
        ApprovalProcessCmpHelper.GetCustomMetadataRecords();
        //ApprovalProcessCmpHelper.getFeedItemsWithComments(PWI1.Id);
        ApprovalProcessCmpHelper.getAccount(PWI1.Id);
        
        Test.StopTest();
    }
    static testMethod void myTest2() {
         Account acc = [Select id from Account limit 1];
        Task tsk1 = [Select id,AccountId,whatid,createddate,createdbyid,Description,Account.Name from Task where whatid=:acc.Id limit 1];
        ApprovalProcessCmpHelper.getTask(tsk1.id);
        ApprovalProcessCmpHelper.updateTask(tsk1.id,'testjchebhjv','vefvf;vfvfv',tsk1,'Submit');
        ApprovalProcessCmpHelper.updateTask(tsk1.id,'testjchebhjv','vefvf;vfvfv',tsk1,'Reject');
    }
}