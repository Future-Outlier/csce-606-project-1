# frozen_string_literal: true

# Verifies saved JSON records and history that survives new store instances.
require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'tarot_cli/reading_store'

class ReadingStoreTest < Minitest::Test
  def setup
    @directory = Dir.mktmpdir('tarot-save-test')
    @path = File.join(@directory, 'readings.json')
    @store = TarotCLI::ReadingStore.new(path: @path)
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_creates_a_file_with_the_designs_exact_fields_and_utf8_text
    question = "What about \"tomorrow\"?\n明天呢？"
    interpretation = "A fresh start.\nTrust yourself — slowly."
    @store.save(question: question, cards: ['The Tower', 'The World'], interpretation: interpretation)

    data = JSON.parse(File.read(@path, encoding: Encoding::UTF_8))
    assert_equal ['readings'], data.keys
    assert_equal 1, data['readings'].size
    assert_equal({ 'ID' => 1, 'saved_at' => data['readings'][0]['saved_at'], 'question' => question,
                   'cards' => ['The Tower', 'The World'], 'interpretation' => interpretation }, data['readings'][0])
  end

  def test_records_the_save_time_as_an_iso8601_string
    before_save = Time.now.to_i
    @store.save(question: 'Question', cards: ['The Fool'])
    saved_at = readings.first['saved_at']

    assert_kind_of String, saved_at
    assert_match(/Z\z/, saved_at)
    assert_operator Time.iso8601(saved_at).to_i, :>=, before_save
    assert_operator Time.iso8601(saved_at).to_i, :<=, Time.now.to_i
  end

  def test_unavailable_interpretation_is_an_empty_string
    @store.save(question: 'Question', cards: ['The Fool'])

    assert_equal '', readings.first['interpretation']
  end

  def test_appends_to_existing_history_after_a_restart
    @store.save(question: 'First question', cards: ['The Fool'])
    first_reading = readings.first
    restarted_store = TarotCLI::ReadingStore.new(path: @path)
    restarted_store.save(question: 'Second question', cards: ['The World'])

    assert_equal([1, 2], readings.map { |reading| reading['ID'] })
    assert_equal first_reading, readings.first
    assert_equal 'Second question', readings.last['question']
  end

  def test_uses_the_highest_existing_id_even_with_gaps_and_reordered_history
    @store.save(question: 'Earlier question', cards: ['The Fool'])
    earlier = readings.first
    File.write(@path, JSON.generate('readings' => [earlier.merge('ID' => 9), earlier.merge('ID' => 3)]))
    @store.save(question: 'New question', cards: ['The World'])

    assert_equal([9, 3, 10], readings.map { |reading| reading['ID'] })
  end

  def test_accepts_an_existing_empty_history
    File.write(@path, '{"readings": []}')
    @store.save(question: 'Question', cards: ['The Fool'])

    assert_equal 1, readings.first['ID']
  end

  private

  def readings
    JSON.parse(File.read(@path))['readings']
  end
end
