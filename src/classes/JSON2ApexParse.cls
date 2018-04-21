public class JSON2ApexParse {

	public class JSON2Apex {
		public Boolean success;
		public Value value;
		public Object error_type;
		public Object error_message;
	}

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

	
	public static List<JSON2Apex> parse(String json) {
		return (List<JSON2Apex>) System.JSON.deserialize(json, List<JSON2Apex>.class);
	}
}