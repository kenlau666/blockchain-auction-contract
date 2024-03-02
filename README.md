# A blockchain-based auction contract with Commitment Scheme

## Flow
1. The seller constructs the contract with his address and sets the start time and the expected price.
2. Before the end time, anyone can call bid(bytes32 h) to submit the hash of a large string and bid amount, and make a deposit = expected price. Expected price acts like an admission ticket here.
3. After the end time, bidders have 24 hours to call release_bid(string memory nonce, uint bid_amount). If the bidder becomes the temporary winner, an event winner_update will be emitted. Only bidders who have submitted the hash can call release and they can only release once. One day later, the final winner is set.
4. Those who do not release correctly will lose the expected value and their bid amount is 0.
5. After 1 hour, the winner is set. Those who release successfully can call withdraw() to take back the deposit if they are not the winner.
6. The winner has to pay the remaining amount = the bid amount – expected price and calls pay() to prove the deposit (bid amount – expected price).
7. The seller receives the bid amount of winner if the winner calls pay() successfully. 

## Explanation
Since everyone has to deposit the amount of expected price set by the seller first, if the winner refuses to pay, the winner cannot get the deposit back but the seller can still get the expected price and choose not to transfer the item. Only stupid winner will not pay.
Paid is a Boolean variable to states whether the winner has deposited the bid amount to the contract. If Paid is true, the seller can withdraw the bid amount from the contract.
