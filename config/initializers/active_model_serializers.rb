ActiveModelSerializers.config.tap do |config|
  # Sử dụng JSON API adapter để format response theo chuẩn
  config.adapter = :json_api
  
  # Key transform
  config.key_transform = :camel_lower
  
  # Include root in JSON
  config.include_root_in_json = true
  
  # JSON API Content Type
  config.jsonapi_content_type = 'application/vnd.api+json'
end
