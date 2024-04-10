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

  def self.execute(name)
    raise Unknown, "'#{name}' is not a jit command." unless COMMANDS.key?(name)

    command_class = COMMANDS[name]
    command_class.new.run
  end
end
