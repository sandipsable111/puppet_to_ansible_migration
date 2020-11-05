require "spec_helper"
require "serverspec"

packages = ["openjdk-7-jdk"]

packages.each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

describe command("debconf-show oracle-java8-installer") do
  its(:stdout) { should match(/^$/) }
  its(:stderr) { should match(/^$/) }
  its(:exit_status) { should eq 0 }
end
