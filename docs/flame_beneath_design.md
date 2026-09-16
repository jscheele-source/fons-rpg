# The Flame Beneath — quest implementation brief

Status: **in development**. The first release implements Flame Projection and a one-character visual prototype. The quest below is an agreed design, **not yet playable**. Do not mark quest complete or advertise the secret chamber until all three resolutions work in the browser.

## Premise

A Flamen in the barracks is nervous when questioned. Persistent or sympathetic dialogue yields fragments about a private meeting, a "second flame", and a room hidden from the fountain's light. Archivist Sel and the historical collection can identify allusions to the Duvian Schism; following the physical clues reveals an old passage and a small concealed sanctuary.

An initiate **voluntarily offered some charge** to a group who promised shared healing and strength. Only once the player reaches the ritual does the initiate learn that the participants intend to drain their entire flame, killing them. The player can intervene before the sacrifice, and the other conspirators do not all have equal knowledge or commitment.

## Gameplay beats

1. Barracks: notice anomalous behavior, question or follow the nervous Flamen. Dialogue tone may affect whether the group is warned.
2. Archive: optional records explain cryptic clues, Vesper practices and a former purging of the order. Avoid making book-reading the only viable path.
3. Concealed passage: use clues and exploration to find a spatially separate, contained ritual room. Include safe travel in both directions and a route back to the stable courtyard. No garden/world rework.
4. Discovery: volunteer learns the ritual is a sacrifice. The player may rescue the initiate or listen to the Vespers. Danger is established by actions and dialogue, not an omniscient exposition pop-up.
5. Resolution: (a) interrupt/fight, including surrender or rescue; (b) willingly join, accepting severe ethical and relationship consequences; (c) collect direct evidence and report to Varro so authority expels the group. Someone who initially joined may later betray them.

## Flame Projection — first slice

Unlocked by Davian after The Measure of Fire. Q launches a visible, single-mesh projectile. Each cast costs **35% of maximum charge**, with a short cooldown and range. The same pool is used for healing. Missed shots still consume charge. Later: Vesper life-siphoning is a distinct, consequential choice, not a free improvement to regeneration.

## Acceptance criteria for later quest milestones

- Each path is playable, saved, restored, and leaves an exit; insufficient charge cannot soft-lock a player.
- Optional clues change dialogue; players can reach the secret via an alternative route.
- Combat only flags unlawful assault when the target is a non-hostile bystander, not an attacking Vesper.
- All quest endings modify world state and at least one continuing relationship.
- Keep pre-quest M2 scene, all original colliders, and original spawn unchanged. Test a full walkable route; deploy one small map change at a time.
- Verify actual browser rendering with the player after every visual pass, not merely headless smoke tests.
