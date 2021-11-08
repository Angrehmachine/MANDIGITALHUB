@isTest
public class OppLineItemTriggerHandlerTest {
	 
    /***************************************************************************
    *@Description : This is a method initialises test data                     *
    *@Params      : void                                                       *
    *@Return      : void                                                       *    
    ****************************************************************************/
    @testSetup
    public static void init () {
		System.runAs(new User(Id = UserInfo.getUserId())) {
            Account acc = new Account(name='Bart Simpson');
            Database.insert(acc);
            Contact ctc = new Contact(firstName='Bart', Lastname='Simpson', accountid= acc.id);
            Database.insert(ctc);
            Pricebook2 prBook = new Pricebook2(Name='Truck',isActive=true);
            Database.insert(prBook);
            Id truckRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Truck').getRecordTypeId();
            Id serviceRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
            Product2[] prods = new Product2[] {
                new Product2 (Name='TGX',recordtypeId=truckRecType,productCode = 'TGX', isActive = true),
                    new Product2 (Name='Service',recordtypeId=serviceRecType,productCode = 'SER', isActive = true,Service_Anual_Percentage__c=10)
                    };
                        Database.insert(prods);
            PricebookEntry[] pbe1 = new PricebookEntry[] {
                new PricebookEntry (Product2ID=prods[0].id,Pricebook2ID=Test.getStandardPricebookId(),UnitPrice=50, isActive=true),
                    new PricebookEntry (Product2ID=prods[0].id,Pricebook2ID=prBook.id,UnitPrice=500, isActive=true) 
                    };
                        Database.insert(pbe1);
            Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'Bart Simpson Test', CloseDate = Date.today(), StageName='Prospecting');
            Database.insert(opp);
    	}
    }
    @isTest
    public static void testOppLineCreation () {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            Id truckRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Truck').getRecordTypeId();
            //Id serviceRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
            Product2 truckProd = [SELECT id FROM Product2 where recordtypeid =: truckRecType  LIMIT 1];  
            PricebookEntry pbe = [SELECT id FROM PricebookEntry WHERE Product2Id =: truckProd.id AND UnitPrice = 500 LIMIT 1];
            Test.startTest();        
            OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2=truckProd,OpportunityId=opp.id,Quantity=2, PricebookEntryId=pbe.id );
            Database.insert(oppLineItem);
            Test.stopTest();
            OpportunityLineItem oppCreated = [SELECT id, unitPrice, totalPrice FROM OpportunityLineItem];
            system.assertEquals(500, oppCreated.UnitPrice);
            system.assertEquals(1000, oppCreated.TotalPrice);
        }
    }
    
    @isTest
    public static void testOppLineCreationAndUpdate () {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            Id truckRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Truck').getRecordTypeId();
            Id serviceRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
            Product2 truckProd = [SELECT id FROM Product2 where recordtypeid =: truckRecType  LIMIT 1];  
            Product2 serviceProd = [SELECT id FROM Product2 where recordtypeid =: serviceRecType  LIMIT 1];  
            PricebookEntry pbe = [SELECT id FROM PricebookEntry WHERE Product2Id =: truckProd.id AND UnitPrice = 500 LIMIT 1];
            Test.startTest();        
            OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2=truckProd,OpportunityId=opp.id,Quantity=2, PricebookEntryId=pbe.id );
            Database.insert(oppLineItem);
            Test.stopTest();
            OpportunityLineItem oppCreated = [SELECT id, unitPrice, totalPrice FROM OpportunityLineItem];
            oppCreated.Service__c = serviceProd.id;
            Database.update(oppCreated);
            oppCreated = [SELECT id, unitPrice, totalPrice FROM OpportunityLineItem];
            system.assertEquals(550, oppCreated.UnitPrice);
            system.assertEquals(1100, oppCreated.TotalPrice);
        }
    }
    
    @isTest
    public static void testOppLineCreationAndUpdate2 () {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
            Id truckRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Truck').getRecordTypeId();
            Id serviceRecType = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
            Product2 truckProd = [SELECT id FROM Product2 where recordtypeid =: truckRecType  LIMIT 1];  
            Product2 serviceProd = [SELECT id FROM Product2 where recordtypeid =: serviceRecType  LIMIT 1];  
            PricebookEntry pbe = [SELECT id FROM PricebookEntry WHERE Product2Id =: truckProd.id AND UnitPrice = 500 LIMIT 1];
            Test.startTest();        
            OpportunityLineItem oppLineItem = new OpportunityLineItem(Product2=truckProd,OpportunityId=opp.id,Quantity=2, PricebookEntryId=pbe.id );
            Database.insert(oppLineItem);
            Test.stopTest();
            OpportunityLineItem oppCreated = [SELECT id, unitPrice, totalPrice, listPrice FROM OpportunityLineItem];
            oppCreated.unitPrice = 750;
            Database.update(oppCreated);
            oppCreated = [SELECT id, unitPrice, totalPrice FROM OpportunityLineItem];
            system.assertEquals(500, oppCreated.UnitPrice);
            system.assertEquals(1000, oppCreated.TotalPrice);
        }
    }
}