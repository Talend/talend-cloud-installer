require 'openssl'
require 'base64'

module Puppet::Parser::Functions
  newfunction(:amazon_ses_smtp_password, :type => :rvalue) do |args|
    key            = args[0]
    message        = 'SendRawEmail'
    versionInBytes = 0x02

    signatureInBytes = OpenSSL::HMAC.digest('sha256', key, message)
    signatureAndVer  = ([versionInBytes] + signatureInBytes.bytes.to_a).pack('c*')

    return Base64.encode64(signatureAndVer)
  end
end
