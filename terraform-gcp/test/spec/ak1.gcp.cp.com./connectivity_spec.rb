require 'spec_helper'

describe host('ak0.gcp.cp.com.') do
  # ping
  it { should be_reachable }
  # set protocol explicitly
  xit { should be_reachable.with( :port => 9092, :proto => 'tcp' ) }
end

describe host('zk0.gcp.cp.com.') do
  # ping
  it { should be_reachable }
  # set protocol explicitly
  xit { should be_reachable.with( :port => 2181, :proto => 'tcp' ) }
end

describe port(9092) do
  xit { should be_listening }
end
