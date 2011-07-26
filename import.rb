#!/usr/bin/ruby

require 'open-uri'
require 'uri'
require 'net/http'
require 'open3'

    accept_format = 'application/json'

max = 10
1.upto( max ) do |i| # i contient la valeur courante de l'itérateur
    puts i
    @index = i

    begin
       puts @index
      url = URI.parse("http://dev-api.vidal.net:9876/PackService/getAllPackages?PACKAPIFILTER=ALL&PRODUCTTYPE%5B%5D=VIDAL&MARKETSTATUS%5B%5D=AVAILABLE&3-ID=" + @index.to_s + "&4-ID=500")

      Net::HTTP.new(url.host, url.port).start do |http|
        req = Net::HTTP::Get.new(url.path + "?" + url.query, initheader = {'Accept' => accept_format})
        response = http.request(req)

        if response.kind_of?(Net::HTTPSuccess)
          json = response.body
          first_index = json.index('{"packs"')

          last_index = json.index(',"rowCount"')

          @for_couchdb = '{"docs"' + json[first_index + 8, last_index - first_index - 8]
          #puts @for_couchdb
        else
          puts response.error!
        end
      end
    rescue
    end

    begin
cmd =  "curl -X POST -d '" + @for_couchdb + "' -H'content-type:application/json' http://127.0.0.1:5984/vidal/_bulk_docs" 

#puts cmd

       stdin, stdout, stderr, wait_thr = Open3.popen3(cmd)
       stdin.close
       stdout.close
       stderr.close
    rescue
       puts $!
    end
end
