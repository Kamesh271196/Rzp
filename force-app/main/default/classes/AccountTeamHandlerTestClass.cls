@istest

public class AccountTeamHandlerTestClass {
    @testsetup
    public static void createData(){
        Vertical_Details__c vd = new Vertical_Details__c();
        vd.Name = 'Test VD';
        Insert vd;
        List<Account> parentAccountList = new List<Account>();
        Account parentAcc = new Account();
        parentAcc.Name = 'Parent Account';
        parentAcc.Vertical__c = vd.Id;
        parentAcc.IF_Hybrid__c = 'Abcd';
        parentAcc.KAM_Handover_Status__c = 'Approved';
        //parentAcc.Email__c = 'manish.saini@razorpay.com';
		//parentAcc.Merchant_ID__c = 'Manish_1235';       
         //accRec.KAM_Handover_Status__c = 'Approved';
        parentAcc.POC__c = UserInfo.getUserId();
        parentAccountList.add(parentAcc);
        Insert parentAccountList;
        Opportunity Opp = new Opportunity();
        opp.Name='TestOpp';
        opp.StageName='Open';
        opp.AccountId=parentAccountList[0].Id;
        opp.CloseDate=Date.valueOf('2023-07-07');
        insert opp;
        List<Account> childAccounts = new List<Account>();
        For(integer i = 0;i < 5;i++){
            Account childAcc = new Account();
            childAcc.Name = 'Child'+i;
            ChildAcc.ParentId = parentAcc.Id;
            childAccounts.add(childAcc);
        }
        Insert childAccounts;    
        
    }
    /*Public Static TestMethod void AccountTeamInsert(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='trdtyrdtr@gghg.com', 
                           EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='jhgjyhf@hjfjr.com');
        insert u1;  
        Account acc=new Account();
        acc.Name='test';
        acc.OwnerId=u1.id;
        acc.Website='http://mswrr';
        acc.Merchant_ID__c='123';
        acc.Managers_In_Role_Hierarchy__c='trdtyrdtr@gghg.com';
        Insert acc;
        AccountTeamMember atm=new AccountTeamMember();
        atm.AccountId=acc.id;
        atm.UserId=u1.id;
        insert atm;
    }
    Public Static TestMethod void AccountTeamDelete(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='trdtyrdtr@gghg.com', 
                           EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='jhgjyhf@hjfjr.com');
        insert u1; 
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Sales Rep']; 
        User u2 = new User(Alias = 'test', Email='test@gghg.com', 
                           EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='test@hjfjr.com');
        insert u2; 
        Account acc=new Account();
        acc.Name='test';
        acc.OwnerId=u1.id;
        acc.Website='http://mswrr';
        acc.Merchant_ID__c='123';
        acc.Managers_In_Role_Hierarchy__c='trdtyrdtr@gghg.com';
        Insert acc;
        AccountTeamMember atm=new AccountTeamMember();
        atm.AccountId=acc.id;
        atm.UserId=u2.id;
        insert atm;
        acc.Managers_In_Role_Hierarchy__c=acc.Managers_In_Role_Hierarchy__c+','+u2.Email;
        update acc;
        acc.Managers_In_Role_Hierarchy__c=acc.Managers_In_Role_Hierarchy__c.remove(u2.Email);
        Delete atm;
    }
    public static TestMethod void updateHybrid_verticalFromParent() {
        test.startTest();
        Vertical_Details__c vd = new Vertical_Details__c();
        vd.Name = 'Test VD';
        Insert vd;
        Vertical_Details__c vd1 = new Vertical_Details__c();
        vd1.Name = 'Test VD 1';
        Insert vd1;
        List<Account> parentAccountList = new List<Account>();
        Account parentAcc = new Account();
        parentAcc.Name = 'Parent Account';
        parentAcc.Vertical__c = vd.Id;
        parentAcc.IF_Hybrid__c = 'Abcd';
        parentAcc.KAM_Handover_Status__c = 'Approved';
        parentAccountList.add(parentAcc);
        Insert parentAccountList;
        List<Account> childAccounts = new List<Account>();
        For(integer i = 0;i < 5;i++){
            Account childAcc = new Account();
            childAcc.Name = 'Child'+i;
            ChildAcc.ParentId = parentAcc.Id;
            childAccounts.add(childAcc);
        }
        Insert childAccounts;
        For(Account acc: parentAccountList){
            acc.Vertical__c = vd1.id;
            acc.IF_Hybrid__c = 'BCDEFGHJ';
        }
        update parentAccountList;
        test.stopTest();
    }*/
    public static TestMethod void onParentAccountUpdateHybrid_Vertical() {
        test.startTest();
        Vertical_Details__c vd1 = new Vertical_Details__c();
        vd1.Name = 'Test VD 1';
        Insert vd1;
        List<Account> updatedAcc = new List<Account>();
        updatedAcc = [Select Id,Name,Vertical__c,IF_Hybrid__c,ParentId from Account Where Name = 'Parent Account'];
        for(Account a:updatedAcc){
            a.Vertical__c = vd1.id;
            a.IF_Hybrid__c = 'Afhbefhbeh';
        }
        //Account_Handler_Class.isFirstTime = true;
        update updatedAcc;
        Account acc = new Account();
        acc.id = updatedAcc[0].id;
        Map<Id,Account> oldMap = New Map<Id,Account>();
        oldMap.put(updatedAcc[0].id,acc);
       // Account_Handler_Class handler = new Account_Handler_Class();
        //handler.onParentAccountUpdateHybrid_Vertical(updatedAcc, oldMap);
        test.stopTest();
    }
    /*public static TestMethod void OnBeforeUpdate() {
        test.startTest();
        List<Account> newAccountList = new List<Account>();
        Account accRec = new Account();
        accRec.Name = 'test';
        accRec.KAM_Handover_Status__c = 'Approved';
        accRec.POC__c = UserInfo.getUserId();
            newAccountList.add(accRec);
        Insert newAccountList;
        for(Account acc:newAccountList){
            acc.Name = 'test 1';
        }
        update newAccountList;
         Account_Handler_Class handler = new Account_Handler_Class();
        handler.OnBeforeUpdate(newAccountList);
        handler.accountownerroleonInsert(newAccountList);
        test.stopTest();
    }*/
    
}