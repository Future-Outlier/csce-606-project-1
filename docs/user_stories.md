happy paths:

As a user I want to be shown usage instructions so I can effectively use the application.
Given the user is navigating the application,
When they type the help command (e.g., help or -h),
Then the terminal must display a clear list of available commands and how to use them.

As a user I want to draw up to three random, unique cards so that I can do a tarot reading.
Given the deck is shuffled and no cards have been drawn yet,
When the user executes the draw command,
Then the system must randomly select a card from the deck,
And all cards must be unique,
And the terminal must display the names of the 3 cards.

As a user I want to reset my drawn cards and shuffle the deck so I can do another reading.
Given the user has already drawn cards,
When the user executes the reset/shuffle command,
Then the active drawn cards must be cleared from the screen,
And all 78 cards must be returned to the deck pool and randomized.

As a repeat user I want to review my saved readings so that I can ponder their meanings.
Given the user has previously saved readings in the system,
When they execute the history/review command,
Then the terminal must display a chronological list of all past readings,
showing which cards were drawn in each session.

As a repeat user I want to see the date/time of my saved readings so that I can
reflect on my history of readings.
Given the user is viewing their saved readings history,
Then each entry must explicitly display the date and time (e.g., YYYY-MM-DD HH:MM) of
when that specific reading was saved.

As a user I want to view ASCII art of the cards so that I can visualize them.
Given a card has been drawn or selected,
When the user requests to see the art for that card,
Then the terminal must render the visual representation (e.g., ASCII art or a
text-based layout wrapper) associated with that specific card.

As a user I want to read detailed descriptions of the cards so that I can
consider their meanings. Given a card has been drawn or selected,
When the user requests the details/meaning of that card,
Then the terminal must print a comprehensive text description of its
traditional tarot interpretation.

sad paths:

As a user I want to be prevented from saving empty readings so I can
keep my record tidy.
Given the user has initialized the app but has not drawn any cards yet,
When they attempt to execute the save command,
Then the systemc must block the save action,
And display an error message stating e.g., "Cannot save an empty reading. Please
draw cards first."

As a user I want to be notified if I try to review but there are no readings so
I can be confident that the system is working as intended.
Given the user has never saved a reading (or the history file is empty),
When they execute the history/review command,
Then the system must display an informational message stating e.g., "No saved
readings found."


As a user I want to be notified if I try to view the art of an invalid card so
I can correct my input.
When the user requests the art for an invalid card identifier,
Then the system must reject the input,
And display an error message stating: "Could not display art. Invalid card selection."

As a user I want to be notified if I try to view details of an invalid card so
I can correct my input.
When the user requests details for a card index or name that does not exist in
the deck (e.g., entering 99 or typing The King of Potatoes),
Then the system must reject the input,
And display an error message stating e.g., "Invalid card selection. Please
select a valid card."

