// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CampaignFactory{
    Campaign[] public deployedCampaigns;

    function createCampaign(uint minimum) public{
        Campaign newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (Campaign[] memory){
        return deployedCampaigns;
    }
}

contract Campaign{

    struct Request{
        string description;
        uint amount;
        address payable recipient;
        bool complete;
        mapping(address => bool) approvals;
        uint approvalCount;
    }

    uint numRequests;
    mapping (uint => Request) requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    uint public approversCount;

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

    constructor(uint minimum, address creator){
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string memory desc, uint value, address payable recipient) public restricted{
        require(approvers[msg.sender]);
        Request storage newRequest = requests[numRequests++];
        newRequest.description = desc;
        newRequest.amount = value;
        newRequest.recipient = recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint index) public {
        Request storage request = requests[index];
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint index) public restricted{
        Request storage request = requests[index];
        require(request.approvalCount > approversCount/2);
        require(!request.complete);
        request.recipient.transfer(request.amount);
        request.complete = true;

    }


}
