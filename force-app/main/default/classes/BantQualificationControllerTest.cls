@IsTest
public class BantQualificationControllerTest{
    @TestSetup
    public static void dataFactory(){
        Account accToInsert = new Account();
        accToInsert.Name = 'Parent Test Account';
        insert accToInsert;
        
        Account accToInsert2 = new Account();
        accToInsert2.Name = 'Test Account';
        accToInsert2.Merchant_id__c = 'testMxId2';
        accToInsert2.ParentId = accToInsert.Id;
        accToInsert2.Email__c = 'Test@gmail.com';
        insert accToInsert2;
        
        BANT_Qualification__c bantqualification = new BANT_Qualification__c();
        bantqualification.Account__c = accToInsert.Id;
        bantqualification.Merchant_ID__c = accToInsert2.Merchant_id__c;
        bantqualification.BANT_Qualification__c = 'HQL';
        bantqualification.status__c = 'Draft';
        insert bantqualification;
        
        GMV__c gmv1 = new GMV__c();
        gmv1.Authorized_GMV__c = 123456.00;
        gmv1.Merchant__c = accToInsert2.Id;
        insert gmv1;
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity opportunity = new Opportunity(
            AccountId = accToInsert2.Id, 
            Name = 'Test Opportunity', 
            Type = 'Current_Account', 
            Methods__c = '', 
            //Service_Provider__c = 'Cashe',
            StageName = 'Open', 
            CloseDate = System.today(), 
            Merchant_ID__c = 'testMxId2', 
            M1_Projection_Cr__c = 2, 
            M2_Projection_Cr__c = 2, 
            M3_Projection_Cr__c = 2, 
            Is_Prime_Opportunity__c = true
        );
        oppList.add(opportunity);
        Opportunity opportunity2 = new Opportunity(
            AccountId = accToInsert2.Id, 
            Name = 'Test Opportunity 2', 
            Type = 'Payment Gateway', 
            Methods__c = 'Payment_link', 
            Service_Provider__c = 'Cashe', 
            StageName = 'Closed Won', 
            CloseDate = System.today(), 
            Merchant_ID__c = 'testMxId23', 
            M1_Projection_Cr__c = 2, 
            M2_Projection_Cr__c = 2, 
            M3_Projection_Cr__c = 2
        );
        oppList.add(opportunity2);
        Opportunity opportunity3 = new Opportunity(
            AccountId = accToInsert2.Id, 
            Name = 'Test Opportunity 2', 
            Type = 'Payment Gateway', 
            Methods__c = 'Optimiser', 
            Service_Provider__c = 'Cashe', 
            StageName = 'Open', 
            CloseDate = System.today(), 
            Merchant_ID__c = 'testMxId24', 
            M1_Projection_Cr__c = 2, 
            M2_Projection_Cr__c = 2, 
            M3_Projection_Cr__c = 2
        );
        oppList.add(opportunity3);
        Opportunity opportunity4 = new Opportunity(
            AccountId = accToInsert2.Id, 
            Name = 'Test Opportunity 3', 
            Type = 'Payment Gateway', 
            Methods__c = 'UPI', 
            StageName = 'Closed Won', 
            Service_Provider__c = 'Cashe', 
            CloseDate = System.today(), 
            Merchant_ID__c = 'testMxId25', 
            M1_Projection_Cr__c = 2, 
            M2_Projection_Cr__c = 2, 
            M3_Projection_Cr__c = 2
        );
        oppList.add(opportunity4);
        Opportunity opportunity5 = new Opportunity(
            AccountId = accToInsert2.Id, 
            Name = 'Test Opportunity 2', 
            Type = 'Payment Gateway', 
            Methods__c = 'Paytm', 
            StageName = 'Closed Lost', 
            Service_Provider__c = 'Cashe', 
            CloseDate = System.today(), 
            Merchant_ID__c = 'testMxId26', 
            M1_Projection_Cr__c = 2, 
            M2_Projection_Cr__c = 2, 
            M3_Projection_Cr__c = 2
        );
        oppList.add(opportunity5);
        insert oppList;
    }
    
    @IsTest
    public static void testCheckParentAccountId(){
        List<Account> accList = [SELECT Id
                                 FROM Account];
        if (!accList.isEmpty() && accList != null){
            Test.startTest();
            for (Account acc : accList){
                Boolean returnedValue = BantQualificationController.checkParentAccountId(acc.Id);
            }
            Test.stopTest();
        }
    }
    
    @IsTest
    public static void getAllChildAccountsMerchantIdsTest(){
        List<Account> accList = [SELECT Id
                                 FROM Account
                                 WHERE ParentId = null
                                 limit 1];
        if (!accList.isEmpty() && accList != null){
            Test.startTest();
            String returnedValue = BantQualificationController.getAllChildAccountsMerchantIds(accList[0].Id);
            Test.stopTest();
        }
    }
    
    @istest
    public static void fetchOpportunitiesfromChildAccount(){
        List<Account> accList = [SELECT id, Name, ParentId
                                 FROM Account
                                 WHERE ParentId != NULL And Name = 'Test Account'
                                 Limit 1];
        
        if (!accList.isEmpty() && accList != NULL){
            BantQualificationCOntroller.fetchOpportunitiesfromChildAccount(accList[0].ParentId, 'Current_Account', '', '');
            // Add method here
            BantQualificationCOntroller.fetchOpportunitiesfromChildAccount(accList[0].ParentId, 'Payment_link', 'UPI', 'Cashe');
        }
    }
    
    @istest
    public static void sendNotificationToOppOwners(){
        List<Opportunity> oppList = [SELECT id, Name
                                     FROM Opportunity
                                     WHERE AccountId != Null
                                     LIMIT 1];
        BANT_Qualification__c bantqualification = [SELECT Id
                                                   FROM BANT_Qualification__c
                                                   LIMIT 1];
        List<String> targetIdList = new List<String>();
        if (!oppList.isEmpty() && oppList != NULL){
            BantQualificationController.sendNotificationToOppOwners(oppList[0].ID, bantqualification.Id);
        }
    }
    
    @IsTest
    public static void cloneAndModifyOriginalOpportunityTest(){
        Map<String,Boolean> cloneIdvsIsPrimeMap =new Map<String,Boolean>();
        List<Opportunity> oppList = [SELECT Id, owner.Id
                                     FROM Opportunity
                                     LIMIT 1];
        cloneIdvsIsPrimeMap.put(oppList[0].Id,true);
        BANT_Qualification__c bantqualification = [SELECT Id
                                                   FROM BANT_Qualification__c
                                                   LIMIT 1];
        String bantId = bantqualification.Id;
        
        if (!oppList.isEmpty() && oppList != null){
            String ownerId = oppList[0].owner.Id;
            Test.startTest();
            List<String> returnedString = BantQualificationController.cloneAndModifyOriginalOpportunities(new List<String>{ oppList[0].Id }, ownerId, bantId, '', cloneIdvsIsPrimeMap, 12,'Jewellery & Accessories');
            Test.stopTest();
            
        }
    }
    
    
    @isTest
    static void testHandleOpportunityRecord(){
        List<BantQualificationController.OpportunityInfo> opportunityDetailsList = new List<BantQualificationController.OpportunityInfo>();
        BantQualificationController.OpportunityInfo opportunityInfo = new BantQualificationController.OpportunityInfo();
        List<Account> accList = [SELECT Id, Merchant_id__c, Name, ParentId
                                 FROM Account
                                 WHERE ParentId != null
                                 limit 1];
        
        List<Opportunity> oppList = [SELECT Id
                                     FROM Opportunity];
        BANT_Qualification__c bantqualification = [SELECT Id
                                                   FROM BANT_Qualification__c
                                                   LIMIT 1];
        String bantId = bantqualification.Id;
        
        opportunityInfo.AccountId = accList[0].Id;
        opportunityInfo.Merchant_ID = accList[0].Merchant_id__c;
        opportunityInfo.isResetstage = true;
        opportunityInfo.stageName = 'Pitch';
        
        opportunityInfo.opportunityId = oppList[0].Id;
        opportunityInfo.Type = 'Payment Gateway';
        opportunityInfo.Methods = 'UPI';
        opportunityInfo.isOppExist = true;
        opportunityInfo.accountName = accList[0].Name;
        opportunityInfo.isClosedLost = false;
        opportunityInfo.parentAccountId = accList[0].ParentId;
        opportunityInfo.businessUnit = 'Domestic Payins';
        opportunityInfo.isClosedLost = NULL;
        opportunityDetailsList.add(opportunityInfo);
        Test.startTest();
        Boolean result = BantQualificationController.handleOpportunityRecord(JSON.serialize(opportunityDetailsList), bantId, '');
        BantQualificationController.bantDetails(bantId);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleOpportunityRecord1(){
        List<BantQualificationController.OpportunityInfo> opportunityDetailsList = new List<BantQualificationController.OpportunityInfo>();
        BantQualificationController.OpportunityInfo opportunityInfo = new BantQualificationController.OpportunityInfo();
        List<Account> accList = [SELECT Id, Merchant_id__c, Name, ParentId
                                 FROM Account
                                 WHERE ParentId != null
                                 limit 1];
        
        List<Opportunity> oppList = [SELECT Id
                                     FROM Opportunity];
        BANT_Qualification__c bantqualification = [SELECT Id
                                                   FROM BANT_Qualification__c
                                                   LIMIT 1];
        String bantId = bantqualification.Id;
        
        opportunityInfo.AccountId = accList[0].Id;
        opportunityInfo.Merchant_ID = accList[0].Merchant_id__c;
        opportunityInfo.isResetstage = true;
        opportunityInfo.stageName = 'Pitch';
        opportunityInfo.serviceProvider = 'Lazypay';
        
        opportunityInfo.opportunityId = oppList[0].Id;
        opportunityInfo.Type = 'Affordability Widget';
        opportunityInfo.Methods = 'Paylater';
        opportunityInfo.isOppExist = false;
        opportunityInfo.accountName = accList[0].Name;
        opportunityInfo.isClosedLost = false;
        opportunityInfo.parentAccountId = accList[0].ParentId;
        opportunityInfo.businessUnit = 'Payment Gateway';
        //opportunityInfo.isClosedLost = NULL;
        
        opportunityDetailsList.add(opportunityInfo);
        Test.startTest();
        Boolean result = BantQualificationController.handleOpportunityRecord(JSON.serialize(opportunityDetailsList), bantId, '');
        Test.stopTest();
    }
    
    @isTest
    static void testSendOpportunityAssignmentEmail(){
        List<Account> accList = [SELECT Id, Merchant_id__c, Name
                                 FROM Account
                                 WHERE ParentId != null
                                 limit 1];
        List<Account> parentAccList = [SELECT Id
                                       FROM Account
                                       WHERE ParentId = null
                                       limit 1];
        String parentAcc = parentAccList[0].Id;
        
        List<Opportunity> oppList = [SELECT Id
                                     FROM Opportunity];
        List<String> oppIdList = new List<String>();
        for (Opportunity op : oppList){
            //oppIdList.add(op.Id);
        }
        Test.startTest();
        // Call the method to test
        BantQualificationController.sendOpportunityAssignmentEmail(oppIdList, parentAcc);
        Test.stopTest();
    }
    
    @isTest
    static void testAssignOpportunityOwner(){
        List<Account> accList = [SELECT Id, Merchant_id__c, Name
                                 FROM Account
                                 WHERE ParentId != null
                                 limit 1];
        String product = 'Payement Gateway';
        String method = 'UPI';
        List<AccountTeamMember> accTeamMemberList = new List<AccountTeamMember>();
        AccountTeamMember accTeamMember1 = new AccountTeamMember(
            AccountId = accList[0].Id, 
            Product__c = 'Payment_link', 
            Method__c = 'Cards', 
            UserId = UserInfo.getUserId()
        );
        
        AccountTeamMember accTeamMember2 = new AccountTeamMember(
            AccountId = accList[0].Id, 
            Product__c = 'Payment_link;Payment_Pages;Payment Gateway;Route', 
            Method__c = 'Cards;UPI', 
            UserId = UserInfo.getUserId()
        );
        AccountTeamMember accTeamMember3 = new AccountTeamMember(
            AccountId = accList[0].Id, 
            Product__c = 'GC distribution catalog;SCLP Gift Card Issuing;CLP Gift Card Issuing;SCLP Wallet Issuance;CLP Wallet Issuance', 
            Method__c = '',
            TeamMemberRole ='EngageHQ',
            Region__c ='North;East;West',
            Category__c ='E-commerce;Fintech;Others', 
            UserId = UserInfo.getUserId()
        );
        accTeamMemberList.add(accTeamMember1);
        accTeamMemberList.add(accTeamMember2);
        accTeamMemberList.add(accTeamMember3);
        insert accTeamMemberList;
        
        Test.startTest();
        BantQualificationController.assignOpportunityOwner('Payment_link', 'Cards', accList[0].Id,'','');
        BantQualificationController.assignOpportunityOwner('Payment_link', '', accList[0].Id,'','');
        BantQualificationController.assignOpportunityOwner('GC distribution catalog', '', accList[0].Id,'','Others');
        BantQualificationController.assignOpportunityOwner('SCLP Gift Card Issuing', '', accList[0].Id,'North','');
        Test.stopTest();
    }
    @IsTest
    static void updateBANTRecordTest(){
        BANT_Qualification__c bantQ =[SELECT Id, status__c, Merchant_ID__c
                                      FROM BANT_Qualification__c LIMIT 1];
        BantQualificationController.updateBANTRecord(bantQ.Id,bantQ.Merchant_ID__c);
             
    }
    
    @IsTest
    static void getChildAccountTest(){
        Account parentAcc = [SELECT ID FROM Account WHERE Name = 'Parent Test Account' LIMIT 1];
        Account accToInsert = new Account();
        accToInsert.Name = 'Test Account 32';
        accToInsert.Merchant_id__c = 'testMxId21';
        accToInsert.ParentId = parentAcc.Id;
        accToInsert.Email__c = 'Test@gmail.com';
        insert accToInsert;
        
        BANT_Qualification__c bantqualification = new BANT_Qualification__c();
        bantqualification.Account__c = accToInsert.Id;
        bantqualification.Merchant_ID__c = accToInsert.Merchant_id__c;
        bantqualification.BANT_Qualification__c = 'LQL';
        bantqualification.status__c = 'Draft';
		bantqualification.Primary_MID__c = 'testMxId21';
        bantqualification.No_of_attempt__c = 0;
        insert bantqualification;
        
        System.debug(bantqualification.Id);
        
        String createdJSON = '{"BANT_Qualification__c":"HQL","Original_Revamp_BANT__c":"'+bantqualification.Id+'","is_Revamp_BANT__c":true,"PrimaryMID":"testMxId21","product":"RazorpayPOS","selectedMerchantIds":"testMxId21","business_Unit":"POS","AccountName":"Test Account 32","ParentAccount":"'+ parentAcc.Id +'","Account__c":"'+ accToInsert.Id +'","bant_Status":"Submitted","primeBANTId":"","isPrimeBANT":false,"OwnerId":"","Auth_Does_the_merchant_have_a_clear_need__c":"Yes","Is_merchant_s_requirement_fulfilled__c":"Yes","Product_GMV_Potential_in_Cr__c":"122","dependencies_priorities_to_convert_QL__c":"Product Gaps","Does_the_merchant_require_convincing__c":"Yes","If_Yes_then_share_the_Merchant_Use_case__c":"test","The_merchant_wants_to_go_live__c":"3 Months","Timeline_Remarks__c":"test","Does_Merchant_have_physical_stores__c":"Yes","Is_the_merchant_currently_with_Paytm__c":"Yes","No_of_Stores__c":"12","If_not_which_competitor_are_they_using__c":"22","Does_the_merchant_deliver_products__c":"Yes","Is_merchant_currently_with_Paytm_Y_N__c":"Yes","No_of_agents_who_handle_delivery__c":"12","If_not_which_competitor_are_they_using_P__c":"test","HQ_in_which_city__c":"Goa","Which_bank_do_they_have_their_settlement__c":"CBI","Auth_Have_they_shared_an_interest__c":"Yes","Is_the_merchant_willing_to_pay_Y_N__c":"Yes","Merchant_SPOC_Name__c":"test","Merchant_Email__c":"test@gmail.com","Merchant_Department__c":"Test2","Merchant_Phone__c":"9876543219","Details_for_merchant_willing_to_pay__c":"test","Budget_Why_not_willing_to_pay__c":"test"}';
        
        BantQualificationController.getRevampBantData(bantqualification.Id);
        // BantQualificationController.updateCurrentBANTCount(bantqualification.Id);
        // BantQualificationController.getChildAccount('testMxId2');
        BantQualificationController.createRevampBANT(createdJSON);
    }
    
    @isTest
    public static void updateCurrentBANTCountTest(){
        Account parentAcc = [SELECT ID FROM Account WHERE Name = 'Parent Test Account' LIMIT 1];
        Account accToInsert = new Account();
        accToInsert.Name = 'Test Account Demo for updateCurrentBANTCountTest';
        accToInsert.Merchant_id__c = 'testMxId21';
        accToInsert.ParentId = parentAcc.Id;
        accToInsert.Email__c = 'Test@gmail.com';
        insert accToInsert;
        
        BANT_Qualification__c bantqualification = new BANT_Qualification__c();
        bantqualification.Account__c = accToInsert.Id;
        bantqualification.Merchant_ID__c = accToInsert.Merchant_id__c;
        bantqualification.BANT_Qualification__c = 'LQL';
        bantqualification.status__c = 'Draft';
		bantqualification.Primary_MID__c = 'testMxId21';
        bantqualification.No_of_attempt__c = 0;
        insert bantqualification;
        BantQualificationController.updateCurrentBANTCount(bantqualification.Id);
    }
    
    @isTest
    public static void getCurrentUserProfileNameTest(){
        BantQualificationController.getCurrentUserProfileName();
    }
    
    @isTest
    public static void creatCMSDraftBANTTest() {
        
        Account parentAcc = [SELECT ID FROM Account WHERE Name = 'Parent Test Account' LIMIT 1];
        Account accToInsert = new Account();
        accToInsert.Name = 'Test Account Demo 1';
        accToInsert.Merchant_id__c = 'testMxId21';
        accToInsert.ParentId = parentAcc.Id;
        accToInsert.Email__c = 'Test@gmail.com';
        insert accToInsert;
        
        BANT_Qualification__c bantqualification = new BANT_Qualification__c();
        bantqualification.Account__c = accToInsert.Id;
        bantqualification.Merchant_ID__c = accToInsert.Merchant_id__c;
        bantqualification.BANT_Qualification__c = 'LQL';
        bantqualification.status__c = 'Draft';
		bantqualification.Primary_MID__c = 'testMxId21';
        bantqualification.No_of_attempt__c = 0;
        insert bantqualification;
        
        String createdJSON = '{"product":"Payment Gateway",' +
            '"methods":"Credit Card",' +
            '"Account__c":"'+ accToInsert.Id +'",' +
            '"business_Unit":"Domestic Pay-ins",' +
            '"engage_hq_category":"Merchant Products",' +
            '"serviceProvider":"Diners",' +
            '"selectedMerchantIds":"'+ bantqualification.Merchant_ID__c +'",' +
            '"PrimaryMID":"testMxId21",' +
            '"isPrimeBANT":false,' +
            '"draft_Contact_Phone__c":"9878765462",' +
            '"draft_Contact_Email__c":"test@gmail.com",' +
            '"draft_Contact_Name__c": "Nav Test"}';
        BantQualificationController.creatCMSDraftBANT(createdJSON);
    }
    
}