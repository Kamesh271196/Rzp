@istest
public class CapitalPerformanceHandlerTest {
  
    @istest static void performanceTest(){
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser342@example.com',
            Email = 'testuser34@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            Alias = 'tuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Account acc = new Account();
        acc.Name = 'Test2343';
        acc.Merchant_ID__c = 'FDcJoCBK4311';
        acc.email__c = 'karthik.j@gmail.com';
        acc.ownerId = testUser.Id;
        insert acc;
        Opportunity opp = new Opportunity();
        opp.Type= 'LOC';
        opp.AccountId = acc.Id;
        opp.closedate = system.today();
        opp.name= 'Test';
        opp.StageName = 'Open';
        insert opp;
        Opportunity opp1 = new Opportunity();
        opp1.Type= 'LOC_EMI';
        opp1.AccountId = acc.Id;
        opp1.closedate = system.today();
        opp1.name= 'Test1';
        opp1.StageName = 'Open';
        insert opp1;
        Capital_Performance__c perf = new Capital_Performance__c();
        perf.Name = '6534764_CARDS_2023_10';
        perf.Product__c = 'CARDS';
        perf.Transaction_Date__c = System.today();
        insert perf;
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        //req.httpMethod  ='POST';
        req.requestUri = '/services/apexrest/CapitalPerformanaceAPI';
        String postData = '[{ "merchant_id": "FDcJoCBK4311", "product_name":"LOC", "capital_lead_score":"Low", "application_id":"435345" },{ "merchant_id": "FDcJoCBK4311", "product_name":"LOC_EMI", "capital_lead_score":"Low", "application_id":"435345" },{"tenure": "97", "withdrawal_count": "78", "total_transaction_value": "1113938.4548387097", "average_transaction_value": "average_transaction_value", "product": "CARDS", "total_loan_disbursed": "57000.000000", "total_principal_recovered": "23896089.660000", "merchant_id": "FDcJoCBK4311", "transaction_date":"2023-10-01" },{"tenure": "97", "withdrawal_count": "78", "total_transaction_value": "1113938.4548387097", "average_transaction_value": "average_transaction_value", "product": "LOC_EMI", "total_loan_disbursed": "57000.000000", "total_principal_recovered": "23896089.660000", "merchant_id": "FDcJoCBK4311", "transaction_date":"2023-10-01" },{"tenure": "97", "withdrawal_count": "78", "total_transaction_value": "1113938.4548387097", "average_transaction_value": "average_transaction_value", "product": "LOC", "total_loan_disbursed": "57000.000000", "total_principal_recovered": "23896089.660000", "merchant_id": "FDcJoCBK4311", "transaction_date":"2023-10-01" }]';
        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        CapitalPerformanaceAPI.upsertData();
        Test.stopTest();
        
    }
}