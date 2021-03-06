require 'erb'
require 'fileutils'
require 'rake/testtask'

desc "Run all tests"
task :test do
  $LOAD_PATH.unshift(File.expand_path('test'))
  require 'redgreen' if Gem.available?('redgreen')
  require 'test/unit'
  Dir['test/*/**/test_*.rb'].each {|test| require test }
end

namespace :build do

  desc "Recompile the Racc parser (pass -v and -g for verbose debugging)"
  task :parser, :racc_args do |t, args|
    sh "racc #{args[:racc_args]} -o lib/coffee_script/parser.rb lib/coffee_script/grammar.y"
  end

  desc "Compile the Narwhal interface for --interactive and --run"
  task :narwhal do
    sh "bin/coffee lib/coffee_script/narwhal/*.coffee -o lib/coffee_script/narwhal/lib/coffee-script"
    sh "mv lib/coffee_script/narwhal/lib/coffee-script/coffee-script.js lib/coffee_script/narwhal/lib/coffee-script.js"
  end

end

desc "Build the documentation page"
task :doc do
  source = 'documentation/index.html.erb'
  child = fork { exec "bin/coffee documentation/coffee/*.coffee -o documentation/js -w" }
  at_exit { Process.kill("INT", child) }
  Signal.trap("INT") { exit }
  loop do
    mtime = File.stat(source).mtime
    if !@mtime || mtime > @mtime
      rendered = ERB.new(File.read(source)).result(binding)
      File.open('index.html', 'w+') {|f| f.write(rendered) }
    end
    @mtime = mtime
    sleep 1
  end
end

namespace :gem do

  desc 'Build and install the coffee-script gem'
  task :install do
    sh "gem build coffee-script.gemspec"
    sh "sudo gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end

  desc 'Uninstall the coffee-script gem'
  task :uninstall do
    sh "sudo gem uninstall -x coffee-script"
  end

end

task :default => :test