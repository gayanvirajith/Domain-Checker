#!/usr/bin/env ruby

# Written by Gayan Virajith
# The script looks particular domain availibility 
# using  `WhoisAPI` - http://www.whoisxmlapi.com
# It will output specified domain name is available or not.

require 'rubygems'
require 'rest_client'
require 'json'

class DomainCheck 
    
    def initialize(user, password, domain)
        # Initialize username, password and service URL
        @username, @password, @domain = user, password, domain

        @url = "http://www.whoisxmlapi.com/whoisserver/WhoisService?" +
                "domainName=#{@domain}&cmd=GET_DN_AVAILABILITY&" + 
                "username=#{@username}&password=#{@password}&outputFormat=JSON"
    end

    # Check domain availability using RestClient helper
    # todo: handle some exceptions and error codes
    def doCheckAvailability
        begin
            response = RestClient.get(@url) { |response, request, result| 
                case response.code
                    when 200
                        # Good response
                        return response.body 
                    when 423
                        # Oops locked !
                        raise "Oops ! The resource that is being accessed is locked"
                    else 
                        response.return!(request, result, &block)
                end                
                return response.body
            }
        rescue SocketError => e            
            raise "Error when fetching from #{e}"        
        end
    end

    # Get availibility output returned from api
    def getOutput
        return doCheckAvailability()
    end

    # returns a human readable version of the response from rest api
    def getText

        # convert the returned JSON data to native Ruby
        # data structure - a hash
        responseHash = JSON.parse(getOutput())

        textOutput = "\nDomain availability infomration\n-----------------\n\n"
        unless responseHash.has_key?("ErrorMessage")  
            textOutput += "Results for #{@domain} \n\n"
            # Loop over the json response returned and append them to 
            # the textOutput string         
            responseHash['DomainInfo'].each {|item| 
                textOutput += "#{item[0]} status: #{item[1]}\n"
            }   
        else
            # Loop over the json response returned and append them to                
            # the textOutput string         
            textOutput += "Unable to process the request due to following error\n"                                         
            responseHash['ErrorMessage'].each {|item|                                  
                textOutput += "#{item[0]} : #{item[1]}\n"                      
            }                                                  
        end
        textOutput += "\n-----------------\n"     
        return textOutput
    end
end    

# Api credentials
# For the whoisxmlapi.com you need to have an account first. 
# If you are a developer you can register as developer for free.
# http://www.whoisxmlapi.com/newaccount.php
# api username 
username = 'user';
# api password
password = 'password'
# the domain name you look for
domainName = 'gayan.com'

# Make DomainCheck instance with
# your defined username, password and domain name
client = DomainCheck.new(username, password, domainName)

# Finally invoke getText() method to have some output.
puts client.getText() 
