# Fons: New Ways Prototype

A foundational first-person 3D science-fantasy RPG prototype built for **Godot 4.3**. It is intentionally made from Godot primitive geometry so we can iterate on gameplay before committing to final art.

## Play the newest browser build

Once GitHub Pages is enabled for the `gh-pages` branch, the permanent play URL is:

**https://jscheele-source.github.io/fons-rpg/**

Every push to `main` automatically rebuilds the Godot Web export and republishes that same URL.

## What is already implemented

- First-person 3D movement, sprinting, jumping, mouse look
- Raycast interaction system
- NPC dialogue with selectable responses
- Quest journal and objective tracking
- Branching Flamen / Piri Riis quest resolution
- Faction reputation
- Inventory and credits
- Attributes and use-based skills
- Melee combat foundation
- Flamen Charge / inner flame resource
- Meditation and Flamecraft
- Lore terminals
- Diegetic shuttle-marker travel
- Save/load (`F5` / `F9`)
- Iustitia Outer Courtyard + abandoned research annex test cell

## Controls

| Input | Action |
|---|---|
| WASD | Move |
| Mouse | Look |
| Shift | Sprint |
| Space | Jump |
| E | Interact |
| Left Mouse | Attack |
| F | Kindle inner flame / heal |
| M | Meditate / restore Charge |
| J | Journal / character sheet |
| F5 | Save |
| F9 | Load |
| Esc | Close UI / release mouse |

## Prototype quest

Talk to **Brother Cael** in the courtyard and ask for work. He sends you to the abandoned research annex for the **Pneuma Resonator Core**. Once you recover it, you can return it to Cael or give it to **Sera Nemm**, a Piri Riis researcher. The decision changes faction reputation and quest resolution.

## Design principle

The goal is not to clone Morrowind's content. The foundation borrows the older immersive-RPG ideas that matter: player freedom, use-based skills, diegetic travel, faction reputation, readable lore, restrained level scaling, and quests built around credible competing interpretations.
