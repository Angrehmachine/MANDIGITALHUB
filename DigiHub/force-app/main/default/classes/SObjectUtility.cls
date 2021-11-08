public class SObjectUtility {
    
    /**
    * Compares two sets of records, and returns the subset of records in which one of a specified set of fields has
    * changed.
    * @param updatedRecords A map of sObject records, keyed by ID
    * @param oldRecords A map of the same sObject records, in a potentially different state, keyed by ID
    * @param fieldSet A set of sObject fields, applicable to the given records, that should be filtered on
    * @return A set records, keyed by ID, found in both 'updatedRecords' and 'oldRecords' with at least one of the
    * specified fields differing between the two.
    */
    public static Map<Id, SObject> filterByChangedFields(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords, Set<SObjectField> fieldSet) {
        Map<Id, SObject> recordsWithChangedField = new Map<Id, SObject>();
        for (Id recordId : updatedRecords.keySet()) {
            SObject updatedRecord = updatedRecords.get(recordId);
            SObject oldRecord = oldRecords.get(recordId);
            for (SObjectField field : fieldSet) {
                if (updatedRecord.get(field) != oldRecord.get(field)) {
                    recordsWithChangedField.put(recordId, updatedRecord);
                    break;
                }
            }
        }
        return recordsWithChangedField;
    }
}