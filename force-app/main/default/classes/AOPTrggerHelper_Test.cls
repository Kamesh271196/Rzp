@istest
public class AOPTrggerHelper_Test {
    
    @testsetup
    public static void dataFactory(){
        Account Parentacc= new Account ();
        Parentacc.name='ParentAccount';
        insert Parentacc;
        Account childAccount= new Account ();
        childAccount.name='ChildAccount';
        childAccount.ParentId=Parentacc.id;
        insert childAccount;
        List<GMV__c> listtoinsert = new List<GMV__c>();
        GMV__c gm = new GMV__c();
        gm.Merchant__c = childAccount.Id;
        gm.Method__c = 'card';
        gm.Transaction_Date__c = date.today();
        gm.Authorized_GMV__c = 345678;
        gm.authorized_international_gmv__c=45555;
        listtoinsert.add(gm);
       	GMV__c gmnet = new GMV__c();
        gmnet.Merchant__c = childAccount.Id;
        gmnet.Method__c = 'Net Banking';
        gmnet.Transaction_Date__c = date.today().addDays(280);
        gmnet.Authorized_GMV__c = 345678;
        gmnet.authorized_international_gmv__c=45555;
        listtoinsert.add(gmnet);
        GMV__c gmupi = new GMV__c();
        gmupi.Merchant__c = childAccount.Id;
        gmupi.Method__c = 'UPI';
        gmupi.Transaction_Date__c =date.today().addDays(280);
        gmupi.Authorized_GMV__c = 345678;
        gmupi.authorized_international_gmv__c=45555;
        listtoinsert.add(gmupi);
        GMV__c gmemi = new GMV__c();
        gmemi.Merchant__c = childAccount.Id;
        gmemi.Method__c = 'emi';
        gmemi.Transaction_Date__c = date.today().addDays(280);
        gmemi.Authorized_GMV__c = 345678;
        gmemi.authorized_international_gmv__c=45555;
        listtoinsert.add(gmemi);
        insert listtoinsert;
        
        
        Opportunity opp=new Opportunity();
        opp.name='test1_product';
        opp.StageName='closed';
        opp.Merchant_ID__c=childAccount.ID;
        opp.Life_Time_GMV__c=100.0;
        opp.type='Vendor_Payout';
        opp.CloseDate=system.today();
        opp.Merchant_Company__c='Murli';
        opp.Email__c = 'murli8091@gmail.com';
        insert opp;
        List<Product_GMV__c> prdgmvlist= new List<Product_GMV__c>();
        Product_GMV__c pgmv=new Product_GMV__c();
        pgmv.Account__c=childAccount.id;
        pgmv.Opportunity__c=opp.id;
        pgmv.GMV__c=1000.0;
        pgmv.Captured_Revenue__C=1000;
        pgmv.Date__c=System.today();
        pgmv.Product__c='Optimiser';
        pgmv.Method__c='wallet';
        pgmv.Unique_Key__c='test1_2019-01-01-product_card';
        prdgmvlist.add(pgmv);
        Product_GMV__c pgmvemi=new Product_GMV__c();
        pgmvemi.Account__c=childAccount.id;
        pgmvemi.Opportunity__c=opp.id;
        pgmvemi.GMV__c=1000.0;
        pgmvemi.Captured_Revenue__C=1000;
        pgmvemi.Date__c=System.today();
        pgmvemi.Product__c='Optimiser';
        pgmvemi.Method__c='emi';
        pgmvemi.Unique_Key__c='test2_2019-01-01-product_card';
        prdgmvlist.add(pgmvemi);
        Product_GMV__c pgmvnet=new Product_GMV__c();
        pgmvnet.Account__c=childAccount.id;
        pgmvnet.Opportunity__c=opp.id;
        pgmvnet.GMV__c=1000.0;
        pgmvnet.Captured_Revenue__C=1000;
        pgmvnet.Date__c=System.today();
        pgmvnet.Product__c='Optimiser';
        pgmvnet.Method__c='net';
        pgmvnet.Unique_Key__c='test3_2019-01-01-product_card';
        prdgmvlist.add(pgmvnet);
        Product_GMV__c pgmvcard=new Product_GMV__c();
        pgmvcard.Account__c=childAccount.id;
        pgmvcard.Opportunity__c=opp.id;
        pgmvcard.GMV__c=1000.0;
        pgmvcard.Captured_Revenue__C=1000;
        pgmvcard.Date__c=System.today();
        pgmvcard.Product__c='Optimiser';
        pgmvcard.Method__c='net';
        pgmvcard.Unique_Key__c='test4_2019-01-01-product_card';
        prdgmvlist.add(pgmvcard);
        Product_GMV__c pgmvupi=new Product_GMV__c();
        pgmvupi.Account__c=childAccount.id;
        pgmvupi.Opportunity__c=opp.id;
        pgmvupi.GMV__c=1000.0;
        pgmvupi.Captured_Revenue__C=1000;
        pgmvupi.Date__c=System.today();
        pgmvupi.Product__c='Optimiser';
        pgmvupi.Method__c='net';
        pgmvupi.Unique_Key__c='test5_2019-01-01-product_card';
        prdgmvlist.add(pgmvupi);
        
        insert prdgmvlist;
        RZP_X_Performance__c RZP= NEW RZP_X_Performance__c();
        RZP.Last_Transaction_Date__c=system.today();
        RZP.Vanilla_Payout_TPV__c=455;
        RZP.Vendor_Payment_TPV__c=455;
        RZP.XLite_Float__c=455;
        RZP.XLite_TPV__c=455;
        RZP.Payout_Links_TPV__c=455;
        RZP.Account__c=childAccount.id;
        INSERT RZP;
        
        Capital_Performance__c perf = new Capital_Performance__c();
        perf.Account__c=childAccount.id;
        perf.Name = '6534764_CARDS_2023_10';
        perf.Product__c = 'CARDS';
        perf.Total_transaction_value__c='3454';
        perf.Transaction_Date__c = System.today();
        insert perf;
        
        
        
    }
    
	@ISTEST
    public static void createAOP(){
        Account acc=[select id from Account where name='ParentAccount'];
        AOP__c aop = new AOP__C();
        aop.account__C=acc.id;
        aop.Financial_Year__c='2024-2025';
        INSERT aop;
        
        
    }    
    
    

}