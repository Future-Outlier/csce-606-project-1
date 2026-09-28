# Sep 28. End-of-Project Retrospective

## What went well

1. Feature branches, pull requests, and CI kept our work incremental and easier to review.
2. We completed the full tarot workflow, including Draw, Shuffle, Save, Review, Load, local Qwen interpretation, View, and Describe.

## What was difficult

1. AI-generated tests often repeated the same behavior, which made the test suite larger and harder to maintain.
2. UX details were difficult to predict from requirements alone. Blank input, command feedback, and menu transitions became clear only after we used the complete product ourselves.

## What the pair would improve next time

1. We would require every AI-generated test to protect a distinct behavior and proactively delete or merge redundant tests.
2. We would run complete usability walkthroughs earlier and after each feature because human use revealed improvements that code and automated tests missed.

## Whether the final app met the original goal

1. Yes. Users can draw cards, shuffle the deck, and save and review their readings from the terminal.
2. The final app also supports Load, local Qwen interpretations, card descriptions, and ASCII art beyond the original core workflow.

# Sep 14. Midterm retro

## What went well
1. the timeline is good
2. use feature branch

## What was difficult
1. asynchronous communication feedback is slow

## What the pair would improve next time
1. Han-Ju uses LLM right now, Ian is trying to use it in the future to improve the speed

## Whether the final app met the original goal
1. so far yes
