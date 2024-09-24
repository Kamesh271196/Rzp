global class Churnmanagement implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    global Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('******');
         return Database.getQueryLocator([Select id,merchant_id__c,Lifetime_GMV__c,First_Transaction_Date__c,Last_Transaction_Date__c,	
                               Old_Churn_Category__c,Churn_Category__c from Account where Lifetime_GMV__c!=null and First_Transaction_Date__c!=null and Last_Transaction_Date__c!=null and Key_Account__c=false]);
    }
    global void execute(Database.BatchableContext BC, List<Account> acclst){
    try{
    Map<Decimal,String> LifeGMV=new Map<Decimal,String>();
    List<Account> finallst=new List<Account>();
        Integer NoOfDays;
    List<Churn_Data_Management__mdt> churnData = [Select MasterLabel,Lower_Limit__c,Daily_Limit__c,Churn_Days__c,Upper_Limit__c from Churn_Data_Management__mdt];
        system.debug('list'+churnData);
        List<Decimal> inte=new List<Decimal>();
    List<Churn_Data_Management__mdt> churndayslst= [Select Churn_Days__c from Churn_Data_Management__mdt limit1];
        system.debug('***********'+churndayslst);
        for(Churn_Data_Management__mdt cs1 : churndayslst)
        {
            inte.add(cs1.Churn_Days__c);
        }
        system.debug('churndays'+inte);
    Map<String,Decimal> Lowermap = new Map<String,Decimal>();
    Map<String,Decimal> Uppermap = new Map<String,Decimal>();
    Map<String,Decimal> Dailymap = new Map<String,Decimal>();
        for(Churn_Data_Management__mdt chdata : churnData){
            Lowermap.put(chdata.MasterLabel,chdata.Lower_Limit__c);
            Uppermap.put(chdata.MasterLabel,chdata.Upper_Limit__c);
            Dailymap.put(chdata.MasterLabel,chdata.Daily_Limit__c);
            
        }
    if(acclst.size()>0){
        system.debug('*******');
        system.debug('churnlimit'+inte.get(0));
            for(Account acc: acclst){
                Integer CalNoOfDays=acc.Last_Transaction_Date__c.daysBetween(system.today());
                if(acc.First_Transaction_Date__c.daysBetween(acc.Last_Transaction_Date__c)>0){
                NoOfDays=acc.First_Transaction_Date__c.daysBetween(acc.Last_Transaction_Date__c);
                }
                else{
                    NoOfDays=1;
                }
                if(CalNoOfDays>=inte.get(0)){
                    for(String category: Lowermap.keyset()){
                        if(category=='P0'){
                            system.debug('*******'+Lowermap.get(category));
                       system.debug('*******'+Uppermap.get(category));
                if(acc.Lifetime_GMV__c >=Lowermap.get(category) && acc.Lifetime_GMV__c<=Uppermap.get(category))
                   {
                LifeGMV.put(acc.Lifetime_GMV__c,acc.Merchant_ID__c);
                for(String s : LifeGMV.values()){         
                if(acc.Churn_Category__c==null){
                system.debug('oldchurncategory'+acc.Churn_Category__c);
                acc.Churn_Category__c=category;
                acc.Entry_Date__c=system.today(); 
                finallst.add(acc);
                }
                else{
                if(acc.Churn_Category__c!=null){
                if(acc.Churn_Category__c!=category){
                system.debug('elseblock');
                acc.Old_Churn_Category__c=acc.Churn_Category__c;
                acc.Churn_Category__c=category;
                acc.Entry_Date__c=system.today(); 
                acc.Exit_Date__c=system.today();
                finallst.add(acc);
                }
                } 
                }
                }   
                   }
                     }
                   }
                    system.debug('noofdays'+NoOfDays);
                   
                        for(String category: Lowermap.keyset()){
                        if(category=='P1'){
                       if(acc.Lifetime_GMV__c>=Lowermap.get(category) && acc.Lifetime_GMV__c/NoOfDays >=Dailymap.get(category) && acc.Lifetime_GMV__c<=Uppermap.get(category)){
                        LifeGMV.put(acc.Lifetime_GMV__c,acc.Merchant_ID__c);
                             for(String s : LifeGMV.values()){ 
                                 if(acc.Churn_Category__c==null){
                                acc.Churn_Category__c=category;
                            acc.Entry_Date__c=system.today(); 
                             finallst.add(acc);  
                             }
                                  else{
                    if(acc.Churn_Category__c!=null){
                        if(acc.Churn_Category__c!=category){
                        system.debug('elseblock');
                acc.Old_Churn_Category__c=acc.Churn_Category__c;
                acc.Churn_Category__c=category;
                acc.Entry_Date__c=system.today(); 
                acc.Exit_Date__c=system.today();
                        finallst.add(acc);
                }    
                } 
                                  }
                             }
                                  }
                             }          
                        }
                    
                            
                                 for(String category: Lowermap.keyset()){
                        if(category=='P2'){
                            if(acc.Lifetime_GMV__c>=Lowermap.get(category) && acc.Lifetime_GMV__c/NoOfDays <Dailymap.get(category) && acc.Lifetime_GMV__c<=Uppermap.get(category)){
                                 LifeGMV.put(acc.Lifetime_GMV__c,acc.Merchant_ID__c);
                                     for(String s : LifeGMV.values()){
                                 if(acc.Churn_Category__c==null){
                                acc.Churn_Category__c=category;
                            acc.Entry_Date__c=system.today(); 
                             finallst.add(acc);  
                             }
                                  else{
                    if(acc.Churn_Category__c!=null){
                        if(acc.Churn_Category__c!=category){
                        system.debug('elseblock');
                acc.Old_Churn_Category__c=acc.Churn_Category__c;
                acc.Churn_Category__c=category;
                acc.Entry_Date__c=system.today(); 
                acc.Exit_Date__c=system.today();
                finallst.add(acc);
                }    
                }    
                             }    
                                     }
                    }
                            }
                                 }
                            
                    system.debug('finallst'+finallst);   
                }
                if(CalNoOfDays<inte.get(0) &&  acc.Churn_Category__c!=null){
                    acc.Old_Churn_Category__c=acc.Churn_Category__c;
                    acc.Churn_Category__c=null;
                    acc.Exit_Date__c=System.today();
                    update acc;   
                }  
            }
              system.debug('*******'+finallst);
             update finallst;                
        }
    }
        catch(Exception e){       
        }
}
    global void finish(Database.BatchableContext BC){  
    }
}