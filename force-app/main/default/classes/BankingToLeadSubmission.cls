/**
	
* Class Name  : BankingToLeadSubmission

* Description : VF Form for Upserting Lead Data
 
* Created by  : Nandhini R S

* Version     : 2.0

* Created Date: 17/04/2019

**/ 

public class BankingToLeadSubmission {
    public String selectedLeadSource {get; set;}
    public string SelectedTeamList {get; set;}
    public BankingToLeadSubmission() {
        selectedLeadSource = 'LeadSource';
        SelectedTeamList = '';
    }
    public Lead ld;
    public pagereference SaveLead(){
    try{
    Dashboard_settings__c settings=Dashboard_settings__c.getInstance();      
    system.debug('******');
    boolean isnew=false; 
    /*Get the Lead Data from the VF Page*/
    //List<Lead> lds=[Select email,lastname,ownerid,IsConverted from Lead where Email =: ld.Email ]; //Commented by Codleo 
    List<Lead> lds=[Select email,lastname,ownerid,IsConverted from Lead where Email =: ld.Email AND recordtype.DeveloperName NOT IN ('Ezetap')]; //Added by Codleo
    system.debug('*****'+lds);
    Lead lea=new Lead();
    if(lds.size()>0){
    Lea=lds.get(0);        
    List<Task> lTask = new List<Task>();
    Task t;
        /*If Lead is already exists and it is not converted,create Task*/
        if(Lea.IsConverted==false){
            if(ld.Email==Lea.Email){
            system.debug('not converted');
    t = new Task();                  
    if(string.valueOf(lea.OwnerId).startsWith('005'))
       {
    t.OwnerId = Lea.OwnerId;
       }
    else{
    t.OwnerId=settings.Owner_Id__c;
        } 
    t.Subject = 'Banking Query';
    t.Priority = 'Normal';
    t.Status = 'Not Started';
    t.Type = 'BankingToLead';
    t.WhoId=Lea.id;
    t.type='BankingToLead';
    DateTime dT = System.now().addDays(1);
    t.ActivityDate=Date.newinstance(dT.year(),dT.month(),dT.day());  
    system.debug('****'+ t.ActivityDate);
    t.Description=ld.Description;
    t.IsReminderSet = true;
    t.ReminderDateTime = dT;             
    lTask.add(t);
    System.debug('****'+lTask);
        
    if(!lTask.IsEmpty()){
    insert t;
    id Taskid=t.id;
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/LeadSubmission/Banking_Thankyou_page?id='+Taskid); 
    System.debug('Taafadfskid'+Taskid);
    return pageRef;                   
         }
        }
         }
        
        /*If Lead exists and it was already converted,create task aganist account*/
        else{
            if(Lea.IsConverted==true){
              system.debug('converted');
    List<Contact> con=[Select id,email,Accountid from Contact where email =:ld.Email];
    Map<id,id> accid=new Map<id,id>();
    if(con.size()>0){
    for(contact c: con){
    accid.put(c.id, c.Accountid);
        }
    List<Account> acclst=[Select id,ownerid from Account where id in:accid.values()];
    for(Account acc: acclst){
    List<Lead> ldlst1=new List<Lead>();
    Task t1=new Task(Subject = 'Banking Query',Priority = 'Normal',Status = 'Not Started',Type = 'BankingLead',WhatId=acc.id,OwnerId=acc.ownerid,ActivityDate=Date.newinstance(System.now().addDays(1).year(),System.now().addDays(1).month(),System.now().addDays(1).day()),Description=ld.Description,IsReminderSet = true,ReminderDateTime = System.now().addDays(1)); 
    List<Task> lTask1=new List<Task>();
   /* t1.Subject = 'Banking Query';
    t1.Priority = 'Normal';
    t1.Status = 'Not Started';
    t1.Type = 'BankingLead';
    t1.WhatId=acc.id;
    t1.OwnerId=acc.ownerid; 
    DateTime dT = System.now().addDays(1);
    t1.ActivityDate=Date.newinstance(dT.year(),dT.month(),dT.day());  
    t1.Description=ld.Description;
    t1.IsReminderSet = true;
    t1.ReminderDateTime = dT;*/ 
    lTask1.add(t1);
    if(!lTask1.IsEmpty()){  
    system.debug('task'+lTask1);
    insert lTask1; 
    id Taskid=t1.id;
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/LeadSubmission/Banking_Thankyou_Page?id='+Taskid); 
    System.debug('Taafadfskid'+Taskid);
    return pageRef;                
       }
        }
        } 
    
    }
        }
    }
        /*If Lead does not exist, create new Lead*/
    else{
    if(lds.size()==0){
    System.debug('********');
    Lea = new Lead();   
    isNew=true;
    system.debug('*****Lead');   
    lea.LastName=ld.LastName;   
    lea.Email=ld.Email;
    lea.Company=ld.Company;
    lea.LeadSource='Banking';
    lea.Description=ld.Description;
    lea.City=ld.City;
    lea.Phone=ld.Phone;
    lea.Source_Detail__c=ld.Source_Detail__c;
    lea.Razorpay_Team__c=SelectedTeamList;
    system.debug('****'+lea.Razorpay_Team__c);
    Database.DMLOptions assignrule = new Database.DMLOptions();
    assignrule.assignmentRuleHeader.useDefaultRule = true;
    lea.setOptions(assignrule);
    List<Contact> con=[Select id,email,Accountid from Contact where email =:lea.Email];
    Map<id,id> accid=new Map<id,id>();
    if(con.size()>0){
    for(contact c: con){
    accid.put(c.id, c.Accountid);
        }
    List<Account> acclst=[Select id,ownerid from Account where id in:accid.values()];
    for(Account acc: acclst){
    List<Lead> ldlst1=new List<Lead>();
    Task t1=new Task(); 
    List<Task> lTask1=new List<Task>();
    t1.Subject = 'Banking Query';
    t1.Priority = 'Normal';
    t1.Status = 'Not Started';
    t1.Type = 'BankingToLead';
    t1.WhatId=acc.id;
    t1.OwnerId=acc.ownerid; 
    DateTime dT = System.now().addDays(1);
    t1.ActivityDate=Date.newinstance(dT.year(),dT.month(),dT.day());  
    t1.Description=lea.Description;
    t1.IsReminderSet = true;
    t1.ReminderDateTime = dT; 
    lTask1.add(t1);
    if(!lTask1.IsEmpty()){  
    system.debug('task'+lTask1);
    insert lTask1; 
    id Taskid=t1.id;
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/LeadSubmission/Banking_Thankyou_Page?id='+Taskid); 
    System.debug('Taafadfskid'+Taskid);
    return pageRef;                
       }
        }
        }
    else{
    Task t =new Task();
    List<Task> lTask = new List<Task>();
    insert Lea;
    t.Subject = 'Banking Query';
    t.Priority = 'Normal';
    t.Status = 'Not Started';
    t.Type = 'BankingToLead';
    t.WhoId=Lea.id;
    t.OwnerId=settings.Owner_Id__c;    
    DateTime dT = System.now().addDays(1);
    t.ActivityDate=Date.newinstance(dT.year(),dT.month(),dT.day());  
    t.Description=lea.Description;
    t.IsReminderSet = true;
    t.ReminderDateTime = dT;            
    lTask.add(t);
    if(!lTask.IsEmpty()){  
    system.debug('ltask'+lTask);
    insert lTask;       
    }
        }       
    id Leadid=lea.id;
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/LeadSubmission/Banking_Thankyou_Page?id='+Leadid); 
    return pageRef;              
        }
    }
    }
    catch(Exception e){     
       }
    return null;
    }        
    public BankingToLeadSubmission(ApexPages.StandardController controller) {      
    ld= (Lead)controller.getRecord(); 
    }
     public List<SelectOption> getLeadsource(){
    List<SelectOption> Leadlst=new  List<SelectOption>();
    Leadlst.add(new SelectOption('Banking','Banking'));
    return Leadlst;
    }
    public List<SelectOption> getTeamList(){
        List<SelectOption> Leadlst1=new  List<SelectOption>{
        new SelectOption('','Select')
         };
    Leadlst1.add(new SelectOption('Direct Sales','Direct Sales'));
    Leadlst1.add(new SelectOption('SME','SME'));
    Leadlst1.add(new SelectOption('Growth','Growth'));
    return Leadlst1;
    }
        }