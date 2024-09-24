@istest
public class CAQuestionHandlerTest {

     
    @istest
    public static void getQuetionsTest(){
        Opportunity opp = new Opportunity();
        opp.CloseDate = system.today();
        opp.Stagename = 'Open';
        opp.Type = 'current_account';
        opp.Name = 'TestCA Opp';
        /*opp.CloseDate = system.today();*/
        insert opp;
        Question__c q1 = new Question__c();
        q1.question__c = 'Business Model: Ask the MX on what sort of business they are into (Eg: E-com, IT Industry , Travel, Etc) ?';
        q1.Answer__c = '';
        q1.Opportunity__c = opp.Id;
        insert q1;
        Question__c q2 = new Question__c();
        q2.question__c = 'Challenges faced by the merchant?';
        q2.Answer__c = '';
        q2.Opportunity__c = opp.Id;
        insert q2;
        CAQuestionHandler.QuestionAnswer qa1 = new CAQuestionHandler.QuestionAnswer();
        qa1.question = 'Business Model: Ask the MX on what sort of business they are into (Eg: E-com, IT Industry , Travel, Etc) ?';
        qa1.answer = 'Test';
        CAQuestionHandler.QuestionAnswer qa2 = new CAQuestionHandler.QuestionAnswer();
        qa2.question = 'Challenges faced by the merchant?';
        qa2.answer = 'Test3';
        List<CAQuestionHandler.QuestionAnswer> qaList = new List<CAQuestionHandler.QuestionAnswer>{qa1,qa2};
        Test.StartTest();
        CAQuestionHandler.getQuetions(opp.Id);
        CAQuestionHandler.saveQuestions(qaList,opp.Id);
        Test.StopTest();
    }
}