@istest
public class AccountImplInterfaceTest {
    @istest static void ownerreassignmentmethod(){
        try{
            Profile p = [select id from profile where name='Integration User'];
            User u1 = new User(LastName = 'last',
                               Email = 'puse0@ama.com',
                               Username = 'puser000@ama.com' + System.currentTimeMillis(),
                               CompanyName = 'TEST2',
                               Title = 'title',
                               Alias = 'alias',
                               TimeZoneSidKey = 'America/Los_Angeles',
                               EmailEncodingKey = 'UTF-8',
                               LanguageLocaleKey = 'en_US',
                               LocaleSidKey = 'en_US',profileid=p.id);
            insert u1;
            Profile p1 = [SELECT Id FROM Profile WHERE Name='Sales Rep'];
            Userrole rr =[SELECT Id,Name FROM Userrole WHERE Name='BGP-1 Rep'];
            user u2 = new User(alias = 'j', email='jsmthyym@acmy65e.com', 
                               emailencodingkey='UTF-8', lastname='Smighth', 
                               languagelocalekey='en_US', 
                               localesidkey='en_US', profileid= p1.Id,
                               timezonesidkey='America/Los_Angeles', 
                               username='jsmittthbfr@acfgme.com',IsActive=true,userroleId=rr.Id);
            insert u2;
            system.runAs(u1){
                Test.startTest();
                Account acc = new Account();
                acc.ownerId= u1.Id;
                acc.name='Test JKK';
                insert acc;
                Map<Id,account> accmap1 = new Map<Id,account>{acc.Id=>acc};
                Opportunity opp= new Opportunity();
                opp.AccountId=acc.Id;
                opp.Type='LOC_EMI';
                opp.Passed_LosState__c=true;
                opp.StageName='Open';
                opp.name='Test Opp';
                opp.CloseDate=system.today();
                insert opp;
                Test.stopTest();
                Account acc2 =[Select id,ownerId from account where id=:acc.Id];
                acc2.ownerId = u2.Id;
                update acc2;
                Map<Id,account> accmap2 = new Map<Id,account>{acc2.Id=>acc2};
                AccountImplInterface.reassignAccountOwnerIfClaimedByManaged(accmap1,accmap2);
            }
        }catch(exception e){
            system.debug('e>'+e);
        }
    }
}