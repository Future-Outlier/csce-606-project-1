require 'open3'
require 'rbconfig'
require 'test_helper'
require 'tarot_cli/card'
require 'tarot_cli/session'

class ViewAcceptanceTest < Minitest::Test
  CARDS = Card.load_from_file(File.expand_path('../../lib/data/cards.json', __dir__))
  EXECUTABLE = File.expand_path('../../bin/tarot', __dir__)
  FAKE_RUNNER = File.expand_path('../support/fake_qwen_runner.rb', __dir__)
  INVALID = 'Could not display art. Invalid card selection.'.freeze

  def test_executable_views_only_the_drawn_card_by_name
    names = CARDS.map { |card| "view #{card.name}\n" }.join
    output = run_executable("new\nQuestion\nview The Fool\ndraw\n#{names}view Not a card\nview\nshuffle\nexit\n")
    drawn = output[/Current Spread: \[ (.*?) \]/, 1]

    assert_equal({ drawn => 1 }, rendered_counts(output))
    assert_equal(CARDS.size + 2, output.scan(INVALID).size)
  end

  def test_view_zero_does_not_select_a_drawn_fool
    card = CARDS.find { |candidate| candidate.name == 'The Fool' }
    refute_nil card
    deck = Deck.new(cards: [card])
    assert_equal card, deck.draw_card
    session = nil
    capture_io { session = TarotCLI::Session.new('Question', deck: deck) }

    output, = capture_io { session.execute('view 0') }
    assert_equal "#{INVALID} Choose a drawn card.\n", output
  end

  def test_every_card_can_be_viewed_after_it_is_drawn
    assert_equal 78, CARDS.size
    assert_equal 78, CARDS.map(&:name).uniq.size
    CARDS.each { |card| assert_card_can_be_viewed(card) }
  end

  private

  def assert_card_can_be_viewed(card)
    refute_empty card.art, card.name
    deck = Deck.new(cards: [card])
    assert_equal card, deck.draw_card
    session = nil
    capture_io { session = TarotCLI::Session.new('Question', deck: deck) }

    output, = capture_io { session.execute("view #{card.name}") }
    assert_equal "#{expected_art(card)}\n", output, card.name
  end

  def rendered_counts(output)
    CARDS.to_h { |card| [card.name, output.scan(expected_art(card)).size] }
         .reject { |_name, count| count.zero? }
  end

  def expected_art(card)
    "#{card.name}\n#{card.art.join("\n")}"
  end

  def run_executable(input)
    output, error, status = Open3.capture3(RbConfig.ruby, '-r', FAKE_RUNNER, EXECUTABLE, stdin_data: input)
    assert status.success?, error
    output.force_encoding(Encoding::UTF_8)
  end
end
