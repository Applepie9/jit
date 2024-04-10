# frozen_string_literal: true

require_relative "command/add"
require_relative "command/commit"
require_relative "command/init"

module Command
  Unknown = Class.new(StandardError)

  COMMANDS = {
    "init" => Init,
    "add" => Add,
    "commit" => Commit
  }.freeze

  def self.execute(dir, env, argv, stdin, stdout, stderr)
    name = argv.first
    args = argv.drop(1)

    raise Unknown, "'#{name}' is not a jit command." unless COMMANDS.key?(name)

    command_class = COMMANDS[name]
    command = command_class.new(dir, env, args, stdin, stdout, stderr)

    command.execute
    command
  end
end