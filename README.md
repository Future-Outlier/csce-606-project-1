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

### saving a reading

Start a reading with `new`, enter a question, and use `draw` one to three times.
Then type `save` to append the reading to `readings.json` in the directory where
you launched the app and return to the main menu.

The file keeps earlier readings across app restarts. Each entry includes an integer
`ID`, an ISO 8601 UTC `saved_at` timestamp, the question, card names in draw order,
and the available interpretation (currently an empty string). See
[`docs/design.md`](docs/design.md#save-file) for the JSON format.

Saving an empty reading is rejected. If saving fails, the app reports the error and
keeps the current reading so you can continue or retry. Invalid existing history is
preserved rather than overwritten.

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
- Save readings to JSON with ordered cards, timestamps, and persistent history
- Clean exit with `exit`, `quit`, or end-of-input

## known limitations

- Load, Review, card details, and interpretation are not implemented yet.

## team member names
- Ian Beckett
- Han-Ju Chen

## AI Citations
- [Card descriptions](https://github.com/ianebeckett/csce-606-project-1/blob/draw-one-card/lib/data/cards.json) generated with Grok (xAI).
