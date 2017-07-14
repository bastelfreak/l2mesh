# OH MY GOSH
# After years of fiddling with Puppet I'm finally writing a good function
# We get a FQDN passed and collect the certificate for it from the puppet API
# afterwards we extract the public key and return it

# Written by Tim 'bastelfreak' Meusel
# openssl magic by the awesome @TheBrayn https://gist.github.com/anonymous/7475be691cbbfa8cde1a011113c20a74
# https://github.com/rest-client/rest-client#ssl-client-certificates
# https://docs.puppet.com/puppet/4.10/functions_ruby_signatures.html
# https://docs.puppet.com/puppet/4.10/functions_ruby_overview.html

require 'openssl'
require 'rest-client'
Puppet::Functions.create_function(:get_public_keys) do
  dispatch :get_public_key do
    param 'String', :fqdn
    return_type 'String'
  end

  dispatch :get_local_public_key do
    return_type 'String'
  end

  dispatch :get_public_keys do
    param 'Array', :fqdns
    return_type 'Hash'
  end

  def get_public_key(fqdn)
    base = 'https://fabric-puppetserver01.vps.hosteurope.de:8140/puppet-ca/v1/certificate-status/'
    url = "#{base}#{fqdn}"
    ssldir = '/etc/puppetlabs/puppet/ssl'
    ca = "#{ssldir}/certs/ca.pem"
    result = RestClient::Resource.new(
      url,
      ssl_ca_file: ca,
      verify_ssl: OpenSSL::SSL::VERIFY_PEER
    ).get
    certificate = OpenSSL::X509::Certificate.new(result)
    certificate.public_key.to_s
  end

  # get the key for the calling node
  def get_local_public_key
    get_public_key scope['facts']['networking']['fqdn']
  end

  def get_public_keys(fqdns)
    keys = {}
    fqdns.each do |fqdn|
      key = get_public_key fqdn
      keys[fqdn] = key
    end
    keys
  end
end
