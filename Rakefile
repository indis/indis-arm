#!/usr/bin/env rake

require "bundler/gem_tasks"
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

LLVM_GCC = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/usr/llvm-gcc-4.2/bin/arm-apple-darwin10-llvm-gcc-4.2'

rule '.disasm' => ['.S'] do |t|
  sh "#{LLVM_GCC} -mthumb -arch armv7 -c #{t.source} -o #{t.name}.o"
  sh "otool -tvVB #{t.name}.o | grep -E '^0' > #{t.name}"
  FileUtils.rm_f("#{t.name}.o")
end

task :fixtures => [
  'spec/fixtures/matcher-spec-gen.disasm',
  'spec/fixtures/matcher-spec-it-gen.disasm',
  'spec/fixtures/matcher-thumb2-is.disasm'
]

task :default => :spec
