global class SmartyStreets {

	public static final String API_PROTO = 'https';
  public static final String API_HOST = 'api.smartystreets.com';

	private String AUTH_ID;
	private String AUTH_TOKEN;
  private Boolean DEBUG;

  public SmartyStreets(String authId, String authToken, Boolean debug){
    this.AUTH_ID = authId;
	  this.AUTH_TOKEN = authToken;
    this.DEBUG = debug || false;
  }

  public SmartyStreets(String authId, String authToken){
    this(authId, authToken, false);
  }

	public String getURLEndpoint(String resourceName){
		return this.getURLEndpoint(resourceName, new URIQuery());
	}

	public String getURLEndpoint(String resourceName, URIQuery query){
		query
			.put('auth-id', this.AUTH_ID)
			.put('auth-token', this.AUTH_TOKEN);

    return '{!API_PROTO}://{!API_HOST}/{!resourceName}'
			.replace('{!API_PROTO}', SmartyStreets.API_PROTO)
			.replace('{!API_HOST}', SmartyStreets.API_HOST)
			.replace('{!resourceName}',resourceName) + query.build();
  }

  private HttpRequest createConnection(String url, String method, Object params){
    HttpRequest connection = new HttpRequest();
    connection.setEndpoint(url);
    connection.setTimeout(60000);

    Map<String, String> header = getHeaders();
    for(String headerKey :header.keySet()){
      connection.setHeader(headerKey, header.get(headerKey));
    }

    connection.setMethod(method);

    if('POST:PUT'.containsIgnoreCase(method)){
      debug(JSON.serialize(params));
      debug(JSON.serializePretty(params));
      connection.setBody(JSON.serialize(params));
    }

    return connection;
  }

	private Map<String, String> getHeaders(){
	  Map<String, String> headers = new Map<String, String>();
		headers.put('Content-Type', 'application/json;charset=UTF-8');
	  return headers;
  }

  public Object makeURLRequest(String url, String method, Object params){
    return makeURLRequest(url, method, params, null);
  }

  public Object makeURLRequest(String url, String method, Type responseType){
    return makeURLRequest(url, method, null, responseType);
  }

  public Object makeURLRequest(
    String url,
    String method,
    Object params,
    Type responseType
  ){
    // if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new SendWithUs_Mock());

    Http http = new Http();
    HttpRequest req = createConnection(url, method, params);
    debug(req);
    HttpResponse res = http.send(req);
    debug(res);

    Integer responseCode = res.getStatusCode();
    if(responseCode < 200 || responseCode >= 300){
      debug(res.getBody());
      throw new SmartyStreetsException(res.getBody());
    }

    String body = res.getBody();
    debug(body);

    Object resData;
    if(responseType == null){
      resData = JSON.deserializeUntyped(body);
    } else {
      resData = JSON.deserialize(body, responseType);
    }
    debug(JSON.serializePretty(resData));
    return resData;
  }

	public List<AddressResponse> street_address(List<AddressRequest> requests){
    String url = getURLEndpoint('street-address');
    List<AddressResponse> res = (List<AddressResponse>) makeURLRequest(url, 'POST', requests, List<AddressResponse>.class);
    return res;
  }

  public AddressResponse street_address(AddressRequest request){
    return this.street_address(new List<AddressRequest>{request})[0];
  }

  private void debug(Object obj){
    if(!this.DEBUG) return;
    System.debug('SMARTYSTREETS: ' + String.valueOf(obj));
  }

  ////////////////////
  // REQUEST MODELS //
  ////////////////////

	public class AddressRequest {
		public String input_id;
		public String street;
		public String street2;
		public String secondary;
		public String city;
		public String state;
		public String zipcode;
		public String lastline;
		public String addressee;
		public String urbanization;
		public Integer candidates;
	}

	public class AddressResponse {
		String input_id;
		Integer input_index;
		Integer candidate_index;
		String addressee;
		String delivery_line_1;
		String delivery_line_2;
		String last_line;
		String delivery_point_barcode;
		AddressComponent components;
		AddressMetadata metadata;
		AddressAnalysis analysis;
	}

	public class AddressComponent {
		String urbanization;
		String primary_number;
		String street_name;
		String street_predirection;
		String street_postdirection;
		String street_suffix;
		String secondary_number;
		String secondary_designator;
		String extra_secondary_number;
		String extra_secondary_designator;
		String pmb_designator;
		String pmb_number;
		String city_name;
		String default_city_name;
		String state_abbreviation;
		String zipccode;
		String delivery_point;
		String delivery_point_check_digit;
	}

	enum RecordType { F, G, H, P, R, S }
	enum ZipType { Unique, Military, POBox, Standard }
	enum RDI { residential, commercial, unknown }
	enum ElotSort { A, D }
	enum Precision { Unknown, None, State, SolutionArea, City, Zip5, Zip6, Zip8, Zip9, Structure }

	public class AddressMetadata {
		RecordType record_type;
		ZipType zip_type;
		String county_fips;
		String country_name;
		String currier_route;
		String congressional_district;
		String building_default_indicator;
		RDI rdi;
		String elot_sequence;
		ElotSort elot_sort;
		Decimal latitude;
		Decimal longitude;
		Precision precision;
		String time_zone;
		Decimal utc_offset;
		String dst;
	}

	enum DVPMatchCode { Y, N, S, D }

	public class AddressAnalysis {
		DVPMatchCode dvp_match_code;
		String dvp_footnotes;
	}


  public class URIQuery {
    Map<String, String> data;

    public URIQuery(){
      data = new Map<String, String>();
    }

    public URIQuery put(String key, String value){
      data.put(key, value);
      return this;
    }

    public String build(){
      String search = '?';
      List<String> pairs = new List<String>();
      for(String key :data.keySet()){
        String value = data.get(key);
        if(String.isEmpty(value)) continue;
        pairs.add(key + '=' + value);
      }
      search += String.join(pairs, '&');
      return search;
    }
  }

  public class SmartyStreetsException extends Exception {}
}