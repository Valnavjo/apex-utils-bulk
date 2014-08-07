/**
 * @author      Josep Vall-llobera <valnavjo_at_gmail.com>
 * @version     1.0.0
 * @since       26/06/2012
 */
public class UtilsBulk {

	/**ATTRIBUTES*/
	private final Map<String, MapBulkGrouper> mapBulkGrouperMap;
	private final Map<String, ListBulkGrouper> listBulkGrouperMap;
	private final Map<String, OldNewPair> oldNewPairMap;
	
	/**SINGLETON PATTERN*/
	private static UtilsBulk instance;
	private static UtilsBulk getInstance() {
		if (instance == null) instance = new UtilsBulk();
		return instance;
	}
	
	/**CONSTRUCTOR*/
	private UtilsBulk() {
		this.mapBulkGrouperMap = new Map<String, MapBulkGrouper>();
		this.listBulkGrouperMap = new Map<String, ListBulkGrouper>();
		this.oldNewPairMap = new Map<String, OldNewPair>();
	}
	
	/**INSTANCE STATIC METHODS*/
	public static MapBulkGrouper getMapBulkGrouper(final String mapBulkGrouperName) {
		if (mapBulkGrouperName == null) throw new BulkGrouperException('"mapBulkGrouperName" is null.');
		
		if (!getInstance().mapBulkGrouperMap.containsKey(mapBulkGrouperName)) {
			getInstance().mapBulkGrouperMap.put(mapBulkGrouperName, new MapBulkGrouper());
		}

		return getInstance().mapBulkGrouperMap.get(mapBulkGrouperName);
	}

	public static ListBulkGrouper getListBulkGrouper(final String listBulkGrouperName) {
		if (listBulkGrouperName == null) throw new BulkGrouperException('"listBulkGrouperName" is null.');
		
		if (!getInstance().listBulkGrouperMap.containsKey(listBulkGrouperName)) {
			getInstance().listBulkGrouperMap.put(listBulkGrouperName, new ListBulkGrouper());
		}

		return getInstance().listBulkGrouperMap.get(listBulkGrouperName);
	}

	public static OldNewPair getOldNewPair(final String oldNewPairName) {
		if (oldNewPairName == null) throw new BulkGrouperException('"oldNewPairName" is null.');
		
		if (!getInstance().oldNewPairMap.containsKey(oldNewPairName)) {
			System.debug(LoggingLevel.WARN, 'The OldNewPair "' + oldNewPairName + '" is not in the Map.');
			return null;
		}

		return getInstance().oldNewPairMap.get(oldNewPairName);
	}

	public static OldNewPair getOldNewPair(final String oldNewPairName,
										   final Map<Id, SObject> oldMap, final Map<Id, SObject> newMap) {
		if (oldNewPairName == null) throw new BulkGrouperException('"oldNewPairName" is null.');
										   	
		if (!getInstance().oldNewPairMap.containsKey(oldNewPairName)) {
			getInstance().oldNewPairMap.put(oldNewPairName, new OldNewPair(oldMap, newMap));
		}

		return getInstance().oldNewPairMap.get(oldNewPairName);
	}
	
	/**PUBLIC STATIC METHODS*/
	public static Map<String, SObject> listToMap(final String keyFieldName,
												 final List<SObject> sObjectList) {
		final Map<String, SObject> mapAux = new Map<String, SObject>();
		
		//-- Prevalidations
		if (keyFieldName == null) throw new BulkGrouperException('"keyFieldName" is null.');
		if (sObjectList == null) throw new BulkGrouperException('"sObjectList" is null.');
		
		//-- 
		for (SObject sObjectAux : sObjectList) {
			if (sObjectAux == null) continue;
			
			String mainMapKey = getSObjectFieldValue(keyFieldName, sObjectAux);
			
			mapAux.put(mainMapKey, sObjectAux);
		}
		
		return mapAux;
	}

	public static Map<String, List<SObject>> listToGroupedMap(final String keyFieldName,
															  final List<SObject> sObjectList) {
		final Map<String, List<SObject>> mapAux = new Map<String, List<SObject>>();
		
		//-- Prevalidations
		if (keyFieldName == null) throw new BulkGrouperException('"keyFieldName" is null.');
		if (sObjectList == null) throw new BulkGrouperException('"sObjectList" is null.');
		
		//-- 
		for (SObject sObjectAux : sObjectList) {
			if (sObjectAux == null) continue;
			
			String mainMapKey = getSObjectFieldValue(keyFieldName, sObjectAux);
			
			groupByList(mainMapKey, sObjectAux, mapAux);
		}
		
		return mapAux;
	}

	public static Map<String, Map<String, SObject>> listToGroupedMap(final String mainKeyFieldName,
																	 final String innerKeyFieldName,
																	 final List<SObject> sObjectList) {
		final Map<String, Map<String, SObject>> mapAux = new Map<String, Map<String, SObject>>();
		
		//-- Prevalidations
		if (mainKeyFieldName == null) throw new BulkGrouperException('"mainKeyFieldName" is null.');
		if (innerKeyFieldName == null) throw new BulkGrouperException('"innerKeyFieldName" is null.');
		if (sObjectList == null) throw new BulkGrouperException('"sObjectList" is null.');
		
		//-- 
		for (SObject sObjectAux : sObjectList) {
			if (sObjectAux == null) continue;
			
			String mainMapKey = getSObjectFieldValue(mainKeyFieldName, sObjectAux);
			String innerMapKey = getSObjectFieldValue(innerKeyFieldName, sObjectAux);
			
			groupByMap(mainMapKey, innerMapKey, sObjectAux, mapAux);
		}
		
		return mapAux;
	}
	
	/**PRIVATE STATIC METHODS*/
	private static String getSObjectFieldValue(final String keyFieldName, final SObject sObjectx) {
		String mainMapKey;
		try {
			Object value = sObjectx.get(keyFieldName);
			return String.valueOf(value);
		} catch (System.SObjectException soe) {
			throw new BulkGrouperException('Field "' + keyFieldName + '" not found in SObject "' +
										   sObjectx.getSObjectType().getDescribe().getName() + '".');
		}
	}
	
	/**
	 * Core method.
	 */
	private static void groupByList(final String mainMapKey,
									final Object objectx,
									final Map<String, List<Object>> mainMap) {
		//-- Prevalidations
		if (mainMap == null) throw new BulkGrouperException('"mainMap" is null.');
		
		//-- 
		List<Object> innerList;
		if (mainMap.containsKey(mainMapKey)) {
			innerList = mainMap.get(mainMapKey);
		} else {
			innerList = (objectx instanceof SObject) ? new List<SObject>() : new List<Object>();
			mainMap.put(mainMapKey, innerList);
		}
		innerList.add(objectx);
	}
	
	/**
	 * Core method.
	 */
	private static void groupByMap(final String mainMapKey, final String innerMapKey,
								   final Object objectx,
								   final Map<String, Map<String, Object>> mainMap) {
		//-- Prevalidations
		if (mainMap == null) throw new BulkGrouperException('"mainMap" is null.');
		
		//-- 
		Map<String, Object> innerMap;
		if (mainMap.containsKey(mainMapKey)) {
			innerMap = mainMap.get(mainMapKey);
		} else {
			innerMap = (objectx instanceof SObject) ? new Map<String, SObject>() : new Map<String, Object>();
			mainMap.put(mainMapKey, innerMap);
		}
		innerMap.put(innerMapKey, objectx);
	}

	/**NESTED CLASSES*/
	public class MapBulkGrouper {

		/**ATTRIBUTES*/
		private final Map<String, Map<String, Object>> mapGroup;
		private final Map<String, Map<String, SObject>> mapGroupSObject;
		
		/**CONSTRUCTOR*/
		private MapBulkGrouper() {
			this.mapGroup = new Map<String, Map<String, Object>>();
			this.mapGroupSObject = new Map<String, Map<String, SObject>>();
		}
		
		/**GETTERS*/
		public Map<String, Map<String, Object>> getMap() {
			return this.mapGroup;
		}
		
		public Map<String, Map<String, SObject>> getSObjectMap() {
			return this.mapGroupSObject;
		}
		
		/**PUBLIC METHODS*/
		public void groupById(final String mainMapKey, final SObject sObjectx) {
			this.groupByField(mainMapKey, sObjectx.Id, sObjectx);
		}

		public void groupByField(final String mainMapKey, final String innerMapKey,
								 final Object objectx) {
			//-- Prevalidations
			if (mainMapKey == null) throw new BulkGrouperException('"mainMapKey" is null.');
			if (innerMapKey == null) throw new BulkGrouperException('"innerMapKey" is null.');
			if (objectx == null) throw new BulkGrouperException('"objectx" is null.');
			
			//-- 
			groupByMap(mainMapKey, innerMapKey, objectx, (objectx instanceof SObject) ? this.mapGroupSObject :
																						this.mapGroup);
		}
	}
	
	public class ListBulkGrouper {

		/**ATTRIBUTES*/
		private final Map<String, List<Object>> listGroup;
		private final Map<String, List<SObject>> listGroupSObject;
		
		/**CONSTRUCTOR*/
		private ListBulkGrouper() {
			this.listGroup = new Map<String, List<Object>>();
			this.listGroupSObject = new Map<String, List<SObject>>();
		}
		
		/**GETTERS*/
		public Map<String, List<Object>> getList() {
			return this.listGroup;
		}
		
		public Map<String, List<SObject>> getSObjectList() {
			return this.listGroupSObject;
		}
		
		/**PUBLIC METHODS*/
		public void groupByField(final String mainMapKey, final Object objectx) {
			//-- Prevalidations
			if (mainMapKey == null) throw new BulkGrouperException('"mainMapKey" is null.');
			if (objectx == null) throw new BulkGrouperException('"objectx" is null.');
			
			groupByList(mainMapKey, objectx, (objectx instanceof SObject) ? this.listGroupSObject :
																			this.listGroup);
		}
	}
	
	public class OldNewPair {
		/**ATTRIBUTES*/
		private final Map<Id, SObject> oldMap;
		private final Map<Id, SObject> newMap;
		
		/**CONSTRUCTOR*/
		private OldNewPair() { }
		
		public OldNewPair(final Map<Id, SObject> oldMap, final Map<Id, SObject> newMap) {
			//-- Prevalidations
			if (oldMap == null) throw new BulkGrouperException('"oldMap" is null.');
			if (newMap == null) throw new BulkGrouperException('"newMap" is null.');
			
			//-- 
			this.oldMap = oldMap;
			this.newMap = newMap;
		}
		
		/**PUBLIC METHODS*/
		public Boolean isChanged(final String fieldName, final Id sObjectId) {
			//-- Prevalidations
			if (fieldName == null) throw new BulkGrouperException('"fieldName" is null.');
			if (sObjectId == null) throw new BulkGrouperException('"sObjectId" is null.');
			
			//-- 
			final SObject oldSObject = this.oldMap.get(sObjectId);
			final SObject newSObject = this.newMap.get(sObjectId);
			
			//-- Validations
			if (oldSObject == null) throw new BulkGrouperException('"oldSObject" is null.');
			if (newSObject == null) throw new BulkGrouperException('"newSObject" is null.');
			
			//-- 
			final String oldValue = UtilsBulk.getSObjectFieldValue(fieldName, oldSObject);
			final String newValue = UtilsBulk.getSObjectFieldValue(fieldName, newSObject);
			
			//-- 
			return oldValue != newValue;
		}
		
		public List<SObject> areChanged(final String fieldName) {
			//-- Prevalidations
			if (fieldName == null) throw new BulkGrouperException('"fieldName" is null.');
			
			//-- List to return
			final List<SObject> sObjects = new List<SObject>();
			
			for (Id sObjectId : newMap.keySet()) {
				if (this.oldMap.get(sObjectId) != null && this.newMap.get(sObjectId) != null) {
					if (UtilsBulk.getSObjectFieldValue(fieldName, this.oldMap.get(sObjectId)) !=
						UtilsBulk.getSObjectFieldValue(fieldName, this.newMap.get(sObjectId))) {
							sObjects.add(this.newMap.get(sObjectId));
						}
				}
			}
			
			//-- Return list
			return sObjects;
		}
		
		public Map<String, SObject> areChanged(final String fieldName, final String mainMapKey) {
			//-- Prevalidations
			if (fieldName == null) throw new BulkGrouperException('"fieldName" is null.');
			if (mainMapKey == null) throw new BulkGrouperException('"mainMapKey" is null.');
			
			//-- List to return
			final Map<String, SObject> sObjectsMap = new Map<String, SObject>();
			
			for (Id sObjectId : newMap.keySet()) {
				if (this.oldMap.get(sObjectId) != null && this.newMap.get(sObjectId) != null) {
					if (UtilsBulk.getSObjectFieldValue(fieldName, this.oldMap.get(sObjectId)) !=
						UtilsBulk.getSObjectFieldValue(fieldName, this.newMap.get(sObjectId))) {
							sObjectsMap.put(UtilsBulk.getSObjectFieldValue(mainMapKey, this.newMap.get(sObjectId)),
											this.newMap.get(sObjectId));
						}
				}
			}
			
			//-- Return list
			return sObjectsMap;
		}
	}
	
	public class BulkGrouperException extends Exception { }
}