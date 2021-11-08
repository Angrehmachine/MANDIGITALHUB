public class contractCreationController {
    //AssetTruck Rectype
    public Id truckRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Truck').getRecordTypeId();
    public static String FINALSTATUSSUCESS = 'Close Won';
    public static String FINALSTATUSFAILED = 'Close Lost';
    
    /*********************************************************************************************
    *@Description : Aura enabled method that will start contract Creation             
    *@Params      : Id (Opportunity Id from recordId)                                                                      
    *@Return      : String                                                                              
    *************************************************************************************************/
    @AuraEnabled
    public static String getContractCreation( Id oppId) {
        String sReturn = '';
        contractCreationController creation = new contractCreationController();
        Opportunity opp = creation.getOpportunityFields(oppId);
        if ( opp.StageName == FINALSTATUSSUCESS || opp.StageName == FINALSTATUSFAILED ) {
            throw new AuraHandledException('Opportunity is already closed');
        } else {
            Contract ctrc = creation.createcontractBasedOnOpportunity(opp);
            if ( ctrc.Id != null ) {
                sReturn = creation.truckAssetCreation(oppId,ctrc);
                if ( sReturn != null ) {
                    try {
                        opp.StageName = FINALSTATUSSUCESS;
                        Database.update(opp);
                    } catch (Exception ex) {
                        sReturn = ex.getMessage();
                    }  
                }
            }
        }
        return sReturn;        
    }
    
    /*********************************************************************************************
    *@Description : Query to retrieve opportunity fields             
    *@Params      : Id (Opportunity Id from recordId)                                                                     
    *@Return      : Opportunity                                                                              
    *************************************************************************************************/
    public Opportunity getOpportunityFields (String oppid) {
        Opportunity retrievedOpp = [SELECT Id, StageName, AccountId, Contract_Duration__c, Pricebook2Id FROM Opportunity WHERE id =:oppid];
        return retrievedOpp;
    }
    
    /*********************************************************************************************
    *@Description : Query to retrieve OpportunityLineItem fields             
    *@Params      : Id (Opportunity Id from recordId)                                                                     
    *@Return      : List<OpportunityLineItem>                                                                              
    *************************************************************************************************/
    public List<OpportunityLineItem> getOpportunityLine (String oppid) {
        List<OpportunityLineItem> oppLineItems = [SELECT id, Name, Service__c, Quantity, Product2Id,Product2.Name from OpportunityLineItem where OpportunityId =:oppid];
        return oppLineItems;
    }
    
    /*********************************************************************************************
    *@Description : Method that based on OpportunityLineItem Records creates Assets of type truck             
    *@Params      : Id (Opportunity Id from recordId), Contract (Contract from creation)                                                                     
    *@Return      : String                                                                              
    *************************************************************************************************/
    public String truckAssetCreation ( String oppId,Contract ctrc ){
        List<OpportunityLineItem> oppLineItems = getOpportunityLine(oppId);
        List<Asset> trucksToBeCreated = new List<Asset>();
        for ( OpportunityLineItem oppLine : oppLineItems ) {
            Integer count = 0;
            while( count < Integer.valueOf(oppLine.Quantity) ) {
                if (oppLine.Service__c != null) {
                    trucksToBeCreated.add(new Asset(Product2Id=oppLine.Product2Id,Contract__c = ctrc.Id, accountid = ctrc.accountid,name = oppLine.Product2.Name, Service_tecnical__c=oppLine.Service__c, recordtypeId=truckRecordTypeId));
                } else {
                    trucksToBeCreated.add(new Asset(Product2Id=oppLine.Product2Id,Contract__c = ctrc.Id, accountid = ctrc.accountid, name = oppLine.Product2.Name, recordtypeId=truckRecordTypeId));
                }
                count++;
            }            
        }
        try {
            Database.insert(trucksToBeCreated);
            return(ctrc.Id);
        } catch (Exception ex) {
            return null;
        }
    }
    
    /*********************************************************************************************
    *@Description : Method to create Contract based on Opportunity values             
    *@Params      : Opportunity record                                                                    
    *@Return      : Contract                                                                         
    *************************************************************************************************/
    public Contract createcontractBasedOnOpportunity ( Opportunity opp) {
        try {
            Contract ctrc = new Contract();
            ctrc.StartDate = system.today();
            ctrc.ContractTerm = Integer.valueOf(opp.Contract_Duration__c);
            ctrc.AccountId = opp.AccountId;
            ctrc.Pricebook2Id = opp.Pricebook2Id;
            ctrc.Status = 'Draft';
            ctrc.opportunity__c = opp.Id;
            Database.insert(ctrc);
            
            return ctrc;
        } catch ( Exception ex ){
            return null;
        }
    }   
}