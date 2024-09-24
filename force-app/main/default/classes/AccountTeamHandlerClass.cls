/**
	
* Class Name  : AccountTeamHandlerClass

* Description : Handler Class for updating account team members in Account field
 
* Created by  : Nandhini R S

* Version     : 1.0

* Created Date: 31/03/2020

**/ 
public class AccountTeamHandlerClass {
        Public void onAfterInsert(List<AccountTeamMember> atmlist){
        try{
        Map<Account,String> accmap=new Map<Account,String>();
        Map<Id,set<Id>> atmap=new Map<Id,set<Id>>();
        Map<Id,String> Usermap1=new Map<Id,String>();
        Map<Id,List<String>> Usermap=new Map<Id,List<String>>();
        Map<id,String> useremailmap=new Map<Id,string>();
        List<Account> acntlist=new List<Account>();
        /*Get the Inserted Account Team Member and account*/
        
        For(AccountTeamMember atm:atmlist) {
        If(atmap.get(atm.AccountId)!=null){
        atmap.get(atm.AccountId).add(atm.UserId);      
        }
        else{
        set<id> atmuserid=new set<Id>(); 
        atmuserid.add(atm.UserId);
        atmap.put(atm.AccountId,atmuserid);
        }
        }
        Set<Id> useridset=new Set<Id>();
        for(Id idValue : atmap.keyset()){           
        for(Id s : atmap.get(idValue ))
         {
          useridset.add(s);
         }
          }
        System.debug('useridset'+useridset);
        system.debug('atmap'+atmap);
        /*Query user Details From Account Team Member*/
        List<User> userlst=[Select id,Email,isactive From User where isactive =true and id in :useridset];      
        System.debug('userlst'+userlst);
        For(User u :userlst){
        useremailmap.put(u.id,u.Email);      
            } 
   
        List<Account> acclst=[Select id,Managers_In_Role_Hierarchy__c from Account where id in:atmap.keyset()];
        If(acclst.size()>0){
        For(Account acc:acclst){
        accmap.put(acc,acc.Managers_In_Role_Hierarchy__c);        
            }   
        }
        /*Add the user to Account*/    
        
        For(Account acc:acclst){
         String useremail='';
         For(Id userid :atmap.get(acc.id)) {
         useremail+=useremailmap.get(userid)+',';
         System.debug('useremail'+useremail);
         }
         if(accmap.get(acc)!=null){
         acc.Managers_In_Role_Hierarchy__c=accmap.get(acc)+useremail;
         acc.MRH_Date__c=System.now();
            }
         else{
         acc.Managers_In_Role_Hierarchy__c=useremail; 
         acc.MRH_Date__c=System.now();
            }
         acntlist.add(acc);
         System.debug('acntlist'+acntlist); 
        }
         Map<String,Account> Accountupdatemap=new map<String,Account>();
         for(Account acc:acntlist){
         Accountupdatemap.put(acc.Managers_In_Role_Hierarchy__c,acc);   
            }
         update Accountupdatemap.Values();
        }
        Catch(Exception e){
        System.debug('Error Message'+e.getMessage());        
            }
        }


Public void OnBeforeDelete(Map<Id,Sobject> Map1){   
        try{
        Map<id,AccountTeamMember> atmlist=(Map<id,AccountTeamMember>) Map1;
        Map<Account,String> accmap=new Map<Account,String>();
        Map<Id,set<Id>> atmap=new Map<Id,set<Id>>();
        Map<Id,String> Usermap1=new Map<Id,String>();
        Map<Id,List<String>> Usermap=new Map<Id,List<String>>();
        Map<id,String> useremailmap=new Map<Id,string>();
        List<Account> acntlist=new List<Account>();
    
        /*Get the Inserted Account Team Member and account*/
        
        For(AccountTeamMember atm:atmlist.values()) {
        If(atmap.get(atm.AccountId)!=null){
        atmap.get(atm.AccountId).add(atm.UserId);      
        }
        else{
        set<id> atmuserid=new set<Id>(); 
        atmuserid.add(atm.UserId);
        atmap.put(atm.AccountId,atmuserid);
        }
        }
        system.debug('atmap'+atmap);
        Set<Id> useridset=new Set<Id>();
        for(Id idValue : atmap.keyset()){           
        for(Id s : atmap.get(idValue ))
         {
          useridset.add(s);
         }
          }
        System.debug('useridset'+useridset);
        system.debug('atmap'+atmap);
        /*Query user Details From Account Team Member*/
        List<User> userlst=[Select id,Email,isactive From User where isactive =true and id in :useridset];      
        System.debug('userlst'+userlst);
        For(User u :userlst){
        useremailmap.put(u.id,u.Email);      
            } 
        List<Account> acclst=[Select id,Managers_In_Role_Hierarchy__c from Account where id in:atmap.keyset()];
        If(acclst.size()>0){
        For(Account acc:acclst){
        accmap.put(acc,acc.Managers_In_Role_Hierarchy__c);        
            }   
        }
            
        /*Add Team member to Account*/
            
        For(Account acc:acclst){
        String useremail='';
        For(Id userid :atmap.get(acc.id)) {
        useremail+=useremailmap.get(userid)+',';
        System.debug('useremail'+useremail);
         }
        string managerinhierarchy=acc.Managers_In_Role_Hierarchy__c;
        if(accmap.get(acc)!=null){
        managerinhierarchy=acc.Managers_In_Role_Hierarchy__c.remove(useremail);
        acc.Managers_In_Role_Hierarchy__c=managerinhierarchy;
        }
        System.debug('manger'+acc.Managers_In_Role_Hierarchy__c);
        acntlist.add(acc);
        System.debug('acntlist'+acntlist);
        }
        Map<String,Account> Accountupdatemap=new map<String,Account>();
        for(Account acc:acntlist){
        Accountupdatemap.put(acc.Managers_In_Role_Hierarchy__c,acc);   
        }
        update Accountupdatemap.Values();
        }
        Catch(Exception e){
        System.debug('Error Message'+e.getMessage());
        }
         }
          }