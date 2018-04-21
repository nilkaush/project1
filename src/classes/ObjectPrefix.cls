public class ObjectPrefix {
	Public static String GetObjPrefix(String s) {
		Map<String, Schema.SObjectType> schmap  = Schema.getGlobalDescribe() ;
		Schema.SObjectType sProduct = schmap.get(s) ;
		Schema.DescribeSObjectResult rProduct = sProduct.getDescribe() ;
		String ProductPrefix = rProduct.getKeyPrefix();
		return ProductPrefix;
	}
}