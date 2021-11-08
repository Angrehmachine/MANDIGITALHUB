public class orderTriggerHandler {
    
    /*********************************************************************************************
    *@Description : On order Creation picks contract id and order id to update existing Assets
    *@Params      : List<Order> (trigger.new)
    *@Return      : void
    *************************************************************************************************/
    public void orderAssetRelationUpdate ( List<Order> OrderList ) {
        Map<String,String> contractOrderIds = new Map<String,String>();
        Set<Id> contractIdSet = new Set<Id>();
        for ( Order ord : OrderList ) {
            contractIdSet.add(ord.contractId);
            contractOrderIds.put(ord.contractId,ord.Id);          
        }
        updateAssets( contractOrderIds, contractIdSet );
    }
    
    /*********************************************************************************************
    *@Description : Updates all assets that have the same contract has OrderList and updates it with the order Id
    *@Params      : Map<String,String> , Set<Id>
    *@Return      : void
    *************************************************************************************************/
    public void updateAssets ( Map<String,String> contractOrderIds, Set<Id> contractIdSet ) {
        try {
            List<Asset> assetToUpdate = [SELECT id, order__c, contract__c FROM Asset WHERE Contract__c IN :contractIdSet];
            for ( Asset assets : assetToUpdate ) {
                if ( contractOrderIds.containsKey(assets.Contract__c) ) {
                    assets.Order__c = contractOrderIds.get(assets.Contract__c);
                }  
            }
            Database.update(assetToUpdate);
        } catch ( Exception ex ) {
            system.debug(ex.getMessage());
        }
    } 
    
    /*********************************************************************************************
    *@Description : Creates orderItems based on opportunityLineItem of related opportunity
    *@Params      : List<Order> (Triger.new)
    *@Return      : void
    *************************************************************************************************/
    public void orderLineItemCreation ( List<Order> OrderList ) {
        // Retrieve all opportunityIds and orders with opportunity
        Set<Id> opportunityIds = new Set<Id>();
        List<Order> orderWithOppList = new List<Order>();
        Set<Id> orderToBeUpdated = new Set<Id>();
        
        for ( Order ord : OrderList ) {
            if ( ord.OpportunityId != null ) {
                opportunityIds.add(ord.OpportunityId);
                orderWithOppList.add(ord);
            }       
        }
        
        // Retrieve all opportunities and opportunityLineItems
        Map<Id, Opportunity> oppsWithLineItems = new Map<Id, Opportunity>([SELECT Id, (SELECT Id,UnitPrice,Quantity,Service__c,Product2Id,PricebookEntryId FROM OpportunityLineItems) FROM Opportunity WHERE id IN:opportunityIds]);
        
        if ( opportunityIds.size() > 0 ) {
            List<OrderItem> orderItemsToBeInserted = new List<OrderItem>();
            for ( Order ord : orderWithOppList ) {
                Opportunity oppWithLineItem = oppsWithLineItems.get(ord.OpportunityId);
                for(OpportunityLineItem oli : oppWithLineItem.OpportunityLineItems)
                {
                    system.debug(oli);
                    orderItemsToBeInserted.add(new OrderItem( Quantity = oli.Quantity, OrderId = ord.id,Service__c = oli.Service__c,UnitPrice = oli.UnitPrice,Product2Id = oli.Product2Id,PricebookEntryId=oli.PricebookEntryId));
                }
                orderToBeUpdated.add(ord.id);
            }
            if ( orderToBeUpdated.size() > 0 ) {
                Database.insert(orderItemsToBeInserted);
                activateOrders(orderToBeUpdated);
                
            }
        }
    }

    /*********************************************************************************************
    *@Description : When orders are created from activated contracts order should be activated as well
    *@Params      : Set<Id>
    *@Return      : void
    *************************************************************************************************/
	@future
    public static void activateOrders ( Set<Id> orderSetToUpdate ) {
		List<Order> orderToUpdate = new List<Order>();         
        try {
            
            for ( Id ordId : orderSetToUpdate ) {
                orderToUpdate.add(new Order (id = ordId, status = 'Activated'));
            }
            Database.update(orderToUpdate);
        } catch ( Exception ex ) {
            system.debug(ex.getMessage());
        }
    }
    
}