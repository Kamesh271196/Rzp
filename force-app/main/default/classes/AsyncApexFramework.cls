Public class AsyncApexFramework extends AsyncApexFrameworkScheduler{
    private static Integer MAX_BATCHLIMIT = 100 ;
    private static Integer availableBatchLimit = null;
    private static List<AsyncQueue__c > lstBatch = new List<AsyncQueue__c >(); 
    private static Integer previousCount = -1;
    private static Integer MAX_RETRY = 2; //User Custom Label here
    
    /**
    * governor limit left for DML operations
    */
    private static Integer availableDMLLimit(){
        return Limits.getLimitDMLRows() - Limits.getDmlRows();
    }
    
   /*Submit batch to this method to create asyncqueue object and process batch*/
    
    public static string submitBatch(Object batchClassInstance, Integer scopeSize, Integer priority , Boolean allowRetryOnFail){
        String jobId = null;
        if(priority == null ||priority == 0 ){
            priority = 99;
        }
        if(previousCount == -1){
            AggregateResult[] groupedResults = [Select Count(Id) FROM AsyncApexJob Where Status = 'Holding'];
        	String exp0 = String.valueOf(groupedResults[0].get('expr0'));
            previousCount = Integer.valueOf(exp0);
        }  
        availableBatchLimit = MAX_BATCHLIMIT - previousCount;
        String s = JSON.serialize(batchClassInstance);
        AsyncQueue__c  q = new AsyncQueue__c (); 
        q.Job_Type__c = 'Batch';
        q.Batch_Size__c  = scopeSize;
        q.object__c = s;
        q.priority__c = priority ; 
        q.Is_Retry__c = allowRetryOnFail;
        q.Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        q.Status__c='Queued';
        q.Retry_Count__c=0;

        if(availableBatchLimit > 0){  
            Database.batchable<sObject> b = (Database.batchable<sObject>)batchClassInstance; 
            q.Job_Id__c = jobId = Database.executeBatch(b, scopeSize);
            q.Status__c = 'Completed';   
        } 
        lstBatch.add(q);
        previousCount++;
        return jobId ;
    }
    public static void flush(){
        try{
        if(!lstBatch.isEmpty()){
            Database.insert(lstBatch,false);
            lstBatch.clear();
        }
        }
        Catch(Exception e){
            
        }
    }
    
    
          /**
     Utility Method to get all pending jobs from custom object to process
    **/
       
    public static List<AsyncQueue__c> getPendingJobs(String jobType, Integer recordToFetch){
        return   [Select Batch_Size__c,object__c,Class_Name__c,Retry_Count__c,Status__c  FROM AsyncQueue__c Where 
                  ( Status__c = 'Queued'
                  OR (Status__c='Failed' AND Is_Retry__c = true )) AND Job_Type__c = :jobType AND Retry_Count__c < : MAX_RETRY
                  Order By priority__c ASC LIMIT :recordToFetch ];
    }
    
     Public Static void startBatchJobs(List<AsyncQueue__c > lstBatch_StatusUpdate){ 
        Integer availableLimit = 0;
        AggregateResult[] groupedResults = [Select Count(Id) FROM AsyncApexJob Where Status = 'Holding'];
        String exp0 = String.valueOf(groupedResults[0].get('expr0'));
        availableLimit = 100 - Integer.valueOf(exp0);
        
        
        /*Invoke 50 batch in single transaction*/
         
        if(availableLimit > 50){
            availableLimit = 50;
        }
        
		if(availableLimit > 0){
            List<AsyncQueue__c > lstBatch = getPendingJobs('Batch', availableLimit)  ;
            if(!lstBatch.isEmpty()){
                for(AsyncQueue__c  q : lstBatch){ 
                    try{
                        if(q.Status__c == 'Failed'){
                            //If previous status is failed, increase retry count
                            q.Retry_Count__c = q.Retry_Count__c + 1;
                        }else{
                            q.Status__c = 'Completed'; 
                        }
                        Type t = Type.forName(q.Class_Name__c);
                        Object des_Obj = JSON.deserialize (q.object__c,t);
                        Database.batchable<sObject> b = (Database.batchable<sObject>)des_Obj;
                        q.Job_Id__c = Database.executeBatch(b, Integer.valueOf(q.Batch_Size__c));
                        
                    }catch(Exception e){
                        q.status__c = 'Failed'; 
                        q.note__c = e.getMessage()+'\n'+e.getStackTraceString();
                    }
                    lstBatch_StatusUpdate.add(q);
                }
            }   
        }         
    }
    
    
    /*Read results of job from Salesofrce job log and update in custom object*/
    
   
    Public Static void collectJobInfo(List<AsyncQueue__c > lstBatch_StatusUpdate){
        Integer availableLimit = availableDMLLimit();  
        if(availableLimit > 0){ 
        List<AsyncQueue__c> lstStatusCheck = [Select Job_Id__c,Note__c FROM AsyncQueue__c Where
                                              Error_Collection_Status__c='Not Collected' AND Status__c  
                                              IN ('Completed','Failed') LIMIT :availableLimit ];
            Map<String,AsyncQueue__c> mpJobMap = new Map<String,AsyncQueue__c>();
            for(AsyncQueue__c a : lstStatusCheck){
                if(!string.isEmpty(a.Job_Id__c)){
                    //convert 15 to 18 digit id
                    Id id15to18 = a.Job_Id__c ;
                    mpJobMap.put(id15to18,a); 
                } 
            } 

            if(mpJobMap.keyset().size() > 0){
                List<AsyncApexJob> lstJobStatus =[Select Id,ExtendedStatus,TotalJobItems,NumberOfErrors,MethodName FROM 
                                                  AsyncApexJob Where Status IN ('Completed','Failed') AND ID IN : mpJobMap.keyset()]; 
                for(AsyncApexJob j : lstJobStatus){ 
                    AsyncQueue__c a = mpJobMap.get(j.Id); 
                    if(a != null){
                        String note = '';
                        note += String.isEmpty(a.Note__c)? '' : a.Note__c +'\n' ; 
                        if(!String.isEmpty(j.ExtendedStatus)){  
                            note+= String.isEmpty(j.ExtendedStatus)? '' : 'Error Messages - '+j.ExtendedStatus +'\n' ;  
                            a.Status__c = 'Failed';
                        }else{
                            a.Status__c = 'Completed'; 
                        }
                        note += String.isEmpty(j.MethodName)? '' : 'Method - '+j.MethodName +'\n'; 
                        note += 'Total Batches - '+j.TotalJobItems + '\n'; 
                        note += 'Number of Errors - '+j.NumberOfErrors ;  
                        a.Note__c = note; 
                        a.Error_Collection_Status__c = 'Collected';
                       lstBatch_StatusUpdate.add(a);     
                    }
                }
            } 
        }
    }
     
    /*Utility method to update status of Async Custom object records*/
   
 Public Static void saveAsyncRecords(List<AsyncQueue__c > lstBatch_StatusUpdate){
        if(!lstBatch_StatusUpdate.isEmpty()){ 
            Database.update(lstBatch_StatusUpdate,false);
         } 
        lstBatch_StatusUpdate.clear(); 
 }
    
      public void execute(SchedulableContext SC) { 
         datetime dt=datetime.now();
        try{   
          
            //integer yr=dt.year();
            //integer month=dt.month();
            //integer date=dt.day();
            integer hour=dt.hour();
            //integer min=dt.minute(); 
            
            if(hour>5){
            List<AsyncQueue__c > lstBatch_StatusUpdate = new List<AsyncQueue__c >();
			collectJobInfo(lstBatch_StatusUpdate); 
        	saveAsyncRecords(lstBatch_StatusUpdate);
        	startBatchJobs(lstBatch_StatusUpdate);
        	saveAsyncRecords(lstBatch_StatusUpdate);
            }          
        }catch(Exception ex){   
            system.debug(ex.getMessage()+' >>  '+ex.getLineNumber());
        }
    }
    public static string submitBatchDashboard(Object batchClassInstance, Integer scopeSize, Integer priority , Boolean allowRetryOnFail){
        String jobId = null;
        if(priority == null ||priority == 0 ){
            priority = 99;
        }        
        String s = JSON.serialize(batchClassInstance);
        AsyncQueue__c  q = new AsyncQueue__c (); 
        q.Job_Type__c = 'Batch';
        q.Batch_Size__c  = scopeSize;
        q.object__c = s;
        q.priority__c = priority ; 
        q.Is_Retry__c = allowRetryOnFail;
        q.Class_Name__c = String.valueOf(batchClassInstance).split(':')[0];
        q.Status__c='Queued';
        q.Retry_Count__c=0;
        lstBatch.add(q);
        previousCount++;
        return jobId ;
    }

    
}