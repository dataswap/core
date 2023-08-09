// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.21;

import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "../libraries/types/DatasetType.sol";
import "../libraries/types/RolesType.sol";
import "../libraries/DatasetLIB.sol";
import "../libraries/Common.sol";
import "../libraries/utils/StringUtils.sol";
import "./IRoles.sol";
import "./IDatasets.sol";
import "./ICarsStorage.sol";

/// @notice Explain to an end user what this does
/// @dev Explain to a developer any extra details
abstract contract IDatasets is Ownable2Step {
    uint256 public datasetCount;
    mapping(uint256 => DatasetType.Dataset) public datasets;
    address public immutable rolesContract;
    address payable public immutable governanceContract;
    address public immutable carsStorageContract;

    using DatasetLIB for DatasetType.Dataset;

    constructor(
        address payable _governanceContract,
        address _rolesContract,
        address _carsStorageContract
    ) {
        governanceContract = _governanceContract;
        rolesContract = _rolesContract;
        carsStorageContract = _carsStorageContract;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyGovernance() {
        require(
            msg.sender == governanceContract,
            "Only governance contract can call this function"
        );
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    modifier onlyRole(bytes32 _role) {
        IRoles role = IRoles(rolesContract);
        require(role.hasRole(_role, msg.sender), "No permission!");
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _metadata a parameter just like in doxygen (must be followed by parameter name)
    function submitMetadata(DatasetType.Metadata calldata _metadata) public {
        //TODO:check if metadata exsits
        Common.requireValidDataset(_metadata);

        // Increment the datasetCount
        datasetCount++;

        // Create a new DatasetType.Dataset instance for the new dataset
        DatasetType.Dataset storage newDataset = datasets[datasetCount];

        // Use the Dataset library method to submit metadata
        newDataset.submitMetadata(_metadata);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    /// @param _proof a parameter just like in doxygen (must be followed by parameter name)
    function submitProof(
        uint256 datasetId,
        DatasetType.Proof calldata _proof
    ) public onlyRole(RolesType.DATASET_PROVIDER) {
        // Ensure the provided datasetId is within the valid range
        require(
            datasetId > 0 && datasetId <= datasetCount,
            "Invalid dataset ID"
        );

        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[datasetId];

        // Use the Dataset library method to submit the proof
        dataset.submitProof(_proof);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    /// @param _verification a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    function submitVerification(
        uint256 datasetId,
        DatasetType.Verification calldata _verification
    )
        public
        onlyRole(RolesType.DATASET_AUDITOR)
        returns (DatasetType.VerifyResult)
    {
        // Ensure the provided datasetId is within the valid range
        require(
            datasetId > 0 && datasetId <= datasetCount,
            "Invalid dataset ID"
        );

        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[datasetId];

        // Use the Dataset library method to submit the verification and return the result
        return
            dataset.submitVerification(
                _verification,
                governanceContract,
                datasetId,
                address(this)
            );
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function approveMetadata(uint256 datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[datasetId];

        // Use the Dataset library method to approve metadata
        dataset.approveMetadata();
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function rejectMetadata(uint256 datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[datasetId];

        // Use the Dataset library method to reject metadata
        dataset.rejectMetadata();
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param _datasetId a parameter just like in doxygen (must be followed by parameter name)
    function approveDataset(uint256 _datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[_datasetId];

        // Use the Dataset library method to approve the dataset
        dataset.approveDataset();
        postApprovedAction(_datasetId);
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param datasetId a parameter just like in doxygen (must be followed by parameter name)
    function rejectDataset(uint256 datasetId) public onlyGovernance {
        // Get the Dataset instance for the provided datasetId
        DatasetType.Dataset storage dataset = datasets[datasetId];

        // Use the Dataset library method to reject the dataset
        dataset.rejectDataset();
    }

    function getState(
        uint256 datasetId
    ) public view returns (DatasetType.State) {
        DatasetType.Dataset storage dataset = datasets[datasetId];
        return dataset.getState();
    }

    function postApprovedAction(uint256 _datasetId) internal {
        DatasetType.Dataset storage dataset = datasets[_datasetId];
        ICarsStorage cars = ICarsStorage(carsStorageContract);
        require(!cars.hasCars(dataset.proof.leafHashes), "cars cids invalid");
        cars.addCars(dataset.proof.leafHashes);
        cars.addCars(dataset.proof.mappingFilesLeafHashes);
    }
}
