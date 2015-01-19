class User < ActiveRecord::Base
   include PublicActivity::Common
  # tracked only: :update, owner: Proc.new{ |controller, model| controller.current_user }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :iam_username, uniqueness: true ,unless: :user_is_member?

  has_many :schedules, dependent: :destroy
  has_many :scheduled_snapshots, dependent: :restrict
  has_many :snapshot_summaries, dependent: :destroy
  has_many :scheduled_summaries, dependent: :destroy
  has_many :scheduled_amis, dependent: :destroy
  has_many :ami_summaries, dependent: :destroy

  has_many :member_user, foreign_key: :admin_id, class_name: 'User'



  REGIONS = {"us-east-1" => ["all", "us-east-1a", "us-east-1c", "us-east-1d"], 
             "us-west-2" => ["all", "us-west-2a", "us-west-2b", "us-west-2c"], 
             "us-west-1" => ["all", "us-west-1a", "us-west-1b"], 
             "eu-west-1" => ["all", "eu-west-1a", "eu-west-1b", "eu-west-1c"], 
             "ap-southeast-1" => ["all", "ap-southeast-1a", "ap-southeast-1b"], 
             "ap-southeast-2" => ["all", "ap-southeast-2a", "ap-southeast-2b"], 
             "ap-northeast-1"=> ["all", "ap-northeast-1a", "ap-northeast-1c"], 
             "sa-east-1" => ["all", "sa-east-1a", "sa-east-1b"],
             "us-gov-west-1" => ['all']
             }

  def user_is_member?
    role ==  'bussiness_man'|| 'normal'
  end

  def generate_password
    self.password = SecureRandom.hex(10)
  end




  def self.get_all_members user
    if user.role == "member" || user.role == "normal_user"
      all_members = [user.id]
    else
      all_members = [user.id]

      all_members.append User.where(:admin_id => user.admin_id).pluck(:id) unless user.admin_id.nil? && user.role=="bussiness_man"
      all_members.append User.where(:admin_id => user.id).pluck(:id) unless User.where(:admin_id => user.id).pluck(:id).blank?
      all_members.append User.where(:id => user.admin_id ).pluck(:id) unless user.admin_id.nil?
    end 
    all_members
  end

  def self.create_iam_user user
    iam = AWS::IAM.new(
        :access_key_id => user.access_key,
        :secret_access_key => user.secret_token,
        :region => user.default_region)
    iam_user = iam.users.create(user.iam_username)
    iam_user.login_profile.password = user.iam_password
    new_access_key = iam_user.access_keys.create
    user_group = iam.groups[user.group_name]
    iam_user.groups.add(user_group)
    user.access_key = new_access_key.credentials[:access_key_id]
    user.secret_token = new_access_key.credentials[:secret_access_key]
    user.save
  end

  def self.delete_iam_user user ,root_user
    iam = AWS::IAM.new(
        :access_key_id => root_user.access_key,
        :secret_access_key => root_user.secret_token,
         :region=> user.default_region)
    iam_user = iam.users[user.iam_username]
    iam_user.delete!
  end

  def self.set_account_alias user
    begin
    iam = AWS::IAM.new(
        :access_key_id => user.access_key,
        :secret_access_key => user.secret_token,
        :region => user.default_region)
    account_alias = iam.account_alias
      unless account_alias.nil?
        account_alias
      else
        arn = iam.users.first.arn
        account_alias= arn.scan(/\d/).join('')
      end
      account_alias
    rescue
      account_alias = nil
    end
  end
             
end
