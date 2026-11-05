# Sprint 1 — A Link Between Galaxies

## Evidence and scope

Confirmed in the local repository: Godot 4.6/GDScript; a menu with Play and Quit; an inactive Load button; animated astronaut movement using arrow keys; a tile-built test world with collision shapes; E interactions that collect keys and spend them to remove locked chest tiles; sounds for success/failure. The working tree was clean before this work. Existing implementation came from the repository; this report does not attribute it to individual teammates.

The README proposes movement, wall collisions, a key, and a locked door. It explicitly calls these proposals pending TA refinement. The implemented keyed objects are chests, not a completed door progression mechanic. Its broader combat, inventory, puzzles, ship upgrades, and planet progression are future plans.

The user's Sprint 1 request calls for a working MVP covering a basic landing UI and movement between areas, plus documentation and team-managed checklist items. Their reports of Logan's and Farhan's suggestions are context, not independently verified instructor feedback. No separate storyboards, assignment documents, issue exports, task lists, or previous use case diagram were present locally. Remote issues/Wiki were not accessed or changed.

Assumptions: a tiny planet/outpost exploration loop is sufficient for a demo; the outpost layout is a placeholder until storyboards are supplied; the planet entrance uses the existing far-end stairs as requested following Logan’s feedback; no Options is preferable to a button with no setting. These are implementation choices, not team or GTA-approved decisions.

## Actual MVP

- New Game and Quit menu with the correct game title and keyboard focus.
- Existing astronaut, arrow-key movement, tile world, assets, and interaction sounds.
- Existing tile collisions plus explicit outer boundaries for both areas.
- Stair entrances: E near the far-north planet stairs visits the outpost; E near the outpost’s south stairs returns. The former landing pads have been removed.
- Visible controls, location, portal prompt, and current key count.
- Existing key pickups and locked chests. Exploration state persists while traveling between areas in one session.
- Escape or the menu button; New Game starts a fresh world with keys/chests restored.
- No save/load, Options, combat, accounts, networking, ship upgrades, or full inventory.

The outpost is authored in its own `scenes/outpost.tscn` and instanced by the main world. Both areas stay loaded, preserving the current session’s changed tiles and keys without a save system.

## Implementation summary

| Source | Responsibility |
| --- | --- |
| `project.godot` | Existing input actions/renderer retained; main scene uses an explicit resource path for first import. |
| `scenes/home_menu.tscn` | Correct title, New Game, Quit; remove inactive Load. |
| `scripts/main_menu.gd` | Focus New Game; existing scene start and quit callbacks. |
| `scenes/testworld.tscn` | Original map and player, outpost scene instance, stair entrance/return markers; one starting-room wall tile opened as a doorway. |
| `scenes/outpost.tscn` | Editable tile-built room, props, labels, stair entrance, and arrival marker. |
| `scripts/demo_world.gd` | Travel using scene markers, boundary guards, HUD, menu return. No runtime room generation. |
| `scripts/player.gd` | Preserve movement/key/chest systems; animate vertical movement and convert interaction position into decoration-local coordinates. |
| `scenes/player.tscn`, `assets/` | Reused unchanged. |

## Challenges encountered

1. The existing map has a south wall below the starting room. A first portal placement south of spawn failed the walking test. Moving the portal north into the same walkable room made it reachable without altering teammates' tile map.
2. Travel must preserve removed tiles and key count, while New Game must restore them. Keeping both areas loaded preserves exploration state; returning to the menu and loading a new scene resets it.
3. The player's animation only ran for horizontal movement. Applying the existing moving animation for either movement axis fixes the vertical case without adding assets.
4. Interaction originally supplied a global position directly to a tile map coordinate method. Explicit conversion to decoration-local space avoids incorrect targeting when that layer is transformed.
5. Godot was absent from this environment. An official 4.6 runtime was downloaded to the chat's scratch folder for validation, without adding a dependency or binary to the team repository. Sandbox restrictions prevented normal user-data log creation; an explicit scratch log path allowed headless runtime checks. A graphical launch failed, so visual/audio QA remains for the team.

## Demo walkthrough

1. Open `project.godot` with Godot 4.6, finish import, press **F5**.
2. Select **New Game**. Point out the controls and key count.
3. Walk north through the new starting-room doorway into the larger room. Head to the left alcove: face the key from below and press **E** to collect it.
4. Head to the northeast passage. Face the locked chest from below and press **E** to spend the key and open the route.
5. Follow the passage north to the existing stairs at the far end. When the prompt appears, press **E** to enter the outpost.
6. Explore the outpost, then approach its south-end stairs and press **E** to return. Arrival points are outside the interaction radius to avoid immediate retriggering.
7. Press **Esc**, or click **Menu · Esc**. Select **New Game** again to show a fresh session.

## Simple demo checklist

Run with F5: menu → New Game → movement → key pickup → unlock the passage → far-end stairs → outpost → south stairs back → Esc → New Game. Check that the player remains visible, the floor renders, walls block movement, and New Game restores the key/chest.

During implementation, headless checks passed the walking route, key/chest progression, both stair transitions, arrival spacing, room scene instancing/draw order, bounds, and session reset. The automated suite was then removed at the user's request to keep this school project small. There are no testing dependencies. A hands-on visual/audio walkthrough remains necessary; those checks did not establish visual quality or audible playback.

## Proposed revised use case diagram

No prior diagram was available, so this is a proposed Sprint 1 replacement, not a verified revision of a supplied diagram. Mermaid renders this as an approximation of actor/use-case notation.

```mermaid
flowchart LR
    Player[Player]
    subgraph MVP["Sprint 1 game"]
        Start([Start new game])
        Explore([Explore and move])
        Travel([Travel between planet and outpost])
        Key([Collect key])
        Chest([Unlock chest with key])
        Menu([Return to menu])
        Quit([Quit game])
    end
    Player --- Start
    Player --- Explore
    Player --- Travel
    Player --- Key
    Player --- Chest
    Player --- Menu
    Player --- Quit
```

Proposed changes relative to the README's initial stories: add menu/session navigation and two-area travel; retain exploration and key collection; describe the actual keyed chest instead of claiming a working locked door. Boundaries are an exploration constraint, not a separate player goal. Omit combat, saves, ship upgrades, and other future use cases. The team should compare this with the official diagram before adopting it.

## Proposed next-sprint backlog

Unassigned proposals; no invented issue numbers or commitments:

- Reconcile actual Sprint 1 acceptance criteria and area layout with GTA feedback and storyboards.
- Add one small key-gated door or exit with a visible objective and completion cue, if approved.
- Improve interaction targeting/prompts and distinguish key/chest artwork for a first-time player.
- Refine camera framing, room boundaries, and UI after hands-on playtesting on team machines.
- Only then select one small puzzle or basic enemy for the next vertical slice; defer large progression systems.

## Team still needs to supply or update

- Official assignment checklist, stories/tasks, storyboards, and original use case diagram; confirm the MVP against them.
- Actual GTA/professor feedback and any resulting requirement changes. None has been invented here.
- Sprint leadership, issue ownership, contributions, estimates, timeline, and status updates using real team decisions.
- Link this work to actual issues, review changes, and perform a graphical demo on a team machine.
- Confirm asset provenance/license obligations for the assets already in the repository.
- Commit/push reviewed source and publish the Wiki draft through the team's normal workflow. At initial handoff, changes were local. The user subsequently authorized committing and pushing the implementation; remote issue changes and Wiki publishing remain outside this work.

## Editor compatibility follow-up

The bundled `addons/github-integration` plugin contains Godot 3 editor scripts and visual-shader resources. Its `graph_offset` deprecation and invalid shader output-port errors originate in those legacy resources. A `.gdignore` excludes that unused editor-only folder from Godot 4 scanning while preserving its files. The game does not reference the plugin. Restart the editor after this change; use the team’s usual Git client for repository operations.

## Visual polish follow-up

Replaced the temporary diamond markers with the existing purple platform artwork, presented as transfer landing pads. The planet pad remains north of spawn on the original walkable floor. The outpost now has metal floor panels, collidable storage lockers/supply props placed away from the central walking route, and small area labels. A nearby prompt reads “Press E to enter outpost” or “Press E to return to planet” and hides when out of reach. A compact top-left location/key/menu bar and bottom-left movement/interaction hint replace the large instruction stack. Both directions of travel, original key/chest behavior, boundaries, and session reset remain unchanged. These decorations add no new inventory, mission, or supply interactions.

## Scene and stair follow-up

Following Logan’s feedback as relayed by the user, moved the outpost’s room tiles, props, labels, stairs, and spawn marker into an editable `outpost.tscn`. Removed runtime room generation and both landing pads. Planet travel now uses the original stair tile at Terrain cell (26, 15); return spawns just south of it. Outpost travel uses its south stair, with arrival farther inside the room.

Checking the full walking route revealed that the original starting pocket was sealed. Removed only Decoration cell (23, 30) to create a one-tile doorway; the rest of the authored map, key pickups, and locked chests remain intact. Reaching the far-end stairs uses the existing key/chest progression. The earlier polish notes describe a previous iteration; the current demo uses stairs and an authored scene.

## Space background follow-up

Changed the outpost floor to the quieter existing metal panel tile (7, 1). Added an editor-visible, non-colliding Space tile layer behind the room using sparse stars from the existing tileset. The project background is now dark navy rather than gray, matching the space artwork even outside the star layer. Room layout, collisions, stairs, props, and travel behavior are unchanged. No assets, dependencies, or automated tests were added.
