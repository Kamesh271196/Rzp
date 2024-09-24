/**
	
* Class Name  : BOBLeadSubmission

* Description : Web form to create Lead
 
* Created by  : Nandhini R S

* Version     : 48.0

* Created Date: 06/03/2020

**/

@isTest
public class BOBLeadSubmissionTestClass {
         static testMethod void Leadnotconverted(){
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
             BOBLeadSubmission controller = new BOBLeadSubmission();
             List<SelectOption> options = controller.getCategory();
             List<SelectOption> International = controller.getInternational();
              List<SelectOption> options1 = controller.getReferalBankList();
             List<SelectOption> options2 = controller.getAssignToList();
          Lead L=new Lead();
          L.IsConverted=false;
          L.FirstName='Test';
          L.Company='Test';
          L.Email='dafdf@test.com';
          L.Description='Test';
          L.city='Bangalore';
          L.Lastname='test';
          L.Phone='8967123456';
          L.Category__c='Education';
          L.Industry='Yes';
          L.Expected_Monthly_Transaction_Volume__c='10000';
         insert L;
     PageReference pref = Page.BOBLeadSubmission; 
     Test.setCurrentPage(pref);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L);
     BOBLeadSubmission mc2 = new BOBLeadSubmission(sc2);
     BOBLeadSubmission mc1 = new BOBLeadSubmission();
     mc2.SaveLead();   
}
    static testMethod void Leadconverted(){
        Test.starttest();
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
        settings.Opp_Stage_Value_2__c='Submitted';
        settings.Opp_Stage_Value_3__c='Activated';
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
        L.Merchant_Activated__c=true;
         insert L;
          L.Merchant_Activated__c=true;
          L.Activation_Form_Status_Update__c=100;
        L.OwnerId=settings.Owner_id__c;
        update L;
         Account acc=new Account();
         acc.name='test';
         insert acc;
          database.leadConvert lc = new database.leadConvert();
		lc.setLeadId(L.id);

		leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		lc.setConvertedStatus(convertStatus.MasterLabel);

		Database.LeadConvertResult lcr = Database.convertLead(lc);
        
         contact con=new contact();
         con.lastname='test';
         con.Email='test1@gmail.com';
         con.AccountId=acc.id;
         insert con;
        Opportunity opp=new Opportunity();
        opp.AccountId=acc.id;
        opp.StageName=settings.Opp_Stage_Value_3__c;
        opp.CloseDate=system.today()+1;
		opp.name='test';
        insert opp;
         Task t=new Task();
     t.Description='test';
     t.ActivityDate=System.today();
     t.Subject = 'Banking';
     t.Priority = 'Normal';
     t.Status = 'Not Started';
     t.Type = 'BankingToL`ead';
     t.WhatId=acc.id;
     insert t;
     PageReference pref = Page.BOBLeadSubmission; 
     Test.setCurrentPage(pref);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L);
     BOBLeadSubmission mc2 = new BOBLeadSubmission(sc2);
     BOBLeadSubmission mc1 = new BOBLeadSubmission();
     mc2.SaveLead();
        test.stopTest();
}
        static testMethod void Accountnoleads(){
        Dashboard_settings__c settings= new Dashboard_settings__c();
        settings.Owner_id__c='0056F000007jBNKQA2';
        settings.Queue_id__c='00G0k000001P9vhEAC';
        settings.Opp_Stage_Value_2__c='Submitted';
        settings.Opp_Stage_Value_3__c='Activated';
         insert settings;
         Account acc=new Account();
         acc.name='test';
         insert acc;
         contact con=new contact();
         con.lastname='test';
         con.Email='test@gmail.com';
         con.AccountId=acc.id;
         insert con;
         Opportunity opp=new Opportunity();
        opp.AccountId=acc.id;
        opp.StageName='test';
        opp.CloseDate=system.today()+1;
		opp.name='test';
        insert opp;
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
     PageReference pref = Page.BOBLeadSubmission; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L2.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L2);
     BOBLeadSubmission mc2 = new BOBLeadSubmission(sc2);
     BOBLeadSubmission mc1 = new BOBLeadSubmission();
     mc2.SaveLead();   
}
         
   static testMethod void leads(){
       Dashboard_settings__c settings= new Dashboard_settings__c();
        settings.Owner_id__c='0056F000007jBNKQA2';
        settings.Queue_id__c='00G0k000001P9vhEAC';
        settings.Opp_Stage_Value_2__c='Submitted';
        settings.Opp_Stage_Value_3__c='Activated';
         insert settings;
   Account acc=new Account();
   acc.name='test';     
     insert acc;
     contact con=new contact();
     con.lastname='test';
     con.Email='test123@gmail.com';
     con.AccountId=acc.id;
     insert con;
    Opportunity opp=new Opportunity();
        opp.AccountId=acc.id;
        opp.StageName=settings.Opp_Stage_Value_3__c;
       opp.CloseDate=system.today()+1;
	   opp.name='test';
        insert opp;
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
     PageReference pref = Page.BOBLeadSubmission; 
     Test.setCurrentPage(pref);
     //pref.getParameters().put('Id', L2.id);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L2);
     BOBLeadSubmission mc2 = new BOBLeadSubmission(sc2);
     BOBLeadSubmission mc1 = new BOBLeadSubmission();
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
     PageReference pref = Page.BOBLeadSubmission; 
     Test.setCurrentPage(pref);
     ApexPages.StandardController sc2 = new ApexPages.StandardController(L2);
     BOBLeadSubmission mc2 = new BOBLeadSubmission(sc2);
     BOBLeadSubmission mc1 = new BOBLeadSubmission();
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