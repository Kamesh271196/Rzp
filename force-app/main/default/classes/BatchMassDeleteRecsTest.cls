@istest
public class BatchMassDeleteRecsTest {
    
    @testSetup
     static void setup()
    {
        Lead ld = new Lead();
        ld.LastName='Kamesh';
        ld.Company='test';
        ld.LeadSource='fewvre';
        insert ld;
    }
    static testmethod void checkbatch()
    {
        string query='Select id from lead';
        Test.startTest();
        Database.executeBatch(new BatchMassDeleteRecs(query),2000);
        // batchApexRetrofit.execute(Database.BatchableContext BC, lstacc);
        Test.stopTest();
        
        
    }
    
    
}