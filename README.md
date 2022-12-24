On-chain white elephant, with NFTs. 

1. Start a game, by passing the addresses that are playing, in the order they should go.
2. Each address can `open` (mint a new NFT) or `steal`, take someone else's (an NFT minted via `open` from someone else in their game).
3. Each NFT can only be stolen twice, max.
4. The same NFT cannot be stolen twice in a row. 
5. Game is over when `open` has been called `game.participants.length` times. 