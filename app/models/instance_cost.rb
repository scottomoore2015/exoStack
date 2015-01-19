class InstanceCost < ActiveRecord::Base
  serialize :sizes ,Array

 INSTANCEREGION = {"us-west-2c" => "us-west-2", "us-west-2a" => "us-west-2","us-west-1" => "us-west",
                   "us-east-1" => "us-east",
                   "sa-east-1" => "sa-east-1",
                   "eu-west-1" => "eu-ireland",
                   "ap-southeast-2" => "apac-syd",
                   "ap-southeast-1" => "apac-sin",
                   "ap-northeast-1" => "apac-tokyo"
                  }


end



# "us-east">US East (N. Virginia)
# "us-west-2">US West (Oregon)
# "us-west">US West (Northern California)
# "eu-ireland">EU (Ireland)
# "apac-sin">Asia Pacific (Singapore)
# "apac-tokyo">Asia Pacific (Tokyo)
# "apac-syd">Asia Pacific (Sydney)
# "sa-east-1">South America (Sao Paulo)


# ap-northeast-1
# Asia Pacific (Tokyo) Region
# ap-southeast-1
# Asia Pacific (Singapore) Region
# ap-southeast-2
# Asia Pacific (Sydney) Region
# eu-west-1
# EU (Ireland) Region
# sa-east-1
# South America (Sao Paulo) Region
# us-east-1
# US East (Northern Virginia) Region
# us-west-1
# US West (Northern California) Region
# us-west-2
# US West (Oregon) Region