public class ClaimOpportunityRecordsController {
    public List<string> SelectedOpportunityIDs{get;set;}
    public ClaimOpportunityRecordsController(ApexPages.StandardSetController listcontroller){
        SelectedOpportunityIDs = new List<string>{};
        for(Opportunity Opp : (List<Opportunity>)listcontroller.getSelected()){
        SelectedOpportunityIDs.add(opp.Id);
        }
    }
}