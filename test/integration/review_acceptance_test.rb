# frozen_string_literal: true

# Checks saved history and review errors through the real executable.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'

class ReviewAcceptanceTest < Minitest::Test
  EXECUTABLE = File.expand_path('../../bin/tarot', __dir__)

  def setup
    @directory = Dir.mktmpdir('tarot-review-acceptance-test')
    @path = File.join(@directory, 'readings.json')
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_reports_missing_history_and_continues
    output = run_cli("review\nhelp\nexit\n")
    assert_includes output, 'No saved readings found.'
    assert_includes output, 'Usage: tarot [command]'
    refute File.exist?(@path)
  end

  def test_reports_empty_history_and_continues
    File.write(@path, JSON.generate('readings' => []))

    output = run_cli("review\nhelp\nexit\n")

    assert_includes output, 'No saved readings found.'
    assert_includes output, 'Usage: tarot [command]'
  end

  def test_displays_saved_reading_details_and_continues
    File.write(@path, JSON.generate('readings' => [saved_reading]))

    output = run_cli("review\nhelp\nexit\n")

    assert_includes output, <<~READING
      Reading ID: 1
      Saved at: 2026-09-16T12:00:00Z
      Question: What comes next?
      Cards: The Fool -> The World
      Interpretation: A new beginning.
    READING
    assert_includes output, 'Usage: tarot [command]'
  end

  def test_reports_malformed_history_without_changing_it_and_continues
    File.write(@path, '{broken json')

    output = run_cli("review\nhelp\nexit\n")

    assert_includes output, 'Could not review saved readings:'
    assert_includes output, 'Usage: tarot [command]'
    assert_equal '{broken json', File.read(@path)
  end

  def test_review_sorts_readings_by_saved_at_with_most_recent_first
    readings = [
      { 'ID' => 2, 'saved_at' => '2026-09-15T12:00:00Z', 'question' => 'older',
        'cards' => ['The Fool'], 'interpretation' => 'old' },
      { 'ID' => 1, 'saved_at' => '2026-09-16T12:00:00Z', 'question' => 'newer',
        'cards' => ['The World'], 'interpretation' => 'new' }
    ]
    File.write(@path, JSON.generate('readings' => readings))

    output = run_cli("review\nexit\n")

    assert_operator output.index('Question: newer'), :<, output.index('Question: older')
  end

  private

  def saved_reading
    { 'ID' => 1, 'saved_at' => '2026-09-16T12:00:00Z', 'question' => 'What comes next?',
      'cards' => ['The Fool', 'The World'], 'interpretation' => 'A new beginning.' }
  end

  def run_cli(input)
    output, error, status = Open3.capture3(
      RbConfig.ruby, EXECUTABLE, stdin_data: input, chdir: @directory
    )
    assert status.success?, error
    assert_empty error
    output
  end
end
