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
#  dispatch :get_cert do
#    param 'String', :fqdn
#    return_type 'String'
#  end

  dispatch :get_public_keys do
    param 'Array', :fqdns
  end

#  def get_cert(fqdn)
#    base = 'https://fabric-puppetserver01.vps.hosteurope.de:8140/puppet-ca/v1/certificate-status/'
#    url = "#{base}#{fqdn}"
#    ssldir = '/etc/puppetlabs/puppet/ssl'
#    ca = "#{ssldir}/certs/ca.pem"
#    client_priv = "#{ssldir}/private_key/fabric-puppetserver01.vps.hosteurope.de.pem"
#    client_cert = "#{ssldir}/certs/fabric-puppetserver01.vps.hosteurope.de.pem"
#    result = RestClient::Resource.new(
#      url: url,
#      ssl_ca_file: ca,
#      ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(client_cert)),
#      ssl_client_key: OpenSSL::PKey::RSA.new(File.read(client_priv)),
#      verify_ssl: OpenSSL::SSL::VERIFY_PEER
#    ).get
#    certificate = OpenSSL::X509::Certificate.new(result)
#    certificate.public_key.to_s
#  end

  def get_public_keys(fqdns)
    base = 'https://fabric-puppetserver01.vps.hosteurope.de:8140/puppet-ca/v1/certificate-status/'
    url = "#{base}#{fqdn}"
    ssldir = '/etc/puppetlabs/puppet/ssl'
    ca = "#{ssldir}/certs/ca.pem"
    client_priv = "#{ssldir}/private_key/fabric-puppetserver01.vps.hosteurope.de.pem"
    client_cert = "#{ssldir}/certs/fabric-puppetserver01.vps.hosteurope.de.pem"
    certs = {}
    fqdns.each do |fqdn|
     #certs[fqdn] = get_cert(fqdn)
      result = RestClient::Resource.new(
        url: url,
        ssl_ca_file: ca,
        ssl_client_cert: OpenSSL::X509::Certificate.new(File.read(client_cert)),
        ssl_client_key: OpenSSL::PKey::RSA.new(File.read(client_priv)),
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      ).get
      certificate = OpenSSL::X509::Certificate.new(result)
      certificate.public_key.to_s
    end
    certs
  end
end
