# frozen_string_literal: true

require 'test_helper'
require 'tarot_cli/session'

class SessionShuffleTest < Minitest::Test
  def test_shuffle_clears_the_question_and_returns_to_the_main_menu
    session = nil
    capture_io { session = TarotCLI::Session.new('Old question') }
    result = nil

    output, = capture_io { result = session.execute('shuffle') }

    assert_equal :exit, result
    assert_nil session.question
    assert_includes output, 'Session cleared and deck shuffled. Returning to Main Menu...'
  end
end
