# A Link Between Galaxies

## Project Overview

A Link Between Galaxies is a space adventure game inspired by the exploration and dungeon progression of Zelda. Our team is developing a space adventure game inspired by the exploration and dungeon progression of Zelda. Players travel between planets in a spaceship, explore small areas, collect items, and complete dungeons containing enemies and puzzles.

Completing a planet rewards the player with a ship upgrade that unlocks access to the next destination. We plan to keep the scope manageable, with a limited number of planets and simple combat and puzzle mechanics.

## Team Members

- [Logan Mann] — @[LogMann27]
- [Emmie Tran] — @[pinkellie1]
- [Sully Deghdegh] — @[SullivanSWE]
- [Samay Naveen] — @[samaynaveen0414]
- [Farhan Sikandar] — @[Fsikand2]

## Planned Features

- Player movement and interaction with the environment
- Planet exploration and dungeon areas
- Basic combat and player health
- Item collection and inventory
- Simple puzzles and locked doors
- Ship upgrades that unlock new planets
- Tracking of completed planets and unlocked destinations

These features describe our current plan. The final scope may change based on team progress and instructor feedback.

## Gameplay Loop

1. Travel to an available planet.
2. Explore the area and collect useful items.
3. Complete the planet’s dungeon and its challenges.
4. Earn a ship upgrade.
5. Unlock and travel to the next planet.

## Development Platform

Godot 4.6 with GDScript, 2D TileMapLayer levels, and the existing Forward Plus renderer.

## Current Progress

- Completed Project Deliverable 00.
- Created the shared GitHub repository.
- Sent collaborator invitations to most team members.
- Preparing initial user stories and tasks for the TA pre-game meeting.

## Proposed First Two-Week Goal

Build a small playable prototype where the player can move around a test area, collect a key, and unlock a door.

### Proposed Tasks

- Select a game engine and confirm that all members can run the starter project.
- Create one small test area.
- Implement player movement and wall collisions.
- Implement key collection and track whether the player has the key.
- Create a locked door that opens only after the key is collected.
- Test the features together and document any problems.

### Initial User Stories

- As a player, I want to move around the environment so that I can explore a planet.
- As a player, I want walls to block my movement so that I stay within the playable area.
- As a player, I want to collect a key so that I can access a locked area.
- As a player, I want a locked door to open when I have the key so that I can progress.

These tasks and user stories are proposals to refine with our TA during the pre-game meeting.

## Team Workflow

- Track features, bugs, and development tasks using GitHub issues.
- Break larger tasks into smaller sub-issues when needed.
- Assign each task to a team member.
- Use separate branches for individual features or fixes.
- Submit pull requests for teammates to review before merging into `main`.
- Record instructor and TA feedback as comments on the relevant issues.
- Keep this README updated as the project develops.

## Running the Project

1. Open `project.godot` in Godot 4.6 and allow asset import to finish.
2. Press F6 only to test an individual scene; press **F5** for the complete menu flow.
3. Select **New Game**. Move with the arrow keys; press **E** to interact.
4. Walk north from spawn toward the cyan diamond and press E to visit the outpost. Walk south to its diamond and press E to return.
5. Press **Esc** or click **Return to Menu**, then start again for a fresh session.

No additional packages are required. Options and save/load are outside this MVP.
See `docs/Sprint-1-Wiki.md` for scope, verification, and team follow-ups.

To run the regression smoke check after importing assets:

```sh
godot --headless --path . --script res://tests/sprint1_smoke.gd
```

The initial progress and two-week goal above are historical proposals, not a completion report. The implemented Sprint 1 status is documented in the Wiki draft.

## Credits
PetriCake Games for the tile map set, https://petricakegames.itch.io/cosmic-lilac

## Course

CS321 — Software Engineering  
Fall 2026
