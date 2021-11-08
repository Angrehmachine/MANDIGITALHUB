public class retrieveAssetController {
    
    /*********************************************************************************************
    *@Description : AuraEnabled method that receiving asset to update , vin and Oem Vin retrieves from API and updates         
    *@Params      : String assetId, String vin, String oemVin                                                                   
    *@Return      : String response                                                                              
    *************************************************************************************************/
    @AuraEnabled
    public static String getAssetFromApi (String assetId, String vin, String oemVin ) {
        String sReturn;
        try {
            digitalHubGetData dhGetData = new digitalHubGetData();  
            String AssetJson = dhGetData.getData(vin,oemVin); 
            system.debug(AssetJson);
            if (AssetJson.contains('Error')) {
                sReturn = AssetJson;
            } else {
                sReturn = updateAsset(assetId,AssetJson);
                system.debug(sReturn);
            }
        } catch (Exception ex) {
            sReturn = ex.getMessage();
            system.debug(ex.getMessage());
        }
        return sReturn;
    }
    
    /*********************************************************************************************
    *@Description : Method that updates the Asset given the response from API         
    *@Params      : String assetId, String jsonStrn                                                                   
    *@Return      : String response                                                                              
    *************************************************************************************************/
    public static String updateAsset (String assetId, String jsonStr) {
        String sReturn = 'success';
        APIDigitalHubWrapper.AssetTruckWrapper resp = ( APIDigitalHubWrapper.AssetTruckWrapper ) JSON.deserialize(jsonStr, APIDigitalHubWrapper.AssetTruckWrapper.class);
        Asset assetToUpdate = new Asset(
            id = assetId,
            vehicleNum__c = resp.vehicleNum,
            vehicleRegNum__c = resp.vehicleRegNum,
            regNumCountryKey__c = resp.regNumCountryKey,
            manufacturer__c = resp.manufacturer,
            prodCode__c = resp.prodCode,
            modelRange__c = resp.modelRange,
            vehicleType__c = resp.vehicleType,
            typeVariant__c = resp.typeVariant,
            deliveryExWorkDate__c = resp.deliveryExWorkDate,
            firstRegDate__c = resp.firstRegDate,
            wheelBase__c = resp.wheelBase,
            overhang__c = resp.overhang,
            suspension__c = resp.suspension,
            truckAxle__c = resp.truckAxle,
            customerRegDate__c = resp.customerRegDate,
            customerNo__c = resp.customerNo,
            customerName__c = resp.customerName,
            measuringPoint__c = JSON.serialize(resp.measuringPoint),
            vehicleTextData__c = JSON.serialize(resp.vehicleTextData)
        );
        try {
            Database.update(assetToUpdate);
        } catch (Exception ex) {
            sReturn = ex.getMessage();
        }
        return sReturn;
    }
    
}