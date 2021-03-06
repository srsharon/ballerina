/*
 *  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package org.wso2.ballerinalang.compiler.semantics.model.types;

import org.ballerinalang.model.types.ServiceType;
import org.ballerinalang.model.types.TypeKind;
import org.wso2.ballerinalang.compiler.semantics.model.TypeVisitor;
import org.wso2.ballerinalang.compiler.semantics.model.symbols.BTypeSymbol;
import org.wso2.ballerinalang.compiler.util.Names;
import org.wso2.ballerinalang.compiler.util.TypeDescriptor;
import org.wso2.ballerinalang.compiler.util.TypeTags;

/**
 * {@code {@link BServiceType}} represents the type of a service in Ballerina.
 *
 * @since 0.965.0
 */
public class BServiceType extends BObjectType implements ServiceType {

    public BServiceType(BTypeSymbol tSymbol) {
        super(TypeTags.SERVICE, tSymbol);
    }

    public String getDesc() {
        // TODO: Fix this properly.
        if (!Names.BUILTIN_PACKAGE.equals(tsymbol.pkgID.name)) {
            return super.getDesc();
        }
        return TypeDescriptor.SIG_SERVICE + getQualifiedTypeName() + ";";
    }

    @Override
    public TypeKind getKind() {
        return TypeKind.SERVICE;
    }

    @Override
    public void accept(TypeVisitor visitor) {
        visitor.visit(this);
    }

    @Override
    public <T, R> R accept(BTypeVisitor<T, R> visitor, T t) {
        return visitor.visit(this, t);
    }

    @Override
    public String toString() {
        return this.tsymbol.toString();
    }
}
