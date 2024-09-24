public class BOBLeadSubmission { 
    public String selectedInternational {get; set;}
    public String selectedCategory {get; set;}
    public string selectedBank{get;set;}
     public string assignTo{get;set;}
    public BOBLeadSubmission() {
        selectedInternational = '';
        selectedCategory = '';
        selectedBank='';
        assignTo='';
    }
    public Lead ld;
    public pagereference SaveLead(){
    try{
    Dashboard_settings__c settings=Dashboard_settings__c.getInstance();      
    boolean isnew=false; 
    /* Checks the lead with the email from Webtolead form */
    //List<Lead> lds=[Select email,lastname,ownerid,IsConverted from Lead where Email =: ld.Email]; // Commented by Codleo
    List<Lead> lds=[Select email,lastname,ownerid,IsConverted from Lead where Email =: ld.Email AND recordtype.DeveloperName NOT IN ('Ezetap')]; // Added by Codleo
    system.debug('*****'+lds);
    Lead lea=new Lead();
    if(lds.size()>0){
    Lea=lds.get(0); 
     /*If Lead exists,create task against the existing lead*/
    List<Task> lTask = new List<Task>();
    Task t;
        if(Lea.IsConverted==false){
           if(ld.Email==Lea.Email){
           system.debug('not converted');
    t = new Task(); 
     /*Checks Lead owner is a queue or User,if queue, assign the task owner to integration user*/
    if(string.valueOf(lea.OwnerId).startsWith('005'))
       {
    t.OwnerId = Lea.OwnerId;
       }
    else{
    t.OwnerId=settings.Owner_Id__c;
        } 
    t.Subject = 'BOB Query';
    t.Priority = 'Normal';
    t.Status = 'Not Started';
    t.Type = 'BOBToLead';
    t.WhoId=Lea.id;
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
    /*Redirects the page to thankyou page*/
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/BOBLeadSubmission/BOB_Thankyou_page?id='+Taskid); 
    System.debug('Taafadfskid'+Taskid);
    return pageRef;                   
         }
        }
	     }
        /*If Lead exists and it is converted,create task against account]*/
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
    Task t1=new Task(); 
    List<Task> lTask1=new List<Task>();
    t1.Subject = 'BOB Query';
    t1.Priority = 'Normal';
    t1.Status = 'Not Started';
    t1.Type = 'BOBToLead';
    t1.WhatId=acc.id;
    t1.OwnerId=acc.ownerid; 
    DateTime dT = System.now().addDays(1);
    t1.ActivityDate=Date.newinstance(dT.year(),dT.month(),dT.day());  
    t1.Description=ld.Description;
    t1.IsReminderSet = true;
    t1.ReminderDateTime = dT; 
    lTask1.add(t1);
    if(!lTask1.IsEmpty()){  
    system.debug('task'+lTask1);
    insert lTask1; 
    id Taskid=t1.id;
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/BOBLeadSubmission/BOB_Thankyou_page?id='+Taskid); 
    System.debug('Taafadfskid'+Taskid);
    return pageRef; 			   
       }
        }
        } 
    
    }
        }
    }
    /*If there is no matching lead, create Lead*/
    else{
    if(lds.size()==0){
    Lea = new Lead();   
    isNew=true;
    system.debug('here check point');
         User user=null;
         if(assignTo!=''){    
            try{user=[select id from user where email=:assignTo];}catch(Exception ex){
}
         }
            /*
       
    system.debug('*****Lead');
  
        if(user!=null){ lea.OwnerId=user.id;}*/
        if(user!=null){ lea.OwnerId=user.id;}
         lea.FirstName=ld.FirstName;
    lea.LastName=ld.LastName;	
    lea.Email=ld.Email;
    lea.Company=ld.Company;
    lea.LeadSource='Banking';
    lea.Description=ld.Description;
    lea.City=ld.City;
    lea.Phone=ld.Phone;
    lea.Source_Detail__c='BOB';
    lea.Industry=selectedCategory;
    lea.International__c=selectedInternational;
    lea.Expected_Monthly_Transaction_Volume__c=ld.Expected_Monthly_Transaction_Volume__c;
    lea.Website=ld.Website;
    lea.Referral_Bank__c=selectedBank;
    /*Assigning Lead Owner to Queue */
    Database.DMLOptions assignrule = new Database.DMLOptions();
    assignrule.assignmentRuleHeader.useDefaultRule = true;
    lea.setOptions(assignrule);
        /*if account exists with Lead Email,Create Task against account*/
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
    t1.Subject = 'BOB Query';
    t1.Priority = 'Normal';
    t1.Status = 'Not Started';
    t1.Type = 'BOBToLead';
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
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/BOBLeadSubmission/BOB_Thankyou_page?id='+Taskid); 
    System.debug('Taafadfskid'+Taskid);
    return pageRef; 			   
       }
        }
        }
        else{
            insert lea;
        }
    id Leadid=lea.id;
    PageReference pageRef = new PageReference('https://razorpay.secure.force.com/BOBLeadSubmission/BOB_Thankyou_page?id='+Leadid); 
    return pageRef;              
        }
    }
    }
    catch(Exception e){     
        }
    return null;
    }        
    public BOBLeadSubmission(ApexPages.StandardController controller) {      
    ld= (Lead)controller.getRecord(); 
    }
    public List<SelectOption> getInternational(){
    List<SelectOption> Leadlst=new  List<SelectOption>{
    new SelectOption('','-Select-')
       };
    Leadlst.add(new SelectOption('Yes','Yes'));
    Leadlst.add(new SelectOption('No','No'));
    return Leadlst;
    }
    public List<SelectOption> getCategory(){
    List<SelectOption> Category=new  List<SelectOption>{
    new SelectOption('','-Select-')
       };
    Category.add(new SelectOption('Education','Education'));
    Category.add(new SelectOption('E Commerce','E Commerce'));
    Category.add(new SelectOption('B2B','B2B'));
    Category.add(new SelectOption('Housing Society','Housing Society'));
    Category.add(new SelectOption('Trust','Trust')); 
    Category.add(new SelectOption('Government','Government'));
    Category.add(new SelectOption('Transportation','Transportation'));
    Category.add(new SelectOption('Insurance','Insurance'));
    Category.add(new SelectOption('Mutual Funds','Mutual Funds'));
    Category.add(new SelectOption('Forex','Forex'));
    Category.add(new SelectOption('Security','Security'));
    Category.add(new SelectOption('Rentals','Rentals'));
    Category.add(new SelectOption('Lending','Lending'));
    return Category;
    }
   
    public List<SelectOption> ReferalBankList;
    
    public List<SelectOption> AssignToList;
     public List<SelectOption> getAssignToList(){
         List<SelectOption> AssignToList=new  List<SelectOption>{
        new SelectOption('','-Select-')
       };
    


         AssignToList.add(new SelectOption('chaitanya.reddy@razorpay.com','Chaitanya Reddy'));
         AssignToList.add(new SelectOption('ajmal.a@razorpay.com','Ajmal Ahmad'));
         AssignToList.add(new SelectOption('suraj.rk@razorpay.com','Suraj R K'));
         AssignToList.add(new SelectOption('rohit.malhotra@razorpay.com','Rohit Malhotra'));
         AssignToList.add(new SelectOption('sarita.kanaujiya@razorpay.com','Sarita Kanaujiya'));
         AssignToList.add(new SelectOption('priya.bhattacharya@razorpay.com','Priya Bhattacharya'));
         AssignToList.add(new SelectOption('abhishek.bajaj@razorpay.com','Abhishek Bajaj'));
         AssignToList.add(new SelectOption('anil.kumar@razorpay.com','Anil Kumar'));
         AssignToList.add(new SelectOption('aparna.rajkumar@razorpay.com','Aparna Raj'));
         //AssignToList.add(new SelectOption('harsha.teja@razorpay.com','Harsha Teja'));
	                  
        return AssignToList;
    }
    
    
    public List<SelectOption> getReferalBankList(){
         List<SelectOption> RefrrakBankLst=new  List<SelectOption>{
        new SelectOption('','-Select-')
       };
    
		Schema.DescribeFieldResult fieldResult = Lead.Referral_Bank__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
             RefrrakBankLst.add(new SelectOption(pickListVal.getLabel(),pickListVal.getLabel()));
	  }                   
   return RefrrakBankLst;
    }
    
    
        }