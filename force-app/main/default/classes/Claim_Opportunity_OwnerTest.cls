@isTest
public class Claim_Opportunity_OwnerTest {
   
    @isTest
    static void testGetResults() {
       
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                OwnerId = UserInfo.getUserId(),
                 CloseDate = system.today(),
                StageName = 'New'
            );
            testOpportunities.add(opp);
        }
        insert testOpportunities;

       
        List<Id> oppIdsWithTestRecordType = new List<Id>();
        for (Integer i = 0; i < 2; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity w ' + i,
                OwnerId = UserInfo.getUserId(),
                  CloseDate = system.today(),
                StageName = 'New'
               
            );
            insert opp;
            oppIdsWithTestRecordType.add(opp.Id);
        }

        Test.startTest();

       
        List<Id> oppIdsToQuery = new List<Id>();
       
        oppIdsToQuery.addAll(oppIdsWithTestRecordType);
        Claim_Opportunity_Owner.getResults(oppIdsToQuery);

        Test.stopTest();

       
    }
}