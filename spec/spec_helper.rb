require 'wordless/cli'
require 'fakeweb'
require 'thor'

RSpec.configure do |config|
  FakeWeb.allow_net_connect = false
  FileUtils.mkdir('tmp') unless File.directory? 'tmp'

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end
    result
  end
end
