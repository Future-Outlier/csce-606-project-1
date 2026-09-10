# frozen_string_literal: true

require 'json'

Card = Data.define(:id, :name, :description) do
  # preload all card data to minimize file I/O
  # this isn't an issue because cards.json is less than 30 kilobytes
  def self.load_from_file(file_path)
    file_contents = File.read(file_path, encoding: Encoding::UTF_8)
    data = JSON.parse(file_contents)
    cards = data['cards']
    cards.map do |card_data|
      new(
        id: card_data['id'],
        name: card_data['name'],
        description: card_data['description']
      )
    end
  end
end
