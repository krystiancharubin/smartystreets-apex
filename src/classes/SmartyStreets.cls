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
    if(Test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new SmartyStreetsMock());

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
		List<AddressResponse> addrRess = this.street_address(new List<AddressRequest>{request});
    return addrRess.isEmpty() ? null : addrRess[0];
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
		public String input_id;
		public Integer input_index;
		public Integer candidate_index;
		public String addressee;
		public String delivery_line_1;
		public String delivery_line_2;
		public String last_line;
		public String delivery_point_barcode;
		public AddressComponent components;
		public AddressMetadata metadata;
		public AddressAnalysis analysis;

		public AddressResponse(){
			this.components = new AddressComponent();
			this.metadata = new AddressMetadata();
			this.analysis = new AddressAnalysis();
		}
	}

	public class AddressComponent {
		public String urbanization;
		public String primary_number;
		public String street_name;
		public String street_predirection;
		public String street_postdirection;
		public String street_suffix;
		public String secondary_number;
		public String secondary_designator;
		public String extra_secondary_number;
		public String extra_secondary_designator;
		public String pmb_designator;
		public String pmb_number;
		public String city_name;
		public String default_city_name;
		public String state_abbreviation;
		public String zipcode;
		public String delivery_point;
		public String delivery_point_check_digit;
	}

	enum RecordType { F, G, H, P, R, S }
	enum ZipType { Unique, Military, POBox, Standard }
	enum RDI { residential, commercial, unknown }
	enum ElotSort { A, D }
	enum Precision { Unknown, None, State, SolutionArea, City, Zip5, Zip6, Zip8, Zip9, Structure }

	public class AddressMetadata {
		public RecordType record_type;
		public ZipType zip_type;
		public String county_fips;
		public String country_name;
		public String currier_route;
		public String congressional_district;
		public String building_default_indicator;
		public RDI rdi;
		public String elot_sequence;
		public ElotSort elot_sort;
		public Decimal latitude;
		public Decimal longitude;
		public Precision precision;
		public String time_zone;
		public Decimal utc_offset;
		public String dst;
	}

	public class AddressAnalysis {
		public String dvp_match_code;
		public String dvp_footnotes;
		public String dvp_cmra;
		public String active;
		public String es_match;
		public String footnotes;
		public String lacslink_code;
		public String lacslink_indicator;
		public String suitelink_match;
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
