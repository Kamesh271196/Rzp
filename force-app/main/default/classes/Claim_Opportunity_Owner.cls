public class Claim_Opportunity_Owner {
    @auraenabled
    public static void getResults(List<Id> oppidset) {
    //List<Opportunity> Opporlst=[Select Id,OwnerId from opportunity where id in :oppidset];//commented by Codleo
    List<Opportunity> Opporlst=[Select Id,OwnerId from opportunity where id in :oppidset AND RecordType.DeveloperName NOT IN ('Ezetap')];//Added by Codleo
     system.debug('Opporlst'+Opporlst);
}
}