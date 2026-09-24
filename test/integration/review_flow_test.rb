# frozen_string_literal: true

# Exercises review inside the test process so coverage includes its success and error paths.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'tarot_cli/cli'

class ReviewFlowTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir('tarot-review-flow-test')
    @path = File.join(@directory, 'readings.json')
    @cli = TarotCLI::CLI.new(save_path: @path)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_review_reports_empty_history_without_displaying_readings
    File.write(@path, JSON.generate('readings' => []))

    output, = capture_io { assert_equal 0, @cli.run(['review']) }

    assert_equal "No saved readings found.\n", output
  end

  def test_review_displays_every_reading_in_timestamp_order_newest_first
    readings = [saved_reading(1, '2026-09-16T12:00:00Z'),
                saved_reading(3, '2026-09-15T12:00:00Z'),
                saved_reading(2, '2026-09-17T12:00:00Z')]
    File.write(@path, JSON.generate('readings' => readings))

    output, = capture_io { assert_equal 0, @cli.run(['review']) }

    assert_equal %w[2 1 3], output.scan(/^Reading ID: (\d+)$/).flatten
  end

  def test_review_reports_a_read_error_and_allows_more_commands
    File.write(@path, '{broken json')

    output, = capture_io { assert_equal 0, @cli.run(['review']) }
    help_output, = capture_io { assert_equal 0, @cli.run(['help']) }

    assert_match(/Could not review saved readings: .+/, output)
    assert_includes help_output, 'Usage: tarot [command]'
    assert_equal '{broken json', File.read(@path)
  end

  private

  def saved_reading(id, saved_at)
    { 'ID' => id, 'saved_at' => saved_at, 'question' => "Question #{id}",
      'cards' => ['The Fool'], 'interpretation' => 'A new beginning.' }
  end
end
