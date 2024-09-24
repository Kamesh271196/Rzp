@isTest
public class CloningClosedLostOpportunityTest {

    @isTest
    static void testCloneAndModifyOriginalOpportunity() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Create a test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Lost',
            CloseDate = System.today().addDays(45),
            Type = 'New Business',
            Methods__c = 'Credit Card',
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Call the invocable method
        List<Id> opportunityIds = new List<Id>{testOpportunity.Id};
        Test.startTest();
        CloningClosedLostOpportunity.cloneAndModifyOriginalOpportunity(opportunityIds);
        Test.stopTest();

        // Retrieve the cloned Opportunity
        Opportunity clonedOpportunity = [SELECT Id, Name, Merchant_ID__c, StageName, CloseDate, Type, AccountId FROM Opportunity WHERE Name = :testOpportunity.Name];

        // Assert that the cloned Opportunity was created and modified correctly
        System.assertEquals(testOpportunity.Merchant_ID__c, clonedOpportunity.Merchant_ID__c);
        System.assertEquals('Closed Lost', clonedOpportunity.StageName);
        System.assertEquals(System.today().addDays(45), clonedOpportunity.CloseDate);
        System.assertEquals(testOpportunity.Type, clonedOpportunity.Type);
        System.assertEquals(testOpportunity.AccountId, clonedOpportunity.AccountId);
    }
}