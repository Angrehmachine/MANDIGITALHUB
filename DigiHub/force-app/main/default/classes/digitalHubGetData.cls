public class digitalHubGetData {
    
    public string getData( String vin, String oemVin ){
        
        String sReturn;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http= new Http();
        String sEndPoint;
        MANDigiHubCredentials__c manDig = MANDigiHubCredentials__c.getOrgDefaults();
        sEndPoint =  manDig.API_res__c + oemVin + '/' + vin;          
        req.setHeader('Client-id', manDig.client_id__c);
        req.setHeader('Client-secret', manDig.client_secret__c);
        req.setHeader('correlation-id', manDig.correlation_id__c);
        req.setEndpoint(sEndPoint);
        req.setMethod('GET');
        req.setCompressed(true);
        req.setTimeout(1200);        
        
        try {
            res = http.send(req);
            
            if(res.getBody() != null )
            {
                sReturn = res.getBody();  
            }
            else{
                sReturn = '{"errorDescription":"Error in service response"}';  
            }
        } catch(System.CalloutException e) {
            sReturn = e.getMessage();
        }
        return sReturn;        
    }  
}