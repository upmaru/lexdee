import Mix.Config

config :lexdee, :environment, :test
config :lexdee, :task, Lexdee.TaskMock

config :logger, level: :warn
