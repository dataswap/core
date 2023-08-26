/*******************************************************************************
 *   (c) 2023 Dataswap
 *
 *  Licensed under the GNU General Public License, Version 3.0 or later (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      https://www.gnu.org/licenses/gpl-3.0.en.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ********************************************************************************/
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.21;

// NOTE: view asserton functions must all be tested by the functions that will change state
interface IDatacapsAssertion {
    function requestAllocateDatacapAssertion(uint64 _matchingId) external;

    function getAvailableDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    function getAllocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    function getTotalDatacapAllocationRequirementAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    function getRemainingUnallocatedDatacapAssertion(
        uint64 _matchingId,
        uint64 _expectSize
    ) external;

    function isNextDatacapAllocationValidAssertion(
        uint64 _matchingId,
        bool _expectOK
    ) external;
}