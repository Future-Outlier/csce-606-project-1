require 'open3'
require 'rbconfig'
require 'test_helper'
require 'tarot_cli/card'

class ViewAcceptanceTest < Minitest::Test
  CARDS = Card.load_from_file(File.expand_path('../../lib/data/cards.json', __dir__))
  EXECUTABLE = File.expand_path('../../bin/tarot', __dir__)
  FAKE_RUNNER = File.expand_path('../support/fake_qwen_runner.rb', __dir__)
  INVALID = 'Could not display art. Invalid card selection.'.freeze

  def test_executable_views_only_the_drawn_card_by_name_or_id
    output = run_executable("new\nQuestion\nview 0\ndraw\n#{view_commands}view 99\nview\nshuffle\nexit\n")
    drawn = output[/Current Spread: \[ (.*?) \]/, 1]

    assert_equal({ drawn => 2 }, rendered_counts(output))
    assert_equal((CARDS.size * 2) + 1, output.scan(INVALID).size)
  end

  private

  def view_commands
    CARDS.flat_map { |card| ["view #{card.name}\n", "view #{card.id}\n"] }.join
  end

  def rendered_counts(output)
    CARDS.to_h { |card| [card.name, output.scan(expected_art(card)).size] }
         .reject { |_name, count| count.zero? }
  end

  def expected_art(card)
    "#{card.name} (##{card.id})\n#{card.art.join("\n")}"
  end

  def run_executable(input)
    output, error, status = Open3.capture3(RbConfig.ruby, '-r', FAKE_RUNNER, EXECUTABLE, stdin_data: input)
    assert status.success?, error
    output.force_encoding(Encoding::UTF_8)
  end
end
