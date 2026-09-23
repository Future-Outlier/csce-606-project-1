# frozen_string_literal: true

require 'json'

Card = Data.define(:name, :description, :art) do
  def initialize(name:, description:, art: [])
    super
  end

  def ascii_art
    "#{name}\n#{art.join("\n")}"
  end

  def self.load_from_file(file_path)
    cards = JSON.parse(File.read(file_path, encoding: Encoding::UTF_8)).fetch('cards')
    cards.map do |card_data|
      new(
        name: card_data['name'],
        description: card_data['description'],
        art: card_data.fetch('art')
      )
    end
  end
end
