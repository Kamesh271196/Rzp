public class AccountHistoryHelper {

    
    public static void  createAccountHistoryRecord(Map<ID,Account> newMap,Map<ID,Account> oldMap,String calledFrom){
        List<AccountHistoryJSON> accounthistoryObjList = new List<AccountHistoryJSON>();
        Map<Id,User> userMap= getAllUser();
            for(Id  accountid:newMap.keySet()){
                if(calledFrom=='Insert'){
                    
                AccountHistoryJSON    accounthistoryObj = new  AccountHistoryJSON();
                accounthistoryObj.accountId=accountid;
                accounthistoryObj.actionTime=System.now();
                accounthistoryObj.type='Owner Change';
                accounthistoryObj.userId='';               
                accounthistoryObj.newValue=  userMap.get(newMap.get(accountid).ownerId).name;
                accounthistoryObj.userteam=userMap.get(newMap.get(accountid).ownerId).UserRole.rollupdescription;   
                accounthistoryObjList.add(accounthistoryObj);
				               
                }
                if(calledFrom=='Update' && oldMap.get(accountid).ownerId!=null 
                   && newMap.get(accountid).ownerId!=oldMap.get(accountid).ownerId ){
                AccountHistoryJSON    accounthistoryObj = new  AccountHistoryJSON();
                accounthistoryObj.accountId=accountid;
                accounthistoryObj.actionTime=System.now();
                accounthistoryObj.type='Owner Change';
                accounthistoryObj.userId='';               
                accounthistoryObj.newValue=  userMap.get(newMap.get(accountid).ownerId).name;
                accounthistoryObj.oldValue=    userMap.get(oldMap.get(accountid).ownerId).name;
                accounthistoryObj.userteam=userMap.get(newMap.get(accountid).ownerId).UserRole.rollupdescription;
                accounthistoryObjList.add(accounthistoryObj);
                }
           		
                
                
            }
        if(accounthistoryObjList.size()>0){
            createAccountHistoryRecord(accounthistoryObjList);
        }
        
    }
    
  
    public static void createAccountHistoryRecord(List<AccountHistoryJSON> accounthistoryObjList){
        List<Account_History__c> accHistoryList= new List<Account_History__c>();
        for(AccountHistoryJSON accounthistoryObj:accounthistoryObjList){
           Account_History__c accountHistoryRecord= new Account_History__c ();
          accountHistoryRecord.Account__c =(Id)accounthistoryObj.accountId;
          accountHistoryRecord.User__c =UserInfo.getUserId();
          accountHistoryRecord.Action_Date__c =accounthistoryObj.actionTime;
          accountHistoryRecord.New_Value__c =accounthistoryObj.newValue;
          accountHistoryRecord.Old_Value__c =accounthistoryObj.oldValue;
          accountHistoryRecord.Type__c =accounthistoryObj.type;  
             accountHistoryRecord.User_Team__c  =accounthistoryObj.userteam; 
            accHistoryList.add(accountHistoryRecord);
        }
        if(  accHistoryList.size()>0){
            insert accHistoryList;
        }                                      
                                              }
  
    public static Map<Id,User> getAllUser(){
         return new Map<Id,User>([select id,UserRole.rollupdescription,Name
                                                          from user ]);
        
    }

}