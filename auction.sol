pragma solidity >=0.7.0 <0.9.0;
// mistake1: pay() will never work
// mistake2: bid()
// mistake3: replay attack
contract auction
{
    mapping (address=>bytes32) public h_bids;
    mapping (address=>uint) public bids;
    mapping (address=>bool) public bidded;
    mapping (address=>bool) public released;
    uint public expected_price;
    uint public start_time;
    uint public end_time;
    uint public release_time;
    address payable public winner;
    address payable public seller;
    uint public greatest = 0;
    bool paid = false;
    event bid_success(address bidder, uint amount);
    event winner_update(address winner, uint amount);

    constructor(address payable _seller, uint p){
        seller = _seller;
        expected_price = p;
        start_time = block.timestamp;
        end_time = start_time + 24 hours;
        release_time = end_time + 24 hours;
    }

    function bid(bytes32 h) public payable
    {
        require(block.timestamp < end_time);
        require(msg.value == expected_price); //fix mistake2, it acts like a entry ticket
        bidded[msg.sender] = true;
        bids[msg.sender] = 0;
        h_bids[msg.sender] = h;
        released[msg.sender] = false;
    }

    function hash(
        string memory _text,
        uint _num
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text, _num));
    }

    // Those who don't release honestly will lose the deposite 
    function release_bid(string memory nonce, uint bid_amount) public
    {
        require(block.timestamp > end_time);
        require(block.timestamp < release_time); // fix mistake3: replay attack
        require(bidded[msg.sender]);
        require(!released[msg.sender]); //only release once correctly
        require(h_bids[msg.sender] == hash(nonce, bid_amount));
        released[msg.sender] = true; // release successfully
        bids[msg.sender] = bid_amount;
        emit bid_success(msg.sender,bid_amount);
        if (bids[msg.sender] > greatest)
        {
            greatest = bids[msg.sender];
            winner = payable(msg.sender);
            emit winner_update(msg.sender,bid_amount);
        }
    }

    function withdraw() public
    {
        require(block.timestamp > release_time); //fix mistake3
        require(msg.sender != winner);
        require(released[msg.sender]); // only those who release successfully
        released[msg.sender] = false; // can only withdraw once
        (bool sent, bytes memory data) = msg.sender.call{value: expected_price}("");
        require(sent);
    }

    function pay() public payable 
    {   
        require(block.timestamp > release_time); // fix mistake1
        require(!paid);
        require(msg.sender == winner);
        require(msg.value >= (greatest-expected_price)); //pay the remaining amount
        paid = true; // flag
        (bool sent, bytes memory data) = seller.call{value: greatest}("");
        require(sent);
    }
}