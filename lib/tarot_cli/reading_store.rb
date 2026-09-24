# frozen_string_literal: true

# Keeps saved readings on disk without replacing history with a partial write.
require 'json'
require 'tempfile'
require 'time'

module TarotCLI
  class ReadingStore
    DEFAULT_PATH = 'readings.json'
    class Error < StandardError; end

    # Tests can use a separate file so they never change the user's history.
    def initialize(path: DEFAULT_PATH)
      @path = File.expand_path(path)
    end

    # Each save adds a new snapshot, even when earlier readings were saved by another run.
    def save(question:, cards:, interpretation: nil)
      data = read_history
      data['readings'] << build_reading(data['readings'], question, cards, interpretation)
      write_history(data)
    rescue SystemCallError, IOError, JSON::JSONError => e
      raise Error, e.message
    end

    # Select by stable ID so display order never changes which reading is loaded.
    def load(id)
      readings.find { |reading| reading['ID'] == id } || raise(Error, 'Saved reading not found.')
    end

    # Return saved readings in their original save order for the review command.
    def readings
      read_history['readings']
    rescue SystemCallError, IOError, JSON::JSONError => e
      raise Error, e.message
    end

    private

    # Card names stay in draw order, and unavailable interpretation is an empty string.
    def build_reading(readings, question, cards, interpretation)
      {
        'ID' => (readings.map { |reading| reading['ID'] }.max || 0) + 1,
        'saved_at' => Time.now.utc.iso8601,
        'question' => question,
        'cards' => cards,
        'interpretation' => interpretation.to_s
      }
    end

    # Only a missing file starts a new history; damaged files must be preserved.
    def read_history
      data = JSON.parse(File.read(@path, encoding: Encoding::UTF_8))
      raise Error, 'Saved readings file has an invalid format.' unless valid_history?(data)

      data
    rescue Errno::ENOENT
      { 'readings' => [] }
    end

    # Existing IDs must be unique so future saves can be identified reliably.
    def valid_history?(data)
      return false unless data.is_a?(Hash) && data['readings'].is_a?(Array)

      readings = data['readings']
      return false unless readings.all? { |reading| valid_reading?(reading) }

      ids = readings.map { |reading| reading['ID'] }
      ids.uniq.size == ids.size
    end

    # Check the design's field types before adding anything to an existing file.
    def valid_reading?(reading)
      return false unless reading.is_a?(Hash)
      return false unless reading['ID'].is_a?(Integer) && reading['ID'].positive?
      return false unless valid_metadata?(reading)

      reading['cards'].is_a?(Array) && reading['cards'].all?(String)
    end

    # Validate the fields that Review displays or uses for timestamp sorting.
    def valid_metadata?(reading)
      text_fields_valid = %w[saved_at question interpretation].all? do |key|
        reading[key].is_a?(String)
      end
      text_fields_valid && valid_saved_at?(reading['saved_at'])
    end

    # Reject timestamps that Review cannot reliably compare chronologically.
    def valid_saved_at?(saved_at)
      Time.iso8601(saved_at)
      true
    rescue ArgumentError
      false
    end

    # Write beside the destination so renaming publishes the complete file in one step.
    def write_history(data)
      Tempfile.create(['.readings-', '.json'], File.dirname(@path), encoding: Encoding::UTF_8) do |file|
        file.write(JSON.pretty_generate(data))
        file.flush
        file.fsync
        file.close
        File.rename(file.path, @path)
      end
    end
  end
end
