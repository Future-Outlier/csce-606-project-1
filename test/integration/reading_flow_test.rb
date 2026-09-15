# frozen_string_literal: true

# Checks CLI, QwenRunner, and ReadingStore together using real temporary save files.
require 'test_helper'
require 'stringio'
require 'tmpdir'
require 'fileutils'
require 'json'
require 'tarot_cli/cli'
require 'support/scripted_qwen_http'

class ReadingFlowTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir('tarot-reading-flow-test')
    @path = File.join(@directory, 'readings.json')
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_saves_the_latest_interpretation_and_displayed_card_order
    responses = ['First', 'Second', "  Final interpretation.\n"].map { |text| completion(text) }
    output = run_cli("new\nQuestion\ndraw\ndraw\ndraw\nsave\nhelp\nexit\n", *responses)
    reading = readings.first

    assert_equal 'Question', reading['question']
    assert_equal 3, reading['cards'].size
    assert_equal drawn_cards(output), reading['cards']
    assert_equal 'Final interpretation.', reading['interpretation']
    assert_includes output, 'Usage: tarot [command]'
  end

  def test_new_cli_instances_append_without_changing_saved_interpretations
    run_cli("new\nFirst question\ndraw\nsave\nexit\n", completion('First interpretation'))
    original = readings.first
    run_cli("new\nSecond question\ndraw\nsave\nexit\n", completion('Second interpretation'))
    first, second = readings

    assert_equal [1, 2], [first['ID'], second['ID']]
    assert_equal original, first
    assert_equal 'Second question', second['question']
    assert_equal 'Second interpretation', second['interpretation']
  end

  def test_malformed_qwen_reply_does_not_save_a_stale_interpretation
    invalid = ScriptedQwenHttp::Response.new(code: '200', body: '{broken json')
    output = run_cli("new\nQuestion\ndraw\ndraw\nsave\nexit\n", completion('Stale interpretation'), invalid)
    reading = readings.first

    assert_includes output, 'Interpretation unavailable: Local Qwen server returned an invalid response.'
    assert_equal '', reading['interpretation']
    assert_equal 2, reading['cards'].size
    assert_equal drawn_cards(output), reading['cards']
  end

  def test_chat_connection_failure_still_allows_saving_the_drawn_cards
    output = run_cli("new\nQuestion\ndraw\nsave\nexit\n", Errno::ECONNREFUSED.new)
    reading = readings.first

    assert_includes output, 'Interpretation unavailable: Could not reach the local Qwen server:'
    assert_equal '', reading['interpretation']
    assert_equal 1, reading['cards'].size
    assert_equal drawn_cards(output), reading['cards']
  end

  def test_corrupt_history_is_preserved_and_the_cli_remains_usable
    File.write(@path, '{broken json')
    output = run_cli("new\nQuestion\ndraw\nsave\nshuffle\nhelp\nexit\n", completion('An interpretation'))

    assert_includes output, 'Could not save reading:'
    refute_includes output, 'Session successfully saved'
    assert_equal '{broken json', File.read(@path)
    assert_includes output, 'Usage: tarot [command]'
  end

  private

  def run_cli(input, *responses)
    runner = TarotCLI::QwenRunner.new(http: ScriptedQwenHttp.new(*responses))
    original_stdin = $stdin
    $stdin = StringIO.new(input)
    output, = capture_io { TarotCLI::CLI.new(runner: runner, save_path: @path).run }
    output
  ensure
    $stdin = original_stdin
  end

  def completion(text)
    body = JSON.generate(choices: [{ message: { content: text } }])
    ScriptedQwenHttp::Response.new(code: '200', body: body)
  end

  def readings
    JSON.parse(File.read(@path))['readings']
  end

  def drawn_cards(output)
    output.lines.grep(/^Current Spread:/).last.scan(/\[ (.*?) \]/).flatten
  end
end
