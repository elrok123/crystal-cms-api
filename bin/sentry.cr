require "option_parser"

build_command = "crystal build ./src/website.cr"
run_command = "./website"
files = ["./src/**/*", "./config/*"]
files_cleared = false
show_help = false

OptionParser.parse! do |parser|
  parser.banner = "Usage: ./bin/sentry [options]"
  parser.on(
    "-r RUN_COMMAND",
    "--run=RUN_COMMAND",
    "Overrides the default run command") { |command| run_command = command }
  parser.on(
    "-b BUILD_COMMAND",
    "--build=BUILD_COMMAND",
    "Overrides the default build command") { |command| build_command = command }
  parser.on(
    "-w FILE",
    "--watch=FILE",
    "Overrides default files and appends to list of watched files") do |file|
    unless files_cleared
      files.clear
      files_cleared = true
    end
    files << file
  end
  parser.on(
    "-i",
    "--info",
    "Shows the values for build command, run command, and watched files"
    ) do
    puts "
      build: \t#{build_command}
      run: \t#{run_command}
      files: \t#{files}
    "
  end
  parser.on(
    "-h",
    "--help",
    "Show this help") do
    puts parser
    exit 0
  end
end

module Sentry
  FILE_TIMESTAMPS = {} of String => String # {file => timestamp}

  class ProcessRunner

    getter app_process : (Nil | Process) = nil

    def initialize(build_command : String, run_command : String, files)
      @app_built = false
      @build_command = build_command
      @run_command = run_command
      @files = [] of String
      @files = files
    end

    private def build_app_process
      Process.run(@build_command, shell: true, output: true, error: true)
    end

    private def create_app_process
      @app_process = Process.new(@run_command, output: true, error: true)
    end

    private def get_timestamp(file : String)
      File.stat(file).mtime.to_s("%Y%m%d%H%M%S")
    end

    def start_app
      app_process = @app_process
      if app_process.is_a? Process
        app_process.kill unless app_process.terminated?
      end

      puts "🤖  compiling app ..."
      build_result = build_app_process()
      if build_result && build_result.success?
        @app_built = true
        create_app_process()
      elsif !@app_built # if build fails on first time compiling, then exit
        puts "🤖  Compile time errors detected. SentryBot shutting down..."
        exit 1
      end
    end

    def scan_files
      file_changed = false
      app_process = @app_process
      files = @files
      Dir.glob(files) do |file|
        timestamp = get_timestamp(file)
        if FILE_TIMESTAMPS[file]? && FILE_TIMESTAMPS[file] != timestamp
          FILE_TIMESTAMPS[file] = timestamp
          file_changed = true
          puts "🤖  #{file}"
        elsif FILE_TIMESTAMPS[file]?.nil?
          puts "🤖  watching file: #{file}"
          FILE_TIMESTAMPS[file] = timestamp
          file_changed = true if (app_process && !app_process.terminated?)
        end
      end

      start_app() if (file_changed || app_process.nil?)
    end
  end
end

process_runner = Sentry::ProcessRunner.new(
  files: files,
  build_command: build_command,
  run_command: run_command
)

puts "🤖  Your SentryBot is vigilant. beep-boop..."

loop do
  process_runner.scan_files
  sleep 1
end
