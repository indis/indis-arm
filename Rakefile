#!/usr/bin/env rake

require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

LLVM_GCC = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/bin/arm-apple-darwin10-llvm-gcc-4.2'

file 'spec/fixtures/matcher-spec-gen.txt' do
  sh "#{LLVM_GCC} -mthumb -c spec/fixtures/matcher-spec-gen.S -o spec/fixtures/matcher-spec-gen.o"
  sh "otool -tvVB spec/fixtures/matcher-spec-gen.o | grep -E '^0' > spec/fixtures/matcher-spec-gen.txt"
  FileUtils.rm_f('spec/fixtures/matcher-spec-gen.o')
end

task :fixtures => 'spec/fixtures/matcher-spec-gen.txt'

task :default => [:fixtures, :spec]