public with sharing class CAQuestionHandler {
    
    @AuraEnabled(cacheable=true)
    public static List<QuestionAnswer> getQuetions(String recordId){
        try {
            List<Opportunity> caOpp = [SELECT Id,Type FROM Opportunity WHERE Id =:recordId];
            List<QuestionAnswer> questionAnswerList = new List<QuestionAnswer>();
            Map<String,Question__c> existingQuestionsMap = new  Map<String,Question__c>();
            for(Question__c existingQuestion : [SELECT Id,Question__c,Answer__c FROM Question__c WHERE Opportunity__c =: caOpp[0].Id ]){
                existingQuestionsMap.put(existingQuestion.Question__c,existingQuestion);
            }
            system.debug('existingQuestionsMap>>'+existingQuestionsMap);
            for(Opportunity_Question__mdt question : [SELECT Product__c,Question__c,Stage_Name__c,MasterLabel FROM Opportunity_Question__mdt WHERE Product__c=:caOpp[0].Type]){
                if(existingQuestionsMap.containsKey(question.Question__c)){
                    QuestionAnswer eqa = new QuestionAnswer();
                    eqa.Id = existingQuestionsMap.get(question.Question__c).Id;
                    eqa.question = question.Question__c;
                    eqa.answer = existingQuestionsMap.get(question.Question__c).Answer__c;
                    questionAnswerList.add(eqa);  
                }else{
                    Question__c newQuestion = new Question__c(Question__c = question.Question__c);
                    //insert newQuestion;
                    QuestionAnswer nqa = new QuestionAnswer();
                    nqa.question = question.Question__c;
                    nqa.answer = '';
                    nqa.Id = newQuestion.Id;
                    questionAnswerList.add(nqa); 
                }
                
            }
            system.debug('questionAnswerList>>>'+questionAnswerList);
            return questionAnswerList;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static String saveQuestions(List<QuestionAnswer> saveQAdetails, String recordId){
        try {
            List<Opportunity> caOpp = [SELECT Id,Type FROM Opportunity WHERE Id =:recordId];
            List<Question__c> saveQuestionsList = new List<Question__c>();
            List<Question_History__c> questionHistoryList = new List<Question_History__c>();
            system.debug('saveQAdetails>'+saveQAdetails);
            Map<String,Question__c> existingQuestionsMap = new  Map<String,Question__c>();
            for(Question__c existingQuestion : [SELECT Id,Question__c,Answer__c FROM Question__c WHERE Opportunity__c=:caOpp[0].Id]){
                existingQuestionsMap.put(existingQuestion.Question__c,existingQuestion);
            }
            for(QuestionAnswer qadetail : saveQAdetails){
                system.debug('qadetail>'+qadetail);
                if(existingQuestionsMap.containsKey(qadetail.question)){
                    Question_History__c qh = new Question_History__c(Question__c = qadetail.question ,Answer__c = qadetail.answer , Parent_Id__c = caOpp[0].Id);
                    questionHistoryList.add(qh);
                   Question__c existingQuestion = new Question__c(Id=existingQuestionsMap.get(qadetail.question).Id,Question__c = qadetail.question, Answer__c = qadetail.answer);
                   saveQuestionsList.add(existingQuestion);
                }else{
                    Question_History__c qh = new Question_History__c(Question__c = qadetail.question ,Answer__c = qadetail.answer , Parent_Id__c = caOpp[0].Id);
                    questionHistoryList.add(qh);
                    Question__c newQuestion = new Question__c(Question__c = qadetail.question, Answer__c = qadetail.answer,Opportunity__c =caOpp[0].Id);
                    saveQuestionsList.add(newQuestion);
                }
            }
            if(saveQuestionsList.size()>0){
                upsert saveQuestionsList;
                if(questionHistoryList.size()>0){
                  insert questionHistoryList;
                }
                return 'SUCCESS';
            }
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            //return 'FAILED';
        }
        return '';
    }
    @AuraEnabled
    public static List<Question_History__c> getQuestionHistories(String recordId){
           return [SELECT Id,Question__c,Answer__c,Parent_Id__c FROM Question_History__c WHERE Parent_Id__c=:recordId];
    }
    public class QuestionAnswer{
      @AuraEnabled
      public string Id{get;set;}
      @AuraEnabled
      public string question{get;set;}
      @AuraEnabled
      public string answer{get;set;}
    }
}