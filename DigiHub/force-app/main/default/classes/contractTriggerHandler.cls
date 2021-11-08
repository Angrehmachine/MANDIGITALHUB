public class contractTriggerHandler {
    
    /*********************************************************************************************
    *@Description : method that checks if contract was updated to Activated          
    *@Params      : List<Contract> (trigger.new)                                                                     
    *@Return      : void                                                                              
    *************************************************************************************************/
    public void orderCreationBasedOnContract ( List<Contract> contractList ) {
        List<Contract> contractToOrderList = new List<Contract>();
        for ( Contract ctrc : contractList ) {
            if ( ctrc.Status == 'Activated' ) {
                contractToOrderList.add(ctrc);
            }
        }
        createorderBasedOnContract(contractToOrderList);
    }
    
    /*********************************************************************************************
    *@Description : Method that creates the order Based on Contract when contract passes to Activated Status          
    *@Params      : List<Contract> (trigger.new)                                                                     
    *@Return      : void                                                                              
    *************************************************************************************************/
    public void createorderBasedOnContract ( List<Contract> contractList ) {
        List<Order> orderToBeCreated = new List<Order>();
        for ( Contract ctrc : contractList ) {
                Order ord = new Order();
                ord.EffectiveDate = system.today();
                ord.Estimated_Delivery_Date__c = ctrc.Estimated_Delivery_Date__c;
                ord.AccountId = ctrc.AccountId;
                ord.Status = 'Draft';
                ord.Pricebook2Id = ctrc.Pricebook2Id;
           		 ord.ContractId = ctrc.id;
            	ord.OpportunityId = ctrc.opportunity__c;
                orderToBeCreated.add(ord);
        }
        
        try {
            Database.insert(orderToBeCreated);
        } catch ( Exception ex ){
            system.debug(ex.getMessage());
        }
    }
}