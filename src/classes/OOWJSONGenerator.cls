//JSON GENERATOR for OOW response 
public class OOWJSONGenerator {
	public static String jsonMethod(String jsonTemp) {
		List<JSONParseClass> objClass = new List<JSONParseClass>();
		objClass = JSONParseClass.parse(jsonTemp);
		System.debug('objClass==>' + objClass);

		try {
			JSONGenerator gen = JSON.createGenerator(true);
			gen.writeStartObject(); //It is used for making starting object(‘{‘)
			gen.writeStringField('evaluation_token','S-NLa3D9r5cFWfmzOjLHb5');
			gen.writeStringField('question_list_id', objClass[0].Value.question_list_id);
			System.debug('objClass[0].Value.question_list_id==>' + objClass[0].Value.question_list_id);
			//  gen.writeStringField('error',null);
			gen.writeNumberField('timestamp', 1504854);
			gen.writeStringField('entity_token', 'P-ckoFPa7guqYEYBJFDNQ8');
			gen.writeStringField('application_token', 'IyKhARmSB6Uys9fhnBDAmNHI1iTWH6tc');
			gen.writeNumberField('application_version_id', 32);
			gen.writeFieldName('required');
			gen.writeStartArray();
			gen.writeStartObject();
			gen.writeStringField('Key', 'answers');
			gen.writeStringField('type', 'object');
			gen.writeStringField('description', 'Object containing answers to out of wallet question prompts.');
			gen.writeFieldName('template');
			gen.writeStartObject();
			gen.writeFieldName('answers');
			gen.writeStartArray();
			System.debug('objClass.questions.size()==>' + objClass[0].value);
			System.debug('objClass.questions.size()==>' + objClass[0].value.questions.size());

			for (Integer i = 0; i < objClass[0].value.questions.size(); i++) {
				gen.writeStartObject(); 
				gen.writeNumberField('question_id', i + 1);
				gen.writeNumberField('answer_id', 0);
				gen.writeEndObject();
			}

			gen.writeEndArray();
			gen.writeEndObject();
			gen.writeEndObject();
			gen.writeEndArray();
			gen.writeFieldName('optional');
			gen.writeStartArray();
			gen.writeEndArray();
			gen.writeFieldName('prompts');
			gen.writeStartObject();
			gen.writeFieldName('answers');
			gen.writeStartObject();
			gen.writeFieldName('questions');
			gen.writeStartArray();
			Integer i = 1;

			for (JSONParseClass.Questions item : objClass[0].value.questions) {
				gen.writeStartObject();
				gen.writeNumberField('id', i);
				Integer j = 1;
				System.debug('-->' + item);
				gen.writeStringField('question', item.question);
				gen.writeFieldName('answers');
				gen.writeStartArray();

				for (String ans : item.answers) { 
					gen.writeStartObject();
					gen.writeNumberField('id', j);
					gen.writeStringField('answer', ans);
					gen.writeEndObject();
					j++;
				}

				gen.writeEndArray();
				i++;
				gen.writeEndObject();
			}

			gen.writeEndArray();
			gen.writeEndObject();
			gen.writeEndObject();
			gen.writeEndObject();
			System.debug('getAsString:' + gen.getAsString());

			return gen.getAsString();
		} catch (Exception ex) {
			System.debug('Line No==>' + ex.getLineNumber());
			return null;
		}
	}
}