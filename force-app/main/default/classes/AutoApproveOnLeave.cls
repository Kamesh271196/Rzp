public without sharing class AutoApproveOnLeave {
    public class ApprovalInput {
        @InvocableVariable(required=true)
        public String ApprovalMessage;
        
        @InvocableVariable(required=true)
        public String accId;
        
        @InvocableVariable(required=true)
        public OutofOffice OOO;
    }
    @InvocableMethod
    public static List<string> approve(List<ApprovalInput> app)
    {
        List<string> stng = new List<string>();
        String error;
        ApprovalInput api = app[0];
        
        try
        {
            Boolean approvecheck=false;
            processInstance PI = [Select id from processInstance where TargetObjectId=:api.accId and status='pending' order by createddate desc];
            ProcessInstanceWorkitem PW = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =:PI.Id];
            
            if(PW!=null)
            {
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                if(api.ApprovalMessage!=null)
                {
                    string comments='Hi\n\nSince Nikita Sehgal is out of office from '+api.OOO.StartDate.format('dd-MMM-yyyy')+' To '+api.OOO.Enddate.format('dd-MMM-yyyy')+', so the request is parked under next level approver in the approval hierarchy\n\n Comment from Nikita Sehgal :- '+api.ApprovalMessage;
                    req2.setComments(comments);
                }
                else 
                { 
                    req2.setComments('');  
                }
                req2.setAction('Approve');
                req2.setWorkitemId(PW.Id);
                Approval.ProcessResult result = Approval.process(req2);  
            }
        }
    catch(Exception e)
    {
        stng.add(e.getMessage());
        return stng;   
    }

    return stng;
}

}