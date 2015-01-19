require 'net/http'
require 'json'
class InstanceCostsController < ApplicationController


  def index
    
  end


def reload_cost
     InstanceCost.delete_all
    arr = []
    arr << URI.parse('http://a0.awsstatic.com/pricing/1/ec2/linux-od.min.js')
    arr << URI.parse('http://a0.awsstatic.com/pricing/1/ec2/rhel-od.min.js')
    arr << URI.parse('http://a0.awsstatic.com/pricing/1/ec2/sles-od.min.js')
    arr << URI.parse('http://a0.awsstatic.com/pricing/1/ec2/mswin-od.min.js')
    arr << URI.parse('http://a0.awsstatic.com/pricing/1/ec2/mswinSQL-od.min.js')
    arr << URI.parse('http://a0.awsstatic.com/pricing/1/ec2/mswinSQLWeb-od.min.js')

    arr.each do |i|
      fetch_price_data(i)
    end
    redirect_to profile_path
  end

  def fetch_price_data(uri)
   begin
     
      jsonp = Net::HTTP.get(uri)
      jsonp.gsub!(/^.*callback\(/, '')  #removes the comment and callback function from the start of the string
      jsonp.gsub!(/\);$/, '')           #removes the end of the callback function
      jsonp.gsub!(/(\w+):/, '"\1":')
      hash = JSON.parse(jsonp)

    operating_system = hash["config"]["valueColumns"].last
    region_wise_data = hash["config"]["regions"]
    region_wise_data.each do |region_object|
      region = region_object["region"]
      instance_type_data = region_object["instanceTypes"]
      instance_type_data.each do |instance_type_object|
        instance_type = instance_type_object["type"]
        sizes = instance_type_object["sizes"]
          instance_cost = InstanceCost.create(:instance_name => 'OnDemand',:operating_system =>operating_system,:region => region ,:instance_type => instance_type, :sizes=> sizes )
      end
    end
     rescue
      flash[:error] = "Price not lodeded!"
      redirect_to profile_path
    end
  end
end