public class AOPTrggerHelper {
    public static void createProductDetails(List<AOP__C> listaop){
        
     List<AOP_Product_Detailsmdt__mdt >   aopProdmdtlist=[select Product_Name__c  from AOP_Product_Detailsmdt__mdt];
     List<AOP_Product_Details__c >   prodList=new List<AOP_Product_Details__c >();
        for(AOP__C aoprecord:listaop){
            for(AOP_Product_Detailsmdt__mdt mdtrecord:aopProdmdtlist){
              AOP_Product_Details__c aopdObj= new   AOP_Product_Details__c();
         	  aopdObj.AOP__c = aoprecord.id; 
              aopdObj.Product_Name__c  = mdtrecord.Product_Name__c;
              prodList.add(aopdObj);  
            }         
        }  
        if(prodList.size()>0){
            insert prodList;
        }
        
    } 
    
    
    public static void calculateFormulaFields(List<AOP__C> listaop,String operation){
        
        if(listaop.size()==1){
            try{
                listaop[0].recordCreated__c=true;
     	String year=listaop[0].Financial_Year__c.split('-')[0];          
		Period fydetails=[SELECT FiscalYearSettings.Name ,StartDate,EndDate FROM Period WHERE Type = 'Year' and FiscalYearSettings.Name=:year];
        Map<Id,Account> childAccountList=new Map<Id,Account>([select id,merchant_id__c from Account where parentid=:listaop[0].account__C]);              	
      	childAccountList.put(listaop[0].account__C,null);
        AggregateResult[] armethodwise=[select method__c,sum(GMV__C) from Product_GMV__C where account__c  in :childAccountList.keyset() and Date__c >= :fydetails.StartDate and   Date__c <= :fydetails.EndDate and method__C!='' and GMV__C>0  group by method__c];
        AggregateResult[] arproductwise=[select product__C,sum(GMV__C) from Product_GMV__C where account__c  in :childAccountList.keyset() and Date__c >= :fydetails.StartDate and   Date__c <= :fydetails.EndDate and product__C!='' and GMV__C>0 group by product__C];
        AggregateResult[] arproductwisegmv=[select method__C,sum(authorized_international_gmv__c) from GMV__C where Merchant__c  in :childAccountList.keyset() and Transaction_Date__c >= :fydetails.StartDate and   Transaction_Date__c <= :fydetails.EndDate and method__C!='' and authorized_international_gmv__c>0 group by method__C];
		List<Capital_Performance__c> arcapitaldetails =[SELECT  Product__c, Transaction_Count__c, Average_Transaction_Value__c, Tenure__c, Total_loan_disbursed__c, Total_transaction_value__c,Total_principal_recovered__c FROM Capital_Performance__c where Account__c  in :childAccountList.keyset() and Transaction_Date__c >= :fydetails.StartDate and   Transaction_Date__c <= :fydetails.EndDate ];
	    List<RZP_X_Performance__c> arxcadetails =[SELECT  Payout_Links_TPV__c,Vendor_Payment_TPV__c,PRODUCT__C,API_Payout_TPV__c, Bulk_Payout_TPV__c, Transaction_Count__c,XLite_Float__c , XLite_TPV__c , Vanilla_Payout_TPV__c  , CA_TPV__c,CA_AMB__c   , No_Of_Employees__c,mtu__C FROM RZP_X_Performance__c WHERE Account__c  in :childAccountList.keyset() and Last_Transaction_Date__c >= :fydetails.StartDate and   Last_Transaction_Date__c <= :fydetails.EndDate ];
        AggregateResult[] monthsgmv_9=[select method__C,sum(Authorized_GMV__c ) from GMV__C where Merchant__c  in :childAccountList.keyset() and Transaction_Date__c > :fydetails.StartDate and   Transaction_Date__c < :fydetails.EndDate and method__C!='' and Authorized_GMV__c >0 and Transaction_Date__c =LAST_N_MONTHS:9 group by method__C];
				double gmv_9_month_netbanking=0.0;
                double gmv_9_month_card=0.0;
                double gmv_9_month_upi=0.0;
                 double gmv_9_month_emi=0.0;
                double gmv_9_month_other=0.0;
                double totalGMV=0.0;
                for(AggregateResult ar:monthsgmv_9){
                    totalGMV=totalGMV+double.valueOf(String.valueOf(ar.get('expr0')));
                    if(String.valueOf(ar.get('method__c')).contains('net')){
                         gmv_9_month_netbanking=gmv_9_month_netbanking+Decimal.valueOf(String.valueOf(ar.get('expr0')));
                    }
                    if(String.valueOf(ar.get('method__c')).contains('card')){
                         gmv_9_month_card=gmv_9_month_card+Decimal.valueOf(String.valueOf(ar.get('expr0')));
                    }
                    if(String.valueOf(ar.get('method__c')).contains('upi')){
                         gmv_9_month_upi=gmv_9_month_upi+Decimal.valueOf(String.valueOf(ar.get('expr0')));
                    }
                    if(String.valueOf(ar.get('method__c')).contains('emi')){
                         gmv_9_month_emi=gmv_9_month_emi+Decimal.valueOf(String.valueOf(ar.get('expr0')));
                    }
                }
                gmv_9_month_other=(totalGMV-gmv_9_month_emi-gmv_9_month_upi-gmv_9_month_card-gmv_9_month_netbanking);
				
                if((listaop[0].L9_months_GMV_Net_banking__c <=0 || listaop[0].L9_months_GMV_Net_banking__c ==null) && gmv_9_month_netbanking>0){
                    listaop[0].L9_months_GMV_Net_banking__c=(gmv_9_month_netbanking/totalGMV)*100;
                }
				if((listaop[0].L9_months_GMV_Affor_BNPL_etc__c  <=0 || listaop[0].L9_months_GMV_Affor_BNPL_etc__c  ==null) && gmv_9_month_emi>0){
                    listaop[0].L9_months_GMV_Affor_BNPL_etc__c =(gmv_9_month_emi/totalGMV)*100;
                }
                if((listaop[0].L9_months_GMV_Creditcard__c  <=0 || listaop[0].L9_months_GMV_Creditcard__c  ==null) && gmv_9_month_card>0){
                    listaop[0].L9_months_GMV_Creditcard__c =(gmv_9_month_card/totalGMV)*100;
                }
                //if(listaop[0].L9_months_GMV_Debit_card__c  <=0 || listaop[0].L9_months_GMV_Debit_card__c  ==null){
                  //  listaop[0].L9_months_GMV_Debit_card__c =(gmv_9_month_netbanking/totalGMV)*100;
                //}
                if((listaop[0].L9_months_GMV_UPI__c   <=0 || listaop[0].L9_months_GMV_UPI__c   ==null )&& gmv_9_month_upi>0){
                    listaop[0].L9_months_GMV_UPI__c  =(gmv_9_month_upi/totalGMV)*100;
                }
                
                if((listaop[0].L9_months_GMV_Others__c  <=0 || listaop[0].L9_months_GMV_Others__c  ==null)&& gmv_9_month_other>0){
                    listaop[0].L9_months_GMV_Others__c =(gmv_9_month_other/totalGMV)*100;
                }
            	decimal ppiwalletgmv=0.0;
                decimal Optimizergmv=0.0;
                decimal CrossBordergmv=0.0;
                decimal Capitalgmv=0.0;
                decimal Payoutsgmv=0.0;
                decimal corpcardgmv=0.0;
                decimal turbotpapgmv=0.0;
                decimal loyalitystackgmv=0.0;
                decimal cardstackgmv=0.0;
                decimal whatsappcheckoutgmv=0.0;
                decimal magiccheckoutgmv=0.0;
                decimal recurringgmv=0.0;
                decimal othergmv=0.0;
                decimal ambxca=0.0;
                decimal tvpxca=0.0;
                decimal tvpxvanillapayout=0.0;
                decimal tvpxvendorpayout=0.0;
                decimal tvpxlitefloat=0.0;
                decimal tvpxlite=0.0;
                decimal tvpxpayoutlink=0.0;
                integer xpayrollnoofemployee=0;
                decimal xpayrollmtu=0.0;
                decimal lendingttld=0.0;
                decimal lendingtda=0.0;
               	decimal corpcardttv=0.0;
                decimal corpcardatv=0.0;
                for(AggregateResult ar:armethodwise){                  
                  if(String.valueOf(ar.get('method__c')).contains('wallet')){
                    ppiwalletgmv=ppiwalletgmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  }
                  else if(String.valueOf(ar.get('method__c')).contains('corporate')){
                    corpcardgmv=corpcardgmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  } 
                  else if(String.valueOf(ar.get('method__c')).contains('net')){
                    othergmv=othergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  }
                  else if(String.valueOf(ar.get('method__c')).contains('card')){
                    cardstackgmv=cardstackgmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  }
                  else if(String.valueOf(ar.get('method__c')).contains('upi')){
                    othergmv=othergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  }
                  else if(String.valueOf(ar.get('method__c')).contains('virtual')){
                    othergmv=othergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  }
                  else if(String.valueOf(ar.get('method__c')).contains('neft')){
                    othergmv=othergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  }
                   else  if(String.valueOf(ar.get('method__c')).contains('NACH')){
                    othergmv=othergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                   }else{
                     othergmv=othergmv+  decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                   }
                }
                
                for(AggregateResult ar:arproductwise){                  
                  if(String.valueOf(ar.get('product__C'))=='Optimiser'|| String.valueOf(ar.get('product__C'))=='Optimizer'){
                    Optimizergmv=Optimizergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));
                  } 
                    
                    
                }
                
                
                for(AggregateResult ar:arproductwisegmv){                                   
                    CrossBordergmv=CrossBordergmv+decimal.valueOf(String.valueOf
                                                              (ar.get('expr0')));                             
                }
               
                for(Capital_Performance__c ar:arcapitaldetails){
                    if(ar.Product__c.contains('Cards') || ar.Product__c.contains('cards') || ar.Product__c.contains('card')|| ar.Product__c.contains('CARDS')){
                        if(ar.Total_transaction_value__c!=null){
                             corpcardttv=corpcardttv+decimal.valueof(ar.Total_transaction_value__c );
                        }
                if(ar.Average_Transaction_Value__c!=null){
                              corpcardatv=corpcardatv+decimal.valueof(ar.Average_Transaction_Value__c) ; 
                        }
                       
                    }else{
                        if(ar.Total_loan_disbursed__c!=null){
                             lendingttld=lendingttld+ar.Total_loan_disbursed__c ;
                        }
                         if(  ar.Total_principal_recovered__c!=null){
                             lendingtda=lendingtda+ar.Total_principal_recovered__c;
                        } 
                        
                          
              
                    }
                               
                }
                for(RZP_X_Performance__c ar:arxcadetails){   

                    if(ar.CA_TPV__c!=null){
                         tvpxca=tvpxca+ar.CA_TPV__c;
                    }
                	if(ar.Vanilla_Payout_TPV__c!=null){
                        tvpxvanillapayout=tvpxvanillapayout+ar.Vanilla_Payout_TPV__c;
                    }
					if(ar.Vendor_Payment_TPV__c!=null){
                        tvpxvendorpayout=tvpxvendorpayout+ar.Vendor_Payment_TPV__c;
                    }                 
                 if(ar.XLite_Float__c!=null){
                        tvpxlitefloat=tvpxlitefloat+ar.XLite_Float__c;
                    } 
                  if(ar.XLite_TPV__c!=null){
                         tvpxlite=tvpxlite+ar.XLite_TPV__c;
                    } 
                if(ar.Payout_Links_TPV__c!=null){
                         tvpxpayoutlink=tvpxpayoutlink+ar.Payout_Links_TPV__c;
                    } 
                if(ar.CA_AMB__c!=null){
                         ambxca=ambxca+ar.CA_AMB__c;
                    } 
                 
                }
                if(listaop[0].GMV_Cur_Year_PPI_Wallet__c<=0 || listaop[0].GMV_Cur_Year_PPI_Wallet__c==null){
                    listaop[0].GMV_Cur_Year_PPI_Wallet__c=ppiwalletgmv/10000000;
                }
                if(listaop[0].GMV_Cur_Year_Optimizer__c<=0 || listaop[0].GMV_Cur_Year_Optimizer__c==null){
                    listaop[0].GMV_Cur_Year_Optimizer__c=Optimizergmv/10000000;
                }
               	if(listaop[0].GMV_Cur_Year_Corp_cards_spends__c <=0  || listaop[0].GMV_Cur_Year_Corp_cards_spends__c ==null){
                    listaop[0].GMV_Cur_Year_Corp_cards_spends__c =corpcardgmv/10000000;
                }
               	if(listaop[0].GMV_Cur_Year_Card_Stack__c <=0  || listaop[0].GMV_Cur_Year_Card_Stack__c ==null){
                    listaop[0].GMV_Cur_Year_Card_Stack__c =cardstackgmv/10000000;
                }
               	if(listaop[0].GMV_Cur_Year_Cross_Border__c<=0  || listaop[0].GMV_Cur_Year_Cross_Border__c==null){
                    listaop[0].GMV_Cur_Year_Cross_Border__c=CrossBordergmv/10000000;
                }
              	if(listaop[0].TPV_Cur_Year_X_CA__c<=0 || listaop[0].TPV_Cur_Year_X_CA__c==null){
                    listaop[0].TPV_Cur_Year_X_CA__c=tvpxca/10000000;
                }
               	if(listaop[0].AMB_Cur_Year_X_CA__c<=0 || listaop[0].AMB_Cur_Year_X_CA__c==null){
                    listaop[0].AMB_Cur_Year_X_CA__c=ambxca/10000000;
                }
               	if(listaop[0].TPV_Cur_Year_Xlite_Float__c<=0 || listaop[0].TPV_Cur_Year_Xlite_Float__c==null){
                    listaop[0].TPV_Cur_Year_Xlite_Float__c=tvpxlitefloat/10000000;
                }
                if(listaop[0].TPV_Cur_Year_XLite__c<=0 || listaop[0].TPV_Cur_Year_XLite__c==null){
                    listaop[0].TPV_Cur_Year_XLite__c=tvpxlite/10000000;
                }
                if(listaop[0].TPV_Cur_Year_X_Vendor_Payout__c<=0 || listaop[0].TPV_Cur_Year_X_Vendor_Payout__c==null){
                    listaop[0].TPV_Cur_Year_X_Vendor_Payout__c=tvpxvendorpayout/10000000;
                }
              	if(listaop[0].TPV_Cur_Year_X_Vanilla_Payout__c<=0 || listaop[0].TPV_Cur_Year_X_Vanilla_Payout__c==null){
                    listaop[0].TPV_Cur_Year_X_Vanilla_Payout__c=tvpxvanillapayout/10000000;
                }
                if(listaop[0].TPV_Cur_Year_Paylout_Link__c<=0 || listaop[0].TPV_Cur_Year_Paylout_Link__c==null){
                    listaop[0].TPV_Cur_Year_Paylout_Link__c=tvpxpayoutlink/10000000;
                }
                if(listaop[0].GMV_Cur_Year_Other__c <=0 || listaop[0].GMV_Cur_Year_Other__c ==null){
                    listaop[0].GMV_Cur_Year_Other__c =othergmv/10000000;
                }
                                
                
            }
            catch(Exception ex){
             System.debug('Error'+ex);   
            }
            
        }
    }

}