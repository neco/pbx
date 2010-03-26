require 'dm-core'
require 'dm-timestamps'
require 'state_machine'

require 'pbx'

DataMapper.setup(:default, PBX.database_uri)

class HuntGroup
  include DataMapper::Resource

  property :id, Serial
  property :name, String, :length => 20, :required => true
  property :groups, String, :length => 100, :required => true
  property :state, String, :length => 20, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime

  state_machine :initial => :day do
    state(:day)
    state(:night)

    event(:wake) { transition(all => :day) }
    event(:sleep) { transition(all => :night) }

    after_transition(:do => :set_forward_delay)
  end

  def set_forward_delay
    groups.split(/,/).each do |group|
      clearpath.set_forward_delay(group.strip, state_name)
    end
  end

  def clearpath
    @clearpath ||= Clearpath.new(PBX.clearpath.username, PBX.clearpath.password)
  end
  private :clearpath
end
