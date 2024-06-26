# frozen_string_literal: true

require "fileutils"
require "pathname"

require_relative "base"

module Command
  class Init < Base
    def run
      path = @args.fetch(0, @dir)

      root_path = expanded_pathname(path)
      git_path  = root_path.join(".git")

      %w[objects refs].each do |dir|
        FileUtils.mkdir_p(git_path.join(dir))
      rescue Errno::EACCES => e
        @stderr.puts "fatal: #{e.message}"
        exit 1
      end

      puts "Initialized empty Jit repository in #{git_path}"
      exit 0
    end
  end
end
