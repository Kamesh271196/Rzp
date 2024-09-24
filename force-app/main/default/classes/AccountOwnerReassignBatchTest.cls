@istest
private class AccountOwnerReassignBatchTest {
    @TestSetup static void methodName() {
       Userrole role = new Userrole(Name='Hybrid - MM',Rollupdescription='Hybrid - MM');
        insert role;
         UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'Hybrid - MM']; 
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser123654@example.com',
            Alias = 'tuser',
            CommunityNickname = 'tuser',
            ProfileId = profile.Id,
            UserRoleId = userRole.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
    }
    @isTest
    static void testBatchExecution() {
      
        user usr=[Select id from user where Username = 'testuser123654@example.com' limit 1];
        Account parentAccount = new Account(Name = 'Parent Account',OwnerId=usr.id);
        insert parentAccount;
        
        Account childAccount = new Account(Name = 'Child Account', ParentId = parentAccount.Id,
                                           Enabler_POC__c = '005C5000000KFECIA4', OwnerId = '0056F000007jBNKQA2',merchant_id__c ='ojhy6543');
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 10; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                ParentId = parentAccount.Id,
                Merchant_Id__c = 'MerchantId'+i,
                OwnerId = usr.id
            );
            testAccounts.add(acc);
        }
        insert testAccounts;
        insert childAccount;
        
        Test.startTest();
        AccountOwnerReassignBatch batchClassInstance = new AccountOwnerReassignBatch();
        Database.executeBatch(batchClassInstance);
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, OwnerId FROM Account WHERE Id = :childAccount.Id];
        System.assertEquals(parentAccount.OwnerId, updatedAccounts[0].OwnerId, 'Owner should have been updated to parent owner');
    }

}