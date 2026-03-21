// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PawToken.sol";

contract PawLedger is Ownable {
    enum CaseStatus { PENDING, ACTIVE, CLOSED, REFUNDED }
    enum MilestoneStatus { PENDING, APPROVED, REJECTED }

    struct Case {
        address rescuer;
        string ipfsMetadata;
        uint256 goalAmount;
        uint256 raisedAmount;
        uint256 deadline;
        CaseStatus status;
        uint256 milestoneCount;
        uint256 approvalCount;
    }

    struct Milestone {
        string evidenceIPFS;
        string description;
        uint256 requestAmount;
        uint256 approveWeight;
        uint256 rejectWeight;
        uint256 submittedAt;
        MilestoneStatus status;
        bool fundsReleased;
    }

    PawToken public pawToken;
    uint256 public reviewerThreshold;
    uint256 public requiredApprovals;

    Case[] public cases;
    mapping(uint256 => Milestone[]) public milestones;
    mapping(uint256 => uint256) public caseBalance;
    mapping(uint256 => uint256) public refundSnapshot;

    mapping(address => bool) public isReviewer;
    mapping(address => uint256) public totalDonated;
    mapping(uint256 => mapping(address => uint256)) public donations;
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public hasVoted;
    mapping(uint256 => mapping(address => bool)) public hasReviewed;

    event ReviewerAdded(address indexed reviewer);
    event CaseSubmitted(uint256 indexed caseId, address indexed rescuer);
    event CaseReviewed(uint256 indexed caseId, address indexed reviewer, bool approved);
    event CaseActivated(uint256 indexed caseId);
    event Donated(uint256 indexed caseId, address indexed donor, uint256 amount);
    event MilestoneSubmitted(uint256 indexed caseId, uint256 indexed idx);
    event MilestoneVoted(uint256 indexed caseId, uint256 indexed idx, address indexed voter, bool approved);
    event MilestoneApproved(uint256 indexed caseId, uint256 indexed idx);
    event MilestoneRejected(uint256 indexed caseId, uint256 indexed idx);
    event MilestoneWithdrawn(uint256 indexed caseId, uint256 indexed idx, uint256 amount);
    event RefundClaimed(uint256 indexed caseId, address indexed donor, uint256 amount);

    constructor(address pawTokenAddr, uint256 threshold, uint256 approvals) Ownable(msg.sender) {
        pawToken = PawToken(pawTokenAddr);
        reviewerThreshold = threshold;
        requiredApprovals = approvals;
        isReviewer[msg.sender] = true;
        emit ReviewerAdded(msg.sender);
    }

    // ─── Case Management ─────────────────────────────────────────────────────

    function submitCase(
        string calldata ipfs,
        uint256 goal,
        uint256 durationDays,
        uint256 milestoneCount
    ) external {
        require(goal > 0, "Goal must be > 0");
        require(durationDays > 0, "Duration must be > 0");
        require(milestoneCount > 0, "Must have milestones");

        uint256 caseId = cases.length;
        cases.push(Case({
            rescuer: msg.sender,
            ipfsMetadata: ipfs,
            goalAmount: goal,
            raisedAmount: 0,
            deadline: block.timestamp + durationDays * 1 days,
            status: CaseStatus.PENDING,
            milestoneCount: milestoneCount,
            approvalCount: 0
        }));

        emit CaseSubmitted(caseId, msg.sender);
    }

    function reviewCase(uint256 caseId, bool approve) external {
        require(isReviewer[msg.sender], "Not a reviewer");
        require(caseId < cases.length, "Invalid case");
        require(cases[caseId].status == CaseStatus.PENDING, "Case not pending");
        require(!hasReviewed[caseId][msg.sender], "Already reviewed");

        hasReviewed[caseId][msg.sender] = true;
        pawToken.mint(msg.sender, 10 ether);

        emit CaseReviewed(caseId, msg.sender, approve);

        if (approve) {
            cases[caseId].approvalCount++;
            if (cases[caseId].approvalCount >= requiredApprovals) {
                cases[caseId].status = CaseStatus.ACTIVE;
                emit CaseActivated(caseId);
            }
        }
    }

    // ─── Donations ────────────────────────────────────────────────────────────

    function donate(uint256 caseId) external payable {
        require(caseId < cases.length, "Invalid case");
        require(cases[caseId].status == CaseStatus.ACTIVE, "Case not active");
        require(msg.value > 0, "Must send AVAX");
        require(block.timestamp < cases[caseId].deadline, "Case expired");

        cases[caseId].raisedAmount += msg.value;
        caseBalance[caseId] += msg.value;
        donations[caseId][msg.sender] += msg.value;
        totalDonated[msg.sender] += msg.value;

        emit Donated(caseId, msg.sender, msg.value);
    }

    // ─── Reviewer Promotion ───────────────────────────────────────────────────

    function becomeReviewer() external {
        require(!isReviewer[msg.sender], "Already a reviewer");
        require(totalDonated[msg.sender] >= reviewerThreshold, "Insufficient donations");

        isReviewer[msg.sender] = true;
        emit ReviewerAdded(msg.sender);
    }

    // ─── Milestones ───────────────────────────────────────────────────────────

    function submitMilestone(
        uint256 caseId,
        uint256 idx,
        string calldata ipfs,
        string calldata desc,
        uint256 amount
    ) external {
        require(caseId < cases.length, "Invalid case");
        Case storage c = cases[caseId];
        require(c.rescuer == msg.sender, "Not rescuer");
        require(c.status == CaseStatus.ACTIVE, "Case not active");
        require(idx < c.milestoneCount, "Invalid milestone index");
        require(amount <= caseBalance[caseId], "Insufficient balance");

        if (milestones[caseId].length > idx) {
            // Re-submission: only allowed if previously rejected
            require(milestones[caseId][idx].status == MilestoneStatus.REJECTED, "Milestone already submitted");
            Milestone storage m = milestones[caseId][idx];
            m.evidenceIPFS = ipfs;
            m.description = desc;
            m.requestAmount = amount;
            m.approveWeight = 0;
            m.rejectWeight = 0;
            m.submittedAt = block.timestamp;
            m.status = MilestoneStatus.PENDING;
            m.fundsReleased = false;
        } else {
            require(milestones[caseId].length == idx, "Must submit milestones in order");
            milestones[caseId].push(Milestone({
                evidenceIPFS: ipfs,
                description: desc,
                requestAmount: amount,
                approveWeight: 0,
                rejectWeight: 0,
                submittedAt: block.timestamp,
                status: MilestoneStatus.PENDING,
                fundsReleased: false
            }));
        }

        emit MilestoneSubmitted(caseId, idx);
    }

    function voteMilestone(uint256 caseId, uint256 idx, bool approve) external {
        require(caseId < cases.length, "Invalid case");
        require(idx < milestones[caseId].length, "Invalid milestone");
        require(donations[caseId][msg.sender] > 0, "Not a donor for this case");
        require(!hasVoted[caseId][idx][msg.sender], "Already voted");
        require(milestones[caseId][idx].status == MilestoneStatus.PENDING, "Milestone not pending");

        hasVoted[caseId][idx][msg.sender] = true;
        Milestone storage m = milestones[caseId][idx];
        uint256 weight = donations[caseId][msg.sender];

        if (approve) {
            m.approveWeight += weight;
        } else {
            m.rejectWeight += weight;
        }

        emit MilestoneVoted(caseId, idx, msg.sender, approve);

        uint256 raised = cases[caseId].raisedAmount;

        // Approve if >50% weight
        if (m.approveWeight * 2 > raised) {
            m.status = MilestoneStatus.APPROVED;
            emit MilestoneApproved(caseId, idx);
        }
        // Reject if >30% weight within 48h of submission
        else if (m.rejectWeight * 100 > raised * 30 && block.timestamp <= m.submittedAt + 48 hours) {
            m.status = MilestoneStatus.REJECTED;
            emit MilestoneRejected(caseId, idx);
        }
    }

    function withdrawMilestone(uint256 caseId, uint256 idx) external {
        require(caseId < cases.length, "Invalid case");
        require(idx < milestones[caseId].length, "Invalid milestone");
        Case storage c = cases[caseId];
        require(c.rescuer == msg.sender, "Not rescuer");
        Milestone storage m = milestones[caseId][idx];
        require(m.status == MilestoneStatus.APPROVED, "Milestone not approved");
        require(!m.fundsReleased, "Already withdrawn");

        uint256 amount = m.requestAmount;
        require(caseBalance[caseId] >= amount, "Insufficient case balance");

        m.fundsReleased = true;
        caseBalance[caseId] -= amount;

        emit MilestoneWithdrawn(caseId, idx, amount);

        // Close case if all milestones completed
        bool allDone = true;
        for (uint256 i = 0; i < c.milestoneCount; i++) {
            if (i >= milestones[caseId].length || !milestones[caseId][i].fundsReleased) {
                allDone = false;
                break;
            }
        }
        if (allDone) {
            c.status = CaseStatus.CLOSED;
        }

        (bool ok,) = payable(msg.sender).call{value: amount}("");
        require(ok, "Transfer failed");
    }

    // ─── Refunds ──────────────────────────────────────────────────────────────

    function claimRefund(uint256 caseId) external {
        require(caseId < cases.length, "Invalid case");
        Case storage c = cases[caseId];
        require(block.timestamp >= c.deadline, "Not expired yet");
        require(
            c.status == CaseStatus.ACTIVE || c.status == CaseStatus.REFUNDED,
            "Not refundable"
        );
        require(donations[caseId][msg.sender] > 0, "No donation to refund");

        // Snapshot remaining balance on first refund claim
        if (c.status == CaseStatus.ACTIVE) {
            refundSnapshot[caseId] = caseBalance[caseId];
            c.status = CaseStatus.REFUNDED;
        }

        uint256 donorShare = donations[caseId][msg.sender];
        uint256 refundAmount = (refundSnapshot[caseId] * donorShare) / c.raisedAmount;
        donations[caseId][msg.sender] = 0; // prevent double-claim

        emit RefundClaimed(caseId, msg.sender, refundAmount);

        (bool ok,) = payable(msg.sender).call{value: refundAmount}("");
        require(ok, "Transfer failed");
    }

    // ─── View Helpers ─────────────────────────────────────────────────────────

    function getCasesCount() external view returns (uint256) {
        return cases.length;
    }

    function getMilestonesCount(uint256 caseId) external view returns (uint256) {
        return milestones[caseId].length;
    }

    function getMilestone(uint256 caseId, uint256 idx) external view returns (Milestone memory) {
        return milestones[caseId][idx];
    }

    // ─── Admin ────────────────────────────────────────────────────────────────

    function updateRequiredApprovals(uint256 n) external onlyOwner {
        requiredApprovals = n;
    }

    function updateReviewerThreshold(uint256 n) external onlyOwner {
        reviewerThreshold = n;
    }
}
