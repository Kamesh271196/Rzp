Global class BatchMassDeleteRecs Implements Database.batchable<sobject>{
     global final string query;
     global BatchMassDeleteRecs(string q){
         
          query=q;
     }
   
     global Database.QueryLocator start(Database.BatchableContext BC){

      return Database.getQueryLocator(query);
     }
     global  void execute(Database.BatchableContext BC,List<SObject> scope){
        Database.delete(scope, false);
    
    }
    global void finish(Database.BatchableContext BC){
    }

 }