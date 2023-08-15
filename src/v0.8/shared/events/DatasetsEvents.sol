/// SPDX-License-Identifier: GPL-3.0-or-later
/// (c) 2023 DataSwap
///
/// Licensed under the GNU General Public License, Version 3.0 or later (the "License");
/// you may not use this file except in compliance with the License.
/// You may obtain a copy of the License at
///     https://www.gnu.org/licenses/gpl-3.0.en.html
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.

pragma solidity ^0.8.21;

library DatasetsEvents {
    /// @notice Event emitted when metadata is approved for a dataset.
    event DatasetMetadataApproved(uint256 indexed _datasetId);

    /// @notice Event emitted when metadata is rejected for a dataset.
    event DatasetMetadataRejected(uint256 indexed _datasetId);

    /// @notice Event emitted when a dataset is approved.
    event DatasetApproved(uint256 indexed _datasetId);

    /// @notice Event emitted when a dataset is rejected.
    event DatasetRejected(uint256 indexed _datasetId);

    /// @notice Event emitted when metadata is submitted for a new dataset.
    event DatasetMetadataSubmitted(
        uint256 indexed _datasetId,
        address indexed _provider
    );

    /// @notice Event emitted when a proof is submitted for a dataset.
    event DatasetProofSubmitted(
        uint256 indexed _datasetId,
        address indexed _provider
    );

    /// @notice Event emitted when a dataset is verified.
    event DatasetVerificationSubmitted(
        uint256 indexed _datasetId,
        address indexed _verifier
    );
}