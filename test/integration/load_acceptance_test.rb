# frozen_string_literal: true

# Exercises restoring and continuing saved readings through separate application runs.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'

class LoadAcceptanceTest < Minitest::Test
  EXECUTABLE = File.expand_path('../../bin/tarot', __dir__)
  FAKE_RUNNER = File.expand_path('../support/fake_qwen_runner.rb', __dir__)

  def setup
    @directory = Dir.mktmpdir('tarot-load-acceptance-test')
    @path = File.join(@directory, 'readings.json')
    run_cli("new\nMy question\ndraw\ndraw\nsave\nexit\n")
    @saved = readings.first
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_restores_displays_and_continues_a_reading_after_restart
    output = run_cli("load\n1\ndraw\ndraw\nsave\nexit\n")
    assert_restored_display(output.split('Drawing card...').first)
    assert_includes output, 'Maximum of 3 cards reached.'
    assert_equal 2, readings.size
    assert_equal @saved, readings.first
    assert_continued_reading(readings.last)
  end

  def test_read_failure_reports_an_error_and_allows_more_commands
    original = File.binread(@path)
    backup = "#{@path}.backup"
    File.rename(@path, backup)
    # A directory at the file path causes a read error even when tests run as root.
    Dir.mkdir(@path)

    output = run_cli("load\n1\nhelp\nexit\n")

    assert_match(/Could not load reading: .+/, output)
    assert_includes output, 'Usage: tarot [command]'
    assert_equal original, File.binread(backup)
  end

  private

  def assert_restored_display(output)
    spread = @saved['cards'].map { |name| "[ #{name} ]" }.join(' -> ')
    assert_includes output, @saved['question']
    assert_includes output, "Current Spread: #{spread}"
    assert_includes output, @saved['interpretation']
  end

  def assert_continued_reading(continued)
    cards = continued['cards']
    assert_equal @saved['question'], continued['question']
    assert_equal @saved['cards'], cards.first(2)
    assert_equal 3, cards.size
    assert_equal 3, cards.uniq.size
    assert_equal "Test interpretation for My question: #{cards.join(', ')}", continued['interpretation']
  end

  def run_cli(input)
    Open3.popen3(RbConfig.ruby, '-r', FAKE_RUNNER, EXECUTABLE, chdir: @directory) do |stdin, stdout, stderr, process|
      stdin.write(input)
      stdin.close
      capture_result(stdout, stderr, process)
    end
  end

  def capture_result(stdout, stderr, process)
    output = Thread.new { stdout.read }
    error = Thread.new { stderr.read }
    wait_for_exit(process)
    assert process.value.success?, error.value
    assert_empty error.value
    output.value
  ensure
    output&.join
    error&.join
  end

  def wait_for_exit(process)
    return if process.join(5)

    Process.kill('KILL', process.pid)
    process.join
    flunk 'CLI did not finish within five seconds.'
  end

  def readings
    JSON.parse(File.read(@path))['readings']
  end
end
