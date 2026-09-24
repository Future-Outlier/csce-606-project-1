# frozen_string_literal: true

# Checks that invalid history and failed writes do not destroy existing saves.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'tarot_cli/reading_store'

class ReadingStoreFailureTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir('tarot-save-failure-test')
    @path = File.join(@directory, 'readings.json')
    @store = TarotCLI::ReadingStore.new(path: @path)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_rejects_blank_or_malformed_json_without_overwriting_it
    ['', " \n", '{broken json'].each do |contents|
      assert_rejected_history(contents)
    end
  end

  def test_review_rejects_invalid_timestamp_without_changing_history
    save_reading
    data = JSON.parse(File.read(@path))
    data['readings'].first['saved_at'] = 'not-a-timestamp'
    contents = JSON.generate(data)
    File.write(@path, contents)

    assert_raises(TarotCLI::ReadingStore::Error) { @store.readings }
    assert_equal contents, File.read(@path)
  end

  def test_reports_an_unwritable_destination
    store = TarotCLI::ReadingStore.new(path: File.join(@directory, 'missing', 'readings.json'))

    assert_raises(TarotCLI::ReadingStore::Error) { store.save(question: 'Question', cards: ['The Fool']) }
    assert_empty Dir.children(@directory)
  end

  private

  def save_reading
    @store.save(question: 'Question', cards: ['The Fool'])
  end

  def assert_rejected_history(contents)
    File.write(@path, contents)
    assert_raises(TarotCLI::ReadingStore::Error) { save_reading }
    assert_equal contents, File.read(@path)
  end
end
