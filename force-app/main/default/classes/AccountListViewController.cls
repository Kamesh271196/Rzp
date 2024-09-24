public class AccountListViewController {
    public static final integer GMV_LIMIT=500000;
    public static string getstartdate(integer input){
        Map<integer,String> mapstartdate=new Map<integer,String>();
        mapstartdate.put(1,'10-01');
        mapstartdate.put(2,'10-01');
        mapstartdate.put(3,'10-01');
        mapstartdate.put(4,'01-01');
        mapstartdate.put(5,'01-01');
        mapstartdate.put(6,'01-01');
        mapstartdate.put(7,'04-01');
        mapstartdate.put(8,'04-01');
        mapstartdate.put(9,'04-01');
        mapstartdate.put(10,'07-01');
        mapstartdate.put(11,'07-01');
        mapstartdate.put(12,'07-01');
        return mapstartdate.get(input);
    }   
     public static string getenddate(integer input){
         Map<integer,String> mapenddate=new Map<integer,String>();
        mapenddate.put(1,'12-31');
        mapenddate.put(2,'12-31');
        mapenddate.put(3,'12-31');
        mapenddate.put(4,'03-31');
        mapenddate.put(5,'03-31');
        mapenddate.put(6,'03-31');
        mapenddate.put(7,'06-31');
        mapenddate.put(8,'06-31');
        mapenddate.put(9,'06-31');
        mapenddate.put(10,'09-30');
        mapenddate.put(11,'09-30');
        mapenddate.put(12,'09-30');
         return mapenddate.get(input);
     }   
    @AuraEnabled(cacheable=true)
    public static List<AccountListViewController.accountListViewJson> getAccount(){
        String mtd_startdate=getstartdate(date.today().month());
        String mtd_enddate=getenddate(date.today().month());
        
        date startdate=date.newInstance(date.today().year(), Integer.valueOf(
            mtd_startdate.split('-')[0]), Integer.valueOf(
            mtd_startdate.split('-')[1]));
        date enddate=date.newInstance(date.today().year(), Integer.valueOf(
            mtd_enddate.split('-')[0]), Integer.valueOf(
            mtd_enddate.split('-')[1]));
		map<String,string> gmvmapped= new map<String,string>();
		AggregateResult[] result= [select Merchant__c,sum(Authorized_GMV__c),max(Transaction_Date__c)  from GMV__c
                    where Transaction_Date__c >= :startdate and Transaction_Date__c<= :enddate 
                    group by Merchant__c  ];
        
        for(AggregateResult ar:result){
            if((Double)ar.get('expr0')>GMV_LIMIT){
              
                    if(!Approval.isLocked((String)ar.get('Merchant__c'))){
                                   gmvmapped.put((String)ar.get('Merchant__c'),String.valueOf(ar.get('expr0')));
                         
                }
            }
            
        }
        
        List<AccountListViewController.accountListViewJson> acclist  = new List<AccountListViewController.accountListViewJson>();
       for(Account acc:[select id ,name,merchant_id__C ,owner.name,owner.UserRole.RollupDescription from Account where id in :gmvmapped.keyset() 
            and Transfred_Account__c=false and owner.UserRole.RollupDescription not in ('KAM', 'Direct Sales', 
                                                                                        'Banking', 'Mid Market', 
                                                                                        'Startup Team') ]){
           
          		AccountListViewController.accountListViewJson accjson= new AccountListViewController.accountListViewJson();
             	accjson.Id=   acc.id;
              	accjson.accountName=acc.name;
                accjson.ownerName=   acc.owner.name;
              	accjson.gmvValue=gmvmapped.get(acc.id); 
                accjson.merchant_id=  acc.merchant_id__C;    
                accjson.team=  acc.owner.UserRole.RollupDescription;                                                                        
                acclist.add(accjson);
            }
       
        return acclist;
    } 
    /*
    @AuraEnabled(cacheable=true)
    public static List < sObject > getUser(String 
     searchKey,String 
    fieldName, String ObjectName,String keyField){
        String filterkey='Mid Market';
         List < sObject > returnList = new List < sObject > ();
        String sQuery =  'select '+fieldName+','+keyField+ ' from '
        +ObjectName+' where UserRole.RollupDescription ='+filterkey+'+ LIMIT 20' ;
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    } 
    @AuraEnabled(cacheable=true)
    public static List < User > getAllUser(){
        String filterkey='Mid Market';
         List < User > returnList = new List < User > ();
       returnList  =  [select Name ,Id  from User where UserRole.RollupDescription =:+ filterkey LIMIT 10] ;
        //List < User > lstOfRecords = Database.query(sQuery);
       
        
        return returnList;
    } 
*/
   @AuraEnabled
    public static String saveAccountChangeDetails(List<String> userdata){
       String result='Failure';
      List<Account> accList = new List<Account> ();
	        for(string data:userdata){
				Account acc= new   Account();
                acc.Transfred_Account__c=true;
             	acc.id= (Id)data;
                acc.OwnerId=getUserId();
                accList.add(acc);
       		 }
        if(accList.size()>0){
            	update accList;
             	result='Sucess';
        }
             
      return result;
    } 
    
    public class accountListViewJson{
       @AuraEnabled public string Id;
       @AuraEnabled public string accountName;
       @AuraEnabled public String ownerName;
       @AuraEnabled  public String gmvValue;
       @AuraEnabled  public String merchant_id;
       @AuraEnabled  public String team;
    }
    public static String getUserId(){
        
        User user=[select id from user where email=:System.Label.EM_MM_Account_Owner  and isActive=true];
       return user.id;
        
    }

}