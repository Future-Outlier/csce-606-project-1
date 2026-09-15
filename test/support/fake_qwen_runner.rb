# frozen_string_literal: true

# Preloaded only in executable tests so drawing cards never needs a model server.
require_relative '../../lib/tarot_cli/qwen_runner'

module FakeQwenRunner
  def interpret(question:, cards:)
    "Test interpretation for #{question}: #{cards.map(&:name).join(', ')}"
  end
end

TarotCLI::QwenRunner.prepend(FakeQwenRunner)
