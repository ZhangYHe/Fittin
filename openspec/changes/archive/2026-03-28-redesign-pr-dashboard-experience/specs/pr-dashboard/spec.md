## MODIFIED Requirements

### Requirement: At-a-Glance Strength Cards
The dashboard MUST feature three aligned summary cards for Squat, Bench, and Deadlift, and those cards MUST keep a consistent size and layout regardless of whether a lift currently has a delta to display.

#### Scenario: A lift has no previous comparable record
- **WHEN** the user opens the PR Dashboard and one or more primary lifts has no prior record that can be used to calculate a delta
- **THEN** the Squat, Bench, and Deadlift cards still render with matching dimensions
- **AND** the missing delta state does not cause the card grid to collapse or resize unevenly.

#### Scenario: User switches summary metric mode
- **WHEN** the user taps the shared summary toggle on the PR Dashboard
- **THEN** all three primary-lift cards switch together between estimated 1RM and actual PR
- **AND** the selected mode is visually obvious and applied consistently across the full card row.

### Requirement: Progression Visualization
The system MUST provide a focused progression chart that visualizes one selected primary lift at a time instead of merging all primary lifts into one low-context graph.

#### Scenario: User switches the displayed lift
- **WHEN** the user changes the selected lift in the chart controls
- **THEN** the chart updates to show only the chosen lift's progression data
- **AND** the chart preserves explicit x-axis and y-axis labels so the time span and weight scale are readable.

### Requirement: Milestone Preview and History
The PR Dashboard MUST keep its landing-page milestone list concise and provide a dedicated destination for the full milestone history.

#### Scenario: User views the PR dashboard landing page
- **WHEN** the PR Dashboard loads milestone data
- **THEN** the main page shows only the two most recent milestone entries
- **AND** it provides a visible affordance for navigating to the complete milestone history screen.

#### Scenario: User filters full milestone history
- **WHEN** the user opens the milestone history screen
- **THEN** they can filter milestone entries by lift or exercise, by time range, and by PR type
- **AND** the resulting list updates to reflect the selected filters.

### Requirement: Localized PR Dashboard Experience
The PR Dashboard and milestone history flow MUST render using the app's active language setting.

#### Scenario: User views PR dashboard in Chinese
- **WHEN** the app language is set to Chinese
- **THEN** the PR Dashboard header, metric toggle labels, chart labels, milestone copy, filter labels, and empty states are shown in Chinese.
