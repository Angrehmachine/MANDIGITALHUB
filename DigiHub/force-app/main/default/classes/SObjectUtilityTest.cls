@IsTest
public class SObjectUtilityTest {
    
    @IsTest
    private static void shouldfilterChangedRecordsByField() {
        String keyPrefix = Contact.SObjectType.getDescribe().getKeyPrefix();
        Id bogusId1 = keyPrefix + '00ZZZZZZZZZZ';
        Id bogusId2 = keyPrefix + '00ZZZZZZZZZY';
        
        Contact originalContact1 = getContact();
        originalContact1.Id = bogusId1;
        
        Contact originalContact2 = getContact();
        originalContact2.Id = bogusId2;
        
        Map<Id, Contact> originalContacts = new Map<Id, Contact> {
            originalContact1.Id => originalContact1,
            originalContact2.Id => originalContact2
         };
                    
                    
        Contact updatedContact1 = originalContact1.clone(true);
        updatedContact1.LastName = 'Smith';
        
        Contact updatedContact2 = originalContact2.clone(true);
        updatedContact2.FirstName = 'Jim';
        
        Map<Id, Contact> updatedContacts = new Map<Id, Contact> {
            updatedContact1.Id => updatedContact1,
        	updatedContact2.Id => updatedContact2
        };
                    
        Test.startTest();
            Map<Id, SObject> filteredByLastName = SObjectUtility.filterByChangedFields(updatedContacts, originalContacts, new Set<SObjectField> { Contact.LastName });
            Map<Id, SObject> filteredByFirstName = SObjectUtility.filterByChangedFields(updatedContacts, originalContacts, new Set<SObjectField> { Contact.FirstName });
            Map<Id, SObject> filteredByFirstAndLastName = SObjectUtility.filterByChangedFields(updatedContacts, originalContacts, new Set<SObjectField> { Contact.FirstName, Contact.LastName });
            Map<Id, SObject> filteredByDescription = SObjectUtility.filterByChangedFields(updatedContacts, originalContacts, new Set<SObjectField> { Contact.Description });
        Test.stopTest();
        
        // Verify records filtered by last name
        System.assertEquals(1, filteredByLastName.size());
        
    }
    
    private static Contact getContact() {
        return new Contact(
            FirstName = 'Bob',
            LastName = 'Barker',
            Description = 'Host of The Price is Right'
        );
    }
}