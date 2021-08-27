module S3Relay
  class PrivateUrl < S3Relay::Base

    attr_reader :expires, :path

    def initialize(uuid, file, options={})
      filename =
        if file.include?(":")
          filename.gsub(":", "%3A")
        else
          Addressable::URI.escape(file)
        end
      filename = filename.gsub("+", "%2B").gsub("#", "%23").gsub("?", "%3F").gsub("\\", "%5C")
      @path    = [uuid, filename].join("/")
      @expires = (options[:expires] || 10.minutes.from_now).to_i
    end

    def generate
      "#{endpoint}/#{path}?#{params}"
    end

    private

    def params
      [
        "AWSAccessKeyId=#{access_key_id}",
        "Expires=#{expires}",
        "Signature=#{signature}"
      ].join("&")
    end

    def signature
      string = "GET\n\n\n#{expires}\n/#{bucket}/#{path}"
      hmac   = OpenSSL::HMAC.digest(digest, secret_access_key, string)
      CGI.escape(Base64.encode64(hmac).strip)
    end

  end
end
