public class AccountCAOpportunitiesHelper {
    public static Boolean runOnce = TRUE;
    
    public static void updateCAOpportunities(List<Account> accList, Map<Id, Account> oldMap){
        
        System.debug('### accList' + accList);
        System.debug('### oldMap' + oldMap);
        Set<String> accountIds = new Set<String>();
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(Account acc : accList){
            System.debug('### acc '+ acc);
            Account oldAccount = oldMap.get(acc.Id);
            System.debug('### oldAccount '+ oldAccount);
            System.debug('### newAccount-Consolidated_Last_Click_Source_Medium__c '+ oldAccount.Consolidated_Last_Click_Attribution_Page__c);
            System.debug('### newAccount-Consolidated_Last_Click_Source_Medium__c '+ acc.Consolidated_Last_Click_Attribution_Page__c);
            
                If( (acc.Consolidated_Last_Click_Attribution_Page__c != oldAccount.Consolidated_Last_Click_Attribution_Page__c) ||
                  	(acc.Consolidated_Last_Click_Attribution_Term__c != oldAccount.Consolidated_Last_Click_Attribution_Term__c) ||
                   (acc.Consolidated_Last_Click_Campaign__c != oldAccount.Consolidated_Last_Click_Campaign__c) ||
                   (acc.Consolidated_Last_Click_Source_Category__c != oldAccount.Consolidated_Last_Click_Source_Category__c) ||
                   (acc.Consolidated_Last_Click_Source_Medium__c != oldAccount.Consolidated_Last_Click_Source_Medium__c) 
                  ){
                    AccountCAOpportunitiesHelper.runOnce=false;
                    accountIds.add(acc.Id);
                }
        }
        System.debug('### accountIds' + accountIds);
        if(accountIds.size() > 0){
            
            for(Opportunity opp : getCAOpportunity(accountIds)){
                System.debug('### opp' + opp);
                opp.Is_Consolidated_Field_Changed__c = opp.Is_Consolidated_Field_Changed__c ? False : True;
                opportunitiesToUpdate.add(opp);
            }
            if(!opportunitiesToUpdate.isEmpty()){
                System.debug('### opportunitiesToUpdate ' + opportunitiesToUpdate);
                UPDATE opportunitiesToUpdate;
            }
        }
    }
    
    public static List<Opportunity> getCAOpportunity(Set<String> accIds){
       // return [SELECT Id,Is_Consolidated_Field_Changed__c, Type FROM Opportunity WHERE Type = 'Current_Account' AND AccountId IN : accIds];
        return [SELECT Id, Is_Consolidated_Field_Changed__c, Type FROM Opportunity WHERE Type = 'Current_Account' AND AccountId IN :accIds AND RecordType.DeveloperName != 'Ezetap'];

    }
}