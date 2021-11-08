public class OppLineItemTriggerHandler {
    
    /*********************************************************************************************
    *@Description : Controls Field SalesPrice based on product and service selections             
    *@Params      : List (trigger.new)                                                                      
    *@Return      : void                                                                                 
    *************************************************************************************************/
    public void updateSalesPriceBasedOnService (List<OpportunityLineItem> newOppLineItemList) {
        Set<Id> productServiceToretrieve = new Set<Id>();
        Set<Id> pricebookToretrieve = new Set<Id>();
        //Add Product2 or PricebookEntry in order to use them to retrieve the unitPrice
        for ( OpportunityLineItem opplineItem : newOppLineItemList ) {
            if ( opplineItem.service__c != null ) {
                productServiceToretrieve.add(opplineItem.service__c);
            }else {
                pricebookToretrieve.add(opplineItem.PricebookEntryId);
            }
        }
        
        Map<id, Product2> productServiceMap = new Map<id, Product2>([SELECT id, Service_Anual_Percentage__c FROM Product2 WHERE id IN :productServiceToretrieve]);
        Map<id, PricebookEntry> pricebookMap = new Map<id, PricebookEntry>([SELECT id, UnitPrice FROM PricebookEntry WHERE id IN :pricebookToretrieve]);
        
        for ( OpportunityLineItem opplineItem : newOppLineItemList ) {
            //If the OpportunityLineItem has a Service associated we should retrive the percentage to calculate the unitary price by unit
            if ( opplineItem.service__c != null ) {
                //This only happens in any update to Service__c or SalesPrice
                if ( productServiceMap.containsKey(opplineItem.service__c) ) {
                    //Price is calculated using Service_Anual_Percentage__c this way we calculate de decimal value to multiply the listprice by it
                    Decimal percentage = ( productServiceMap.get(opplineItem.service__c).Service_Anual_Percentage__c / 100);
                    oppLineItem.UnitPrice =  opplineItem.ListPrice + (opplineItem.ListPrice * percentage);		
                }
                //This happens when we have an update and the opportunityLineItem doesn't have a Service
            }else if ( oppLineItem.ListPrice != null ) {
                oppLineItem.UnitPrice =  opplineItem.ListPrice;
                //When we Insert ListPrice is not yet fullfilled so in order to retrieve it i need to retrieve it from the PricebookEntry related to this OpportunityLineItem
            }else if ( oppLineItem.PricebookEntryId != null && pricebookMap.containsKey(oppLineItem.PricebookEntryId) ){
                oppLineItem.UnitPrice = pricebookMap.get(oppLineItem.PricebookEntryId).UnitPrice;
            }             
        }
    }     
}