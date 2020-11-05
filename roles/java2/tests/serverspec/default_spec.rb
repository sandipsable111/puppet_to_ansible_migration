require "spec_helper"
require "serverspec"

packages = []

case os[:family]
when "freebsd"
  packages = ["java/openjdk13"]
when "redhat"
  packages = ["java-1.8.0-openjdk", "java-1.8.0-openjdk-devel"]
when "openbsd"
  packages = ["jdk"]
when "ubuntu"
  packages = ["openjdk-8-jdk"]
end

packages.each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

case os[:family]
when "freebsd"
  describe file("/proc") do
    it { should be_mounted.with(type: "procfs") }
    it { should be_mounted }
  end

  describe file("/dev/fd") do
    it { should be_mounted.with(type: "fdescfs") }
    it { should be_mounted }
  end
when "ubuntu"
  if os[:release].to_f < 16.04
    describe command("debconf-show oracle-java8-installer") do
      its(:stdout) { should match(/#{ Regexp.escape("* shared/accepted-oracle-license-v1-1: true") }/) }
      its(:stderr) { should match(/^$/) }
      its(:exit_status) { should eq 0 }
    end
  else
    describe command("debconf-show oracle-java8-installer") do
      its(:stdout) { should match(/^$/) }
      its(:stderr) { should match(/^$/) }
      its(:exit_status) { should eq 0 }
    end
  end
end

case os[:family]
when "openbsd"
  describe command("/usr/local/jdk-11/bin/jps") do
    its(:stdout) { should match(/^\d+\s+Jps/) }
    its(:stderr) { should match(/^$/) }
    its(:exit_status) { should eq 0 }
  end
else
  describe command("jps") do
    its(:stdout) { should match(/^\d+\s+Jps/) }
    its(:stderr) { should match(/^$/) }
    its(:exit_status) { should eq 0 }
  end
end
