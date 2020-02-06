module Paymongo
  class Tokenization 
    def initialize(gateway)
      @gateway = gateway
      @config = gateway.config
      @config.assert_has_keys
    end
    def tokenize(attributes)
      create(
        {
          data: {
            attributes: { 
              number: attributes[:number],
              expiry_month: attributes[:expiry_month],
              expiry_year: attributes[:expiry_year],
              cvc: attributes[:cvc]
            }
          }
        }
      )
    end 
    def create(attributes)
      _do_create '/tokens', transaction: attributes
    end 
    def _do_create(path, params=nil)
      response = @config.https.post("#{@config.base_url}#{path}", params)
      _handle_transaction_response(response)
    end 
    def _handle_transaction_response(response)
      if response[:data]
        SuccessfulResult.new(
          transaction: Transaction._new(@gateway, response[:data])
        )
      elsif response[:errors]
        ErrorResult.new(@gateway, response[:errors])
      else
        raise UnexpectedError, 'expected :data'
      end
    end
  end 
end 