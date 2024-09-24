@isTest
private class AutoApproveOnLeaveTest {
    
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
    static testMethod void testApproveMethod() {
        Account acc = [Select id from Account limit 1];
        Task tsk1 = [Select id from Task where whatid=:acc.Id limit 1];
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        List<id> lstid = new List<id>(); 
        lstid.add('0056F00000DJQf3QAH');
        app.setNextApproverIds(lstid);
        app.setObjectId(acc.id);
        app.setProcessDefinitionNameOrId('SF_Task_Approval_new');
        
        Approval.ProcessResult result = Approval.process(app);
        ProcessInstance pi = [SELECT TargetObjectId, CreatedDate FROM ProcessInstance WHERE TargetObjectId = :acc.Id];
        ProcessInstanceWorkItem PWI = [Select id from ProcessInstanceWorkItem where ProcessInstanceId=:pi.Id order by createddate desc limit 1];
        AutoApproveOnLeave.ApprovalInput input = new AutoApproveOnLeave.ApprovalInput();
        OutofOffice tst = new OutofOffice();
        tst.StartDate=System.now();
        tst.EndDate=System.Now()+1;
        input.OOO=tst;
        input.ApprovalMessage = 'Sample approval message';
        input.accId =acc.Id;
        List<AutoApproveOnLeave.ApprovalInput> inputs = new List<AutoApproveOnLeave.ApprovalInput>();
        inputs.add(input);
        List<String> result1 = AutoApproveOnLeave.approve(inputs);   
    }
}