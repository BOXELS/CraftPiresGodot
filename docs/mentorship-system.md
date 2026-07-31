# Mentorship & Power Imbalance System

## Overview

**Not all civilizations are equal** - Advanced players can mentor and protect new players, creating dynamic power relationships and hilarious trolling scenarios. This makes alliances more meaningful and creates epic underdog stories.

## Power Imbalance Mechanics

### Civilization Tiers

**Primitive Civ (New Player)**
- **Peasants**: Stage 1 (walking, wooden tools, vulnerable)
- **Resources**: Basic (wood, stone, food, clay)
- **Technology**: Feudal Age or earlier
- **Vulnerability**: Can be easily destroyed by advanced players
- **Protection**: Can receive mentorship and resources

**Advanced Civ (Experienced Player)**
- **Peasants**: Stage 3-4 (carts, hovercrafts, diamond tools)
- **Resources**: Rare materials (diamonds, emeralds, obsidian)
- **Technology**: Castle/Imperial Age
- **Power**: Can easily destroy primitive civs
- **Mentorship**: Can protect and boost new players

**Mega Civ (Alliance Leader)**
- **Peasants**: Stage 4 (hovercrafts, master tools)
- **Resources**: Massive stockpiles of all materials
- **Technology**: Imperial Age with wonders
- **Power**: Can field armies of advanced units
- **Leadership**: Can coordinate multiple allied civs

## Mentorship System

### How Mentorship Works

**Mentor Benefits:**
- **Protection** - Advanced player defends primitive civ
- **Resource sharing** - Donate materials to boost development
- **Technology transfer** - Share blueprints and knowledge
- **Military support** - Advanced units defend primitive territory
- **Strategic guidance** - Voice chat advice and coordination

**Mentee Benefits:**
- **Rapid progression** - Skip early game grinding
- **Protection** - Safe from other advanced players
- **Resources** - Access to rare materials
- **Learning** - See advanced strategies in action
- **Alliance membership** - Part of powerful alliance

### Mentorship Mechanics

**Resource Donation:**
```typescript
interface MentorshipDonation {
  mentorId: string;
  menteeId: string;
  resources: ResourceMap;
  tools: Tool[];
  vehicles: Vehicle[];
  cooldown: number; // Prevent spam
}

// Example: Advanced player donates to primitive
function donateToMentee(mentor: Player, mentee: Player, donation: MentorshipDonation) {
  // Transfer resources
  mentor.inventory.subtract(donation.resources);
  mentee.inventory.add(donation.resources);
  
  // Transfer tools (if mentee can use them)
  if (mentee.peasants.stage >= getRequiredStage(donation.tools)) {
    mentee.peasants.equipTools(donation.tools);
  }
  
  // Start mentorship cooldown
  mentor.mentorshipCooldown = 24 * 60 * 60; // 24 hours
}
```

**Protection System:**
- **Mentor can declare protection** over mentee's territory
- **Other advanced players** respect protection (or risk war)
- **Mentor's advanced units** patrol mentee's territory
- **Mentee gains alliance benefits** (shared vision, resources)

**Technology Transfer:**
- **Blueprint sharing** - Mentee can use mentor's blueprints
- **Tool upgrades** - Mentor can provide better tools
- **Vehicle access** - Mentee can use mentor's vehicles
- **Knowledge sharing** - Voice chat strategy sessions

## Hilarious Trolling Scenarios

### Peasant Cannon Ammunition

**The Ultimate Troll Move:**
- **Advanced player** loads primitive peasants into trebuchets
- **Peasant physics** - They fly through the air, screaming
- **Survival chance** - 5% chance to survive and become saboteur
- **95% death rate** - Most peasants die on impact
- **Resource cost** - 50 food + training cost per peasant

**Trolling Mechanics:**
```typescript
interface PeasantAmmunition {
  peasantId: string;
  survivalChance: number; // 5% for primitive, 15% for advanced
  sabotageChance: number; // If survives, chance to sabotage
  damage: number; // Based on peasant weight and speed
  specialEffects: string[]; // Screaming, flailing, etc.
}

function launchPeasant(peasant: Peasant, trebuchet: SiegeWeapon) {
  // Calculate trajectory
  const trajectory = calculateTrajectory(peasant.position, trebuchet.target);
  
  // Roll for survival
  const survivalRoll = Math.random();
  if (survivalRoll < peasant.survivalChance) {
    // Peasant survives, becomes saboteur
    peasant.becomeSaboteur(trebuchet.target);
    return "Peasant survives! Sabotage mission begins!";
  } else {
    // Peasant dies, deal damage
    const damage = calculatePeasantDamage(peasant);
    trebuchet.target.takeDamage(damage);
    return "Peasant splatters on impact! " + damage + " damage dealt!";
  }
}
```

**Streaming Gold:**
- *"Advanced player launches 50 primitive peasants at enemy fortress"*
- *"Peasants fly through the air screaming, most die on impact"*
- *"One peasant survives, becomes saboteur, starts destroying from inside"*
- *"Viewers donate resources to fund more peasant launches"*

### Power Imbalance Battles

**Primitive vs Advanced:**
- **Primitive civ** with wooden tools vs **Advanced civ** with diamond weapons
- **Hilarious mismatch** - Primitive peasants die instantly
- **Underdog story** - Can primitive civ survive?
- **Mentor intervention** - Advanced ally comes to rescue

**Advanced vs Mega:**
- **Advanced civ** vs **Mega alliance** with wonders
- **Epic scale** - Hundreds of units on each side
- **Strategic depth** - Complex tactics and coordination
- **Dramatic moments** - Commander deaths, alliance betrayals

## Alliance Dynamics

### Mentorship Alliances

**Structure:**
- **1 Mega civ** (alliance leader)
- **2-3 Advanced civs** (experienced players)
- **5-10 Primitive civs** (new players under mentorship)
- **Total**: 8-14 players per alliance

**Benefits:**
- **Protection** - Primitive civs safe from other advanced players
- **Rapid progression** - New players advance quickly
- **Resource sharing** - Advanced players donate materials
- **Military coordination** - Combined armies for major attacks
- **Knowledge transfer** - Experienced players teach new ones

**Challenges:**
- **Coordination** - Managing players of different skill levels
- **Resource management** - Balancing donations vs own needs
- **Protection costs** - Advanced players must defend primitive allies
- **Communication** - Voice chat with mixed experience levels

### Cross-Region Mentorship

**Epic Scale:**
- **Mentor in Region A** protects **mentee in Region B**
- **Cross-region travel** - Advanced player visits mentee's region
- **Resource caravans** - Transport materials between regions
- **Military support** - Advanced units defend distant territory

**Revenge Stories:**
- **Primitive player** bullied in Region A
- **Advanced mentor** from Region B hears the call
- **Cross-region invasion** - Advanced player travels to help
- **Epic battle** - Advanced vs Advanced, with primitive ally

## Streaming Content

### Mentorship Stories

**Daily Content:**
- **"Will the primitive civ survive the night?"**
- **"Advanced player donates 1000 diamonds to new player"**
- **"Cross-region mentorship - epic journey begins"**
- **"Primitive player's first hovercraft - emotional moment"**

**Epic Moments:**
- **"Mentor sacrifices own resources to save mentee"**
- **"Primitive player becomes advanced, returns to help others"**
- **"Cross-region alliance forms to protect new players"**
- **"Peasant cannon barrage - 100 peasants launched at once"**

### Trolling Content

**Hilarious Scenarios:**
- **"Advanced player launches primitive peasants as ammunition"**
- **"Peasant physics - they fly through the air screaming"**
- **"One peasant survives, becomes saboteur"**
- **"Viewers donate to fund more peasant launches"**

**Community Engagement:**
- **Chat votes** on whether to launch peasants
- **Donations** to fund peasant ammunition
- **Suggestions** for trolling strategies
- **Rooting for** primitive peasants to survive

## Balance Considerations

### Power Imbalance Management

**Protection Limits:**
- **Mentor can only protect** 3-5 primitive civs at once
- **Protection costs resources** - Advanced player must invest
- **Cooldown periods** - Prevent spam donations
- **Territory limits** - Can't protect entire world

**Progression Acceleration:**
- **Mentored players advance** 2-3× faster than solo
- **Still requires time** - Can't skip entire progression
- **Resource caps** - Can't give infinite materials
- **Skill requirements** - Must learn to use advanced tools

**Anti-Griefing:**
- **Mentorship contracts** - Formal agreements with terms
- **Abuse reporting** - Mentors can't exploit mentees
- **Resource limits** - Prevent infinite donations
- **Protection windows** - Time limits on mentorship

### Strategic Depth

**Mentor Strategy:**
- **Choose mentees carefully** - Invest in promising players
- **Balance donations** - Don't cripple own development
- **Protect strategically** - Focus on valuable territory
- **Build relationships** - Long-term alliance benefits

**Mentee Strategy:**
- **Choose mentors wisely** - Find reliable protectors
- **Learn quickly** - Maximize mentorship benefits
- **Contribute to alliance** - Don't just take resources
- **Plan independence** - Eventually become self-sufficient

## Technical Implementation

### Mentorship System

```typescript
interface Mentorship {
  mentorId: string;
  menteeId: string;
  startDate: Date;
  protectionLevel: 'basic' | 'full' | 'mega';
  resourceDonations: ResourceMap;
  toolDonations: Tool[];
  vehicleAccess: Vehicle[];
  status: 'active' | 'paused' | 'terminated';
}

interface MentorshipBenefits {
  resourceMultiplier: number; // 2-3× faster progression
  protectionRadius: number; // Territory protection
  toolAccess: Tool[]; // Can use mentor's tools
  vehicleAccess: Vehicle[]; // Can use mentor's vehicles
  allianceBenefits: AllianceBenefits; // Shared vision, resources
}
```

### Peasant Physics

```typescript
interface PeasantAmmunition {
  peasantId: string;
  weight: number; // Affects trajectory
  survivalChance: number; // Based on peasant stage
  sabotageChance: number; // If survives
  specialEffects: string[]; // Visual/audio effects
  damage: number; // Based on weight and speed
}

function calculatePeasantTrajectory(peasant: Peasant, target: Position): Trajectory {
  const weight = peasant.weight;
  const speed = trebuchet.power;
  const distance = calculateDistance(peasant.position, target);
  
  return {
    arc: calculateArc(weight, speed, distance),
    flightTime: calculateFlightTime(weight, speed, distance),
    impactForce: calculateImpactForce(weight, speed),
    specialEffects: generatePeasantEffects(peasant)
  };
}
```

### Alliance Management

```typescript
interface MentorshipAlliance {
  id: string;
  leader: Player; // Mega civ
  advancedMembers: Player[]; // Experienced players
  primitiveMembers: Player[]; // New players
  mentorshipPairs: Mentorship[];
  sharedResources: ResourceMap;
  protectionZones: Territory[];
  crossRegionSupport: boolean;
}
```

## The Experience

### For Mentors

**Rewards:**
- **Protection** - Mentees defend mentor's territory
- **Resource sharing** - Mentees contribute to alliance
- **Strategic depth** - Complex alliance management
- **Streaming content** - Epic mentorship stories

**Challenges:**
- **Resource investment** - Must donate materials
- **Protection costs** - Must defend mentee territory
- **Coordination** - Manage players of different skill levels
- **Communication** - Teach and guide new players

### For Mentees

**Benefits:**
- **Rapid progression** - Skip early game grinding
- **Protection** - Safe from other advanced players
- **Learning** - See advanced strategies in action
- **Alliance membership** - Part of powerful alliance

**Responsibilities:**
- **Contribute to alliance** - Don't just take resources
- **Learn quickly** - Maximize mentorship benefits
- **Follow guidance** - Listen to mentor's advice
- **Plan independence** - Eventually become self-sufficient

### For Viewers

**Entertainment:**
- **Hilarious trolling** - Peasant cannon launches
- **Epic mentorship** - Advanced players helping new ones
- **Power imbalance** - Primitive vs Advanced battles
- **Cross-region drama** - Mentors traveling to help mentees

**Community:**
- **Root for underdogs** - Support primitive players
- **Donate resources** - Fund peasant launches
- **Suggest strategies** - Help with mentorship
- **Form fan communities** - Support favorite alliances

---

## The Vision

**This creates a dynamic world where:**
- **Not all players are equal** - Power imbalances create drama
- **Mentorship matters** - Advanced players can help new ones
- **Trolling is hilarious** - Peasant cannon launches for comedy
- **Alliances are meaningful** - Protection and resource sharing
- **Stories emerge** - Underdog comebacks, epic rescues

---

*From primitive peasants to hovercraft masters. From trolling launches to epic mentorship. Every player's journey is unique.*
