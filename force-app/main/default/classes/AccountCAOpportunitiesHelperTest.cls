@isTest
public class AccountCAOpportunitiesHelperTest {
    @testsetup
    public static void createData(){
        Dashboard_settings__c settings = Dashboard_settings__c.getInstance();
        settings.User_for_TransferToCoreSales__c='jddjd';
        insert settings;
    }
    @isTest
    public static void updateCAOpportunitiesTest(){
        list<Account> acclist = new list<account>();
        map<id,Account> oldAcc = new map<id,Account>();
        set<string> setId = new set<string>();
         account acc1 = new account();
        acc1.name='Test Acczzzzz';
        acc1.Consolidated_Last_Click_Attribution_Page__c = 'Perfor';
       
        insert acc1;
        acclist.add(acc1);
        account acc = new account();
        acc.name='Test Acc';
        acc.Consolidated_Last_Click_Attribution_Page__c = 'Performance';
       
        insert acc;
       
        oldAcc.put(acc1.id, acc);
       
        System.debug('### test acc '+ acc);
        opportunity op = new opportunity();
        op.Name='Test Opp';
        op.StageName='Qualify';
        op.CloseDate=date.today();
        op.accountId=acc1.id;
        op.Merchant_Name__c='Test CP';
        op.Merchant_Company__c='test';
        op.AccountId=acc1.Id;
        op.type = 'Current_Account';
        op.Is_Consolidated_Field_Changed__c = true;
        insert op;
         setId.add(op.AccountId);
        System.debug('### test opp '+ op);
        acc.Consolidated_Last_Click_Attribution_Page__c = 'ddddd';
        //acc.Consolidated_Last_Click_Attribution_Page__c = 'razorpay.com/x/current-accounts/';
        UPDATE acc;
        System.debug('### after update acc '+ acc);
        
        test.startTest();
        AccountCAOpportunitiesHelper.updateCAOpportunities(acclist,oldAcc);
        AccountCAOpportunitiesHelper.getCAOpportunity(setId);
        
        test.stopTest();
        
        
        System.debug(' ### Opp '+ [SELECT Id,Is_Consolidated_Field_Changed__c, Type, CA_Channel_New__c FROM Opportunity WHERE AccountId = :acc1.Id]);
    }
    @isTest
    public static void updateCAOppTest(){
        list<Account> aclist = new list<account>();
        map<id,Account> oldAc = new map<id,Account>();
        set<string> setIds = new set<string>();
         
        
        account ac = new account();
        ac.name='Test Acc';
        ac.Consolidated_Last_Click_Attribution_Page__c = 'Performance';
       
        insert ac;
       aclist.add(ac);
        oldAc.put(ac.id, ac);
       
        System.debug('### test acc '+ ac);
        opportunity op = new opportunity();
        op.Name='Test Opp';
        op.StageName='Qualify';
        op.CloseDate=date.today();
        op.accountId=ac.id;
        op.Merchant_Name__c='Test CP';
        op.Merchant_Company__c='test';
        op.AccountId=ac.Id;
        op.type = 'Current_Account';
        op.Is_Consolidated_Field_Changed__c = true;
        insert op;
         setIds.add(op.AccountId);
        System.debug('### test opp '+ op);
        ac.Consolidated_Last_Click_Attribution_Page__c = 'ddddd';
        //acc.Consolidated_Last_Click_Attribution_Page__c = 'razorpay.com/x/current-accounts/';
        UPDATE ac;
        System.debug('### after update acc '+ ac);
        
        test.startTest();
        AccountCAOpportunitiesHelper.updateCAOpportunities(aclist,oldAc);
        AccountCAOpportunitiesHelper.getCAOpportunity(setIds);
        
        test.stopTest();
        
        
        System.debug(' ### Opp '+ [SELECT Id,Is_Consolidated_Field_Changed__c, Type, CA_Channel_New__c FROM Opportunity WHERE AccountId = :ac.Id]);
    }
}