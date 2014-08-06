require 'rubygems'
require 'rest_client'
require 'json'

class DomainCheck 
    
    # Username
    @username

    # Password
    @password

    # Domain you look for
    @domain

    # Service url
    @url

    def initialize(user, password, domain)
        @username, @password, @domain = user, password, domain

        @url = "http://www.whoisxmlapi.com/whoisserver/WhoisService?domainName=#{@domain}&cmd=GET_DN_AVAILABILITY&username=#{@username}&password=#{@password}&outputFormat=JSON"
    end

    def doCheckAvailability
        response = RestClient.get(@url)
        return response.body
    end

    def getOutput
        return doCheckAvailability()
    end

    # returns a human readable version of the response from rest api
    def getText

        # convert the returned JSON data to native Ruby
        # data structure - a hash
        responseHash = JSON.parse(getOutput())

        textOutput = "\nDomain availability infomration\n-----------------\n\n"
        textOutput += "Results for #{@domain} \n\n"

        # Loop over the json response returned and append them to the textOutput string 
        
        responseHash['DomainInfo'].each {|item| 
            textOutput += "#{item[0]} status: #{item[1]}\n"
        }   
        textOutput += "\n-----------------\n"     
        return textOutput
    end
end    

username = 'gayan';
password = 'eppo123'
domainName = 'gayan.com'

client = DomainCheck.new(username, password, domainName)
puts client.getText() 
