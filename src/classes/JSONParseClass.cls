// Generated by JSON2Apex http://json2apex.herokuapp.com/
//
public class JSONParseClass {
	public Boolean success;
	public Value value;

	public class Value {
		public String product_app_id;
		public Integer applicant_index;
		public String question_list_id;
		public List<Questions> questions;
	}

	public class Questions {
		public String question;
		public List<String> answers;
	}

	public static List<JSONParseClass> parse(String json) {
		System.debug('json==>' + json);
		return (List<JSONParseClass>) System.JSON.deserialize(json, List<JSONParseClass>.class);
	}
}