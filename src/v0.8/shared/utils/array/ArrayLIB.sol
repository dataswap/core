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

import {FinanceType} from "src/v0.8/types/FinanceType.sol";

library ArrayUint16LIB {
    /// @notice Retrieve the count of unique elements in an array.
    function countUniqueElements(
        uint16[] memory _elements
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;
        uint16[] memory uniques = new uint16[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Retrieve the count of unique elements in an array and the array of unique elements after deduplication.
    /// @return The count of unique elements and the array of unique elements after deduplication.
    function uniqueElements(
        uint16[] memory _elements
    ) internal pure returns (uint256, uint16[] memory) {
        uint256 uniqueCount = 0;
        uint16[] memory uniques = new uint16[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        // Create a new array with only unique elements
        uint16[] memory result = new uint16[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            result[i] = uniques[i];
        }

        return (uniqueCount, result);
    }

    /// @notice The number of times a particular element appears in an array.
    function countOccurrences(
        uint16[] memory _elements,
        uint16 _target
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;

        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == _target) {
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Calculate the number of elements remaining after removing a specific element from an array.
    /// @return The count of elements remaining.
    function countAfterRemoval(
        uint16[] memory _elements,
        uint16 _elementToRemove
    ) internal pure returns (uint256) {
        uint256 countRemaining = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                countRemaining++;
            }
        }
        return countRemaining;
    }

    /// @notice Remove a specific element from an array.
    /// @return The modified array with the specified element removed.
    function removeElement(
        uint16[] memory _elements,
        uint16 _elementToRemove
    ) internal pure returns (uint256, uint16[] memory) {
        uint16[] memory updatedArray = new uint16[](_elements.length);

        uint256 newSize = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                updatedArray[newSize] = _elements[i];
                newSize++;
            }
        }

        // Create a new array with only the elements that are not equal to _elementToRemove
        uint16[] memory result = new uint16[](newSize);
        for (uint256 i = 0; i < newSize; i++) {
            result[i] = updatedArray[i];
        }

        return (newSize, result);
    }

    /// @notice Check if an array has duplicate elements.
    /// @return True if there are duplicates, false otherwise.
    function hasDuplicates(
        uint16[] memory _elements
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            for (uint256 j = i + 1; j < _elements.length; j++) {
                if (_elements[i] == _elements[j]) {
                    return true; // Found a duplicate element
                }
            }
        }
        return false; // No duplicates found
    }

    /// @notice Check if a specified element exists in the array.
    function isContains(
        uint16[] memory _elements,
        uint16 target
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == target) {
                return true;
            }
        }
        return false;
    }

    /// @notice Appends a new element to an array.
    /// @dev This internal pure function is used to append a new element to an existing array of elements.
    /// @param _elements The array of elements to which the new element will be appended.
    /// @param _element The new element to be appended.
    /// @return An updated array containing the original elements and the new element.
    function append(
        uint16[] memory _elements,
        uint16 _element
    ) internal pure returns (uint16[] memory) {
        uint16[] memory ret = new uint16[](_elements.length + 1);
        for (uint256 i = 0; i < _elements.length; i++) {
            ret[i] = _elements[i];
        }
        ret[_elements.length] = _element;
        return ret;
    }
}

library ArrayUint32LIB {
    /// @notice Retrieve the count of unique elements in an array.
    function countUniqueElements(
        uint32[] memory _elements
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;
        uint32[] memory uniques = new uint32[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Retrieve the count of unique elements in an array and the array of unique elements after deduplication.
    /// @return The count of unique elements and the array of unique elements after deduplication.
    function uniqueElements(
        uint32[] memory _elements
    ) internal pure returns (uint256, uint32[] memory) {
        uint256 uniqueCount = 0;
        uint32[] memory uniques = new uint32[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        // Create a new array with only unique elements
        uint32[] memory result = new uint32[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            result[i] = uniques[i];
        }

        return (uniqueCount, result);
    }

    /// @notice The number of times a particular element appears in an array.
    function countOccurrences(
        uint32[] memory _elements,
        uint32 _target
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;

        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == _target) {
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Calculate the number of elements remaining after removing a specific element from an array.
    /// @return The count of elements remaining.
    function countAfterRemoval(
        uint32[] memory _elements,
        uint32 _elementToRemove
    ) internal pure returns (uint256) {
        uint256 countRemaining = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                countRemaining++;
            }
        }
        return countRemaining;
    }

    /// @notice Remove a specific element from an array.
    /// @return The modified array with the specified element removed.
    function removeElement(
        uint32[] memory _elements,
        uint32 _elementToRemove
    ) internal pure returns (uint256, uint32[] memory) {
        uint32[] memory updatedArray = new uint32[](_elements.length);

        uint256 newSize = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                updatedArray[newSize] = _elements[i];
                newSize++;
            }
        }

        // Create a new array with only the elements that are not equal to _elementToRemove
        uint32[] memory result = new uint32[](newSize);
        for (uint256 i = 0; i < newSize; i++) {
            result[i] = updatedArray[i];
        }

        return (newSize, result);
    }

    /// @notice Check if an array has duplicate elements.
    /// @return True if there are duplicates, false otherwise.
    function hasDuplicates(
        uint32[] memory _elements
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            for (uint256 j = i + 1; j < _elements.length; j++) {
                if (_elements[i] == _elements[j]) {
                    return true; // Found a duplicate element
                }
            }
        }
        return false; // No duplicates found
    }

    /// @notice Check if a specified element exists in the array.
    function isContains(
        uint32[] memory _elements,
        uint32 target
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == target) {
                return true;
            }
        }
        return false;
    }

    /// @notice Appends a new element to an array.
    /// @dev This internal pure function is used to append a new element to an existing array of elements.
    /// @param _elements The array of elements to which the new element will be appended.
    /// @param _element The new element to be appended.
    /// @return An updated array containing the original elements and the new element.
    function append(
        uint32[] memory _elements,
        uint32 _element
    ) internal pure returns (uint32[] memory) {
        uint32[] memory ret = new uint32[](_elements.length + 1);
        for (uint256 i = 0; i < _elements.length; i++) {
            ret[i] = _elements[i];
        }
        ret[_elements.length] = _element;
        return ret;
    }
}

library ArrayUint64LIB {
    /// @notice Retrieve the count of unique elements in an array.
    function countUniqueElements(
        uint64[] memory _elements
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;
        uint64[] memory uniques = new uint64[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Retrieve the count of unique elements in an array and the array of unique elements after deduplication.
    /// @return The count of unique elements and the array of unique elements after deduplication.
    function uniqueElements(
        uint64[] memory _elements
    ) internal pure returns (uint256, uint64[] memory) {
        uint256 uniqueCount = 0;
        uint64[] memory uniques = new uint64[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        // Create a new array with only unique elements
        uint64[] memory result = new uint64[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            result[i] = uniques[i];
        }

        return (uniqueCount, result);
    }

    /// @notice The number of times a particular element appears in an array.
    function countOccurrences(
        uint64[] memory _elements,
        uint64 _target
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;

        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == _target) {
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Calculate the number of elements remaining after removing a specific element from an array.
    /// @return The count of elements remaining.
    function countAfterRemoval(
        uint64[] memory _elements,
        uint64 _elementToRemove
    ) internal pure returns (uint256) {
        uint256 countRemaining = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                countRemaining++;
            }
        }
        return countRemaining;
    }

    /// @notice Remove a specific element from an array.
    /// @return The modified array with the specified element removed.
    function removeElement(
        uint64[] memory _elements,
        uint64 _elementToRemove
    ) internal pure returns (uint256, uint64[] memory) {
        uint64[] memory updatedArray = new uint64[](_elements.length);

        uint256 newSize = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                updatedArray[newSize] = _elements[i];
                newSize++;
            }
        }

        // Create a new array with only the elements that are not equal to _elementToRemove
        uint64[] memory result = new uint64[](newSize);
        for (uint256 i = 0; i < newSize; i++) {
            result[i] = updatedArray[i];
        }

        return (newSize, result);
    }

    /// @notice Check if an array has duplicate elements.
    /// @return True if there are duplicates, false otherwise.
    function hasDuplicates(
        uint64[] memory _elements
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            for (uint256 j = i + 1; j < _elements.length; j++) {
                if (_elements[i] == _elements[j]) {
                    return true; // Found a duplicate element
                }
            }
        }
        return false; // No duplicates found
    }

    /// @notice Check if a specified element exists in the array.
    function isContains(
        uint64[] memory _elements,
        uint64 target
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == target) {
                return true;
            }
        }
        return false;
    }

    /// @notice Appends a new element to an array.
    /// @dev This internal pure function is used to append a new element to an existing array of elements.
    /// @param _elements The array of elements to which the new element will be appended.
    /// @param _element The new element to be appended.
    /// @return An updated array containing the original elements and the new element.
    function append(
        uint64[] memory _elements,
        uint64 _element
    ) internal pure returns (uint64[] memory) {
        uint64[] memory ret = new uint64[](_elements.length + 1);
        for (uint256 i = 0; i < _elements.length; i++) {
            ret[i] = _elements[i];
        }
        ret[_elements.length] = _element;
        return ret;
    }
}

library ArrayAddressLIB {
    /// @notice Retrieve the count of unique elements in an array.
    function countUniqueElements(
        address[] memory _elements
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;
        address[] memory uniques = new address[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Retrieve the count of unique elements in an array and the array of unique elements after deduplication.
    /// @return The count of unique elements and the array of unique elements after deduplication.
    function uniqueElements(
        address[] memory _elements
    ) internal pure returns (uint256, address[] memory) {
        uint256 uniqueCount = 0;
        address[] memory uniques = new address[](_elements.length);

        for (uint256 i = 0; i < _elements.length; i++) {
            bool isUnique = true;
            for (uint256 j = 0; j < uniqueCount; j++) {
                if (_elements[i] == uniques[j]) {
                    isUnique = false;
                    break;
                }
            }
            if (isUnique) {
                uniques[uniqueCount] = _elements[i];
                uniqueCount++;
            }
        }

        // Create a new array with only unique elements
        address[] memory result = new address[](uniqueCount);
        for (uint256 i = 0; i < uniqueCount; i++) {
            result[i] = uniques[i];
        }

        return (uniqueCount, result);
    }

    /// @notice The number of times a particular element appears in an array.
    function countOccurrences(
        address[] memory _elements,
        address _target
    ) internal pure returns (uint256) {
        uint256 uniqueCount = 0;

        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == _target) {
                uniqueCount++;
            }
        }

        return uniqueCount;
    }

    /// @notice Calculate the number of elements remaining after removing a specific element from an array.
    /// @return The count of elements remaining.
    function countAfterRemoval(
        address[] memory _elements,
        address _elementToRemove
    ) internal pure returns (uint256) {
        uint256 countRemaining = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                countRemaining++;
            }
        }
        return countRemaining;
    }

    /// @notice Remove a specific element from an array.
    /// @return The modified array with the specified element removed.
    function removeElement(
        address[] memory _elements,
        address _elementToRemove
    ) internal pure returns (uint256, address[] memory) {
        address[] memory updatedArray = new address[](_elements.length);

        uint256 newSize = 0;
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] != _elementToRemove) {
                updatedArray[newSize] = _elements[i];
                newSize++;
            }
        }

        // Create a new array with only the elements that are not equal to _elementToRemove
        address[] memory result = new address[](newSize);
        for (uint256 i = 0; i < newSize; i++) {
            result[i] = updatedArray[i];
        }

        return (newSize, result);
    }

    /// @notice Check if an array has duplicate elements.
    /// @return True if there are duplicates, false otherwise.
    function hasDuplicates(
        address[] memory _elements
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            for (uint256 j = i + 1; j < _elements.length; j++) {
                if (_elements[i] == _elements[j]) {
                    return true; // Found a duplicate element
                }
            }
        }
        return false; // No duplicates found
    }

    /// @notice Check if a specified element exists in the array.
    function isContains(
        address[] memory _elements,
        address target
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _elements.length; i++) {
            if (_elements[i] == target) {
                return true;
            }
        }
        return false;
    }

    /// @notice Appends a new element to an array.
    /// @dev This internal pure function is used to append a new element to an existing array of elements.
    /// @param _elements The array of elements to which the new element will be appended.
    /// @param _element The new element to be appended.
    /// @return An updated array containing the original elements and the new element.
    function append(
        address[] memory _elements,
        address _element
    ) internal pure returns (address[] memory) {
        address[] memory ret = new address[](_elements.length + 1);
        for (uint256 i = 0; i < _elements.length; i++) {
            ret[i] = _elements[i];
        }
        ret[_elements.length] = _element;
        return ret;
    }
}

/// @title ArraysPaymentInfoLIB
/// @dev This library provides functions for managing ArraysPaymentInfo[]-related operations.
library ArraysPaymentInfoLIB {
    // Helper function to append two arrays
    function appendArrays(
        FinanceType.PaymentInfo[] memory arr1,
        FinanceType.PaymentInfo[] memory arr2
    ) internal pure returns (FinanceType.PaymentInfo[] memory) {
        uint256 len1 = arr1.length;
        uint256 len2 = arr2.length;

        FinanceType.PaymentInfo[] memory result = new FinanceType.PaymentInfo[](
            len1 + len2
        );

        for (uint256 i = 0; i < len1; i++) {
            result[i] = arr1[i];
        }

        for (uint256 i = 0; i < len2; i++) {
            result[len1 + i] = arr2[i];
        }

        return result;
    }
}
