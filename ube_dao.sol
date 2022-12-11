// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UbeDaoContract is Ownable{

    /*
     *  Events
    */
    event TransferSent(address _from, address _destAddr, uint _amount);

    /*
     *  Storage
    */
    using Counters for Counters.Counter;
    Counters.Counter private num_bounties;
    bounty[] public dao_bounties; 

    struct bounty {
        // Metadata related to bounty.
        bool is_bounty_closed;
        address wallet_address;
        uint256 bounty_amount;
        string email;
        string discord_username;
        uint256 start_time;
        uint256 end_time;
        string services;
        string consideration;
        milestone[] milestones_list;
        // Contributor List
        contributor[] contributor_list;
    }

    struct contributor{
        string by;
        string name;
        string title;
        string email;
        address wallet_address;
    }

    struct milestone{
        uint256 amount;
        uint256 timestamp;
        bool is_milestone_acheived;
    }

    // Constructor.
    constructor() {
    }

    // Functions
    function put_bounty(address _wallet_address, uint256 _bounty_amount, string memory _email, string memory _discord_username, uint256 _start_time, uint256 _end_time, string memory _services, string memory _consideration) external onlyOwner returns (uint256 idx){

        dao_bounties.push();

        idx = num_bounties.current();        
        bounty storage _bounty = dao_bounties[idx] ;
        
        _bounty.is_bounty_closed = false;
        _bounty.wallet_address = _wallet_address;
        _bounty.bounty_amount = _bounty_amount;
        _bounty.email = _email;
        _bounty.discord_username = _discord_username;
        _bounty.start_time = _start_time;
        _bounty.end_time = _end_time;
        _bounty.services = _services;
        _bounty.consideration = _consideration;

        num_bounties.increment();

    }

    // Functions to push milestones.
    function push_milestones(uint256 _idx, uint256 _timestamp, uint256 _amount, IERC20 token) external onlyOwner{

        uint256 erc20balance = token.balanceOf(msg.sender);
        require(_amount <= erc20balance, "balance is low");

        bounty storage _bounty = dao_bounties[_idx];

        // Sanity checks for milestones.
        require(_bounty.is_bounty_closed == false, "Bounty is closed, choose a different bounty");
        require(_timestamp >= _bounty.start_time, "Milestone time should be greater than start time of the bounty");
        require(_timestamp <= _bounty.end_time, "Milestone time should be less than end time of the bounty");

        milestone memory _milestone;
        _milestone.amount = _amount;
        _milestone.timestamp = _timestamp;
        _milestone.is_milestone_acheived = false;

        
        token.transferFrom(msg.sender, address(this), _amount);
        emit TransferSent(msg.sender, address(this), _amount);
        _bounty.milestones_list.push(_milestone);


    }

    function get_milestone_list(uint256 _idx) public view returns(milestone[] memory _milestone_list){
        _milestone_list = dao_bounties[_idx].milestones_list;
    }

    // Function to enter as contributor 
    function push_contributor(uint256 _idx, string memory _by, string memory _name, string memory _title, string memory _email, address _wallet_address) public {
        
        bounty storage _bounty = dao_bounties[_idx];

        // Sanity checks for contributors.
        require(_bounty.is_bounty_closed == false, "Bounty is closed, choose a different bounty");

        contributor memory _contributor;
        _contributor.by = _by;
        _contributor.name = _name;
        _contributor.title = _title;
        _contributor.email = _email;
        _contributor.wallet_address = _wallet_address;

        _bounty.contributor_list.push(_contributor);
    }

    function get_contributor_list(uint256 _idx) public view returns(contributor[] memory _contributor_list){
        _contributor_list = dao_bounties[_idx].contributor_list;
    }

    // Function to revoke the bounty.
    function revoke_bounty(uint256 _idx, IERC20 token) external onlyOwner{
        bounty storage _bounty = dao_bounties[_idx];

        // Sanity checks
        require(_bounty.is_bounty_closed == false, "Bounty is closed, choose a different bounty");

        for(uint256 i=0; i<_bounty.milestones_list.length; i++){
            uint256 erc20balance = token.balanceOf(address(this));
            require(_bounty.milestones_list[i].is_milestone_acheived == false, "Milestone already acheived, payed to the contributor cannot revoke");
            require(_bounty.milestones_list[i].amount <= erc20balance, "balance is low");
            token.transfer(msg.sender, _bounty.milestones_list[i].amount);
            emit TransferSent(address(this), msg.sender, _bounty.milestones_list[i].amount);
        }

        _bounty.is_bounty_closed = true;
    }

    // Function to approve the bounty depending upon the milestone.
    function approve_bounty(uint256 _idx, uint256 _milestone_idx, uint256 _contributor_idx, IERC20 token) external onlyOwner{
        bounty storage _bounty = dao_bounties[_idx];

        // Sanity checks
        require(_bounty.is_bounty_closed == false, "Bounty is closed, choose a different bounty");
        require(_bounty.milestones_list[_milestone_idx].is_milestone_acheived == false, "Milestone already acheived, choose a different milestone");
        require(_bounty.milestones_list[_milestone_idx].timestamp <= block.timestamp, "Milestone deadline yet not acheived");

        token.transfer(_bounty.contributor_list[_contributor_idx].wallet_address, _bounty.milestones_list[_milestone_idx].amount);
        emit TransferSent(address(this), _bounty.contributor_list[_contributor_idx].wallet_address, _bounty.milestones_list[_milestone_idx].amount);

        _bounty.milestones_list[_milestone_idx].is_milestone_acheived = true;
    }
}