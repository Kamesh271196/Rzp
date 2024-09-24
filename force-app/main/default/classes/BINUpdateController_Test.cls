@Istest
public class BINUpdateController_Test {
    
    
   @Istest
    public static void callBINUpdate(){
        BINUpdateController.BINUpdateWrapper binrequest
            = new BINUpdateController.BINUpdateWrapper();
       binrequest.comment='comment'; 
       binrequest.bin='bin';
       binrequest.cardnetwork='Test';
       binrequest.cardtype='Test';
       binrequest.countrycode='+91'; 
       binrequest.isbulk='Yes';
       binrequest.issuer='Issuer'; 
       binrequest.selectedapprovalpoc='Approval POC';
       binrequest.approvalurl='url';
       binrequest.selectedmendatehub='mendate';
       binrequest.selected3ds='3ds';
       binrequest.selectedheadlessotp='otp'; 
	   binrequest.file='UmVjb3JkSUQsTWVyY2hhbnRJRCxHU1RJTixQaW4gQ29kZSxPd25lciBFbWFpbCxVbnF1YWxpZmllZC9RdWFsaWZpZWQsVW5xdWFsaWZpZWQgUmVhc29uLE90aGVyIFJlYXNvbixDYW1wYWlnbiBOYW1l';	        
       binrequest.filename='Test File';
        
       BINUpdateController.saveBINRequest(binrequest);  
      
    }

}