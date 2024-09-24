@ISTEST
public class AccountListViewControllerTest {
    
    @testsetup
    public static void dataFactory(){
        UserRole ur1 = new UserRole(Name = 'EM');
        insert ur1;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u3 = new User(Alias = 'standt', email='sysadmuserpwc3@testorg.com', LastName='Testing', LanguageLocaleKey='en_US', ProfileId = p.Id, 
                           EmailEncodingKey='UTF-8', LocaleSidKey='en_US', UserRoleId = ur1.Id, TimeZoneSidKey='America/Los_Angeles', 
                           username='sysadmuserpwc3@testorg.com', isactive = true);
        insert u3;
        system.runAs(u3){
            Account account = new Account (Name='Test Merchant-01',Merchant_id__c='TestMerchant01');
            insert account;
            GMV__C gmv= new GMV__C();
            gmv.Authorized_GMV__c=15000000;
            gmv.Merchant__c=account.id;
            gmv.Transaction_Date__c=system.today().addMonths(-1);
            gmv.method__c='UPI';
            insert gmv;
            
        }
       
        
    }
     @istest
        public static void getAccountTest(){
          AccountListViewController.getAccount();
        }
   
		@istest
        public static void saveAccountTest(){
            List<String> accountidlist = new List<String>();
            Account account=[select id from Account where merchant_id__c='TestMerchant01'];
            accountidlist.add(account.id);
          AccountListViewController.saveAccountChangeDetails(accountidlist);
        }    

}