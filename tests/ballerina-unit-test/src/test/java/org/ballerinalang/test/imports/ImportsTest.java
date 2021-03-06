/*
 *  Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

package org.ballerinalang.test.imports;

import org.ballerinalang.test.util.BCompileUtil;
import org.ballerinalang.test.util.CompileResult;
import org.testng.annotations.Test;

import static org.ballerinalang.test.util.BAssertUtil.validateError;
import static org.testng.Assert.assertEquals;

/**
 * Test cases for imports.
 */
public class ImportsTest {

    @Test(description = "Test self import")
    public void testSelfImport() {
        CompileResult result = BCompileUtil.compile("test-src/imports/self-import", "foo");
        assertEquals(result.getErrorCount(), 1);
        validateError(result, 0, "cyclic module imports detected 'foo -> foo'", 2, 1);
    }

    @Test(description = "Test cyclic imports")
    public void testCyclicImports() {
        CompileResult result = BCompileUtil.compile("test-src/imports/cyclic-imports", "abc");
        assertEquals(result.getErrorCount(), 3);
        validateError(result, 0, "cyclic module imports detected 'def -> ghi -> def'", 2, 1);
        validateError(result, 1, "cyclic module imports detected 'abc -> def -> ghi -> jkl -> abc'", 2, 1);
        validateError(result, 2, "cyclic module imports detected 'abc -> def -> ghi -> abc'", 3, 1);
    }
}
