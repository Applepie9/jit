# frozen_string_literal: true

require "fileutils"
require "pathname"

require "command"
require "repository"

module CommandHelper
  def self.included(suite)
    suite.before { jit_cmd "init", repo_path.to_s }
    suite.after  { FileUtils.rm_rf(repo_path) }
  end

  def repo_path
    Pathname.new(File.expand_path('test-repo', __dir__))
  end

  def repo
    @repo ||= Repository.new(repo_path.join(".git"))
  end

  def write_file(name, contents)
    path = repo_path.join(name)
    FileUtils.mkdir_p(path.dirname)

    flags = File::RDWR | File::CREAT | File::TRUNC
    File.open(path, flags) { |file| file.write(contents) }
  end

  def make_executable(name)
    File.chmod(0755, repo_path.join(name))
  end

  def make_unreadable(name)
    File.chmod(0200, repo_path.join(name))
  end

  def jit_cmd(*argv)
    @stdin  = StringIO.new
    @stdout = StringIO.new
    @stderr = StringIO.new

    @cmd = Command.execute(repo_path.to_s, {}, argv, @stdin, @stdout, @stderr)
  end

  def assert_status(status)
    assert_equal(status, @cmd.status)
  end

  def assert_stdout(message)
    assert_output(@stdout, message)
  end

  def assert_stderr(message)
    assert_output(@stderr, message)
  end

  def assert_output(stream, message)
    stream.rewind
    assert_equal(message, stream.read)
  end
end
