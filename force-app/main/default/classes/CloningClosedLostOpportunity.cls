/**    
*   Class Name     :  CloningClosedLostOpportunity
*
*   Description    :  This class will clone the Closed Lost Opportunity and create a new Opportunity.   
*
*    Created By    :  Murli Manohar Jha   
*
*    Created Date  :  07/08/2023
*
*    Version       :  V1.0 Created

**/


public class CloningClosedLostOpportunity {
    
    @InvocableMethod
    public static List<string> cloneAndModifyOriginalOpportunity(List<Id> originalOpportunityId) {
        List<String> lstid = new List<String>();
        try{
            // Clone the original Opportunity
            Opportunity originalOpportunity = [SELECT Id, Name,Merchant_ID__c,Methods__c,AccountId,Type,CloseDate, StageName FROM Opportunity WHERE Id = :originalOpportunityId];
            Opportunity clonedOpportunity = originalOpportunity.clone(false, true); // shallow clone of the Opportunity
            
            // Modify the cloned Opportunity
            clonedOpportunity.Merchant_ID__c = originalOpportunity.Merchant_ID__c;
            clonedOpportunity.StageName = 'Open';
            clonedOpportunity.CloseDate = System.today().addDays(45);
            clonedOpportunity.Type = originalOpportunity.Type;
            clonedOpportunity.AccountId = originalOpportunity.AccountId;
            clonedOpportunity.Name = originalOpportunity.Name+'_cloned';
            clonedOpportunity.Methods__c = originalOpportunity.Methods__c;
            // Modify the original Opportunity
            originalOpportunity.Merchant_ID__c = '';
            //originalOpportunity.Name = originalOpportunity.Name+'_Cloned';
            
            
            Database.SaveResult results = Database.update(originalOpportunity);
            
            List<Opportunity> opplst = new List<Opportunity>();
            // Insert the cloned Opportunity to create a new record
            if (results.isSuccess()) {
                system.debug('I am here: Murli');
                opplst.add(clonedOpportunity);
                Database.SaveResult[] insertopp = database.insert(opplst,false);
                if(insertopp[0].isSuccess())
                {
                  lstid.add(insertopp[0].getId());
                  return lstid; 
                }
               return null; 
            }else {
                for (Database.Error error : results.getErrors()) {
                    System.debug('Error in updating the original Opportunity: ' + error.getMessage());
                }

            }          
        }catch(Exception ex){
            System.debug('An error occurred while cloning the Closed Lost Opportunity: ' + ex.getMessage());
             return null;
        }
         return null;
    }
}