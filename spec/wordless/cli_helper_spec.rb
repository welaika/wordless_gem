require 'spec_helper'

class MyClass
  include Wordless::CLIHelper

  def thor
    @thor ||= Thor.new
  end
end

RSpec.describe Wordless::CLIHelper do
  let(:subject) { MyClass.new }

  context "#error" do
    it "raises a SystemExit error" do
      allow(subject).to receive(:log_message)
      expect { subject.send(:error, "Wrong") }.to raise_error(SystemExit)
    end

    it "prints the message to stdout" do
      allow(subject).to receive(:exit)
      expect { subject.send(:error, "Wrong") }.to output(/Wrong/).to_stdout
    end
  end
end
