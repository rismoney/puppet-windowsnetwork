require 'puppet'

require File.dirname(__FILE__) + '/../../../spec_helper'

describe Puppet::Type.type(:ipconfig) do

  it do
    expect {
      Puppet::Type.type(:ipconfig).new(:name => '')
    }.to raise_error(Puppet::Error, /Name must not be empty/)
  end
end
