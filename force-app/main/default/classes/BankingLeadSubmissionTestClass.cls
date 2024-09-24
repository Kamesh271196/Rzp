@isTest
public class BankingLeadSubmissionTestClass {
         static testMethod void Leadnotconverted(){
          Lead L=new Lead();
          L.IsConverted=false;
          L.FirstName='Test';
          L.Company='Test';
          L.Email='dafdf@test.com';
          L.LeadSource='Call';
          L.Description='Test';
          L.city='Bangalore';
          L.Lastname='test';
          L.Razorpay_Team__c='Direct Sales';
         insert L;
     PageReference pref = Page.LeadSubmissionVF; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L);
     BankingToleadsubmission mc2 = new BankingToleadsubmission(sc2);
     BankingToleadsubmission mc1 = new BankingToleadsubmission();
     mc2.SaveLead();   
}
    static testMethod void Leadconverted(){
        User testUser = new User();
          testUser.LastName='test';
          testUser.Alias='test';
          testUser.Email='test@razorpay.com';
          testUser.Username='test@razorpay.com';
          testUser.ProfileId='00e6F000001PsYDQA0';
          testUser.TimeZoneSidKey='Asia/Kolkata';
          testUser.LocaleSidKey='en_IN';
          testUser.EmailEncodingKey='ISO-8859-1';
          testUser.LanguageLocaleKey='en_US';
          insert testUser;

        Dashboard_settings__c settings= new Dashboard_settings__c();
        settings.Owner_id__c='0056F000007jBNKQA2';
        settings.Queue_id__c='00G0k000001P9vhEAC';
         insert settings;
          Lead L=new Lead(); 
          L.FirstName='Test1';
          L.Company='Test1';
          L.Email='test1@test.com';
          L.LeadSource='Call';
          L.Description='Test';
          L.city='Bangalore';
          L.Lastname='test';
          L.IsConverted=false;
        L.Razorpay_Team__c='Direct Sales';
         insert L;
          L.Merchant_Activated__c=true;
          L.Activation_Form_Status_Update__c=100;
        L.OwnerId=settings.Owner_id__c;
        update L;
         
         Account acc=new Account();
         acc.name='test';
        
         insert acc;
         contact con=new contact();
         con.lastname='test';
         con.Email='test1@gmail.com';
         con.AccountId=acc.id;
         insert con;
         
         Task t=new Task();
     t.Description='test';
     t.ActivityDate=System.today();
     t.Subject = 'Banking';
     t.Priority = 'Normal';
     t.Status = 'Not Started';
     t.Type = 'BankingToLead';
     t.WhatId=acc.id;
     insert t;
     PageReference pref = Page.LeadSubmissionVF; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L);
     BankingToleadsubmission mc2 = new BankingToleadsubmission(sc2);
     BankingToleadsubmission mc1 = new BankingToleadsubmission();
     mc2.SaveLead();   
}
         static testMethod void Accountnoleads(){
         Account acc=new Account();
         acc.name='test';
         insert acc;
         contact con=new contact();
         con.lastname='test';
         con.Email='test@gmail.com';
         con.AccountId=acc.id;
         insert con;
         Lead L2=new Lead();
     L2.LastName='Test';
     L2.FirstName='Test';
     L2.Company='Test';
     L2.Email='test@gmail.com';
     L2.LeadSource='Call';
     L2.Description='Test';
     L2.city='Bangalore';
     L2.LeadSource='call';
     L2.Razorpay_Team__c='Direct Sales';
         Task t=new Task();
     t.Description='test';
     t.ActivityDate=System.today();
     t.Subject = 'Banking';
     t.Priority = 'Normal';
     t.Status = 'Not Started';
     t.Type = 'BankingToLead';
     t.WhatId=acc.id;
     insert t;
     PageReference pref = Page.LeadSubmissionVF; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L2.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L2);
     BankingToleadsubmission mc2 = new BankingToleadsubmission(sc2);
     BankingToleadsubmission mc1 = new BankingToleadsubmission();
     mc2.SaveLead();   
}
         
          static testMethod void leads(){
             Account acc=new Account();
         acc.name='test';
        
     insert acc;
     contact con=new contact();
     con.lastname='test';
     con.Email='test123@gmail.com';
     con.AccountId=acc.id;
     insert con;
     Lead L2=new Lead();
     L2.LastName='Test';
     L2.FirstName='Test';
     L2.Company='Test';
     L2.Email='test@gmail.com';
     L2.LeadSource='Call';
     L2.Description='Test';
     L2.city='Bangalore';  
     L2.LeadSource='call';
     L2.Razorpay_Team__c='Direct Sales';
     PageReference pref = Page.LeadSubmissionVF; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L2.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L2);
     BankingToleadsubmission mc2 = new BankingToleadsubmission(sc2);
     BankingToleadsubmission mc1 = new BankingToleadsubmission();
     mc2.SaveLead();           
     Task t=new Task();
     t.Description='test';
     t.ActivityDate=System.today();
     t.Subject = 'Banking';
     t.Priority = 'Normal';
     t.Status = 'Not Started';
     t.Type = 'BankingToLead';
     t.WhoId=L2.id;
     insert t;
}
static testMethod void leads1(){
    Lead L=new Lead();
     L.LastName='Test';
     L.FirstName='Test';
     L.Company='Test';
     L.Email='test@gmail.com';
     L.LeadSource='Call';
     L.Description='Test';
     L.city='Bangalore';  
     L.LeadSource='call';
    Insert L;
    Lead L2=new Lead();
     L2.LastName='Test';
     L2.FirstName='Test';
     L2.Company='Test';
     L2.Email='test@gmail.com';
     L2.LeadSource='Call';
     L2.Description='Test';
     L2.city='Bangalore';  
     L2.LeadSource='call';
     PageReference pref = Page.LeadSubmissionVF; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L2.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L2);
     BankingToleadsubmission mc2 = new BankingToleadsubmission(sc2);
     BankingToleadsubmission mc1 = new BankingToleadsubmission();
     mc2.SaveLead();           
     Task t=new Task();
     t.Description='test';
     t.ActivityDate=System.today();
     t.Subject = 'Banking';
     t.Priority = 'Normal';
     t.Status = 'Not Started';
     t.Type = 'BankingToLead';
     t.WhoId=L2.id;
     insert t;   
}
     }