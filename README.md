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
- Clean exit with `exit`, `quit`, or end-of-input

## known limitations

- Tarot reading commands are not implemented yet.

## team member names
- Ian Beckett
- Han-Ju Chen
