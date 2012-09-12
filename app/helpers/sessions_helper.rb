module SessionsHelper
	def application_url(redirect_uri)
    url = URI(redirect_uri)
    url.scheme + "://" + url.host
  end
end