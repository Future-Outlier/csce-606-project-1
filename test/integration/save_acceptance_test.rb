# frozen_string_literal: true

# Exercises saving through the real executable, including separate application runs.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'

class SaveAcceptanceTest < Minitest::Test
  EXECUTABLE = File.expand_path('../../bin/tarot', __dir__)
  FAKE_RUNNER = File.expand_path('../support/fake_qwen_runner.rb', __dir__)

  def setup
    @directory = Dir.mktmpdir('tarot-save-acceptance-test')
    @path = File.join(@directory, 'readings.json')
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_saves_a_partial_reading_and_returns_to_the_main_menu
    output = run_cli("new\nMy question\ndraw\nsave\nhelp\nexit\n")
    reading = readings.first

    assert_includes output, 'Session successfully saved to disk. Returning to Main Menu...'
    assert_includes output, 'Usage: tarot [command]'
    assert_equal 'My question', reading['question']
    assert_equal drawn_cards(output), reading['cards']
    assert_equal "Test interpretation for My question: #{reading['cards'].join(', ')}", reading['interpretation']
    assert_includes output, reading['interpretation']
  end

  def test_saved_readings_survive_restarting_the_application
    run_cli("new\nFirst question\ndraw\nsave\nexit\n")
    first_reading = readings.first
    run_cli("new\nSecond question\ndraw\nsave\nexit\n")

    assert_equal([1, 2], readings.map { |reading| reading['ID'] })
    assert_equal first_reading, readings.first
    assert_equal 'Second question', readings.last['question']
  end

  def test_rejects_save_at_the_main_menu_and_continues
    output = run_cli("save\nhelp\nexit\n")

    assert_includes output, 'Cannot save an empty reading.'
    assert_includes output, 'Usage: tarot [command]'
    refute File.exist?(@path)
  end

  def test_rejects_an_empty_session_and_allows_drawing_before_saving
    output = run_cli("new\nQuestion\nsave\ndraw\nsave\nexit\n")

    assert_includes output, 'Cannot save an empty reading. Please draw cards first.'
    assert_equal 1, readings.size
    assert_equal 1, readings.first['cards'].size
  end

  def test_failed_save_preserves_history_and_allows_more_commands
    File.write(@path, '{broken json')
    output = run_cli("new\nQuestion\ndraw\nsave\ndraw\nshuffle\nhelp\nexit\n")

    assert_includes output, 'Could not save reading:'
    refute_includes output, 'Session successfully saved'
    assert_equal 2, drawn_cards(output).size
    assert_includes output, 'Usage: tarot [command]'
    assert_equal '{broken json', File.read(@path)
  end

  private

  def run_cli(input)
    output, error, status = Open3.capture3(
      RbConfig.ruby, '-r', FAKE_RUNNER, EXECUTABLE, stdin_data: input, chdir: @directory
    )
    assert status.success?, error
    assert_empty error
    output
  end

  def readings
    JSON.parse(File.read(@path))['readings']
  end

  def drawn_cards(output)
    output.lines.grep(/^Current Spread:/).last.scan(/\[ (.*?) \]/).flatten
  end
end
