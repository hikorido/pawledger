// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PawToken.sol";

contract PawLedger is Ownable {
    // ─── Enums ───────────────────────────────────────────────────────────────

    enum CaseStatus { PENDING, ACTIVE, CLOSED, REFUNDED }
    enum MilestoneStatus { PENDING, APPROVED, REJECTED }

    // ─── Structs ─────────────────────────────────────────────────────────────

    struct Case {
        address rescuer;
        string  ipfsMetadata;
        uint256 goalAmount;
        uint256 raisedAmount;
        uint256 deadline;
        CaseStatus status;
        uint256 milestoneCount;
        uint256 approvalCount;
    }

    struct Milestone {
        string  evidenceIPFS;
        string  description;
        uint256 requestAmount;
        uint256 approveWeight;
        uint256 rejectWeight;
        uint256 submittedAt;
        MilestoneStatus status;
        bool    fundsReleased;
    }

    // ─── State Variables ─────────────────────────────────────────────────────

    PawToken public pawToken;
    uint256  public reviewerThreshold;
    uint256  public requiredApprovals;

    Case[]   public cases;
    mapping(uint256 => Milestone[]) public milestones;

    // ─── Mappings ────────────────────────────────────────────────────────────

    mapping(address => bool)    public isReviewer;
    mapping(address => uint256) public totalDonated;
    mapping(uint256 => mapping(address => uint256)) public donations;
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public hasVoted;
    mapping(uint256 => mapping(address => bool)) public hasReviewed;

    // ─── Events ───────────────────────────────────────────────────────────────

    event ReviewerAdded(address indexed reviewer);

    // ─── Constructor ──────────────────────────────────────────────────────────

    /// @param pawTokenAddr  Deployed PawToken contract address
    /// @param threshold     Min cumulative AVAX (wei) to become a reviewer
    /// @param approvals     Number of reviewer approvals needed to activate a case
    constructor(address pawTokenAddr, uint256 threshold, uint256 approvals)
        Ownable(msg.sender)
    {
        require(pawTokenAddr != address(0), "Zero token address");
        pawToken          = PawToken(pawTokenAddr);
        reviewerThreshold = threshold;
        requiredApprovals = approvals;

        // Deployer is auto-registered as the first reviewer
        isReviewer[msg.sender] = true;
        emit ReviewerAdded(msg.sender);
    }

    // ─── Owner Functions ──────────────────────────────────────────────────────

    function updateRequiredApprovals(uint256 n) external onlyOwner {
        require(n > 0, "Must be > 0");
        requiredApprovals = n;
    }

    function updateReviewerThreshold(uint256 n) external onlyOwner {
        reviewerThreshold = n;
    }
}
