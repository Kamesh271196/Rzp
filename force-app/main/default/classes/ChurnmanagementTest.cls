@isTest
public class ChurnmanagementTest {
           public static testmethod void ChurnData(){
            List<Account> lstAccount= new List<Account>();
            Account acc = new Account();
            acc.Name ='Name';
            acc.Merchant_ID__c='gmv1234gmv123';
            lstAccount.add(acc);
        insert lstAccount;
        GMV__c gmv1=new GMV__c();
        gmv1.Authorized_GMV__c=10000;
        gmv1.Transaction_Date__c=Date.newInstance(2018,09,12);
        gmv1.Merchant__c=acc.id;
        insert gmv1; 
        GMV__c gmv=new GMV__c();
        gmv.Authorized_GMV__c=5000000;
        gmv.Transaction_Date__c=Date.newInstance(2018,10,12);
        gmv.Merchant__c=acc.id;
        insert gmv;
        Churn_Data_Management__mdt cs1 =new Churn_Data_Management__mdt();
       cs1.MasterLabel='P0';
       cs1.Lower_Limit__c=2500000;
       cs1.Upper_Limit__c=10000000;
    DataBase.executeBatch(new Churnmanagement(),1); 
    }
     public static testmethod void ChurnDataPo(){
           List<Account> lstAccount= new List<Account>();
         Account acc = new Account();
            acc.Name ='Name';
            acc.Merchant_ID__c='gmv1234gmv123';
            acc.Churn_Category__c='p1';
            lstAccount.add(acc);
        insert lstAccount;
        GMV__c gmv1=new GMV__c();
        gmv1.Authorized_GMV__c=10000;
        gmv1.Transaction_Date__c=Date.newInstance(2018,09,12);
        gmv1.Merchant__c=acc.id;
        insert gmv1;
        GMV__c gmv=new GMV__c();
        gmv.Authorized_GMV__c=5000000;
        gmv.Transaction_Date__c=Date.newInstance(2018,10,12);
        gmv.Merchant__c=acc.id;
        insert gmv;
         Churn_Data_Management__mdt cs1 =new Churn_Data_Management__mdt();
       cs1.MasterLabel='P1';
       cs1.Lower_Limit__c=2500000;
       cs1.Upper_Limit__c=10000000;
    DataBase.executeBatch(new Churnmanagement(),1); 
    }
      public static testmethod void ChurnData1(){
           List<Account> lstAccount= new List<Account>();
         Account acc = new Account();
            acc.Name ='Name';
            acc.Merchant_ID__c='gmv1234gmv123';
          acc.Churn_Category__c='P1';
            lstAccount.add(acc);
        insert lstAccount;
          acc.Old_Churn_Category__c='p0';
           update lstAccount;
        GMV__c gmv1=new GMV__c();
        gmv1.Authorized_GMV__c=10000;
        gmv1.Transaction_Date__c=Date.newInstance(2018,09,12);
        gmv1.Merchant__c=acc.id;
        insert gmv1;
        GMV__c gmv=new GMV__c();
        gmv.Authorized_GMV__c=1200000;
        gmv.Transaction_Date__c=Date.newInstance(2018,10,12);
        gmv.Merchant__c=acc.id;
        insert gmv;
        Churn_Data_Management__mdt cs1 =new Churn_Data_Management__mdt();
       cs1.MasterLabel='P1';
       cs1.Lower_Limit__c=2500000;
       cs1.Upper_Limit__c=10000000;       
    DataBase.executeBatch(new Churnmanagement(),1); 
    } 
     public static testmethod void ChurnData2(){
           List<Account> lstAccount= new List<Account>();
         Account acc = new Account();
            acc.Name ='Name';
            acc.Merchant_ID__c='gmv1234gmv123';
            lstAccount.add(acc);
        insert lstAccount;
        GMV__c gmv1=new GMV__c();
        gmv1.Authorized_GMV__c=10000;
        gmv1.Transaction_Date__c=Date.newInstance(2018,09,12);
        gmv1.Merchant__c=acc.id;
        insert gmv1;
        GMV__c gmv=new GMV__c();
        gmv.Authorized_GMV__c=1200000;
        gmv.Transaction_Date__c=Date.newInstance(2018,10,12);
        gmv.Merchant__c=acc.id;
        insert gmv;
        Churn_Data_Management__mdt cs1 =new Churn_Data_Management__mdt();
       cs1.MasterLabel='P0';
       cs1.Lower_Limit__c=2500000;
       cs1.Upper_Limit__c=10000000;
    DataBase.executeBatch(new Churnmanagement(),1); 
    }
      public static testmethod void ChurnDataP2(){
           List<Account> lstAccount= new List<Account>();
         Account acc = new Account();
            acc.Name ='Name';
            acc.Merchant_ID__c='gmv1234gmv123';
            lstAccount.add(acc);
        insert lstAccount;
        GMV__c gmv1=new GMV__c();
        gmv1.Authorized_GMV__c=10000;
        gmv1.Transaction_Date__c=Date.newInstance(2018,09,12);
        gmv1.Merchant__c=acc.id;
        insert gmv1;
        GMV__c gmv=new GMV__c();
        gmv.Authorized_GMV__c=100000;
        gmv.Transaction_Date__c=Date.newInstance(2018,10,12);
        gmv.Merchant__c=acc.id;
        insert gmv;
         Churn_Data_Management__mdt cs1 =new Churn_Data_Management__mdt();
       cs1.MasterLabel='P0';
       cs1.Lower_Limit__c=2500000;
       cs1.Upper_Limit__c=10000000;
    DataBase.executeBatch(new Churnmanagement(),1); 
    }
    public static testmethod void ChurnDataP2Ifelse(){
           List<Account> lstAccount= new List<Account>();
         Account acc = new Account();
            acc.Name ='Name';
            acc.Merchant_ID__c='gmv1234gmv123';
            acc.Churn_Category__c='P2';
            lstAccount.add(acc);
        insert lstAccount;
        GMV__c gmv1=new GMV__c();
        gmv1.Authorized_GMV__c=10000;
        gmv1.Transaction_Date__c=Date.newInstance(2018,09,12);
        gmv1.Merchant__c=acc.id;
        insert gmv1;
        GMV__c gmv=new GMV__c();
        gmv.Authorized_GMV__c=100000;
        gmv.Transaction_Date__c=Date.newInstance(2018,10,12);
        gmv.Merchant__c=acc.id;
        insert gmv;
        Churn_Data_Management__mdt cs1 =new Churn_Data_Management__mdt();
       cs1.MasterLabel='P2';
       cs1.Lower_Limit__c=2500000;
       cs1.Upper_Limit__c=10000000;       
    DataBase.executeBatch(new Churnmanagement(),1); 
    }

}