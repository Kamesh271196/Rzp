public class CapitalPerformanceHanler {
    /*public static Map<String,Capital_Performance__c> performanceRecMap = new Map<String,Capital_Performance__c>();
    
    public static List<Database.upsertResult> inserCapitalPerformancerecords(Map<String,Capital_Performance__c> capitalPerformanceMap){
        system.debug('xPerformanceMap>>>'+capitalPerformanceMap.size());
        List<Database.upsertResult> uResults = new List<Database.upsertResult>();
        if(capitalPerformanceMap != null && capitalPerformanceMap.size()>0){
            uResults= Database.upsert(capitalPerformanceMap.values(),false);
        }
        return uResults;
    }
    
    public static Map<String,Capital_Performance__c> createCapitalPerformanceRecotrds(Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>> capitalPerformanceData){
        system.debug('capitalPerformanceData>>'+capitalPerformanceData);
        Map<String,Account> capitalAccountIdMap = new Map<String,Account>();
        for(Account acc : [SELECT Id,Merchant_Id__c,(SELECT Id,Name,Transaction_Count__c,Account__c,Total_principal_recovered__c,Total_loan_disbursed__c,Tenure__c,
                                                     Average_Transaction_Value__c,Total_transaction_value__c FROM Capital_Performances__r WHERE Product__c IN ('CARDS','LOC','LOC_EMI')) 
                           FROM Account WHERE Merchant_Id__c IN : capitalPerformanceData.keyset()]){
                               capitalAccountIdMap.put(acc.Merchant_Id__c,acc);        
                           }
        for(List<CapitalJSONRequestWrapper.RequestWrapper> capitalDataList : capitalPerformanceData.values()) {
            for(CapitalJSONRequestWrapper.RequestWrapper capitalData : capitalDataList){
                Capital_Performance__c performanceRecord = null;
                
                String transactionMYearMonth = String.valueOf(capitalData.transaction_date).substring(0,7);
                if(!capitalAccountIdMap.isEmpty()){ 
                    for(Capital_Performance__c existingRec : capitalAccountIdMap.get(capitalData.merchant_id).Capital_Performances__r){
                        String recordName = capitalData.merchant_id + '_' + capitalData.product + '_' + transactionMYearMonth;
                        if (existingRec.Name.equalsIgnoreCase(recordName)) {
                            performanceRecord = existingRec;
                            break;
                        } 
                    }
                }
                if(performanceRecord != null){
                    system.debug('>>>>453345'+performanceRecord);
                    performanceRecord.Account__c =  capitalAccountIdMap.get(capitalData.merchant_id).Id;
                    performanceRecord.Transaction_Count__c += 1;
                    performanceRecord.Tenure__c = (capitalData.avg_tenure != null && capitalData.avg_tenure != '') ? capitalData.avg_tenure : performanceRecord.Tenure__c;
                    performanceRecord.Average_Transaction_Value__c = (capitalData.average_transaction_value != null && capitalData.average_transaction_value != '') ? capitalData.average_transaction_value : performanceRecord.Average_Transaction_Value__c;
                    performanceRecord.Total_loan_disbursed__c = capitalData.total_loan_disbursed;
                    performanceRecord.Total_principal_recovered__c = (capitalData.total_principal_recovered != null) ? capitalData.total_principal_recovered : performanceRecord.Total_principal_recovered__c;
                    performanceRecord.Total_transaction_value__c = (capitalData.total_transaction_value != null && capitalData.total_transaction_value != '') ? capitalData.total_transaction_value : performanceRecord.Total_transaction_value__c;
                    performanceRecord.Product__c = capitalData.product;
                    performanaceRecord.withdrawal_count__c = capitalData.withdrawal_count;
                    performanceRecord.Transaction_Date__c = capitalData.transaction_date;
                    performanceRecMap.put(performanceRecord.Name,performanceRecord);
                }
                if(performanceRecord == null){
                    performanceRecord = createNewCapitalPerfRecord(capitalAccountIdMap,capitalData);
                    performanceRecMap.put(performanceRecord.Name,performanceRecord);
                }
            }
            
        }
        return performanceRecMap; 
    }
    
    public static Capital_Performance__c createNewCapitalPerfRecord(Map<String,Account> AccountMap , CapitalJSONRequestWrapper.RequestWrapper data){
        Capital_Performance__c capitalRec = new Capital_Performance__c();
        
        if(AccountMap.get(data.merchant_id) != null){
            capitalRec.Account__c = AccountMap.get(data.merchant_id).Id;
        }
        
        String transactionMonth = String.valueOf(data.transaction_date).substring(0, 7);
        capitalRec.Name = data.merchant_id +'_'+ data.product +'_'+ transactionMonth;
        capitalRec.Transaction_Count__c = 1;
        capitalRec.Tenure__c = data.avg_tenure;
        capitalRec.Product__c = data.product;
        capitalRec.Average_Transaction_Value__c = data.average_transaction_value;
        capitalRec.Total_loan_disbursed__c = data.total_loan_disbursed;
        capitalRec.Total_principal_recovered__c = data.total_principal_recovered;
        capitalRec.Total_transaction_value__c = data.total_transaction_value;
        capitalRec.Transaction_Date__c = data.transaction_date;
        capitalRec.withdrawal_count__c = capitalData.withdrawal_count;
        return capitalRec;
    }
    */
    public static void updateCapitaLeadScore(Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>> LeadScoreMap){
        system.debug('LeadScoreMap>>'+LeadScoreMap);
        Map<String,Opportunity> capitalOppMap = new Map<String,Opportunity>();
        List<Exception_Log__c> errorList = new List<Exception_Log__c>();
        for(Opportunity opp : [SELECT Id,Name,Type,Account.Merchant_Id__c FROM Opportunity WHERE 
                               Type IN ('CARDS','LOC','LOC_EMI','LOC EMI') AND 
                               Account.Merchant_Id__c IN : LeadScoreMap.keySet()]){
                            system.debug('opp>>'+opp.Type);
                            for(CapitalJSONRequestWrapper.RequestWrapper data : LeadScoreMap.get(opp.Account.Merchant_Id__c)){
                                   if(opp.Type == data.product_name){
                                       opp.Capital_Lead_Score__c = data.capital_lead_score;
                                       capitalOppMap.put(opp.Id,opp);
                                   }
                               }
                            }
        if(!capitalOppMap.isempty()){
            Opportunity_Handler_Class.CONVERTING_LEAD = true;
            Database.SaveResult[] results = Database.update(capitalOppMap.values(),false);  
            /*for(Database.SaveResult result : results){
                if(!result.isSuccess()){
                    /*for(Database.Error err : result.getErrors()) {
                        Exception_Log__c  errorlog = new Exception_Log__c ();
                        errorlog.Exception_Message__c  = err.getMessage();
                        errorlog.Exception_Cause__c   = err.getMessage();
                        errorList.add(errorlog);
                    }
                    
                }
            }*/
        }
        /*if(errorList.size()>0){
            insert errorList; 
        }
        system.debug('errorlog>>'+errorList);*/
    }
}