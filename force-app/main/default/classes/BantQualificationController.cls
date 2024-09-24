/**
 * Class Name  : BantQualificationController
 * Description : For BANT
 * Created by  : Navneet
 * Version     : 1.1
 *Test Class   : BantQualificationControllerTest
 * Created Date: 25/02/2024
 **/
public without sharing class BantQualificationController{
    @AuraEnabled
    public static boolean checkParentAccountId(String recordId){
        List<String> merchantIds = new List<String>();
        if (recordId != null && recordId != ''){
            List<Account> accList = [SELECT Id, ParentId
                                     FROM Account
                                     where Id = :recordId AND ParentId = NULL
                                     LIMIT 1];
            if (accList != null && !accList.isEmpty()){
                return true;
            } else{
                return false;
            }
        } else{
            System.debug('error');
        }
        return null;
    }

    @AuraEnabled(cacheable = true)
    public static String getAllChildAccountsMerchantIds(String parentAccountId){
        List<OpportunityDetailWrap> OpportunityWrapperList = new List<OpportunityDetailWrap>();
        if (parentAccountId != null && parentAccountId != ''){
            List<Account> accList = [SELECT Id, Name, Merchant_ID__c, GMV_CFY__c
                                     FROM Account
                                     where ParentId = :parentAccountId AND Merchant_ID__c != ''
                                     order by GMV_CFY__c DESC];
            if (accList != null && !accList.isEmpty()){
                for (Account ac : accList){
                    OpportunityDetailWrap oppwrap = new OpportunityDetailWrap();
                    oppwrap.account_Id = ac.Id;
                    oppwrap.Merchant_ID = ac.Merchant_ID__c;
                    oppwrap.GMV_CFY = ac.GMV_CFY__c;
                    oppwrap.accountName = ac.Name;
                    oppwrap.isDisabledOpp = true;
                    oppwrap.isDecisionOption = true;
                    oppwrap.isPrimeOppDisabled = true;
                    OpportunityWrapperList.add(oppwrap);
                }
                if (OpportunityWrapperList != null && !OpportunityWrapperList.isEmpty()){
                    return JSON.serialize(OpportunityWrapperList);
                }
            }
        }
        return null;
    }

    @AuraEnabled
    public static String fetchOpportunitiesfromChildAccount(String parentAccountId, String product, String method, String serviceProvider){

        Set<Id> childAccountIdSet = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<OpportunityDetailWrap> OpportunityWrapperList = new List<OpportunityDetailWrap>();
        List<Account> accList = new List<Account>();
        if (parentAccountId != null && parentAccountId != ''){
            /*Make a Dynamic Query on Different Conditions.*/

            String query = 'SELECT Id, Name, Merchant_ID__c, GMV_CFY__c, ';
            if (product != '' && product != null){
                query += '(SELECT Id, Name, StageName, Type, Methods__c, CreatedDate, BANT_Qualification_Rec__c, BANT_Qualification_Rec__r.CreatedDate,BANT_Qualification__c, BANT_Qualification_Rec__r.Name ';
                query += 'FROM Opportunities ';
                query += 'WHERE Merchant_ID__c != \'\' ';
                if ((method != '' && method != null) && (serviceProvider != '' && serviceProvider != null)){
                    query += 'AND Type = \'' + product + '\' AND Methods__c = \'' + method + '\' AND Service_Provider__c = \'' + serviceProvider + '\' ';
                } else if ((method != '' && method != null) && (serviceProvider == '' || serviceProvider == null)){
                    query += 'AND Type = \'' + product + '\' AND Methods__c = \'' + method + '\' ';
                } else if ((method == '' || method != null) && (serviceProvider != '' && serviceProvider != null)){
                    query += 'AND Type = \'' + product + '\' AND Service_Provider__c = \'' + serviceProvider + '\' ';
                } else{
                    query += 'AND Type = \'' + product + '\' ';
                }
                query += 'ORDER BY LastModifiedDate DESC LIMIT 1) ';
            }
            query += 'FROM Account ';
            query += 'WHERE ParentId = :parentAccountId AND Merchant_ID__c != \'\' ';
            query += 'ORDER BY GMV_CFY__c DESC';

            accList = Database.query(query);
            System.debug('93 accList==>' + JSON.serializePretty(accList));
            /*ENd  Dynamic Query*/
            if (accList != null && !accList.isEmpty()){
                for (Account ac : accList){
                    if (ac.Opportunities.size() > 0){
                        for (Opportunity opp : ac.Opportunities){
                            OpportunityDetailWrap oppwrap = new OpportunityDetailWrap();
                            oppwrap.Id = opp.Id;
                            oppwrap.isPrimeOpp = false;
                            oppwrap.account_Id = ac.Id;
                            if ((opp.BANT_Qualification_Rec__c != null || opp.BANT_Qualification_Rec__c != '') && opp.BANT_Qualification__c == 'HQL'){
                                oppwrap.isDisabledOpp = true;
                                oppwrap.inputRow = 'inputRow';
                                oppwrap.isBANTOpp = true;
                                oppwrap.isDecisionOption = true;
                                oppwrap.BANTName = opp.BANT_Qualification_Rec__r.Name;
                                oppwrap.BANTId = opp.BANT_Qualification_Rec__c;
                                oppwrap.BANTCreatedDate = opp.BANT_Qualification_Rec__r.CreatedDate;
                                oppwrap.Name = opp.Name + ' - (BANT Opportunity)';
                            } else{
                                oppwrap.Name = opp.Name;
                            }
                            if (opp.StageName == 'Closed Won' || opp.StageName == 'Onboarding'){
                                oppwrap.isDecisionOption = true;
                                oppwrap.isDisabledOpp = true;
                                oppwrap.inputRow = 'inputRow';
                            } else if (opp.StageName == 'Closed Lost'){
                                oppwrap.isClosedLost = true;
                                oppwrap.isDecisionOption = true;
                                oppwrap.isDisabledOpp = false;
                                oppwrap.inputRow = '';


                            } else if (opp.StageName == 'Open'){
                                oppwrap.isDecisionOption = true;
                            }
                            if ((opp.Type == 'Opfin' || opp.Type == 'Current_Account' || opp.Type == 'Payout_Link' || opp.Type == 'Tax_Payment' || opp.Type == 'GST_AdvanceTax_Payments' || opp.Type == 'Escrow' || opp.Type == 'Payout Pro' || opp.Type == 'Accounting Integration' || opp.Type == 'Bulk Payout' || opp.Type == 'P2P' || opp.Type == 'Digital_wallet' || opp.Type == 'Enterprise Neobanking' || opp.Type == 'Vendor_Payout' || opp.Type == 'MARKETPLACE_ES' || opp.Type == 'LOC' || opp.Type == 'Corporate Cards' || opp.Type == 'Early Settlement') && opp.StageName != 'Closed Lost'){
                                oppwrap.isDecisionOption = true;
                                oppwrap.isDisabledOpp = true;
                                oppwrap.inputRow = 'closeLostinputRow';
                            }
                            oppwrap.StageName = opp.StageName;
                            oppwrap.Type = opp.Type;
                            oppwrap.Methods = opp.Methods__c;
                            oppwrap.Merchant_ID = ac.Merchant_ID__c;
                            oppwrap.accountName = ac.Name;
                            oppwrap.created_Date = Date.valueOf(opp.CreatedDate);
                            oppwrap.isResetStage = false;
                            oppwrap.GMV_CFY = ac.GMV_CFY__c;
                            oppwrap.isOpportunityExist = true;
                            oppwrap.isPrimeOppDisabled = false;
                            OpportunityWrapperList.add(oppwrap);
                        }
                    } else{
                        OpportunityDetailWrap oppwrap = new OpportunityDetailWrap();
                        oppwrap.account_Id = ac.Id;
                        oppwrap.Merchant_ID = ac.Merchant_ID__c;
                        oppwrap.GMV_CFY = ac.GMV_CFY__c;
                        oppwrap.accountName = ac.Name;
                        oppwrap.isOpportunityExist = false;
                        oppwrap.isDecisionOption = true;
                        oppwrap.isPrimeOppDisabled = false;
                        OpportunityWrapperList.add(oppwrap);
                    }
                }
            }
        }
        if (OpportunityWrapperList != null){
            return JSON.serialize(OpportunityWrapperList);
        }
        return null;
    }

    @AuraEnabled
    public static boolean handleOpportunityRecord(String OpportunityDetails, String bantRecordId, String PrimeMID){
        Boolean isUpdated = false;
        Boolean isInserted = false;
        Boolean isCloned = false;
        String ownerId = '';
        String parenetAccountId = '';
        String businessUnit = '';
        System.debug('updateOpportunityDetails' + OpportunityDetails);
        List<OpportunityInfo> OpportunityDetailsList = (List<OpportunityInfo>)JSON.deserialize(OpportunityDetails, List<OpportunityInfo>.class);

        System.debug('updateOpportunityDetails test =>' + JSON.serializePretty(OpportunityDetailsList));
        List<Opportunity> updateopList = new List<Opportunity>();
        List<String> cloneOpportunityIdList = new List<String>();
        List<String> OpportunityIdList = new List<String>();
        List<Opportunity> createNewOpportunityList = new List<Opportunity>();
        Map<String, Boolean> cloneOppIdVsPrimeMidMap = new Map<String, Boolean>();
        String primaryMerchantIdForClonedOpp = '';

        Integer noOfStores;
        String CategoryOfMerchant;

        try{
            if (OpportunityDetailsList != null && bantRecordId != ''){
                parenetAccountId = OpportunityDetailsList[0].parentAccountId;
                businessUnit = OpportunityDetailsList[0].businessUnit;

                System.debug('Product Type =>' + OpportunityDetailsList[0].Type + 'Method =>' + OpportunityDetailsList[0].Methods + 'Parent Account Id => ' + OpportunityDetailsList[0].parentAccountId + 'Region=>' + OpportunityDetailsList[0].regionforEng + 'Category=>' + OpportunityDetailsList[0].categoryforGC);

                if ((OpportunityDetailsList[0].Type == 'CLP Gift Card Issuing' || OpportunityDetailsList[0].Type == 'CLP Wallet Issuance' || OpportunityDetailsList[0].Type == 'SCLP Gift Card Issuing' || OpportunityDetailsList[0].Type == 'SCLP Wallet Issuance') && OpportunityDetailsList[0].regionforEng != null){
                    System.debug('1Region wise');
                    ownerId = assignOpportunityOwner(OpportunityDetailsList[0].Type, OpportunityDetailsList[0].Methods, OpportunityDetailsList[0].parentAccountId, OpportunityDetailsList[0].regionforEng, '');
                    System.debug(ownerId);

                } else if (OpportunityDetailsList[0].Type == 'GC distribution catalog' && OpportunityDetailsList[0].categoryforGC != null){
                    System.debug('2Catory wise');
                    ownerId = assignOpportunityOwner(OpportunityDetailsList[0].Type, OpportunityDetailsList[0].Methods, OpportunityDetailsList[0].parentAccountId, '', OpportunityDetailsList[0].categoryforGC);
                    System.debug(ownerId);
                } else{
                    System.debug('3Product or method wise');
                    ownerId = assignOpportunityOwner(OpportunityDetailsList[0].Type, OpportunityDetailsList[0].Methods, OpportunityDetailsList[0].parentAccountId, '', '');
                    System.debug(ownerId);
                }

                System.debug('202 ownerId=>' + ownerId);

                for (OpportunityInfo info : OpportunityDetailsList){
                    if (info.isOppExist == true && info.isClosedLost == null && info.stageName != 'Closed Lost'){
                        Opportunity op = new Opportunity();
                        op.Id = info.opportunityId;
                        op.Engage_HQ_Category__c = info.engage_hq_category;
                        op.Business_Unit__c = info.businessUnitProd;
                        op.BANT_Qualification_Rec__c = bantRecordId;
                        op.BANT_Qualification__c = 'HQL';
                        op.BU_Assigned_Date__c = System.now();

                        if (PrimeMID != ''){
                            op.Primary_MID__c = PrimeMID;
                        }
                        if (info.Type == 'Bill Me'){
                            if (info.noOfStores != null && String.isNotBlank(info.noOfStores)){
                                op.No_of_Stores__c = Integer.valueOf(info.noOfStores);
                            }

                            if (info.categoryOfMerchant != null && String.isNotBlank(info.categoryOfMerchant)){
                                op.Category_of_Merchant__c = String.valueOf(info.categoryOfMerchant);
                            }
                        }

                        if (info.isPrimeOpp == true && info.isPrimeOpp != null){
                            op.Is_Prime_Opportunity__c = info.isPrimeOpp;

                        } else if (info.isPrimeOpp == false && info.isPrimeOpp != null){
                            op.Is_Prime_Opportunity__c = info.isPrimeOpp;
                        }
                        if (ownerId != ''){
                            op.OwnerId = ownerId;
                        }
                        System.debug('update OwnerId' + op.OwnerId);
                        if (info.isResetstage == true && (info.stageName != 'Open' || info.stageName != 'Closed Lost')){
                            op.stageName = 'Open';
                        }
                        updateopList.add(op);
                        System.debug('Op values that have been added: ' + updateopList);
                    } else if (info.isOppExist == false){
                        Opportunity opp1 = new Opportunity();
                        opp1.BANT_Qualification_Rec__c = bantRecordId;
                        opp1.Business_Unit__c = info.businessUnitProd;
                        opp1.AccountId = info.AccountId;
                        opp1.Engage_HQ_Category__c = info.engage_hq_category;
                        opp1.Service_Provider__c = info.serviceProvider;
                        opp1.CloseDate = Date.today().addDays(30);
                        opp1.Methods__c = info.Methods;
                        opp1.BU_Assigned_Date__c = System.now();
                        opp1.StageName = 'open';
                        opp1.Type = info.Type;
                        opp1.BANT_Qualification__c = 'HQL';
                        if (PrimeMID != ''){
                            opp1.Primary_MID__c = PrimeMID;
                        }
                        if (info.Type == 'Bill Me'){
                            if (info.noOfStores != null && String.isNotBlank(info.noOfStores)){
                                opp1.No_of_Stores__c = Integer.valueOf(info.noOfStores);
                            }
                            if (info.categoryOfMerchant != null && String.isNotBlank(info.categoryOfMerchant)){
                                opp1.Category_of_Merchant__c = String.valueOf(info.categoryOfMerchant);
                            }
                        }

                        if (info.isPrimeOpp == true && info.isPrimeOpp != null){

                            opp1.Is_Prime_Opportunity__c = info.isPrimeOpp;


                        }

                        if (ownerId != ''){
                            opp1.OwnerId = ownerId;
                        }
                        String OppTypeMethodSPName = '';
                        if (!String.isEmpty(info.Methods) && !String.isEmpty(info.serviceProvider)){

                            OppTypeMethodSPName = info.Type + '_' + info.Methods + '_' + info.serviceProvider;

                        } else if (!String.isEmpty(info.Methods) && String.isEmpty(info.serviceProvider)){

                            OppTypeMethodSPName = info.Type + '_' + info.Methods;

                        } else if (String.isEmpty(info.Methods) && !String.isEmpty(info.serviceProvider)){

                            OppTypeMethodSPName = info.Type + '_' + info.serviceProvider;
                        } else{
                            OppTypeMethodSPName = info.Type;
                        }
                        if (!String.isEmpty(OppTypeMethodSPName) && OppTypeMethodSPName != ''){
                            opp1.Name = info.accountName + '_' + OppTypeMethodSPName;
                            opp1.Merchant_ID__c = info.Merchant_ID + '_' + OppTypeMethodSPName;
                        }
                        createNewOpportunityList.add(opp1);
                    } else if (info.isOppExist == true && info.isClosedLost == true && info.stageName == 'Closed Lost'){
                        cloneOpportunityIdList.add(info.opportunityId);


                        if (info.isPrimeOpp == true && info.isPrimeOpp != null){
                            cloneOppIdVsPrimeMidMap.put(info.opportunityId, info.isPrimeOpp);

                        }
                        if (info.Type == 'Bill Me'){
                            if (info.noOfStores != null && String.isNotBlank(info.noOfStores)){
                                noOfStores = Integer.valueOf(info.noOfStores);
                            }
                            if (info.categoryOfMerchant != null && String.isNotBlank(info.categoryOfMerchant)){
                                CategoryOfMerchant = String.valueOf(info.categoryOfMerchant);
                            }
                        }
                    }
                }
                if (ownerId != '' && bantRecordId != ''){
                    try{
                        BANT_Qualification__c bq = new BANT_Qualification__c();
                        bq.Id = bantRecordId;
                        if(String.isBlank(bq.BANT_Source__c)){
                          bq.BANT_Source__c ='Direct';
                        }
                        bq.BU_Product_Owner__c = ownerId;
                        update bq;

                    } catch (Exception e){
                        System.debug('Exception==>' + e.getMessage());
                    }


                }
                if (updateopList != null && !updateopList.isEmpty()){
                    Database.SaveResult[] updatedOpportunity = Database.update (updateopList);
                    for (Database.SaveResult sr : updatedOpportunity){
                        if (sr.isSuccess()){
                            OpportunityIdList.add(sr.getId());
                            isUpdated = true;
                        }
                    }
                }
                if (createNewOpportunityList != null && !createNewOpportunityList.isEmpty()){
                    System.debug('254 createNewOpportunityList==>' + JSON.serializePretty(createNewOpportunityList));
                    Database.SaveResult[] insertopp = database.insert (createNewOpportunityList);
                    System.debug('insertopp==289>' + insertopp);
                    for (Database.SaveResult sr : insertopp){
                        if (sr.isSuccess()){
                            OpportunityIdList.add(sr.getId());
                            isInserted = true;
                        }
                    }
                }
                if (!cloneOpportunityIdList.isEmpty() && cloneOpportunityIdList != null && ownerId != ''){
                    List<String> cloneOppIdList = cloneAndModifyOriginalOpportunities(cloneOpportunityIdList, ownerId, bantRecordId, PrimeMID, cloneOppIdVsPrimeMidMap, noOfStores, CategoryOfMerchant);
                    System.debug('cloneOppIdList' + cloneOppIdList);
                    if (cloneOppIdList != null && !cloneOppIdList.isEmpty()){
                        for (String coi : cloneOppIdList){
                            OpportunityIdList.add(coi);
                        }

                        isCloned = true;
                    }
                }
                if (!OpportunityIdList.isEmpty() && OpportunityIdList != null){

                    if (ownerId != ''){
                        sendNotificationToOppOwners(ownerId, bantRecordId);
                    }
                    if (parenetAccountId != ''){
                        sendOpportunityAssignmentEmail(OpportunityIdList, parenetAccountId);
                    }
                }
            }
        } catch (Exception e){
            System.debug('e >>' + e.getMessage());
            System.debug('e.getLineNumber()>>' + e.getLineNumber());
            //this method for when opportunity get any error.

            try{
                BANT_Qualification__c[] BANTRecord = [SELECT Id
                                                      FROM BANT_Qualification__c
                                                      WHERE Id = :bantRecordId
                                                      LIMIT 1];
                delete BANTRecord;
            } Catch (Exception ex){
                throw new AuraHandledException('Exception Occured in delete Bent at line number ' + ex.getLineNumber() + ' with Message : ' + ex.getMessage());
            }


            throw new AuraHandledException(e.getMessage());
        }
        return isCloned || isInserted || isUpdated;
    }

    public static List<String> cloneAndModifyOriginalOpportunities(List<String> originalOpportunityIds, String ownerId, String bantRecordId, String primaryMID, Map<String, Boolean> cloneOppIdVsPrimeMidMap, Integer noOfStores, String CategoryOfMerchant){
        List<String> clonedOpportunityIds = new List<String>();

        try{
            if (!originalOpportunityIds.isEmpty() && originalOpportunityIds != null){
                List<Opportunity> opportunities = [SELECT Id, Name, Merchant_ID__c, Methods__c, Engage_HQ_Category__c, Service_Provider__c, AccountId, Account.ParentId, Type, CloseDate, StageName, Business_Unit__c, No_of_Stores__c, Category_of_Merchant__c
                                                   FROM Opportunity
                                                   WHERE Id IN:originalOpportunityIds];

                List<Opportunity> clonedOpportunities = new List<Opportunity>();

                for (Opportunity originalOpportunity : opportunities){
                    Opportunity clonedOpportunity = originalOpportunity.clone(false, true); // shallow clone of the Opportunity

                    // Modify the cloned Opportunity
                    clonedOpportunity.Merchant_ID__c = originalOpportunity.Merchant_ID__c;
                    clonedOpportunity.StageName = 'Open';
                    clonedOpportunity.CloseDate = System.today().addDays(45);
                    clonedOpportunity.Type = originalOpportunity.Type;
                    clonedOpportunity.AccountId = originalOpportunity.AccountId;
                    clonedOpportunity.Engage_HQ_Category__c = originalOpportunity.Engage_HQ_Category__c;
                    clonedOpportunity.Service_Provider__c = originalOpportunity.Service_Provider__c;
                    clonedOpportunity.Business_Unit__c = originalOpportunity.Business_Unit__c;
                    String originalOppName = originalOpportunity.Name + '_cloned';
                    clonedOpportunity.Name = originalOppName;

                    if (clonedOpportunity.Type == 'Bill Me'){
                        if (noOfStores != null){
                            clonedOpportunity.No_of_Stores__c = noOfStores;
                        }
                        if (CategoryOfMerchant != null){
                            clonedOpportunity.Category_of_Merchant__c = CategoryOfMerchant;
                        }
                    }

                    clonedOpportunity.Methods__c = originalOpportunity.Methods__c;
                    clonedOpportunity.BANT_Qualification__c = 'HQL';
                    clonedOpportunity.BU_Assigned_Date__c = System.now();
                    if (ownerId != ''){
                        clonedOpportunity.OwnerId = ownerId;
                    }
                    if (bantRecordId != ''){
                        clonedOpportunity.BANT_Qualification_Rec__c = bantRecordId;
                    }
                    if (primaryMID != ''){
                        clonedOpportunity.Primary_MID__c = primaryMID;
                    }
                    if (!cloneOppIdVsPrimeMidMap.isEmpty() && cloneOppIdVsPrimeMidMap.containsKey(originalOpportunity.Id)){
                        clonedOpportunity.Is_Prime_Opportunity__c = cloneOppIdVsPrimeMidMap.get(originalOpportunity.Id);
                    }


                    clonedOpportunities.add(clonedOpportunity);

                    // Modify the original Opportunity
                    originalOpportunity.Merchant_ID__c = '';
                }

                if (!clonedOpportunities.isEmpty()){
                    Database.SaveResult[] updateResults = Database.update (opportunities, false);
                    List<Opportunity> successfulUpdates = new List<Opportunity>();

                    for (Database.SaveResult updateResult : updateResults){
                        if (updateResult.isSuccess()){
                            successfulUpdates.add(opportunities[updateResults.indexOf(updateResult)]);
                        } else{
                            for (Database.Error error : updateResult.getErrors()){
                                System.debug('Error in updating the original Opportunity: ' + error.getMessage());
                            }
                        }
                    }

                    if (!successfulUpdates.isEmpty()){
                        Database.SaveResult[] insertResults = Database.insert (clonedOpportunities, false);

                        for (Database.SaveResult insertResult : insertResults){
                            if (insertResult.isSuccess()){
                                clonedOpportunityIds.add(insertResult.getId());
                            } else{
                                for (Database.Error error : insertResult.getErrors()){
                                    System.debug('Error in inserting the cloned Opportunity: ' + error.getMessage());
                                }
                            }
                        }
                    }
                }
            }
        } catch (Exception ex){
            System.debug('An error occurred while cloning the Opportunities: ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }

        return clonedOpportunityIds;
    }

    public static String assignOpportunityOwner(String productName, String methodName, String parentAccId, String regionforEng, String categoryforGC){
        String oppOwnerId = '';
        List<AccountTeamMember> accTeamMemberList = [SELECT Id, Product__c, Method__c, UserId, User.Name, Region__c, Category__c
                                                     FROM AccountTeamMember
                                                     WHERE AccountId = :parentAccId];
        System.debug('accTeamMemberList=>' + accTeamMemberList);
        if (accTeamMemberList != null && !accTeamMemberList.isEmpty()){
            for (AccountTeamMember accTeamMember : accTeamMemberList){


                if (accTeamMember != null && accTeamMember.Product__c != null){
                    if (productName != null && !String.isBlank(productName) && methodName != null && !String.isBlank(methodName)){

                        if (accTeamMember.Method__c != null && !String.isBlank(accTeamMember.Method__c) && accTeamMember.Product__c.split(';').contains(productName) && accTeamMember.Method__c.split(';').contains(methodName)){
                            oppOwnerId = accTeamMember.UserId;
                        }
                        System.debug('533 accTeamMemberList=>' + oppOwnerId);

                    } else if (productName != null && !String.isBlank(productName) && (methodName == null || String.isBlank(methodName))){
                        if (regionforEng != null && !String.isBlank(regionforEng) && (categoryforGC == null || String.isBlank(categoryforGC)) && accTeamMember.Region__c != null){
                            if (accTeamMember.Product__c.split(';').contains(productName) && accTeamMember.Region__c.split(';').contains(regionforEng)){
                                oppOwnerId = accTeamMember.UserId;
                            }
                            System.debug('540 accTeamMemberList=>' + oppOwnerId);

                        } else if ((regionforEng == null || String.isBlank(regionforEng)) && categoryforGC != null && !String.isBlank(categoryforGC) && accTeamMember.Category__c != null){
                            if (accTeamMember.Product__c.split(';').contains(productName) && accTeamMember.Category__c.split(';').contains(categoryforGC)){
                                oppOwnerId = accTeamMember.UserId;
                            }
                            System.debug('546 accTeamMemberList=>' + oppOwnerId);

                        } else if (String.isBlank(regionforEng) && String.isBlank(categoryforGC)){
                            if (accTeamMember.Product__c.split(';').contains(productName)){
                                oppOwnerId = accTeamMember.UserId;
                            }
                            System.debug('552 accTeamMemberList=>' + oppOwnerId);

                        }
                    }
                }


            }
            if (oppOwnerId == ''){
                Account parentAcc = [SELECT Id, OwnerId
                                     FROM Account
                                     WHERE Id = :parentAccId
                                     LIMIT 1];
                if (parentAcc != null){
                    oppOwnerId = parentAcc.OwnerId;
                }
            }
        } else if (oppOwnerId == ''){
            Account parentAcc = [SELECT Id, OwnerId
                                 FROM Account
                                 WHERE Id = :parentAccId
                                 LIMIT 1];
            if (parentAcc != null){
                oppOwnerId = parentAcc.OwnerId;
            }
        }
        System.debug('oppOwnerId=>' + oppOwnerId);
        if (oppOwnerId != ''){
            return oppOwnerId;
        }
        return null;
    }

    public static void sendNotificationToOppOwners(String recipientId, String targetId){
        CustomNotificationType notificationType = [SELECT Id, DeveloperName
                                                   FROM CustomNotificationType
                                                   WHERE DeveloperName = 'Opportunity_Assignment_Notification_Through_BANT'];
        if (targetId != '' && recipientId != ''){

            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            // Set the contents for the notification
            notification.setTitle('BANT Record!');
            notification.setBody('A BANT record has been created for your action.');
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            // Actually send the notification
            try{
                notification.send(new Set<String>{ recipientId });
            } catch (Exception e){
                System.debug('Problem sending notification: ' + e.getMessage());
            }

        }
        createFeedRecord(recipientId, 'BANT Record!');
        // FeedItem feed = new FeedItem();
        // feed.ParentId = recipientId;
        // feed.Body = 'BANT Record!';
        // insert feed;
    }

    public static void sendOpportunityAssignmentEmail(List<String> opportunityIdList, String parentAccountId){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> cclist = new List<String>();
        List<String> tolist = new List<String>();
        Account parentAccount = [SELECT Id, Name, OwnerId, Owner.Name, Owner.Email
                                 FROM Account
                                 WHERE Id = :parentAccountId
                                 LIMIT 1];

        List<Opportunity> sendEmailOpportunityList = [SELECT Id, Name, OwnerId, Owner.Name, Owner.ManagerId, Owner.Manager.Email, Account.Name, Account.OwnerId, Account.Owner.Name, Owner.Email, BANT_Qualification_Rec__r.Name, BANT_Qualification_Rec__c
                                                      FROM Opportunity
                                                      WHERE Id IN:opportunityIdList AND Is_Prime_Opportunity__c = true
                                                      LIMIT 1];
        for (Opportunity op : sendEmailOpportunityList){
            // Create Email Subject
            String subject = op.BANT_Qualification_Rec__r.Name + ' record has been created for your action';
            // Create Email Body
            String body = 'Hi ' + op.Owner.Name + '<br/><br/>';
            body += 'There is a Prime Opportunity assigned to you. Please follow the link below to access the opportunity:<br/><br/>';
            body += '<b>Parent Account</b>: ' + parentAccount.Name + '<br/>';
            body += '<b>Parent Account Owner</b>: ' + parentAccount.Owner.Name + '<br/>';
            body += '<b>Account Name</b>: ' + op.Account.Name + '<br/>';
            body += '<b>Prime Opportunity link</b>: <a href="' + URL.getOrgDomainURL().toExternalForm() + '/' + op.Id + '">' + op.Name + '</a><br/><br/>';
            body += '<b>BANT Link</b>: <a href="' + URL.getOrgDomainURL().toExternalForm() + '/' + op.BANT_Qualification_Rec__c + '">' + op.BANT_Qualification_Rec__r.Name + '</a><br/><br/>';
            if (parentAccount.Owner.Email != null){
                cclist.add(parentAccount.Owner.Email);
            }

            if (op.Owner.Email != null){
                tolist.add(op.Owner.Email);

            }
            if (op.Owner.Manager.Email != null){
                tolist.add(op.Owner.Manager.Email);
            }


            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subject);
            email.setHtmlBody(body);
            email.setToAddresses(tolist);
            email.setCcAddresses(cclist);
            emailList.add(email);
        }

        Messaging.SendEmailResult[] result = Messaging.sendEmail(emailList);
        System.debug('result' + result);
    }

    /********************Code for update BANT END*************************/
    @AuraEnabled(cacheable = true)
    public static BANT_Qualification__c bantDetails(String bantId){
        System.debug('bantId=>' + bantId);
        if (String.isNotBlank(bantId)){
            BANT_Qualification__c bantDetails = [SELECT Id, NAME, Account__c,Engage_HQ_Category__c, Product__c, Methods__c, Service_Provider__c, Primary_MID__c, OwnerId, Status__c, Business_Unit__c, Lead__c
                                                 FROM BANT_Qualification__c
                                                 WHERE Id = :bantId];
            System.debug('bantDetailList=>' + bantDetails);
            if (bantDetails != null){
                return bantDetails;
            }
        }
        return null;
    }

    @AuraEnabled
    public static boolean updateBANTRecord(String bantRecordId, String selectedMerchantIds){
        try{
            BANT_Qualification__c bantQualification = [SELECT Id, status__c, Merchant_ID__c
                                                       FROM BANT_Qualification__c
                                                       WHERE Id = :bantRecordId];
            if (bantQualification != null && bantQualification.status__c == 'Draft'){
                bantQualification.status__c = 'Reject';
                bantQualification.Merchant_ID__c = String.isNotBlank(selectedMerchantIds) ? selectedMerchantIds : bantQualification.Merchant_ID__c;
                Database.SaveResult saveResult = Database.update (bantQualification, false);
                return saveResult.isSuccess();
            } else{
                return false;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Added By Navneet to get revamp BANT data
    @AuraEnabled(cacheable = false)
    public static void updateCurrentBANTCount(string recordId){
        System.debug('Inside current BANT Count');
        List<BANT_Qualification__c> currentBANTData = [SELECT Id, No_of_attempt__c, Last_attepmt_date__c
                                                       FROM BANT_Qualification__c
                                                       WHERE id = :recordId
                                                       LIMIT 1];
        System.debug('record we got: ' + currentBANTData);
        try{
            if (currentBANTData.size() > 0 && !currentBANTData.isEmpty()){
                BANT_Qualification__c bant = currentBANTData[0];
                if (bant.No_of_attempt__c == null){
                    bant.No_of_attempt__c = 0;
                } else{
                    bant.No_of_attempt__c += 1;
                }
                bant.Last_attepmt_date__c = System.now();
                Database.SaveResult updateBantResult = database.update (bant);
                if (updateBantResult.isSuccess()){
                    string toInsertInBant = 'Total number of revamp BANT Attempts: ' + bant.No_of_attempt__c;
                    createFeedRecord(recordId, toInsertInBant);
                    // return 'Success';
                }
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        // return null;
    }

    @AuraEnabled(cacheable = true)
    public Static Object getRevampBantData(String recordId){
        System.debug('Record Id Of the Parent BANT =>' + recordId);
        List<BANT_Qualification__c> bantData = [SELECT Id, Product__c, Primary_MID__c, Account__c, Merchant_ID__c, Business_Unit__c, Status__c, Methods__c, BU_Product_Owner__c, Add_On_BANT_of_the_product__c, Service_Provider__c, Engage_HQ_Category__c, No_of_Stores__c, Category_of_Bant_Non_bant_Lead__c
                                                FROM BANT_Qualification__c
                                                WHERE Id = :recordId
                                                LIMIT 1];
        System.debug('bantData =>' + bantData);

        if (bantData != null && bantData.size() > 0){
            Map<String, String> childAccountMap = getChildAccount(bantData[0].Primary_MID__c);
            String childAccountId = childAccountMap.get('Id');
            String childAccountName = childAccountMap.get('Name');
            List<Object> bantDataFinal = new List<Object>();
            bantDataFinal.add(bantData[0]);
            bantDataFinal.add(childAccountId);
            bantDataFinal.add(childAccountName);
            System.debug('bantDataFinal is =>' + bantDataFinal);
            // bantDataFinal.add(childAccountName);

            return bantDataFinal;
        }
        return null;
    }

    // @AuraEnabled(cacheable = true)
    public Static Map<String, String> getChildAccount(String merchantId){
        if (String.isNotBlank(merchantId)){
            List<Account> accData = [SELECT Id, Name
                                     FROM Account
                                     WHERE Merchant_ID__c = :merchantId];
            Map<String, String> accDataMap = new Map<String, String>();
            accDataMap.put('Id', accData[0].Id);
            accDataMap.put('Name', accData[0].Name);
            System.debug(accDataMap);
            if (accDataMap != null && accDataMap.size() > 0){
                return accDataMap;
            }
        }

        return null;
    }

    @AuraEnabled
    public static string createRevampBANT(String data){
        System.debug('data we got -> ' + data);
        if (data != null && String.isNotBlank(data)){
            Map<String, Object> finalDataLst = (Map<String, Object>)JSON.deserializeUntyped(data);
            String productGMVPotentialStr = (String) finalDataLst.get('Product_GMV_Potential_in_Cr__c');
            Decimal productGMVPotentialDecimal;
            if (productGMVPotentialStr != null && productGMVPotentialStr.length() > 0){
                productGMVPotentialDecimal = Decimal.valueOf(productGMVPotentialStr);
            }

            Integer noOfStoresInteger = 0;
            Integer No_of_agents_who_handle_delivery = 0;
            System.debug('(String)finalDataLst.get(\'No_of_Stores__c\') => ' + finalDataLst.get('No_of_Stores__c'));
            if ((String) finalDataLst.get('No_of_Stores__c') != '' && (String) finalDataLst.get('No_of_Stores__c') != null){
                String noOfStoresStr = (String) finalDataLst.get('No_of_Stores__c');
                noOfStoresInteger = Integer.valueOf(noOfStoresStr);
            }
            if ((String) finalDataLst.get('No_of_agents_who_handle_delivery__c') != '' && (String) finalDataLst.get('No_of_agents_who_handle_delivery__c') != null){
                String Noofagentswhohandledelivery = (String) finalDataLst.get('No_of_agents_who_handle_delivery__c');
                No_of_agents_who_handle_delivery = Integer.valueOf(Noofagentswhohandledelivery);
            }
            System.debug('ParentAccount is ->' + finalDataLst.get('ParentAccount'));
            BANT_Qualification__c revampBant = new BANT_Qualification__c(// Revamp details
            BANT_Source__c ='Revamp',

            is_Revamp_BANT__c = (Boolean) finalDataLst.get('is_Revamp_BANT__c'), Primary_MID__c = (String) finalDataLst.get('PrimaryMID'), Account__c = (String) finalDataLst.get('ParentAccount'), Product__c = (String) finalDataLst.get('product'), BANT_Qualification__c = (String) finalDataLst.get('BANT_Qualification__c'), Merchant_ID__c = (String) finalDataLst.get('selectedMerchantIds'), Business_Unit__c = (String) finalDataLst.get('business_Unit'), Methods__c = (String) finalDataLst.get('methods'), Original_Revamp_BANT__c = (String) finalDataLst.get('Original_Revamp_BANT__c'), Status__c = (String) finalDataLst.get('bant_Status'), 
            // Budget
            Is_the_merchant_willing_to_pay_Y_N__c = (String) finalDataLst.get('Is_the_merchant_willing_to_pay_Y_N__c'), Budget_Why_not_willing_to_pay__c = (String) finalDataLst.get('Budget_Why_not_willing_to_pay__c'), Details_for_merchant_willing_to_pay__c = (String) finalDataLst.get('Details_for_merchant_willing_to_pay__c'), 
            // Authority
            Merchant_SPOC_Name__c = (String) finalDataLst.get('Merchant_SPOC_Name__c'), Merchant_Phone__c = (String) finalDataLst.get('Merchant_Phone__c'), Merchant_Email__c = (String) finalDataLst.get('Merchant_Email__c'), Merchant_Department__c = (String) finalDataLst.get('Merchant_Department__c'), Auth_Have_they_shared_an_interest__c = (String) finalDataLst.get('Auth_Have_they_shared_an_interest__c'), 
            // Need
            Auth_Does_the_merchant_have_a_clear_need__c = (String) finalDataLst.get('Auth_Does_the_merchant_have_a_clear_need__c'), Is_merchant_s_requirement_fulfilled__c = (String) finalDataLst.get('Is_merchant_s_requirement_fulfilled__c'), Product_GMV_Potential_in_Cr__c = productGMVPotentialDecimal, Comments_on_Dependencies_if_any__c = (String) finalDataLst.get('Comments_on_Dependencies_if_any__c'), If_Yes_then_share_the_Merchant_Use_case__c = (String) finalDataLst.get('If_Yes_then_share_the_Merchant_Use_case__c'), Does_the_merchant_require_convincing__c = (String) finalDataLst.get('Does_the_merchant_require_convincing__c'), dependencies_priorities_to_convert_QL__c = (String) finalDataLst.get('dependencies_priorities_to_convert_QL__c'), 
            // Timeline
            The_merchant_wants_to_go_live__c = (String) finalDataLst.get('The_merchant_wants_to_go_live__c'), Timeline_Remarks__c = (String) finalDataLst.get('Timeline_Remarks__c'), 
            // Physical Stores
            Does_Merchant_have_physical_stores__c = (String) finalDataLst.get('Does_Merchant_have_physical_stores__c'), No_of_Stores__c = noOfStoresInteger,                                                      // (Integer)finalDataLst.get('No_of_Stores__c'),
            Category_of_Bant_Non_bant_Lead__c = (String) finalDataLst.get('Category_of_Bant_Non_bant_Lead__c'), Is_the_merchant_currently_with_Paytm__c = (String) finalDataLst.get('Is_the_merchant_currently_with_Paytm__c'), If_not_which_competitor_are_they_using__c = (String) finalDataLst.get('If_not_which_competitor_are_they_using__c'), 
            // Business Delivery
            Does_the_merchant_deliver_products__c = (String) finalDataLst.get('Does_the_merchant_deliver_products__c'), No_of_agents_who_handle_delivery__c = No_of_agents_who_handle_delivery, Is_merchant_currently_with_Paytm_Y_N__c = (String) finalDataLst.get('Is_merchant_currently_with_Paytm_Y_N__c'), If_not_which_competitor_are_they_using_P__c = (String) finalDataLst.get('If_not_which_competitor_are_they_using_P__c'), 
            // Region
            HQ_in_which_city__c = (String) finalDataLst.get('HQ_in_which_city__c'), Which_bank_do_they_have_their_settlement__c = (String) finalDataLst.get('Which_bank_do_they_have_their_settlement__c'), Region__c = (String) finalDataLst.get('Region__c'), 
            // Category
            Category__c = (String) finalDataLst.get('Category__c'), Service_Provider__c = (String) finalDataLst.get('serviceProvider'));
            //   System.debug('revampBant data is => ' + revampBant.Product_GMV_Potential_in_Cr__c);
            System.debug('Before insert revampBant => ' + JSON.serialize(revampBant));

            Database.SaveResult insertRevampBantResult = database.insert (revampBant);
            System.debug('insertRevampBantResult=>' + JSON.serializePretty(insertRevampBantResult));
            //   System.debug('insertRevampBantResult=>' + insertRevampBantResult.BANT_Qualifcation_link__c);

            if (insertRevampBantResult.isSuccess()){
                List<OpportunityInfo> oppInfo = new List<OpportunityInfo>();
                OpportunityInfo oppInfoData = new OpportunityInfo();
                oppInfoData.AccountId = (String) finalDataLst.get('Account__c');
                oppInfoData.Merchant_ID = (String) finalDataLst.get('selectedMerchantIds');
                System.debug('Testing MID =>' + (String) finalDataLst.get('selectedMerchantIds'));
                System.debug('revampBant.Primary_MID__c =>' + revampBant.Primary_MID__c);
                oppInfoData.Methods = (String) finalDataLst.get('methods');
                oppInfoData.parentAccountId = (String) finalDataLst.get('Account__c');
                oppInfoData.businessUnit = (String) finalDataLst.get('business_Unit');
                oppInfoData.engage_hq_category = (String) finalDataLst.get('engage_hq_category');
                oppInfoData.serviceProvider = (String) finalDataLst.get('serviceProvider');
                oppInfoData.businessUnitProd = (String) finalDataLst.get('business_Unit');
                oppInfoData.noOfStores = (String) finalDataLst.get('No_of_Stores__c');
                oppInfoData.Type = (String) finalDataLst.get('product');
                oppInfoData.isOppExist = false;
                oppInfoData.isPrimeOpp = true;
                oppInfoData.stageName = 'open';
                oppInfoData.accountName = (String) finalDataLst.get('AccountName');
                oppInfoData.regionforEng = (String) finalDataLst.get('Region__c');
                oppInfoData.categoryforGC = (String) finalDataLst.get('Category__c');
                oppInfo.add(oppInfoData);
                String dataForOpportunity = JSON.serialize(oppInfo);

                Boolean isOppCreated = handleOpportunityRecord(dataForOpportunity, revampBant.Id, revampBant.Primary_MID__c);
                System.debug('850 isOppCreated=>' + isOppCreated);


                // (String) finalDataLst.get('Original_Revamp_BANT__c');
                String recordLink = URL.getOrgDomainURL().toExternalForm() + '/' + revampBant.Id;

                if ((String) finalDataLst.get('Original_Revamp_BANT__c') != null){
                    createFeedRecord((String) finalDataLst.get('Original_Revamp_BANT__c'), 'Revamp BANT has been created. New BANT Link is :' + recordLink);
                }


                return revampBant.Id;
            } else{
                return null;
            }
        }
        return null;
    }

    public static void createFeedRecord(String parent_Id, String bodyDetails){
        FeedItem feed = new FeedItem();
        try{
            if (String.isNotBlank(bodyDetails) && String.isNotBlank(parent_Id)){
                feed.ParentId = parent_Id;
                feed.Body = bodyDetails;
            }
            insert feed;
        } catch (Exception ex){
            System.debug('ex==>' + ex);
            throw new AuraHandledException(ex.getMessage());

        }
    }

    @AuraEnabled(cacheable = true)
    public static String getCurrentUserProfileName(){
        String userProfile = [SELECT Id, profile.Name
                              FROM User
                              WHERE Id = :UserInfo.getUserId()].profile.Name;
        System.debug('userProfile=>' + userProfile);
        return userProfile;
    }

    @AuraEnabled
    public static boolean creatCMSDraftBANT(String cmsDraftBantDetail){
        String PRODUCT = '';
        String METHOD = '';
        String ACCOUNT_ID = '';
        String OWNER_ID = '';
        String  Account_Owner ='';

        if (String.isBlank(cmsDraftBantDetail)){
            return false;
        } else{
            Map<String, Object> cmsDraftBantDetailJSON = (Map<String, Object>)JSON.deserializeUntyped(cmsDraftBantDetail);
            BANT_Qualification__c instanceOfBantQualification = new BANT_Qualification__c();
            try{
                if (cmsDraftBantDetailJSON != null){

                    PRODUCT = (String) cmsDraftBantDetailJSON.get('product');
                    METHOD = (String) cmsDraftBantDetailJSON.get('methods');
                    ACCOUNT_ID = (String) cmsDraftBantDetailJSON.get('Account__c');
                    OWNER_ID = assignOpportunityOwner(PRODUCT, METHOD, ACCOUNT_ID, '', '');
                    if(String.isNotBlank(ACCOUNT_ID)){
                        Account_Owner =[SELECT Id ,ownerId FROM Account WHERE Id =:ACCOUNT_ID].OwnerId;
                    }
                    

                    instanceOfBantQualification.BANT_Source__c = 'Neobanking CSM';
                    instanceOfBantQualification.Account__c = ACCOUNT_ID;
                    instanceOfBantQualification.Product__c = PRODUCT;
                    instanceOfBantQualification.Methods__c = METHOD;
                    instanceOfBantQualification.Business_Unit__c = (String) cmsDraftBantDetailJSON.get('business_Unit');
                    instanceOfBantQualification.Engage_HQ_Category__c = (String) cmsDraftBantDetailJSON.get('engage_hq_category');
                    instanceOfBantQualification.Service_Provider__c = (String) cmsDraftBantDetailJSON.get('serviceProvider');
                    instanceOfBantQualification.Merchant_ID__c = (String) cmsDraftBantDetailJSON.get('selectedMerchantIds');
                    instanceOfBantQualification.Primary_MID__c = (String) cmsDraftBantDetailJSON.get('PrimaryMID');
                    if ((Boolean) cmsDraftBantDetailJSON.get('isPrimeBANT')){
                        instanceOfBantQualification.Earliest_BANT_ID__c = (String) cmsDraftBantDetailJSON.get('primeBANTId');
                    }
                    instanceOfBantQualification.Status__c = 'Draft';
                    if (String.isNotBlank(OWNER_ID)){
                        instanceOfBantQualification.BU_Product_Owner__c = OWNER_ID;
                       
                    }
                    if(String.isNotBlank(Account_Owner)){
                        instanceOfBantQualification.OwnerId = Account_Owner;
                    }
                    instanceOfBantQualification.draft_Contact_Phone__c = (String) cmsDraftBantDetailJSON.get('draft_Contact_Phone__c');
                    instanceOfBantQualification.draft_Contact_Email__c = (String) cmsDraftBantDetailJSON.get('draft_Contact_Email__c');
                    instanceOfBantQualification.draft_Contact_Name__c = (String) cmsDraftBantDetailJSON.get('draft_Contact_Name__c');

                    Database.saveResult saveResultData = Database.insert (instanceOfBantQualification, false);
                    System.debug('saveResultData==>' + JSON.serializePretty(saveResultData));
                    if (saveResultData.isSuccess()){
                        // if (String.isNotBlank(OWNER_ID) && saveResultData.Id != null){
                        //     sendNotificationToOppOwners(OWNER_ID, saveResultData.Id);
                        // }
                        return true;
                    } else{
                        System.debug('Insertion failed');
                        // throw new AuraHandledException(e.getMessage());
                        return false;

                    }
                }
            } catch (Exception ex){
                throw new AuraHandledException(ex.getMessage());

            }
            return null;

        }
    }

    /*********************Update BANT Details END*************************/
    public class OpportunityDetailWrap{
        public String Id{ get; set; }

        public String Merchant_ID{ get; set; }

        public String Name{ get; set; }

        public String accountName{ get; set; }

        public String account_Id{ get; set; }

        public String BaseURLName{ get; set; }

        public String BANTURLName{ get; set; }

        public String StageName{ get; set; }

        public boolean isDecisionOption{ get; set; }

        public String Type{ get; set; }

        public String Methods{ get; set; }

        public String bantqualification{ get; set; }

        public boolean isStageCloseLost{ get; set; }

        public Decimal GMV_CFY{ get; set; }

        public String alreadyOpp{ get; set; }

        public String inputRow{ get; set; }

        public Boolean isHigestGMV{ get; set; }

        public boolean checked{ get; set; }

        public boolean isClosedLost{ get; set; }

        public Date created_Date{ get; set; }

        public boolean isDisabledOpp{ get; set; }

        public boolean isResetStage{ get; set; }

        public boolean isOpportunityExist{ get; set; }

        public boolean isPrimeOpp{ get; set; }

        public boolean isPrimeOppDisabled{ get; set; }

        public boolean isBANTOpp{ get; set; }

        public String BANTId{ get; set; }

        public String BANTName{ get; set; }

        public DateTime BANTCreatedDate{ get; set; }

    }

    public class OpportunityInfo{
        public String AccountId;
        public String Merchant_ID;
        public Boolean isResetstage;
        public String stageName;
        public String opportunityId;
        public String Type;
        public String Methods;
        public boolean isOppExist;
        public String accountName;
        public Boolean isClosedLost;
        public String parentAccountId;
        public String businessUnit;
        public String engage_hq_category;
        public String serviceProvider;
        public boolean isPrimeOpp;
        public String businessUnitProd;
        public String noOfStores;
        public String categoryOfMerchant;
        public String regionforEng;
        public String categoryforGC;

    }

}