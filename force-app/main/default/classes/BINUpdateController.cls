public class BINUpdateController {
    
       
    @AuraEnabled
	public static string saveBINRequest(BINUpdateController.BINUpdateWrapper binrequest){
    	string message='';
        string description='';
        try{
       if(binrequest.comment!=null){
            description=description+'Comments :'+binrequest.comment+'\n'+'------------------------'+'\n';
        }else{
            description=description+'\n'+'------------------------'+'\n';

        }    
         
        if(binrequest.isbulk!=null){
           description=description+'Request Type: BIN Update \n '+'Is Bulk: '+binrequest.isbulk+'\n';
        }
        if(binrequest.bin!=null){
            description=description+'BIN :'+binrequest.bin+'\n';
        }
        if(binrequest.issuer!=null){
            description=description+'Issuer :'+binrequest.issuer+'\n';
        }
        if(binrequest.cardtype!=null){
            description=description+'Card Type :'+binrequest.cardtype+'\n';
        }
        if(binrequest.selectedcardsubtype!=null){
            description=description+'Card Subtype :'+binrequest.selectedcardsubtype+'\n';
        }
        if(binrequest.cardnetwork!=null){
            description=description+'Card cardnetwork :'+binrequest.cardnetwork+'\n';
        }
        if(binrequest.selectedheadlessotp!=null){
            description=description+'Headless OTP :'+binrequest.selectedheadlessotp+'\n';
        }
        if(binrequest.selected3ds!=null){
            description=description+'3ds :'+binrequest.selected3ds+'\n';
        }
        if(binrequest.selectedmendatehub!=null){
            description=description+'Mandate Hub :'+binrequest.selectedmendatehub+'\n';
        }
        if(binrequest.selectedapprovalpoc!=null){
            description=description+'Approval POC :'+binrequest.selectedapprovalpoc+'\n';
        }
        if(binrequest.approvalurl!=null){
            description=description+'Approval Email URL :'+binrequest.approvalurl+'\n';
        }
        
       
        FreshDesk_Ticket__c fdticket = new FreshDesk_Ticket__c();
        fdticket.CX_Approval_Status__c='Approval not Required';
        fdticket.CX_Subject__c='BIN Request';
        fdticket.CX_Priority__c='3';
        fdticket.Status__c='2';
        fdticket.CX_Group__c ='SRF';
        //fdticket.CX_Sub_category__c='';
        //fdticket.CX_Item__c='';
        fdticket.Merchant_Id__c='BINUPDATEMERCHANT';
        //fdticket.CX_Category__c='';
        fdticket.Product_Name__c='Payment Gateway';
        fdticket.CX_TicketOrigin__c='Salesforce';
        //fdticket.Priority_Reason__c='Loss-making;';
        Insert fdticket;
        CX_SRF_SPR__c  srdspr= new CX_SRF_SPR__c ();
        srdspr.CX_FreshDesk_Ticket__c =fdticket.id;
        srdspr.CX_Request_Type_Name__c='IIN Updates'; 
        insert srdspr;
         if(binrequest.file!=null && binrequest.file!=''){
            ContentVersion cv = createContentVersion(binrequest.file, binrequest.filename);
            ContentDocumentLink cdl = createContentLink(cv.Id, srdspr.id);
        }
		fdticket.CX_Description__c= description;
            if(!Test.isRunningTest()){
                 update fdticket;
            }    
       
        system.debug(binrequest);
            message=String.valueOf(fdticket.id);
        }catch(exception ex){
 			message='error';            
        }
        return message;
	}
    
    public class BINUpdateWrapper{
        @AuraEnabled
        public String isbulk{get;set;}
        @AuraEnabled
        public String bin{get;set;}
        @AuraEnabled
        public String countrycode{get;set;}
        @AuraEnabled
        public String issuer{get;set;}
        @AuraEnabled
        public String cardnetwork{get;set;}
        @AuraEnabled
        public String comment{get;set;}
        @AuraEnabled
        public String selectedcardsubtype{get;set;}
        @AuraEnabled
        public String selectedheadlessotp{get;set;}
        @AuraEnabled
        public String selected3ds{get;set;}
        @AuraEnabled
        public String selectedmendatehub{get;set;}
        @AuraEnabled
        public String selectedapprovalpoc{get;set;}
        @AuraEnabled
        public String filename{get;set;}
        @AuraEnabled
        public String file{get;set;}
        @AuraEnabled
        public String approvalurl{get;set;}
        @AuraEnabled
        public String cardtype{get;set;}
        
        
        
    }
    
private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
              if (contentVersionId == null || recordId == null) { return null; }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId 
      FROM ContentVersion 
      WHERE Id =: contentVersionId
    ].ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    // ShareType is either 'V', 'C', or 'I'
    // V = Viewer, C = Collaborator, I = Inferred
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
}
	private static ContentVersion createContentVersion(String base64, String filename) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    try {
      insert cv;
      return cv;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
}