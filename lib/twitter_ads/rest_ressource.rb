#
# @ Seevibes 2015
# Author Thomas Landspurg
#
# thomas@seevibes.com
#
#


module TwitterAds



  # Common class to manage access to recourse
  # Need access to client, prefix, and ops available on this ressource
  #
  # provide operation oauth autenthificated operation (get/post/put/delete)
  # as well as dynamically discovered opertions, using the ops instance variable
  #
  class RestResource
    @prefix = ''
    attr :access_token, :prefix, :client, :attributes, :id, :name

    def init
    	@id = @attributes['id']
      @name = @attributes['name']
    end

    # Utility funciton to do a get on the RES API
    def get(action = '', params = nil)
      do_request :get, action, params
    end

    def post(action, params = nil)
      do_request :post, action, params
    end

    def put(action, params = nil)
      do_request :put, action, params
    end

    def delete(action = '', params = nil)
      do_request :delete, action, params
    end

    def do_request(verb, action, params)
      url = "https://#{ADS_API_ENDPOINT}/0/#{prefix}#{action}"
      url = url[0..-2] if url[-1] == '/'

      # TODO: add a logger
      puts "Doing request:#{verb} #{prefix} #{action} #{params} URL:#{url}" if TRACE
      res = ::MultiJson.load(@client.access_token.request(verb, url, params).body)

      # TODO: pretty format the errors
      raise AdsError, res['errors'].first['code'] if res['errors']
      res['data']
    end


    # Dynamic check of methods
    # tab_ops contain the list of allowed method and verbs
    # prefix the prefix to add to the method
    #
    def check_method(tab_ops, prefix, method_sym, do_call, *arguments, &block)
      method_sym = method_sym.id2name
      verb = :get
      [:post, :get, :delete, :put].each do |averb|
        if method_sym.start_with? averb.id2name
          verb = averb
          method_sym[averb.id2name + '_'] = ''
          break
        end
      end
      if tab_ops[verb].include? method_sym.to_sym
        if do_call
          params = arguments.first
          method = prefix + method_sym
          method += "/#{params.shift}"  if params.first && params.first.class != Hash
          return do_request verb, method, params.shift
        else
          return nil
        end
      end
      nil
    end

    def method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      check_method(@ops, '', method_sym, true, arguments, block) || super
    end

    def respond_to?(method_sym)
      if check_method(@ops, '', method_sym.to_sym, false, '', nil)
        return true
      end
      super
    end

    def as_json
      @attributes
    end

    def refresh
      @attributes = get('')
      init
    end
  end

end
