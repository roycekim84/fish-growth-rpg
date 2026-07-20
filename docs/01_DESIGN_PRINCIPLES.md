# Design Principles

> Every feature must pass through these principles.

## Document Status

- Version: 1.0
- Status: Active
- Role: Provides design rules for features, systems, content, and implementation decisions

## Purpose

This document defines the design philosophy of Fish Adventure RPG.

When a new system is proposed or an existing system is changed, these principles take priority over convenience, feature quantity, or short-term implementation speed.

Implementation follows direction. Direction does not follow implementation.

## 1. Exploration First

Exploration is the center of the game.

The player does not explore merely to become stronger. The player grows stronger so that more of the world becomes explorable.

Before adding a feature, ask:

- Does it reveal a new place, route, creature, interaction, or possibility?
- Does it make the player curious about the world?
- Does it help the player reach something that was previously inaccessible?

If the answer is no, the feature must justify why it belongs in the game.

## 2. Discovery Is a Primary Reward

Rewards are not limited to currency, experience, or items.

A new place, species, ability, story, route, behavior, secret, or environmental interaction can be a major reward.

The game should create moments where the player thinks:

> I did not know this existed.

Numerical rewards may support discovery, but should not replace it.

## 3. Every Species Must Change Gameplay

A new species should create a meaningful difference in play.

Preferred differences include:

- New traversal abilities
- New environmental interactions
- New combat styles
- New social or quest interactions
- New strengths, weaknesses, and tactical choices
- Access to routes or regions unavailable to other species

A species should not exist only because it has higher numbers.

Bad distinction:

```text
Attack +10
Health +20
Speed +3%
```

Better distinction:

```text
Climbs waterfalls
Passes through narrow caves
Glides over hazards
Activates electrical devices
Survives toxic water
Breaks fragile barriers
```

Stat differences are allowed, but they should support identity rather than replace it.

## 4. Discovery Over Grinding

Progress should not depend on repeating one low-value action an excessive number of times.

Avoid objectives such as:

- Eat the same fish 100 times
- Repeat the same stage only to increase a counter
- Wait without making meaningful decisions
- Farm a resource with no variation or discovery

Repetition is acceptable when the situation, route, strategy, risk, or reward changes enough to remain engaging.

## 5. Respect Player Time

The game should not create friction solely to increase playtime.

Minimize:

- Unnecessary waiting
- Repeated confirmations
- Long travel through already-solved spaces without purpose
- Excessive resource farming
- Punishment that erases large amounts of progress
- Interfaces that hide the next meaningful objective

A player returning after a break should quickly understand what they can explore next.

## 6. Horizontal Progression Remains Important

Levels provide vertical progression. Species and abilities provide horizontal progression.

Vertical progression includes:

- Health
- Damage
- Defense
- Efficiency
- Mastery

Horizontal progression includes:

- Species
- Traversal abilities
- Environmental interactions
- Alternate routes
- Quest options
- New play styles

The game must not allow vertical progression to make horizontal progression irrelevant.

## 7. Obstacles Should Create Curiosity

A blocked path should feel like a future promise, not an arbitrary denial.

Good traversal gates:

- A visible waterfall that suggests a climbing species
- A narrow cave that suggests a flexible body
- A strong current that requires greater swimming capability
- A powered ruin that reacts to electricity
- A dangerous trench that requires pressure resistance

The player should understand that the obstacle can eventually be overcome, even when the solution is not immediately known.

## 8. The World Comes Before the Menu

The player should experience systems through the world whenever practical.

Prefer:

- Discovering a species in its habitat
- Receiving quests from characters in the environment
- Seeing inaccessible routes before unlocking them
- Learning behavior through play and observation

Avoid turning every activity into a disconnected menu, checklist, or notification panel.

UI should clarify the world, not replace it.

## 9. Systems Must Connect

New systems should strengthen existing systems rather than operate as isolated feature islands.

Examples:

- Species unlocks connect quests, exploration, and traversal
- Bosses protect regions, abilities, or story progression
- The encyclopedia records discovery and hints at unexplored habitats
- Achievements encourage alternate exploration routes
- Photos and GPS may connect to stamps, titles, and collection progress

A feature with no meaningful connection to the core loop should be reconsidered.

## 10. Reality Enhances Fantasy

Real-world features are optional extensions of the game fantasy.

GPS, photographs, EXIF data, local stamps, and exploration records may reward players for discovering the real world. They must follow these rules:

- The primary game remains playable without them
- Location participation is opt-in
- Privacy and safety take priority over reward design
- Players are not encouraged to enter dangerous or restricted locations
- Lack of GPS permission does not block core progression
- Anti-cheat measures should avoid punishing legitimate players unnecessarily

Real-world exploration should feel like a bonus adventure, not an obligation.

## 11. Easy to Begin, Deep to Complete

The first minutes should be understandable without a manual.

The player should quickly learn how to:

- Move
- Explore
- Interact
- Identify danger
- Recognize an inaccessible route
- Understand the next objective

Long-term depth should come from world knowledge, species mastery, route planning, optional challenges, collections, and interconnected systems—not from confusing initial controls.

## 12. Meaningful Choices Over False Choices

Choices should produce noticeable consequences in route, play style, risk, reward, timing, or narrative context.

Examples:

- Which species should be used for the next region?
- Which route is safer or more rewarding?
- Which quest should be completed first?
- Should the player specialize for combat or traversal?

Avoid presenting multiple options that lead to effectively identical results.

## 13. Combat Supports Exploration

Combat is an important tool, but it is not the sole purpose of the game.

Combat may:

- Protect a territory
- Create risk during travel
- Test species mastery
- Gate a boss region
- Resolve a quest
- Reward preparation and environmental understanding

Combat should not consume so much of the experience that exploration becomes downtime between fights.

## 14. Content Must Have a Clear Purpose

Every new feature, species, quest, biome, enemy, item, and interface should answer:

1. Why does this exist?
2. What player experience does it create?
3. Which part of the core loop does it strengthen?
4. How does it connect to the world or another system?
5. What would be lost if it were removed?

If these questions do not have strong answers, the content should be revised, postponed, or removed.

## Feature Review Checklist

Before implementation, confirm the following:

- [ ] It strengthens exploration, discovery, or world understanding
- [ ] It creates a meaningful player experience
- [ ] It respects the player's time
- [ ] It avoids meaningless repetition
- [ ] It connects to at least one existing core system
- [ ] Its reward is more than a number increasing
- [ ] It remains understandable on a mobile device
- [ ] It does not make another important system irrelevant
- [ ] It has a clear reason to exist
- [ ] It is consistent with the game vision

For real-world features, also confirm:

- [ ] Participation is optional
- [ ] Privacy requirements are explicit
- [ ] Safety risks have been considered
- [ ] Core progression works without location or photo permission

## Golden Rule

Every major system should reinforce this loop:

```text
Explore
→ Discover
→ Grow
→ Gain a new possibility
→ Explore further
```

A system that weakens or bypasses this loop should not be introduced without a deliberate, documented change in project direction.
