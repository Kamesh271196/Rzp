@istest
public class BulkEmailCommunication_Test {
    /*
    @istest
    public static void testbulkemailticket(){
        
        Bulk_Email_Communication__c email=new Bulk_Email_Communication__c();
        email.Subject__c='Test Subject';
        email.Body__c='Test body';
        email.Merchant_Email__c='syed.fyaz@razorpay.com';
        email.Merchant_Id__c='testmerchantid';
        email.Group__c='1082000637524';
        email.Agent_Category__c='Risk Report_Merchant';
        email.Agent_Items__c='Increase';
        email.Agent_Sub_Category__c='Limit Enhancement';
        email.Status__c='2';
        insert email;
        email.Active__c=true;
        email.create_fd_ticket__c=true;
        update email;
        
    }
    */
    @istest
    public static void testbulkemailticketbulk(){
        List<Bulk_Email_Communication__c> listbulkemail= new  List<Bulk_Email_Communication__c>();
        for(integer i=0;i<=299;i++){
            Bulk_Email_Communication__c email=new Bulk_Email_Communication__c();
        	email.Subject__c='Test Subject';
        	email.Body__c='Test body';
        	email.Merchant_Email__c='syed.fyaz@razorpay.com';
        	email.Merchant_Id__c='testmerchantid'+i;
        	email.Group__c='1082000637524';
        	email.Agent_Category__c='Risk Report_Merchant';
        	email.Agent_Items__c='Increase';
        	email.Agent_Sub_Category__c='Limit Enhancement';
        	email.Status__c='2';
        	listbulkemail.add(email);
        }
       
        insert listbulkemail;
        Set<Id> idset= new Set<Id>();
        for(Bulk_Email_Communication__c email:listbulkemail){
 			email.Active__c=true;
        	email.create_fd_ticket__c=true; 
            idset.add(email.id);
        }      
        update listbulkemail;
                
      
       
    }
   
}