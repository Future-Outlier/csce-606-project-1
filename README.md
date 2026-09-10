# tarot-cli

## installation/setup instructions

Install Ruby 4.0.1, then install the project dependencies:

```bash
bundle install
```

## running the app

Start the interactive CLI:

```bash
bundle exec ruby bin/tarot
```

Display the usage statement without starting an interactive session:

```bash
bundle exec ruby bin/tarot --help
```

## running tests

```bash
bundle exec rake test
```

## generating coverage reports

Coverage reporting is planned for a later PR.

## list of main features

- Interactive command-line interface
- Help and usage statement
- Start a reading with a non-blank question
- Draw random cards without duplicates in the active reading
- Shuffle all cards back into the deck and return to the main menu
- Clean exit with `exit`, `quit`, or end-of-input

## known limitations

- Save, Review, card details, and interpretation are not implemented yet.

## team member names
- Ian Beckett
- Han-Ju Chen

## AI Citations
- [Card descriptions](https://github.com/ianebeckett/csce-606-project-1/blob/draw-one-card/lib/data/cards.json) generated with Grok (xAI).
