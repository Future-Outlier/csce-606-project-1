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

  def test_rejects_invalid_history_containers
    ['null', '[]', '{}', '{"readings": null}', '{"readings": {}}', '{"readings": [null]}'].each do |contents|
      assert_rejected_history(contents)
    end
  end

  def test_rejects_invalid_record_fields
    save_reading
    reading = JSON.parse(File.read(@path))['readings'].first
    invalid_fields = { 'ID' => '1', 'saved_at' => nil, 'question' => nil,
                       'cards' => [123], 'interpretation' => nil }
    invalid_fields.each do |key, value|
      assert_rejected_history(JSON.generate('readings' => [reading.merge(key => value)]))
    end
  end

  def test_rejects_duplicate_ids
    save_reading
    reading = JSON.parse(File.read(@path))['readings'].first

    assert_rejected_history(JSON.generate('readings' => [reading, reading]))
  end

  def test_reports_an_unwritable_destination
    store = TarotCLI::ReadingStore.new(path: File.join(@directory, 'missing', 'readings.json'))

    assert_raises(TarotCLI::ReadingStore::Error) { store.save(question: 'Question', cards: ['The Fool']) }
    assert_empty Dir.children(@directory)
  end

  def test_reports_a_directory_used_as_a_file
    Dir.mkdir(@path)

    assert_raises(TarotCLI::ReadingStore::Error) { save_reading }
    assert File.directory?(@path)
  end

  def test_failed_serialization_preserves_history_and_removes_the_temporary_file
    save_reading
    original = File.binread(@path)

    assert_raises(TarotCLI::ReadingStore::Error) do
      @store.save(question: "\xFF".dup.force_encoding(Encoding::UTF_8), cards: ['The World'])
    end
    assert_equal original, File.binread(@path)
    assert_equal ['readings.json'], Dir.children(@directory)
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
