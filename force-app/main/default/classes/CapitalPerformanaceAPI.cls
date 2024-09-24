/*
 * Author: Karthik J
 * Description: This RestResource class is used to create the Performance records for Capital Products
 * Date: 2023-08-16
 * Version : 1.0
*/

@RestResource(urlMapping='/CapitalPerformanaceAPI') 
global class CapitalPerformanaceAPI{
    @Httppost
    global static List<ResponseWrapper> upsertData(){
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        List<CapitalJSONRequestWrapper.RequestWrapper> jSONdataList = new List<CapitalJSONRequestWrapper.RequestWrapper>();
        Map<String,CapitalJSONRequestWrapper.RequestWrapper> merchantIdMapforCapital = new Map<String,CapitalJSONRequestWrapper.RequestWrapper>();
        Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>> merchantIdMapforCARDS = new Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>>();
        Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>> merchantIdMapforLOC_EMI = new Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>>();
        Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>> merchantIdMapforLOC = new Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>>();
        Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>> merchantIdMapLeadScore = new Map<String,List<CapitalJSONRequestWrapper.RequestWrapper>>();
        Map<String,Capital_Performance__c>capitalPerformanceRecMap = new Map<String,Capital_Performance__c>();
        List<Database.upsertResult> uResults = new List<Database.upsertResult>();
        ResponseWrapper responseInstance = new ResponseWrapper();

        if(request.requestBody.toString() != null){
            system.debug('>>>'+request.requestBody.toString());
            JSONParser parser = JSON.createParser(request.requestBody.toString());
            system.debug('parser>>'+parser);
            while (parser.nextToken() != null) {
                system.debug('parser.getCurrentToken()>>'+parser.getCurrentToken());
                system.debug('JSONToken.START_OBJECT>>'+JSONToken.START_OBJECT);
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    system.debug('parser>>'+parser);
                    CapitalJSONRequestWrapper.RequestWrapper jsondata = (CapitalJSONRequestWrapper.RequestWrapper)parser.readValueAs(CapitalJSONRequestWrapper.RequestWrapper.class);
                    string temp = JSON.serialize(jsondata); 
                    parser.skipChildren();
                    CapitalJSONRequestWrapper.RequestWrapper performanceData = (CapitalJSONRequestWrapper.RequestWrapper)JSON.deserialize(temp, CapitalJSONRequestWrapper.RequestWrapper.class);
                    jSONdataList.add(performanceData);
                    system.debug('jSONdataList>>>'+jSONdataList);
                }
            }
        for(CapitalJSONRequestWrapper.RequestWrapper data : jSONdataList){
            if(data.capital_lead_score != null && data.merchant_id != null ){
                if(merchantIdMapLeadScore.keyset().contains(data.merchant_id)){
                    merchantIdMapLeadScore.get(data.merchant_id).add(data);
                }else{
                  merchantIdMapLeadScore.put(data.merchant_id,new List<CapitalJSONRequestWrapper.RequestWrapper>{data});
                }
                }
            if(data.merchant_id != null && data.transaction_date != null ){
                if(data.product=='CARDS'){
                    if(merchantIdMapforCARDS.keyset().contains(data.merchant_id)){
                        merchantIdMapforCARDS.get(data.merchant_id).add(data);
                    }else{
                        merchantIdMapforCARDS.put(data.merchant_id,new List<CapitalJSONRequestWrapper.RequestWrapper>{data});
                    }
                    
                }else if(data.product== 'LOC_EMI'){
                    if(merchantIdMapforLOC_EMI.keyset().contains(data.merchant_id)){
                        merchantIdMapforLOC_EMI.get(data.merchant_id).add(data);
                    }else{
                        merchantIdMapforLOC_EMI.put(data.merchant_id,new List<CapitalJSONRequestWrapper.RequestWrapper>{data});
                    }
                }else{
                    if(merchantIdMapforLOC.keyset().contains(data.merchant_id)){
                        merchantIdMapforLOC.get(data.merchant_id).add(data);
                    }else{
                        merchantIdMapforLOC.put(data.merchant_id,new List<CapitalJSONRequestWrapper.RequestWrapper>{data});
                    }
                }
            }

            }
            if(!merchantIdMapLeadScore.isEmpty()){
             CapitalPerformanceHandler.updateCapitaLeadScore(merchantIdMapLeadScore);
            }
            if(!merchantIdMapforCARDS.isEmpty()){
               capitalPerformanceRecMap = CapitalPerformanceHandler.createCapitalPerformanceRecords(merchantIdMapforCARDS);
            }if(!merchantIdMapforLOC_EMI.isEmpty()){
               capitalPerformanceRecMap = CapitalPerformanceHandler.createCapitalPerformanceRecords(merchantIdMapforLOC_EMI);
            }if(!merchantIdMapforLOC.isEmpty()){
                capitalPerformanceRecMap = CapitalPerformanceHandler.createCapitalPerformanceRecords(merchantIdMapforLOC);
            }
            if(!capitalPerformanceRecMap.isEmpty()){
               uResults = CapitalPerformanceHandler.inserCapitalPerformancerecords(capitalPerformanceRecMap);
            }
            if(uResults.size()>0){
                List<ResponseWrapper> responseList = new List<ResponseWrapper>();
                for(Database.upsertResult result : uResults){
                    system.debug('result>>'+result);
                    if(result.isSuccess()){
                        
                        responseInstance.message = 'Performance Records Upsert Sucessfully!';
                        responseInstance.Status = 'Success';
                        responseInstance.responsecode = 200;
                        responseInstance.referenceId = result.getId();
                        responseList.add(responseInstance);
                        
                    }else{
                        responseInstance.message = 'Error in Upserting Performance Records!';
                        responseInstance.Status = 'Error';
                        responseInstance.responsecode = 500;
                        responseInstance.referenceId = result.getId();
                        responseList.add(responseInstance);
                        Utilities.inserErrorLog('',JSON.serialize(jSONdataList));
                        
                    }
                }
                return responseList;
            }
        }
     return null;
  }
    global class ResponseWrapper{
        global string message{get;set;}
        global string Description{get;set;}
        global string Status{get;set;}
        global Integer responsecode{get;set;}
        global string referenceId{get;set;}
    }

}