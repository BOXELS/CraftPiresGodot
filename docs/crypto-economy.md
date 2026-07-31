# Crypto Economy System

## Overview

**CraftPires features an in-game cryptocurrency tied to real-world crypto**, creating a unique economic layer where players can earn real value from their in-game achievements. This adds another dimension to the "forever game" concept and creates meaningful rewards for long-term engagement.

## The CraftPires Token (CPT)

### Token Economics

**Token Name**: CraftPires Token (CPT)
**Blockchain**: Ethereum (or other major blockchain)
**Total Supply**: 1,000,000,000 CPT
**Token Type**: ERC-20 (or equivalent)
**Utility**: In-game currency, governance, real-world value

### Token Distribution

**Initial Distribution (20% - 200M CPT):**
- **Development Team**: 10% (100M CPT)
- **Early Investors**: 5% (50M CPT)
- **Community Rewards**: 3% (30M CPT)
- **Liquidity Pool**: 2% (20M CPT)

**In-Game Rewards (60% - 600M CPT):**
- **Seasonal Rewards**: 40% (400M CPT) - Distributed over 10 years
- **Achievement Rewards**: 15% (150M CPT) - Milestone achievements
- **Community Events**: 5% (50M CPT) - Special competitions and events

**Ecosystem Development (20% - 200M CPT):**
- **Partnerships**: 10% (100M CPT) - Strategic partnerships
- **Marketing**: 5% (50M CPT) - Community growth
- **Reserve Fund**: 5% (50M CPT) - Future development

## Earning CPT In-Game

### Seasonal Rewards

**End-of-Season Distribution:**
- **Hall of Legends Winners**: 50% of seasonal pool
- **Top 10 Civilizations**: 30% of seasonal pool
- **Participation Rewards**: 20% of seasonal pool

**Reward Calculation:**
```typescript
interface SeasonalReward {
  civilizationId: string;
  prestige: number;
  territory: number;
  resources: number;
  battles: number;
  achievements: number;
  totalScore: number;
  cptReward: number;
}

function calculateSeasonalReward(civ: Civilization): number {
  const prestige = civ.prestige * 100;
  const territory = civ.territorySize * 50;
  const resources = civ.totalResourcesMined * 0.1;
  const battles = civ.battlesWon * 200;
  const achievements = civ.achievements.length * 500;
  
  const totalScore = prestige + territory + resources + battles + achievements;
  const cptReward = (totalScore / totalSeasonalScore) * seasonalPool;
  
  return cptReward;
}
```

### Achievement Rewards

**Milestone Achievements:**
- **First Diamond Mine**: 100 CPT
- **First Wonder Built**: 500 CPT
- **First Cross-Region Alliance**: 1,000 CPT
- **First Peasant Cannon Success**: 250 CPT
- **First Mud Trap Disaster**: 100 CPT (comedy reward)

**Rare Achievements:**
- **Immortal Commander**: 2,000 CPT (survive entire season)
- **Master Builder**: 1,500 CPT (build 100+ structures)
- **War Legend**: 2,500 CPT (win 50+ battles)
- **Diplomatic Genius**: 1,800 CPT (maintain 5+ alliances)

**Community Achievements:**
- **Featured Blueprint**: 500 CPT (blueprint featured in community)
- **Streaming Star**: 1,000 CPT (top streamer of the month)
- **Community Helper**: 750 CPT (help new players)
- **Creative Genius**: 1,200 CPT (most creative contraption)

### Daily/Weekly Rewards

**Daily Login**: 10 CPT
**Weekly Participation**: 50 CPT
**Monthly Activity**: 200 CPT
**Quarterly Milestone**: 500 CPT

## Spending CPT In-Game

### Cosmetic Purchases

**Commander Skins**: 100-500 CPT
**Building Textures**: 200-800 CPT
**Beam Colors**: 50-200 CPT
**Banner Designs**: 100-300 CPT
**Emotes**: 25-100 CPT

### Quality of Life Upgrades

**Starter Resources**: 100 CPT (spawn with extra resources)
**Faster Construction**: 200 CPT (10% faster building)
**Extra Peasant Slots**: 500 CPT (additional team members)
**Priority Queue**: 300 CPT (faster server access)

### Premium Features

**Private Regions**: 1,000 CPT (exclusive region access)
**Advanced Analytics**: 500 CPT (detailed statistics)
**Custom Blueprints**: 200 CPT (unlock blueprint editor)
**Alliance Management**: 800 CPT (advanced alliance tools)

## Real-World Integration

### Cryptocurrency Exchange

**Trading Pairs:**
- **CPT/ETH**: Primary trading pair
- **CPT/BTC**: Bitcoin pair
- **CPT/USDT**: Stablecoin pair
- **CPT/USD**: Fiat pair (where legal)

**Exchange Listings:**
- **Decentralized Exchanges**: Uniswap, SushiSwap
- **Centralized Exchanges**: Binance, Coinbase (future)
- **Game-Specific Exchanges**: Specialized gaming token exchanges

### Real-World Value

**Price Discovery:**
- **Market-driven pricing** based on supply and demand
- **Seasonal fluctuations** based on game activity
- **Achievement scarcity** creates value for rare accomplishments
- **Community growth** drives long-term value

**Value Proposition:**
- **Real rewards** for in-game achievements
- **Tradable assets** with real-world value
- **Governance rights** in game development
- **Exclusive access** to premium features

## Rare Items & NFTs

### CraftPires Rare Items (CPRIs)

**What They Are:**
- **Unique digital assets** representing rare in-game items
- **NFTs on blockchain** with verifiable ownership
- **Real-world value** that can be traded outside the game
- **War objectives** that players can fight over and capture

**Types of Rare Items:**
- **Legendary Weapons**: Unique Commander weapons with special abilities
- **Ancient Artifacts**: Rare items from previous seasons
- **Crystal Relics**: Gem-encrusted items with unique properties
- **Master Blueprints**: One-of-a-kind building designs
- **Commander Skins**: Exclusive cosmetic items
- **Territory Deeds**: Ownership rights to specific map regions

### Rare Item Generation

**Seasonal Drops:**
- **End-of-season rewards** for top performers
- **Random drops** during special events
- **Community contests** for creative achievements
- **Developer rewards** for exceptional gameplay

**Rarity Tiers:**
- **Common (White)**: 1,000+ in circulation
- **Uncommon (Green)**: 100-999 in circulation
- **Rare (Blue)**: 10-99 in circulation
- **Epic (Purple)**: 1-9 in circulation
- **Legendary (Gold)**: Unique (1 in existence)

**Drop Mechanics:**
```typescript
interface RareItemDrop {
  id: string;
  name: string;
  rarity: 'common' | 'uncommon' | 'rare' | 'epic' | 'legendary';
  properties: ItemProperties;
  dropChance: number;
  requirements: DropRequirement[];
}

interface DropRequirement {
  type: 'achievement' | 'territory' | 'resource' | 'battle';
  value: number;
  description: string;
}

function calculateDropChance(player: Player, event: GameEvent): number {
  const baseChance = event.baseDropChance;
  const prestigeBonus = player.prestige * 0.01;
  const territoryBonus = player.territorySize * 0.005;
  const achievementBonus = player.achievements.length * 0.02;
  
  return Math.min(baseChance + prestigeBonus + territoryBonus + achievementBonus, 0.1);
}
```

### War & Capture Mechanics

**Item Warfare:**
- **Siege battles** can capture rare items from enemy civilizations
- **Alliance raids** can target specific rare items
- **Cross-region wars** can be fought over legendary items
- **Defensive strategies** to protect valuable items

**Capture Rules:**
- **Siege victory** allows capture of 1-3 rare items
- **Alliance victory** can redistribute items among members
- **Defensive victory** protects all items from capture
- **Item protection** through special defensive structures

**Item Trading:**
- **In-game trading** between players
- **External marketplaces** (OpenSea, Rarible)
- **Auction systems** for high-value items
- **Alliance exchanges** for strategic items

### Real-World Trading

**Marketplace Integration:**
- **OpenSea**: Primary NFT marketplace
- **Rarible**: Alternative marketplace
- **Game-specific marketplace**: Built-in trading system
- **Auction houses**: High-value item auctions

**Trading Features:**
- **Instant trading** within game
- **External wallet** integration
- **Price discovery** through market dynamics
- **Trading history** and provenance tracking

**Value Drivers:**
- **Game utility** - Items provide in-game advantages
- **Rarity** - Limited supply creates value
- **Provenance** - History of ownership and battles
- **Community demand** - Player interest drives prices

### Epic Storylines

**The Diamond Crown War:**
- *"Two alliances fight for months over the legendary Diamond Crown"*
- *"Crown changes hands 15 times during the season"*
- *"Final battle involves 50+ players across 3 regions"*
- *"Winner sells crown for $10,000 in real money"*

**The Emerald Throne Saga:**
- *"Solo player discovers ancient Emerald Throne in deep cave"*
- *"Alliances form and break over control of the throne"*
- *"Throne provides massive diplomatic bonuses"*
- *"Player becomes richest in game history"*

**The Obsidian Blade Chronicles:**
- *"Legendary weapon appears in random drop"*
- *"Player uses blade to win 20+ battles"*
- *"Blade becomes most valuable item in game"*
- *"Final owner retires from game, sells blade for retirement fund"*

**The Crystal Fortress Deed:**
- *"Rare territory deed for prime map location"*
- *"Alliance builds massive fortress on the land"*
- *"Fortress becomes impenetrable, controls entire region"*
- *"Deed sells for $50,000 to real estate investor"*

### Item Properties & Effects

**Legendary Weapons:**
- **Unique abilities** not available elsewhere
- **Visual effects** that stand out in game
- **Historical significance** from previous battles
- **Trading value** based on utility and rarity

**Ancient Artifacts:**
- **Seasonal bonuses** from previous years
- **Unique lore** and backstory
- **Collector value** for completionists
- **Nostalgia factor** for long-time players

**Crystal Relics:**
- **Enhanced abilities** for specific playstyles
- **Beautiful visuals** that enhance gameplay
- **Status symbols** showing achievement
- **Investment potential** for collectors

**Master Blueprints:**
- **Unique building designs** not available elsewhere
- **Enhanced stats** compared to standard blueprints
- **Creative freedom** for unique structures
- **Architectural value** for builders

### Economic Impact

**Player Behavior:**
- **Risk-taking** to capture valuable items
- **Alliance formation** around rare item protection
- **Strategic planning** for item acquisition
- **Long-term investment** in rare items

**Market Dynamics:**
- **Supply and demand** for specific items
- **Seasonal fluctuations** based on game events
- **Community speculation** on item values
- **Real-world trading** outside the game

**Story Generation:**
- **Epic battles** over valuable items
- **Alliance betrayals** for rare items
- **Solo player victories** against alliances
- **Community legends** around specific items

### Technical Implementation

**NFT Smart Contracts:**
```solidity
contract CraftPiresRareItem {
    struct RareItem {
        uint256 id;
        string name;
        string description;
        uint256 rarity;
        mapping(string => uint256) properties;
        address currentOwner;
        uint256[] ownershipHistory;
        uint256 creationTime;
        uint256 lastTransfer;
    }
    
    mapping(uint256 => RareItem) public rareItems;
    mapping(address => uint256[]) public playerItems;
    
    function transferItem(uint256 itemId, address to) public;
    function captureItem(uint256 itemId, address captor) public;
    function getItemHistory(uint256 itemId) public view returns (uint256[]);
}
```

**In-Game Integration:**
```typescript
interface RareItem {
  id: string;
  name: string;
  rarity: string;
  properties: ItemProperties;
  owner: string;
  location: Position;
  captureable: boolean;
  value: number;
  history: OwnershipRecord[];
}

interface OwnershipRecord {
  owner: string;
  timestamp: number;
  method: 'drop' | 'capture' | 'trade' | 'auction';
  battleId?: string;
  price?: number;
}

function captureItem(itemId: string, captor: string, battleId: string): boolean {
  const item = getRareItem(itemId);
  if (!item.captureable) return false;
  
  // Update ownership
  item.owner = captor;
  item.history.push({
    owner: captor,
    timestamp: Date.now(),
    method: 'capture',
    battleId: battleId
  });
  
  // Update blockchain
  updateNFTOwnership(itemId, captor);
  
  // Notify community
  broadcastItemCapture(itemId, captor, battleId);
  
  return true;
}
```

## The Experience

### For Players

**High-Stakes Gameplay:**
- **Real value** at risk in every battle
- **Strategic decisions** about item protection
- **Alliance dynamics** around rare items
- **Investment opportunities** in rare items

**Epic Moments:**
- **Capturing legendary items** from enemies
- **Defending valuable items** against sieges
- **Trading rare items** for strategic advantage
- **Selling items** for real-world profit

### For Viewers

**Entertainment:**
- **Epic battles** over valuable items
- **Alliance drama** around rare items
- **Trading stories** and market speculation
- **Real-world value** of in-game items

**Community:**
- **Item speculation** and price discussions
- **Battle coverage** for rare item conflicts
- **Trading advice** and market analysis
- **Legendary item** showcases

### For Streamers

**Content Creation:**
- **Rare item hunts** and discovery
- **Epic battles** over valuable items
- **Trading sessions** and market analysis
- **Real-world value** discussions

**Monetization:**
- **Rare item giveaways** to viewers
- **Trading commissions** from item sales
- **Battle coverage** for rare item conflicts
- **Market speculation** content

---

## The Vision

**This creates a world where:**
- **Every battle** can have real-world consequences
- **Every rare item** tells a story of conquest
- **Every alliance** forms around valuable objectives
- **Every player** can become a legend through rare items
- **Every season** creates new legends and stories

---

*From virtual battles to real-world treasures. Every rare item is a story waiting to be told, a legend waiting to be made.*

## Governance System

### Token Holder Rights

**Voting Power:**
- **1 CPT = 1 Vote** for governance proposals
- **Minimum 1,000 CPT** required to submit proposals
- **Voting periods** of 7 days for major decisions
- **Quorum requirement** of 10% of circulating supply

**Governance Proposals:**
- **Game balance changes** (resource costs, building stats)
- **New feature additions** (new materials, contraptions)
- **Economic adjustments** (CPT rewards, distribution)
- **Community events** (special competitions, rewards)

### Decentralized Autonomous Organization (DAO)

**Structure:**
- **Core Team**: 20% voting power (development team)
- **Community**: 80% voting power (token holders)
- **Proposal System**: Community-driven development
- **Treasury Management**: Community-controlled funds

**Decision Making:**
- **Technical Proposals**: Core team + community input
- **Economic Proposals**: Community majority vote
- **Feature Proposals**: Community vote + core team approval
- **Emergency Changes**: Core team (with community oversight)

## Anti-Cheat & Fair Play

### Token Protection

**Anti-Bot Measures:**
- **Human verification** for large CPT transactions
- **Behavioral analysis** to detect automated farming
- **Rate limiting** on CPT earning activities
- **Manual review** of suspicious accounts

**Fair Distribution:**
- **Skill-based rewards** rather than time-based farming
- **Achievement verification** through multiple data points
- **Community reporting** system for suspicious activity
- **Regular audits** of reward distribution

### Economic Balance

**Inflation Control:**
- **Fixed total supply** with controlled distribution
- **Deflationary mechanisms** (token burning for premium features)
- **Seasonal resets** prevent infinite accumulation
- **Market dynamics** balance supply and demand

**Price Stability:**
- **Reserve fund** for market stabilization
- **Gradual distribution** prevents price crashes
- **Utility value** maintains token demand
- **Community growth** drives long-term value

## Technical Implementation

### Smart Contracts

```solidity
contract CraftPiresToken {
    string public name = "CraftPires Token";
    string public symbol = "CPT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1000000000 * 10**18;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function transfer(address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}
```

### In-Game Integration

```typescript
interface CryptoIntegration {
  walletAddress: string;
  cptBalance: number;
  earnedCPT: number;
  spentCPT: number;
  transactions: Transaction[];
}

interface Transaction {
  id: string;
  type: 'earn' | 'spend' | 'transfer';
  amount: number;
  reason: string;
  timestamp: number;
  txHash?: string;
}

function earnCPT(playerId: string, amount: number, reason: string): boolean {
  // Verify achievement/activity
  if (!verifyAchievement(playerId, reason)) return false;
  
  // Update in-game balance
  updatePlayerBalance(playerId, amount);
  
  // Record transaction
  recordTransaction(playerId, 'earn', amount, reason);
  
  // Trigger smart contract (if applicable)
  if (amount >= minimumTransfer) {
    triggerSmartContract(playerId, amount);
  }
  
  return true;
}
```

### Wallet Integration

**Supported Wallets:**
- **MetaMask**: Browser extension wallet
- **WalletConnect**: Mobile wallet support
- **Coinbase Wallet**: Easy fiat on-ramp
- **Trust Wallet**: Mobile-first experience

**Wallet Features:**
- **Seamless connection** to game account
- **Real-time balance** updates
- **Transaction history** within game
- **Easy withdrawal** to external wallets

## Legal & Regulatory Considerations

### Compliance

**Regulatory Compliance:**
- **Securities laws** - Ensure token doesn't qualify as security
- **Gaming regulations** - Comply with local gaming laws
- **Tax implications** - Provide tax reporting tools
- **AML/KYC** - Anti-money laundering compliance

**Jurisdiction Considerations:**
- **US regulations** - SEC compliance for token sales
- **EU regulations** - MiCA compliance for crypto assets
- **Asian markets** - Local crypto regulations
- **Gaming restrictions** - Some jurisdictions restrict crypto gaming

### Risk Management

**User Protection:**
- **Clear disclaimers** about token risks
- **Educational resources** about crypto and gaming
- **Support systems** for technical issues
- **Dispute resolution** for token-related problems

**Platform Security:**
- **Multi-signature wallets** for platform funds
- **Insurance coverage** for major losses
- **Regular security audits** of smart contracts
- **Emergency procedures** for security incidents

## The Experience

### For Players

**Earning Real Value:**
- **Achievement rewards** have real-world value
- **Skill-based earning** rewards gameplay mastery
- **Community recognition** through token holdings
- **Investment potential** in game success

**Spending Options:**
- **Cosmetic upgrades** enhance gameplay experience
- **Quality of life** improvements reduce friction
- **Premium features** unlock advanced capabilities
- **Governance participation** influence game development

### For Investors

**Token Utility:**
- **In-game currency** with real demand
- **Governance rights** in game development
- **Staking rewards** for long-term holders
- **Trading opportunities** in crypto markets

**Value Drivers:**
- **Game popularity** drives token demand
- **Achievement scarcity** creates value
- **Community growth** increases adoption
- **Real-world integration** expands use cases

### For Streamers

**Content Creation:**
- **Real rewards** for streaming achievements
- **Viewer engagement** through token giveaways
- **Community building** around token economy
- **Monetization** through token-based rewards

**Community Features:**
- **Token donations** from viewers
- **Achievement celebrations** with real value
- **Community events** with token prizes
- **Governance participation** with community

---

## The Vision

**This creates a world where:**
- **In-game achievements** have real-world value
- **Players are invested** in long-term success
- **Community governance** drives development
- **Economic incentives** align with gameplay
- **Real-world integration** expands possibilities

---

*From virtual achievements to real-world value. Every season, every battle, every creative contraption can earn you something tangible.*
