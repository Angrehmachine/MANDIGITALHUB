public class assetTriggerHandler {
    public Id serviceRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Service').getRecordTypeId();
    public Id truckRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Truck').getRecordTypeId();
    
    /*********************************************************************************************
    *@Description : Method that based on Trucks created creates associated Services            
    *@Params      : List<Asset> (trigger.new)                                                                     
    *@Return      : void                                                                              
    *************************************************************************************************/
    public void createServices ( List<Asset> assetsCreated ) {
        List<Asset> serviceTobeCreated = new List<Asset>();
        Set<Id> serviceIds = new Set<Id>();
        for (Asset truck : assetsCreated) {
            if ( truck.Service_tecnical__c != null ) {
                serviceIds.add(truck.Service_tecnical__c);
            }
        }
        
        if ( serviceIds.size() != 0 ) {
            Map<Id,Product2> serviceProdMap = new Map<Id,Product2>([SELECT id, Name FROM Product2 WHERE id IN:serviceIds]);
            
            for (Asset truck : assetsCreated) {
                if ( truck.Service_tecnical__c != null && serviceProdMap.containsKey(truck.Service_tecnical__c)) {
                    serviceTobeCreated.add(new Asset(Product2Id=truck.Service_tecnical__c,Contract__c = truck.Contract__c, accountid = truck.accountid,name = serviceProdMap.get(truck.Service_tecnical__c).Name, recordtypeid = serviceRecordTypeId ,Truck__c=truck.Id));
                }
            }
            Database.insert(serviceTobeCreated);
        } 
    }
    
    /*********************************************************************************************
    *@Description : Method to block trying to relate asset of type Truck with a Asset of type Service that already has a Service ( Maintain 1 to 1 logic )          
    *@Params      : List<Asset> (trigger.new)                                                                     
    *@Return      : void                                                                              
    *************************************************************************************************/
    public void checkExisting ( List<Asset> assetsCreated ) {
        
        Set<Id> truckids = new Set<Id>();
        for (Asset service : assetsCreated) {
            if ( service.recordtypeid == serviceRecordTypeId ) {
                truckids.add(service.Truck__c);
            }
        }
        
        List<Asset> truckList = [Select id, (select id from Service__r ) from Asset where id IN : truckids];
        if ( !truckList.isEmpty() ) {
            Map<Id,List<Asset>> truckServiceListMap = new Map<Id,List<Asset>>();
            for ( Asset serv : truckList ) {
                truckServiceListMap.put(serv.Id,serv.Service__r); 
            }
            for (Asset service : assetsCreated) {
                if ( service.recordtypeid == serviceRecordTypeId && truckServiceListMap.containsKey(service.Truck__c) ) {
                    if ( !truckServiceListMap.get(service.Truck__c).isEmpty() ) {
                        service.addError('This Truck already has a Service');
                    }
                }
            }
        }
    }
    
}