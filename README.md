# UbeDao

UbeDaoContrat aims to solve the problem mentioned in the UBE Destiny Hackathon - https://gitcoin.co/issue/29600.

Video Demo Link - https://www.youtube.com/watch?v=l0KlfrqP5XA&ab_channel=RagibHussain

Usage -
The contract has been deployed on Goerli testnet and Celo testnet, the mentioned address for both of them is mentioned below :

1. https://explorer.celo.org/alfajores/address/0xE7f1856c9209AF86c0756f6Af28fEACD2d18185D/transactions#address-tabs
2. https://goerli.etherscan.io/address/0x87e940bf5c8fc26ad9f80985d23176d21646423e

Data Structures -

The structures used is as follows-

1. bounty[] - It is an array of all the bounties being released by the DAO. Once the DAO releases a bounty it is pushed at the end of the array, and any bounty can be accessed by its index. Each element is a structure containing the following fields:

   1. is_bounty_closed - It tells whether the bounty is closed or currently active;
   2. wallet_address - The address of the multisig wallet;
   3. bounty_amount - The amount of bounty decided;
   4. email - The email address of the DAO where the contributor can reach for queries;
   5. discord_username - DAO discord username;
   6. start_time - Starting time for the bounty;
   7. end_time - Ending time for the bounty;
   8. services - An ipfs link for the DAO Contributor Agreement services uploaded file;
   9. consideration - An ipfs link for the DAO to take things into consideration;
   10. milestones_list - An array of the structures of the milestones which contains elements like amount for that milestone, timestamp of completion, whether a milestone is active or acheived;
   11. contributor_list - An array of all the contributors enrolling for a bounty with the DAO, and containing all the metadata related to the contributor;

WorkFlow -

1. The DAO is the owner of the contract and it can only only create bounties and the milestone.
2. The DAO first calls the put_bounty() function with all the relevant details, related to the bounty, this function call populates the bounty array with the current added bounty.
3. The DAO can then create as many milestones for a particular bounty by providing the amount determined for that milestone, timestamp which is the deadline to acheive that milestone and calling the push_milestone() function.
4. Once the DAO is satisfied with all the milestones added for a particular bounty the contributor can search in the list of dao_bounties[] with the id and determine which bounty it wants to contribute.
5. Once decided, the contributer calls the function push_contributor() to add himself in the contrbutor list of the corresponding bounty whose index it derived from step 4.
6. If the DAO posting the bounty, thinks of approving the bounty, he can choose the contributor from the contributor_list[] and depending on the milestone he wants to approve it can call the approve_bounty() function, the amount deposited for that milestone also gets transfered to the selected contributor and the milestone is marked as acheived to stop draining of funds by mutli transfer of the same milestone. Here, different contributors can be chosen for different milestone, and the reward can be transfered.
7. If the DAO thinks of cancelling a particular bounty, then it can call the revoke_bounty() function, and all the amount stored for a particular bounty in the respective milestones, will then be transferred back to the DAO multisig wallet and the bounty will be closed, so no other contributor can enroll into it.
8. Also the DAO multisig wallet address is the owner of the UbeDao Contract and it has the ability to transfer the ownership to other multisig contracts by calling the transferOwnership() function.
