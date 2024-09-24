public class AccountImplInterface {

    
   public static void reassignAccountOwnerIfClaimedByManaged(Map<Id,Account> oldAccountList, Map<Id,Account> newAccountList){
    System.debug('oldAccountList>'+oldAccountList);
    System.debug('newAccountList>'+newAccountList);
       Set<Id> managedAccountIds = new Set<Id>();
       Map<Id,User> userMap =new Map<Id,User>([Select id,name,Profile.name,userrole.name from user]);
       for(Account acc : newAccountList.values()){
           system.debug('opp44>>'+UserMap.get(acc.OwnerId).userrole.name);
           system.debug('managedAccountIds>'+managedAccountIds);
           if(oldAccountList.get(acc.Id).ownerID != acc.ownerId  && userMap.get(oldAccountList.get(acc.Id).ownerId).Profile.name =='Integration User' 
              && Label.Managed_User_Role.contains(UserMap.get(acc.OwnerId).userrole.name) && !managedAccountIds.contains(acc.Id)){
               managedAccountIds.add(acc.Id);
           }
       }
       system.debug('managedAccountIds>'+managedAccountIds);
       List<Opportunity> updateOppList = new List<Opportunity>();
       List<String> managedProducts = Label.Managed_Products.split(',');
       for(Opportunity managedOpp : [Select Id,Type,AccountId,previous_poc__c,Passed_LosState__c,LOS_Application_State__c,OwnerId from Opportunity where AccountId in:managedAccountIds AND Type in:managedProducts]){
           system.debug('managedOpp>'+managedOpp);
           String previous =managedOpp.OwnerId;
           if((managedOpp.Type =='CARDS' || managedOpp.Type =='LOC_EMI') && managedOpp.Passed_LosState__c){
               managedOpp.previous_poc__c =null;
           }
           else{
              managedOpp.previous_poc__c =managedOpp.OwnerId; 
              managedOpp.ownerId =newAccountList.get(managedOpp.AccountId).ownerId;
           }
           
           updateOppList.add(managedOpp);
          
       }
       system.debug('updateOppList>'+updateOppList);
       if(updateOppList.size()>0){
           database.update(updateOppList,false);
       }
   }
      
}