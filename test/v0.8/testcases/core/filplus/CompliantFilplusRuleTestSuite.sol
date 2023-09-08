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

import {Errors} from "src/v0.8/shared/errors/Errors.sol";
import {FilplusEvents} from "src/v0.8/shared/events/FilplusEvents.sol";
import {Generator} from "test/v0.8/helpers/utils/Generator.sol";
import {IFilplus} from "src/v0.8/interfaces/core/IFilplus.sol";
import {IFilplusAssertion} from "test/v0.8/interfaces/assertions/core/IFilplusAssertion.sol";
import {FilplusCompliantTestSuiteBase} from "test/v0.8/testcases/core/filplus/abstract/FilplusTestSuiteBase.sol";

/// @notice set CompliantFilplusRuleTestCaseWithGeolocationSuccess test case,it should be success
contract CompliantFilplusRuleTestCaseWithGeolocationSuccess is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule geolocation compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(5, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            0
        );
        assertion.isCompliantRuleGeolocationAsseretion(
            regions,
            countrys,
            citys,
            true
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithMinRegions test case,it should be success
contract CompliantFilplusRuleTestCaseWithMinRegions is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule geolocation compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(2, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(2, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            2,
            3,
            0,
            0
        );
        assertion.isCompliantRuleGeolocationAsseretion(
            regions,
            countrys,
            citys,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithMaxReplicasPerCountry test case,it should be success
contract CompliantFilplusRuleTestCaseWithMaxReplicasPerCountry is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule geolocation compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(5, 2);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            0
        );
        assertion.isCompliantRuleGeolocationAsseretion(
            regions,
            countrys,
            citys,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithInvalidNilCitys test case,it should be success
contract CompliantFilplusRuleTestCaseWithInvalidNilCitys is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule geolocation compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(5, 2);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            0
        );
        citys[0] = new uint32[](0);
        vm.expectRevert(bytes("City is required"));
        assertion.isCompliantRuleGeolocationAsseretion(
            regions,
            countrys,
            citys,
            true
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithInvalidDuplicateCity test case,it should be success
contract CompliantFilplusRuleTestCaseWithInvalidDuplicateCity is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule geolocation compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(5, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            2
        );
        vm.expectRevert(bytes("Invalid duplicate city"));
        assertion.isCompliantRuleGeolocationAsseretion(
            regions,
            countrys,
            citys,
            true
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithMaxReplicasPerCity test case,it should be success
contract CompliantFilplusRuleTestCaseWithMaxReplicasPerCity is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule geolocation compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(5, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            0
        );

        citys[1][0] = citys[0][0];
        assertion.isCompliantRuleGeolocationAsseretion(
            regions,
            countrys,
            citys,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithProportionSuccess test case,it should be success
contract CompliantFilplusRuleTestCaseWithProportionSuccess is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule proportion compliant to the filplus.
    function action() internal override {
        assertion.isCompliantRuleMaxProportionOfMappingFilesToDatasetAsseretion(
            40,
            10000,
            true
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithProportionOverflow test case,it should be success
contract CompliantFilplusRuleTestCaseWithProportionOverflow is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule proportion compliant to the filplus.
    function action() internal override {
        assertion.isCompliantRuleMaxProportionOfMappingFilesToDatasetAsseretion(
            400,
            10000,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithTotalReplicasSuccess test case,it should be success
contract CompliantFilplusRuleTestCaseWithTotalReplicasSuccess is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule total replicas compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(5, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            0
        );
        address[][] memory dps = generator.generateGeolocationActors(
            5,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = generator.generateGeolocationActors(
            5,
            3,
            0,
            0,
            address(199)
        );

        assertion.isCompliantRuleTotalReplicasPerDatasetAsseretion(
            dps,
            sps,
            regions,
            countrys,
            citys,
            true
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithInvalidCountrys test case,it should be success
contract CompliantFilplusRuleTestCaseWithInvalidCountrys is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule total replicas compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(5, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(6, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            5,
            3,
            0,
            0
        );
        address[][] memory dps = generator.generateGeolocationActors(
            5,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = generator.generateGeolocationActors(
            5,
            3,
            0,
            0,
            address(199)
        );

        assertion.isCompliantRuleTotalReplicasPerDatasetAsseretion(
            dps,
            sps,
            regions,
            countrys,
            citys,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithMaxReplicasOverflow test case,it should be success
contract CompliantFilplusRuleTestCaseWithMaxReplicasOverflow is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule total replicas compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(11, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(
            11,
            0
        );
        uint32[][] memory citys = generator.generateGeolocationCitys(
            11,
            3,
            0,
            0
        );
        address[][] memory dps = generator.generateGeolocationActors(
            11,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = generator.generateGeolocationActors(
            11,
            3,
            0,
            0,
            address(199)
        );

        assertion.isCompliantRuleTotalReplicasPerDatasetAsseretion(
            dps,
            sps,
            regions,
            countrys,
            citys,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithMinReplicasOverflow test case,it should be success
contract CompliantFilplusRuleTestCaseWithMinReplicasOverflow is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule total replicas compliant to the filplus.
    function action() internal override {
        uint16[] memory regions = generator.generateGeolocationPositions(3, 0);
        uint16[] memory countrys = generator.generateGeolocationPositions(3, 0);
        uint32[][] memory citys = generator.generateGeolocationCitys(
            3,
            3,
            0,
            0
        );
        address[][] memory dps = generator.generateGeolocationActors(
            3,
            3,
            0,
            0,
            address(99)
        );
        address[][] memory sps = generator.generateGeolocationActors(
            3,
            3,
            0,
            0,
            address(199)
        );

        assertion.isCompliantRuleTotalReplicasPerDatasetAsseretion(
            dps,
            sps,
            regions,
            countrys,
            citys,
            false
        );
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithSPsPerDatasetSuccess test case,it should be success
contract CompliantFilplusRuleTestCaseWithSPsPerDatasetSuccess is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if rule sps per dataset compliant to the filplus.
    function action() internal override {
        assertion.isCompliantRuleMinSPsPerDatasetAsseretion(10, 5, 5, true);
    }
}

/// @notice set CompliantFilplusRuleTestCaseWithSPsPerDatasetOverflow test case,it should be success
contract CompliantFilplusRuleTestCaseWithSPsPerDatasetOverflow is
    FilplusCompliantTestSuiteBase
{
    constructor(
        IFilplus _filplus,
        IFilplusAssertion _assertion,
        Generator _generator,
        address _governanceContractAddresss
    )
        FilplusCompliantTestSuiteBase(
            _filplus,
            _assertion,
            _generator,
            _governanceContractAddresss
        ) // solhint-disable-next-line
    {}

    /// @dev The main action of the test, where if sps per dataset rule compliant to the filplus.
    function action() internal override {
        assertion.isCompliantRuleMinSPsPerDatasetAsseretion(10, 8, 1, false);
    }
}
