# User Stories

Help remains usage guidance, not one of these eight graded stories.

## Essential

### 1. Draw one card per command (#13)

As a user, I want each `draw` to draw one card so that I can build a reading.

**Acceptance Criteria**

- Each `draw` displays and removes exactly one valid card; cards do not repeat before Shuffle.
- A fourth draw is rejected until Shuffle.

### 2. Shuffle and start a new reading (#14)

As a user, I want to Shuffle all cards so that I can start a new reading.

**Acceptance Criteria**

- Shuffle returns all 78 cards, randomizes the deck, and clears the cards, question, and interpretation.
- The next draw requires a new question.

### 3. Save a reading (#15)

As a user, I want to save a reading so that I can review it later.

**Acceptance Criteria**

- After at least one draw, Save preserves the question, card order, timestamp, and available interpretation across restarts.
- Write failures display a clear error without crashing.

### 4. Review saved readings (#17)

As a returning user, I want to review saved readings so that I can revisit prior results.

**Acceptance Criteria**

- Review lists readings in save order with their question, cards, timestamp, and available interpretation.
- An empty history or malformed file displays a clear message without crashing.

### 5. Ask a question and receive an interpretation (#18)

As a user, I want an interpretation based on my question and three cards so that the reading addresses my intent.

**Acceptance Criteria**

- A non-blank question is required before drawing.
- After the third draw, the local Qwen runner receives the question and ordered cards once, and its interpretation is displayed.
- Runner failures display a clear error without crashing.

## Essential Sad Path

### 6. Prevent saving an empty reading (#16)

As a user, I want empty readings rejected so that invalid records are not saved.

**Acceptance Criteria**

- Save with no drawn cards displays an error and does not create or modify saved-reading data.

## Optional

### 7. Describe a card (#23)

As a user, I want to view a card's meaning so that I can understand it.

**Acceptance Criteria**

- A valid card displays the correct description; an invalid identifier displays a clear error.

### 8. View card ASCII art (#24)

As a user, I want to view a card's ASCII art so that I can visualize it in the terminal.

**Acceptance Criteria**

- A valid card displays the correct ASCII art; an invalid identifier displays a clear error.
