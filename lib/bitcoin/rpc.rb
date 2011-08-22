require 'rest_client'

class Bitcoin::RPC
  def initialize(options)
    @user, @pass = options[:user], options[:pass]
    @host, @port = options[:host], options[:port]
    @ssl = options[:ssl]
  end
  
  def credentials
    if @user
      "#{@user}:#{@pass}"
    else
      nil
    end
  end
  
  def service_url
    url = @ssl ? "https://" : "http://"
    url.concat "#{credentials}@" if c = credentials
    url.concat "#{@host}:#{@port}"
    url
  end
  
  def dispatch(request)
    respdata = RestClient.post service_url, request.to_post_data
    response = JSON.parse(respdata)
    raise Bitcoin::Errors::RPCError, response['error'] if response['error']
    response['result']
  end
  
  private
  def symbolize_keys(hash)
    case hash
    when Hash
      hash.inject({}) do |result, (key, value)|
        key = key.to_sym if key.kind_of?(String)
        value = symbolize_keys(value)
        result[key] = value
        result
      end
    when Array
      hash.collect do |ele|
        symbolize_keys(ele)
      end
    else
      hash
    end
  end
end
