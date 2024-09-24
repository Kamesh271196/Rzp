/**    
*    Class Name    : Account_Handler_Class
*
*    Description   :  Handler class to update the KAM_Handover_Status__c field on Account and to copy Account POC to Account Team.   
*
*    Created By    :  Nandhini R S   
*
*    Created Date  :  07/05/2019
*
*    Version       :  3.1 Updated

*    Modified By   : Kamesh N  

**/
public class Account_Handler_Class {
    public static boolean isFirstTime = true;
    public static Boolean CONVERTING_LEAD = false;
    /*Account to update the KAM_Handover_Status__c field*/
    public void OnBeforeUpdate(List<Account> acclst ){
        for(Account acc:acclst){
            if(acc.POC__c!=null){
                if(acc.KAM_Handover_Status__c=='Approved'){
                    id owner=acc.OwnerId;            
                    acc.OwnerId=acc.POC__c;
                    acc.POC__c=owner; 
                    acc.KAM_Handover_Status__c='Handover';
                    system.debug('handleracc'+acc.id);
                } 
            }     
        }
    }
    /*Copy Account POC and create Account Team*/  
    public void OnBeforeUpdateforaccteam(Map<Id,Sobject> Map1,Map<id,Sobject> Map2){
        /*Map<id,Account> NewMap=(Map<id,Account>) Map1;
Map<id,Account> OldMap=(Map<id,Account>) Map2;
List<AccountTeamMember> atmlist=new List<AccountTeamMember>();
for(Account Acc:NewMap.values()){
if(OldMap.get(Acc.Id).POC__c!=Newmap.get(Acc.Id).POC__c) {
AccountTeamMember atm=new AccountTeamMember();
atm.AccountId=Acc.id;
atm.UserId=OldMap.get(Acc.Id).POC__c;
system.debug('****'+OldMap.get(Acc.Id).POC__c);
atmlist.add(atm);
}
}  
insert atmlist;*/
    }
    
    /*Handler Class to call the batch account creation*/
    
    public void accountownerroleonInsert(List<Account> acclst){
        try{
            system.debug('acclst'+acclst);
            set<Id> accidlst=new set<id>();
            for(Account Acc:acclst){
                accidlst.add(acc.id);   
            }
            system.debug('accidlst'+accidlst);
            Manager_Role_in_Hierarchy managerroleinhierarchy=    new Manager_Role_in_Hierarchy(accidlst);
            ID batchprocessid = AsyncApexFramework.submitBatch(managerroleinhierarchy,2000,99,True);
            AsyncApexFramework.flush();
            // Database.executeBatch(new Manager_Role_in_Hierarchy(accidlst), 200);
        }
        Catch(Exception e){
            system.debug('Error Message'+e.getMessage());        
        }
    }
    
    /*Handler Class to call the batch, if the account owner is changed*/
    public void accountownerrole(Map<Id,Sobject> Map1,Map<id,Sobject> Map2){
        try{
            Map<id,Account> NewMap=(Map<id,Account>) Map1;
            Map<id,Account> OldMap=(Map<id,Account>) Map2;
            set<Id> accidlst=new set<id>();
            List<AccountTeamMember> atmlist=new List<AccountTeamMember>();
            for(Account Acc:NewMap.values()){
                if(OldMap.get(Acc.Id).OwnerID!=Newmap.get(Acc.Id).OwnerID) {
                    accidlst.add(acc.id);   
                }
            }
            system.debug('accidlst'+accidlst);
            Manager_Role_in_Hierarchy managerroleinhierarchy=    new Manager_Role_in_Hierarchy(accidlst);
            ID batchprocessid = AsyncApexFramework.submitBatch(managerroleinhierarchy,2000,99,True);
            AsyncApexFramework.flush();
            //Database.executeBatch(new Manager_Role_in_Hierarchy(accidlst), 200); 
        }
        Catch(Exception e){
            system.debug('Error Message'+e.getMessage());        
        }
    }
    //This method update IF/Hybrid and Vertical From Parent Account To Child Account on Child Account insertion    
    public void updateHybrid_verticalFromParent(List<Account> newAccountList){
        try{
            Set<Id> parentAccountId = new Set<Id>();
            for(Account accObj:newAccountList){
                if(accObj.ParentId !=null){
                    parentAccountId.add(accObj.ParentId);
                }
                
            }
            if(parentAccountId.size() > 0){
                System.debug('newAccountList '+newAccountList);
                SOQLAccountInterfaceImpl soqlaccountinterfaceImpl = new SOQLAccountInterfaceImpl();
                Map<Id,Account> parentAccountVertical = soqlaccountinterfaceImpl.getParentAccount(parentAccountId);
                System.debug('parentAccountVertical '+parentAccountVertical);
                
                for(Account insertedAccount : newAccountList){
                    if(parentAccountVertical.containsKey(insertedAccount.ParentId)){
                        // Account accObj = new Account();
                        insertedAccount.Vertical__c = parentAccountVertical.get(insertedAccount.ParentId).Vertical__c;
                        insertedAccount.IF_Hybrid__c = parentAccountVertical.get(insertedAccount.ParentId).IF_Hybrid__c ;
                        
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('Exception at '+ex.getLineNumber()+' cause '+ex.getCause()+' message '+ex.getMessage());
        }
    }
    //This method update IF/Hybrid and Vertical From Parent Account To Child Account on Parent Account update    
    
    public void onParentAccountUpdateHybrid_Vertical(List<Account> parentAccountList,Map<Id, Account> oldMap){
        try{
            Set<Id> accountIdSet = new Set<Id>();
            
            Map<Id,Account> parentAccountDetails = new Map<Id,Account>();
            List<Account> updatedChildAccounts = new List<Account>();
            System.debug('parentAccountList '+parentAccountList);
            System.debug('oldMap '+oldMap);
            for(Account accObj:parentAccountList){
                
                if(((accObj.Vertical__c != oldMap.get(accObj.id).Vertical__c || accObj.IF_Hybrid__c != oldMap.get(accObj.id).IF_Hybrid__c ))){
                    accountIdSet.add(accObj.Id);
                    parentAccountDetails.put(accObj.id,accObj);
                    System.debug('parentAccountDetails '+parentAccountDetails);
                    System.debug('accountIdSet '+accountIdSet);
                    
                }
            }
            SOQLAccountInterfaceImpl soqlaccountinterfaceImpl = new SOQLAccountInterfaceImpl();
            Map<Id,List<Account>> parentVsChildAccount = soqlaccountinterfaceImpl.getChildAccount(accountIdSet);
            System.debug('parentVsChildAccount '+parentVsChildAccount.keySet());
            System.debug('parentVsChildAccount '+parentVsChildAccount.Values());
            System.debug('parentVsChildAccount '+parentVsChildAccount.Values());
            if(parentVsChildAccount.size() > 0){
                for(Id accId:parentVsChildAccount.keySet()){
                    for(Account acc:parentVsChildAccount.get(accId)){
                        acc.Vertical__c = parentAccountDetails.get(accId).Vertical__c;
                        acc.IF_Hybrid__c = parentAccountDetails.get(accId).IF_Hybrid__c;
                        updatedChildAccounts.add(acc);
                    }
                }   
            }
            //System.debug('accountIdSet '+accountIdSet);
            
            if(updatedChildAccounts.size() >0){
                update updatedChildAccounts;
            }
        }
        catch(Exception ex){
            System.debug('Exception at '+ex.getLineNumber()+' cause '+ex.getCause()+' message '+ex.getMessage());
            
        }
    }
    //Added to support during Parent Account change with any related Opps and cons for -SF-04932
    public void onParentAccountUpdate(Map<id,Account> oldmap,Map<id,Account> newmap)
    {
        try
        {
        Set<id> paccid = new Set<id>();
        Map<id,Opportunity> accoppmap = new Map<id,Opportunity>();
        Map<id,id> accconmap = new Map<id,id>();
        Map<id,id> oppmap = new Map<id,id>();
        Map<id,Account> acccon = new Map<id,Account>();
        for(Account acc1:oldmap.values())
        {
            if(!paccid.contains(acc1.ParentId))
            {
               paccid.add(acc1.ParentId); 
            } 
        }
       MAP<id,Opportunity> popplist = new map<id,opportunity>([Select id,accountid,LinkedOpportunity__c  from opportunity where AccountID IN:paccid]);
       MAP<id,Opportunity> opplistmap = new map<id,opportunity>([Select id,accountid,LinkedOpportunity__c  from opportunity where AccountID IN:newmap.keyset()]);
        List<AccountContactRelation> acrlst =[Select id,accountid,contactId from Accountcontactrelation where ContactId IN(Select id from contact where Accountid in:newmap.keyset())];
       
        if(!popplist.isEmpty())
        {
         for(Opportunity opplst:popplist.values())
        {
            if(opplst.LinkedOpportunity__c!=null)
            {
              if(opplistmap.get(opplst.LinkedOpportunity__c)!=null)
            {
              accoppmap.put(opplistmap.get(opplst.LinkedOpportunity__c).AccountId,opplistmap.get(opplst.LinkedOpportunity__c));
            }  
            }
            
        }   
        }
           
        if(!acrlst.isEmpty())
        {
          for(Accountcontactrelation conlst:acrlst)
        {
           accconmap.put(conlst.Accountid,conlst.ContactId);
          
        }   
        }
            
        for(Account acc:newmap.values())
        {
           system.debug('Aoppp'+acc.ParentId+oldmap.get(acc.Id).ParentId+oldmap.get(acc.Id).ParentId+accoppmap.containsKey(oldmap.get(acc.Id).ParentId)+UserInfo.getProfileId()+System.label.parentAccount_Opportunity_linking_profile_id.split(',').contains(UserInfo.getProfileId()));
            if(acc.parentId!=oldmap.get(acc.Id).ParentId && oldmap.get(acc.Id).ParentId!=null && 
            (accoppmap.containsKey(acc.Id) && !System.label.parentAccount_Opportunity_linking_profile_id.split(',').contains(UserInfo.getProfileId() ) 
            ||(accconmap.containskey(acc.Id) && accconmap.containskey(oldmap.get(acc.Id).ParentId)) ))
            {
                acc.ParentId.adderror('Please Remove the Opportunities or Contacts related to the parent Account before changing ');
            }
             if(oldmap.get(acc.Id).ParentId==null && acc.parentId!=oldmap.get(acc.Id).ParentId )
            {
                acccon.put(acc.Id,acc);
            }
            if(oldmap.get(acc.Id).ParentId!=null && acc.parentId!=oldmap.get(acc.Id).ParentId)
            {
                acccon.put(acc.Id,acc);
            }
        }
        if(!acccon.isempty())
        {
            ContactTriggerHandler.afterAccountChangeHandler(acccon);
        }            
        }
        Catch(Exception e)
        {
            System.debug('Error Occured :'+e.getMessage()+'in the line'+e.getLineNumber());
        }
    }
}