// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;

type InstructionGenerator object {
    jvm:MethodVisitor mv;
    BalToJVMIndexMap indexMap;
    string currentPackageName;

    public function __init(jvm:MethodVisitor mv, BalToJVMIndexMap indexMap, string currentPackageName) {
        self.mv = mv;
        self.indexMap = indexMap;
        self.currentPackageName = currentPackageName;
    }

    function generateConstantLoadIns(bir:ConstantLoad loadIns) {
        bir:BType bType = loadIns.typeValue;

        if (bType is bir:BTypeInt || bType is bir:BTypeByte) {
            any val = loadIns.value;
            self.mv.visitLdcInsn(val);
        } else if (bType is bir:BTypeFloat) {
            any val = loadIns.value;
            self.mv.visitLdcInsn(val);
        } else if (bType is bir:BTypeString) {
            any val = loadIns.value;
            self.mv.visitLdcInsn(val);
        } else if (bType is bir:BTypeBoolean) {
            any val = loadIns.value;
            self.mv.visitLdcInsn(val);
        } else if (bType is bir:BTypeNil) {
            self.mv.visitInsn(ACONST_NULL);
        } else {
            error err = error( "JVM generation is not supported for type : " + io:sprintf("%s", bType));
            panic err;
        }

        self.storeToVar(loadIns.lhsOp.variableDcl);
    }

    function generateMoveIns(bir:Move moveIns) {
        self.loadVar(moveIns.rhsOp.variableDcl);
        self.storeToVar(moveIns.lhsOp.variableDcl);
    }


    function generateBinaryOpIns(bir:BinaryOp binaryIns) {
        if (binaryIns.kind == bir:BINARY_LESS_THAN) {
            self.generateLessThanIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_ADD) {
            self.generateAddIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_EQUAL) {
            self.generateEqualIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_SUB) {
            self.generateSubIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_DIV) {
            self.generateDivIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_MUL) {
            self.generateMulIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_MOD) {
            self.generateRemIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_AND) {
            self.generateAndIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_OR) {
            self.generateOrIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_LESS_EQUAL) {
            self.generateLessEqualIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_NOT_EQUAL) {
            self.generateNotEqualIns(binaryIns);
        }  else if (binaryIns.kind == bir:BINARY_GREATER_THAN) {
            self.generateGreaterThanIns(binaryIns);
        }  else if (binaryIns.kind == bir:BINARY_GREATER_EQUAL) {
            self.generateGreaterEqualIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_REF_EQUAL) {
            self.generateRefEqualIns(binaryIns);
        } else if (binaryIns.kind == bir:BINARY_REF_NOT_EQUAL) {
            self.generateRefNotEqualIns(binaryIns);
        } else {
            error err = error("JVM generation is not supported for type : " + io:sprintf("%s", binaryIns.kind));
            panic err;
        }
    }

    function generateBinaryRhsAndLhsLoad(bir:BinaryOp binaryIns) {
        self.loadVar(binaryIns.rhsOp1.variableDcl);
        self.loadVar(binaryIns.rhsOp2.variableDcl);
    }

    private function generateLessThanIns(bir:BinaryOp binaryIns) {
        self.generateBinaryCompareIns(binaryIns, IFLT);
    }

    private function generateGreaterThanIns(bir:BinaryOp binaryIns) {
        self.generateBinaryCompareIns(binaryIns, IFGT);
    }

    private function generateLessEqualIns(bir:BinaryOp binaryIns) {
        self.generateBinaryCompareIns(binaryIns, IFLE);

    }

    private function generateGreaterEqualIns(bir:BinaryOp binaryIns) {
        self.generateBinaryCompareIns(binaryIns, IFGE);
    }

    private function generateBinaryCompareIns(bir:BinaryOp binaryIns, int opcode) {
        if (opcode != IFLT && opcode != IFGT && opcode != IFLE && opcode != IFGE) {
            error err = error(io:sprintf("Unsupported opcode '%s' for binary operator.", opcode));
            panic err;
        }

        self.generateBinaryRhsAndLhsLoad(binaryIns);
        jvm:Label label1 = new;
        jvm:Label label2 = new;

        self.mv.visitInsn(LCMP);
        self.mv.visitJumpInsn(opcode, label1);

        self.mv.visitInsn(ICONST_0);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_1);

        self.mv.visitLabel(label2);
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateEqualIns(bir:BinaryOp binaryIns) {
        self.generateBinaryRhsAndLhsLoad(binaryIns);

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        bir:BType lhsOpType = binaryIns.rhsOp1.variableDcl.typeValue;
        bir:BType rhsOpType = binaryIns.rhsOp2.variableDcl.typeValue;
        if (lhsOpType is bir:BTypeInt|bir:BTypeByte && rhsOpType is bir:BTypeInt|bir:BTypeByte) {
            self.mv.visitInsn(LCMP);
            self.mv.visitJumpInsn(IFNE, label1);
        } else if (lhsOpType is bir:BTypeFloat && rhsOpType is bir:BTypeFloat) {
            self.mv.visitInsn(DCMPL);
            self.mv.visitJumpInsn(IFNE, label1);
        } else if (lhsOpType is bir:BTypeBoolean && rhsOpType is bir:BTypeBoolean) {
            self.mv.visitJumpInsn(IF_ICMPNE, label1);
        } else {
            self.mv.visitMethodInsn(INVOKESTATIC, TYPE_CHECKER, "isEqual",
                    io:sprintf("(L%s;L%s;)Z", OBJECT, OBJECT), false);
            self.storeToVar(binaryIns.lhsOp.variableDcl);
            return;
        }

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_0);

        self.mv.visitLabel(label2);
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateNotEqualIns(bir:BinaryOp binaryIns) {
        self.generateBinaryRhsAndLhsLoad(binaryIns);

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        // It is assumed that both operands are of same type
        bir:BType lhsOpType = binaryIns.rhsOp1.variableDcl.typeValue;
        bir:BType rhsOpType = binaryIns.rhsOp2.variableDcl.typeValue;
        if (lhsOpType is bir:BTypeInt|bir:BTypeByte && rhsOpType is bir:BTypeInt|bir:BTypeByte) {
            self.mv.visitInsn(LCMP);
            self.mv.visitJumpInsn(IFEQ, label1);
        } else if (lhsOpType is bir:BTypeFloat && rhsOpType is bir:BTypeFloat) {
            self.mv.visitInsn(DCMPL);
            self.mv.visitJumpInsn(IFEQ, label1);
        } else if (lhsOpType is bir:BTypeBoolean && rhsOpType is bir:BTypeBoolean) {
            self.mv.visitJumpInsn(IF_ICMPEQ, label1);
        } else {
            self.mv.visitMethodInsn(INVOKESTATIC, TYPE_CHECKER, "isEqual",
                    io:sprintf("(L%s;L%s;)Z", OBJECT, OBJECT), false);
            self.mv.visitJumpInsn(IFNE, label1);
        }

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_0);

        self.mv.visitLabel(label2);
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateRefEqualIns(bir:BinaryOp binaryIns) {
        self.generateBinaryRhsAndLhsLoad(binaryIns);

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        bir:BType lhsOpType = binaryIns.rhsOp1.variableDcl.typeValue;
        bir:BType rhsOpType = binaryIns.rhsOp2.variableDcl.typeValue;
        if (lhsOpType is bir:BTypeInt|bir:BTypeByte && rhsOpType is bir:BTypeInt|bir:BTypeByte) {
            self.mv.visitInsn(LCMP);
            self.mv.visitJumpInsn(IFNE, label1);
        } else if (lhsOpType is bir:BTypeFloat && rhsOpType is bir:BTypeFloat) {
            self.mv.visitInsn(DCMPL);
            self.mv.visitJumpInsn(IFNE, label1);
        } else if (lhsOpType is bir:BTypeBoolean && rhsOpType is bir:BTypeBoolean) {
            self.mv.visitJumpInsn(IF_ICMPNE, label1);
        } else {
            self.mv.visitMethodInsn(INVOKESTATIC, TYPE_CHECKER, "isReferenceEqual",
                    io:sprintf("(L%s;L%s;)Z", OBJECT, OBJECT), false);
            self.storeToVar(binaryIns.lhsOp.variableDcl);
            return;
        }

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_0);

        self.mv.visitLabel(label2);
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateRefNotEqualIns(bir:BinaryOp binaryIns) {
        self.generateBinaryRhsAndLhsLoad(binaryIns);

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        // It is assumed that both operands are of same type
        bir:BType lhsOpType = binaryIns.rhsOp1.variableDcl.typeValue;
        bir:BType rhsOpType = binaryIns.rhsOp2.variableDcl.typeValue;
        if (lhsOpType is bir:BTypeInt|bir:BTypeByte && rhsOpType is bir:BTypeInt|bir:BTypeByte) {
            self.mv.visitInsn(LCMP);
            self.mv.visitJumpInsn(IFEQ, label1);
        } else if (lhsOpType is bir:BTypeFloat && rhsOpType is bir:BTypeFloat) {
            self.mv.visitInsn(DCMPL);
            self.mv.visitJumpInsn(IFEQ, label1);
        } else if (lhsOpType is bir:BTypeBoolean && rhsOpType is bir:BTypeBoolean) {
            self.mv.visitJumpInsn(IF_ICMPEQ, label1);
        } else {
            self.mv.visitMethodInsn(INVOKESTATIC, TYPE_CHECKER, "isReferenceEqual",
                    io:sprintf("(L%s;L%s;)Z", OBJECT, OBJECT), false);
            self.mv.visitJumpInsn(IFNE, label1);
        }

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_0);

        self.mv.visitLabel(label2);
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateAddIns(bir:BinaryOp binaryIns) {
        bir:BType bType = binaryIns.lhsOp.typeValue;
        if (bType is bir:BTypeInt || bType is bir:BTypeByte) {
            self.generateBinaryRhsAndLhsLoad(binaryIns);
            self.mv.visitInsn(LADD);
        } else if (bType is bir:BTypeString) {
            self.generateBinaryRhsAndLhsLoad(binaryIns);
            self.mv.visitMethodInsn(INVOKEVIRTUAL, "java/lang/String", "concat",
                                    io:sprintf("(L%s;)L%s;", STRING_VALUE, STRING_VALUE) , false);
        } else if (bType is bir:BTypeFloat) {
            self.generateBinaryRhsAndLhsLoad(binaryIns);
            self.mv.visitInsn(DADD);
        } else if (bType is bir:BXMLType) {
            self.generateBinaryRhsAndLhsLoad(binaryIns);
            self.mv.visitMethodInsn(INVOKESTATIC, XML_FACTORY, "concatenate", 
                                    io:sprintf("(L%s;L%s;)L%s;", XML_VALUE, XML_VALUE, XML_VALUE), false);
        } else {
            error err = error("JVM generation is not supported for type " +
                              io:sprintf("%s", binaryIns.lhsOp.typeValue));
            panic err;
        }

        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateSubIns(bir:BinaryOp binaryIns) {
        bir:BType bType = binaryIns.lhsOp.typeValue;
        self.generateBinaryRhsAndLhsLoad(binaryIns);
        if (bType is bir:BTypeInt) {
            self.mv.visitInsn(LSUB);
        } else if (bType is bir:BTypeFloat) {
            self.mv.visitInsn(DSUB);
        } else {
            error err = error( "JVM generation is not supported for type " +
                            io:sprintf("%s", binaryIns.lhsOp.typeValue));
            panic err;
        }
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateDivIns(bir:BinaryOp binaryIns) {
        bir:BType bType = binaryIns.lhsOp.typeValue;
        self.generateBinaryRhsAndLhsLoad(binaryIns);
        if (bType is bir:BTypeInt) {
            self.mv.visitInsn(LDIV);
        } else if (bType is bir:BTypeFloat) {
            self.mv.visitInsn(DDIV);
        } else {
            error err = error( "JVM generation is not supported for type " +
                            io:sprintf("%s", binaryIns.lhsOp.typeValue));
            panic err;
        }
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateMulIns(bir:BinaryOp binaryIns) {
        bir:BType bType = binaryIns.lhsOp.typeValue;
        self.generateBinaryRhsAndLhsLoad(binaryIns);
        if (bType is bir:BTypeInt) {
            self.mv.visitInsn(LMUL);
        } else if (bType is bir:BTypeFloat) {
            self.mv.visitInsn(DMUL);
        } else {
            error err = error( "JVM generation is not supported for type " +
                            io:sprintf("%s", binaryIns.lhsOp.typeValue));
            panic err;
        }
        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateRemIns(bir:BinaryOp binaryIns) {
            bir:BType bType = binaryIns.lhsOp.typeValue;
            self.generateBinaryRhsAndLhsLoad(binaryIns);
            if (bType is bir:BTypeInt) {
                self.mv.visitInsn(LREM);
            } else if (bType is bir:BTypeFloat) {
                self.mv.visitInsn(DREM);
            } else {
                error err = error( "JVM generation is not supported for type " +
                                io:sprintf("%s", binaryIns.lhsOp.typeValue));
                panic err;
            }
            self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateAndIns(bir:BinaryOp binaryIns) {
        // ILOAD
        // ICONST_1
        // IF_ICMPNE L0
        // ILOAD
        // ICONST_1
        // IF_ICMPNE L0
        // ICONST_1
        // ISTORE

        //io:println("AND ins : " + io:sprintf("%s", binaryIns));

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        self.loadVar(binaryIns.rhsOp1.variableDcl);

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(IF_ICMPNE, label1);

        self.loadVar(binaryIns.rhsOp2.variableDcl);

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(IF_ICMPNE, label1);

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_0);

        self.mv.visitLabel(label2);

        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function generateOrIns(bir:BinaryOp binaryIns) {
        // ILOAD
        // ICONST_1
        // IF_ICMPNE L0
        // ILOAD
        // ICONST_1
        // IF_ICMPNE L0
        // ICONST_1
        // ISTORE

        //io:println("OR ins : " + io:sprintf("%s", binaryIns));

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        self.loadVar(binaryIns.rhsOp1.variableDcl);

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(IF_ICMPEQ, label1);

        self.loadVar(binaryIns.rhsOp2.variableDcl);

        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(IF_ICMPEQ, label1);

        self.mv.visitInsn(ICONST_0);
        self.mv.visitJumpInsn(GOTO, label2);

        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_1);

        self.mv.visitLabel(label2);

        self.storeToVar(binaryIns.lhsOp.variableDcl);
    }

    function getJVMIndexOfVarRef(bir:VariableDcl varDcl) returns int {
        return self.indexMap.getIndex(varDcl);
    }

    function generateMapNewIns(bir:NewMap mapNewIns) {
        bir:BType typeOfMapNewIns = mapNewIns.typeValue;

        string className = MAP_VALUE_IMPL;

        if (typeOfMapNewIns is bir:BRecordType) {
            className = self.currentPackageName + cleanupTypeName(typeOfMapNewIns.name.value);
        }

        self.mv.visitTypeInsn(NEW, className);
        self.mv.visitInsn(DUP);
        loadType(self.mv, mapNewIns.typeValue);
        self.mv.visitMethodInsn(INVOKESPECIAL, className, "<init>", io:sprintf("(L%s;)V", BTYPE), false);
        self.storeToVar(mapNewIns.lhsOp.variableDcl);
    }

    function generateTableNewIns(bir:NewTable tableNewIns) {
        self.mv.visitTypeInsn(NEW, TABLE_VALUE);
        self.mv.visitInsn(DUP);
        loadType(self.mv, tableNewIns.typeValue);
        self.loadVar(tableNewIns.indexColOp.variableDcl);
        self.loadVar(tableNewIns.keyColOp.variableDcl);
        self.loadVar(tableNewIns.dataOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESPECIAL, TABLE_VALUE, "<init>", io:sprintf("(L%s;L%s;L%s;L%s;)V", BTYPE,
                ARRAY_VALUE, ARRAY_VALUE, ARRAY_VALUE), false);
        self.storeToVar(tableNewIns.lhsOp.variableDcl);
    }

    function generateStreamNewIns(bir:NewStream streamNewIns) {
        self.mv.visitTypeInsn(NEW, STREAM_VALUE);
        self.mv.visitInsn(DUP);
        loadType(self.mv, streamNewIns.typeValue);
        self.loadVar(streamNewIns.nameOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESPECIAL, STREAM_VALUE, "<init>", io:sprintf("(L%s;L%s;)V", BTYPE,
                STRING_VALUE), false);
        self.storeToVar(streamNewIns.lhsOp.variableDcl);
    }

    function generateMapStoreIns(bir:FieldAccess mapStoreIns) {
        // visit map_ref
        self.loadVar(mapStoreIns.lhsOp.variableDcl);
        bir:BType varRefType = mapStoreIns.lhsOp.variableDcl.typeValue;

        // visit key_expr
        self.loadVar(mapStoreIns.keyOp.variableDcl);

        // visit value_expr
        bir:BType valueType = mapStoreIns.rhsOp.variableDcl.typeValue;
        self.loadVar(mapStoreIns.rhsOp.variableDcl);
        addBoxInsn(self.mv, valueType);

        if (varRefType is bir:BJSONType) {
            self.mv.visitMethodInsn(INVOKESTATIC, JSON_UTILS, "setElement",
                    io:sprintf("(L%s;L%s;L%s;)V", OBJECT, STRING_VALUE, OBJECT), false);
        } else {
            self.mv.visitMethodInsn(INVOKEINTERFACE, MAP_VALUE, "put",
                    io:sprintf("(L%s;L%s;)L%s;", OBJECT, OBJECT, OBJECT), true);

            // emit a pop, since we are not using the return value from the map.put()
            self.mv.visitInsn(POP);
        }
    }

    function generateMapLoadIns(bir:FieldAccess mapLoadIns) {
        // visit map_ref
        self.loadVar(mapLoadIns.rhsOp.variableDcl);
        bir:BType varRefType = mapLoadIns.rhsOp.variableDcl.typeValue;
        addUnboxInsn(self.mv, varRefType);

        // visit key_expr
        self.loadVar(mapLoadIns.keyOp.variableDcl);

        if (varRefType is bir:BJSONType) {
            self.mv.visitTypeInsn(CHECKCAST, STRING_VALUE);
            self.mv.visitMethodInsn(INVOKESTATIC, JSON_UTILS, "getElement",
                    io:sprintf("(L%s;L%s;)L%s;", OBJECT, STRING_VALUE, OBJECT), false);
        } else {
            self.mv.visitMethodInsn(INVOKEINTERFACE, MAP_VALUE, "get",
                    io:sprintf("(L%s;)L%s;", OBJECT, OBJECT), true);
        }

        // store in the target reg
        bir:BType targetType = mapLoadIns.lhsOp.variableDcl.typeValue;
        addUnboxInsn(self.mv, targetType);
        self.storeToVar(mapLoadIns.lhsOp.variableDcl);
    }

    function generateObjectLoadIns(bir:FieldAccess objectLoadIns) {
        // visit object_ref
        self.loadVar(objectLoadIns.rhsOp.variableDcl);
        bir:BType varRefType = objectLoadIns.rhsOp.variableDcl.typeValue;

        // visit key_expr
        self.loadVar(objectLoadIns.keyOp.variableDcl);

        // invoke get() method, and unbox if needed
        self.mv.visitMethodInsn(INVOKEINTERFACE, OBJECT_VALUE, "get",
                io:sprintf("(L%s;)L%s;", STRING_VALUE, OBJECT), true);
        bir:BType targetType = objectLoadIns.lhsOp.variableDcl.typeValue;
        addUnboxInsn(self.mv, targetType);

        // store in the target reg
        self.storeToVar(objectLoadIns.lhsOp.variableDcl);
    }

    function generateObjectStoreIns(bir:FieldAccess objectStoreIns) {
        // visit object_ref
        self.loadVar(objectStoreIns.lhsOp.variableDcl);
        bir:BType varRefType = objectStoreIns.lhsOp.variableDcl.typeValue;

        // visit key_expr
        self.loadVar(objectStoreIns.keyOp.variableDcl);

        // visit value_expr
        bir:BType valueType = objectStoreIns.rhsOp.variableDcl.typeValue;
        self.loadVar(objectStoreIns.rhsOp.variableDcl);
        addBoxInsn(self.mv, valueType);

        // invoke set() method
        self.mv.visitMethodInsn(INVOKEINTERFACE, OBJECT_VALUE, "set",
                io:sprintf("(L%s;L%s;)V", STRING_VALUE, OBJECT), true);
    }

    # Generate a new instance of an array value
    # 
    # + inst - the new array instruction
    function generateArrayNewIns(bir:NewArray inst) {
        self.mv.visitTypeInsn(NEW, ARRAY_VALUE);
        self.mv.visitInsn(DUP);
        loadType(self.mv, inst.typeValue);
        self.loadVar(inst.sizeOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESPECIAL, ARRAY_VALUE, "<init>", io:sprintf("(L%s;J)V", BTYPE), false);
        self.storeToVar(inst.lhsOp.variableDcl);
    }

    # Generate adding a new value to an array
    # 
    # + inst - array store instruction
    function generateArrayStoreIns(bir:FieldAccess inst) {
        self.loadVar(inst.lhsOp.variableDcl);
        self.loadVar(inst.keyOp.variableDcl);
        self.loadVar(inst.rhsOp.variableDcl);

        bir:BType varRefType = inst.lhsOp.variableDcl.typeValue;
        if (varRefType is bir:BJSONType ||
                (varRefType is bir:BArrayType && varRefType.eType  is bir:BJSONType)) {
            self.mv.visitMethodInsn(INVOKESTATIC, JSON_UTILS, "setArrayElement",
                    io:sprintf("(L%s;JL%s;)V", OBJECT, OBJECT), false);
            return;
        }

        string valueDesc;
        if (varRefType is bir:BArrayType) {
            if (varRefType.eType is bir:BTypeByte) {
                self.mv.visitInsn(L2I);
                self.mv.visitInsn(I2B);
                valueDesc = "B";
            } else if (varRefType.eType is bir:BTypeInt) {
                valueDesc = "J";
            } else if (varRefType.eType is bir:BTypeString) {
                valueDesc = io:sprintf("L%s;", STRING_VALUE);
            } else if (varRefType.eType is bir:BTypeBoolean) {
                valueDesc = "Z";
            } else if (varRefType.eType is bir:BTypeFloat) {
                valueDesc = "D";
            } else {
                valueDesc = io:sprintf("L%s;", OBJECT);
            }
        } else {
            valueDesc = io:sprintf("L%s;", OBJECT);
        }

        self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "add", io:sprintf("(J%s)V", valueDesc), false);
    }

    # Generating loading a new value from an array to the top of the stack
    # 
    # + inst - field access instruction
    function generateArrayValueLoad(bir:FieldAccess inst) {
        self.loadVar(inst.rhsOp.variableDcl);
        self.loadVar(inst.keyOp.variableDcl);
        bir:BType bType = inst.lhsOp.variableDcl.typeValue;

        bir:BType varRefType = inst.rhsOp.variableDcl.typeValue;
        if (varRefType is bir:BJSONType ||
                (varRefType is bir:BArrayType && varRefType.eType  is bir:BJSONType)) {
            self.mv.visitMethodInsn(INVOKESTATIC, JSON_UTILS, "getArrayElement",
                        io:sprintf("(L%s;J)L%s;", OBJECT, OBJECT), false);
        } else if (bType is bir:BTypeInt) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getInt", "(J)J", false);
        } else if (bType is bir:BTypeString) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getString", io:sprintf("(J)L%s;", STRING_VALUE),
                                        false);
        } else if (bType is bir:BTypeBoolean) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getBoolean", "(J)Z", false);
        } else if (bType is bir:BTypeByte) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getByte", "(J)B", false);
        } else if (bType is bir:BTypeFloat) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getFloat", "(J)D", false);
        } else if (bType is bir:BRecordType) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getRefValue", io:sprintf("(J)L%s;", OBJECT), false);
            self.mv.visitTypeInsn(CHECKCAST, MAP_VALUE);
        } else if (bType is bir:BXMLType) {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getRefValue", io:sprintf("(J)L%s;", OBJECT), false);
            self.mv.visitTypeInsn(CHECKCAST, XML_VALUE);
        } else {
            self.mv.visitMethodInsn(INVOKEVIRTUAL, ARRAY_VALUE, "getRefValue", io:sprintf("(J)L%s;", OBJECT), false);
        }

        self.storeToVar(inst.lhsOp.variableDcl);
    }

    function generateNewErrorIns(bir:NewError newErrorIns) {
        self.mv.visitTypeInsn(NEW, ERROR_VALUE);
        self.mv.visitInsn(DUP);
        self.loadVar(newErrorIns.reasonOp.variableDcl);
        self.loadVar(newErrorIns.detailsOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESPECIAL, ERROR_VALUE, "<init>",
                           io:sprintf("(L%s;L%s;)V", STRING_VALUE, OBJECT), false);
        self.storeToVar(newErrorIns.lhsOp.variableDcl);
    }

    function generateCastIns(bir:TypeCast typeCastIns) {
        // load source value
        self.loadVar(typeCastIns.rhsOp.variableDcl);
        generateCheckCast(self.mv, typeCastIns.rhsOp.typeValue, typeCastIns.lhsOp.typeValue);
        self.storeToVar(typeCastIns.lhsOp.variableDcl);
    }

    function generateTypeTestIns(bir:TypeTest typeTestIns) {
        // load source value
        self.loadVar(typeTestIns.rhsOp.variableDcl);

        // load targetType
        loadType(self.mv, typeTestIns.typeValue);

        self.mv.visitMethodInsn(INVOKESTATIC, TYPE_CHECKER, "checkIsType",
                io:sprintf("(L%s;L%s;)Z", OBJECT, BTYPE), false);
        self.storeToVar(typeTestIns.lhsOp.variableDcl);
    }

    function generateObjectNewIns(bir:NewInstance objectNewIns) {
        string className = self.currentPackageName + cleanupTypeName(objectNewIns.typeDef.name.value);
        self.mv.visitTypeInsn(NEW, className);
        self.mv.visitInsn(DUP);
        loadType(self.mv, objectNewIns.typeDef.typeValue);
        self.mv.visitTypeInsn(CHECKCAST, OBJECT_TYPE);
        self.mv.visitMethodInsn(INVOKESPECIAL, className, "<init>", io:sprintf("(L%s;)V", OBJECT_TYPE), false);
        self.storeToVar(objectNewIns.lhsOp.variableDcl);

        // todo : check if this is a new service object creation and process its annotation
        boolean isServiceType = false;

        if (isServiceType) {
            string varName = "#0";
            string pkgClassName = lookupGlobalVarClassName(self.currentPackageName + varName);
            self.mv.visitFieldInsn(GETSTATIC, pkgClassName, varName, io:sprintf("L%s;", MAP_VALUE));
            loadType(self.mv, objectNewIns.typeDef.typeValue);
            self.mv.visitTypeInsn(CHECKCAST, OBJECT_TYPE);
            self.mv.visitMethodInsn(INVOKESTATIC, io:sprintf("%s", ANNOTATION_UTILS), "processObjectAnnotations",
                                        io:sprintf("(L%s;L%s;)V", MAP_VALUE, OBJECT_TYPE), false);
        }
    }

    function generateFPLoadIns(bir:FPLoad inst) {
        string lambdaName = inst.name.value + "$lambda$";
        string methodClass = lookupFullQualifiedClassName(self.currentPackageName + inst.name.value);
        bir:BType returnType = inst.lhsOp.typeValue;
        boolean isVoid = false;
        if (returnType is bir:BInvokableType) {
            isVoid = returnType.retType is bir:BTypeNil;
        } else {
            error err = error( "Expected BInvokableType, found " + io:sprintf("%s", returnType));
            panic err;
        }
        foreach var v in inst.closureMaps {
            if (v is bir:VarRef) {
                self.loadVar(v.variableDcl);
            }
        }
        self.mv.visitInvokeDynamicInsn(methodClass, lambdaName, isVoid, inst.closureMaps.length());
        generateVarStore(self.mv, inst.lhsOp.variableDcl, self.currentPackageName, 
            self.getJVMIndexOfVarRef(inst.lhsOp.variableDcl));
        lambdas[lambdaName] = (inst, methodClass);
    }

    function generateNewXMLElementIns(bir:NewXMLElement newXMLElement) {
        self.loadVar(newXMLElement.startTagOp.variableDcl);
        self.mv.visitTypeInsn(CHECKCAST, XML_QNAME);
        self.loadVar(newXMLElement.endTagOp.variableDcl);
        self.mv.visitTypeInsn(CHECKCAST, XML_QNAME);
        self.loadVar(newXMLElement.defaultNsURIOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESTATIC, XML_FACTORY, "createXMLElement",
                io:sprintf("(L%s;L%s;L%s;)L%s;", XML_QNAME, XML_QNAME, STRING_VALUE, XML_VALUE), false);
        self.storeToVar(newXMLElement.lhsOp.variableDcl);
    }

    function generateNewXMLQNameIns(bir:NewXMLQName newXMLQName) {
        self.mv.visitTypeInsn(NEW, XML_QNAME);
        self.mv.visitInsn(DUP);
        self.loadVar(newXMLQName.localnameOp.variableDcl);
        self.loadVar(newXMLQName.nsURIOp.variableDcl);
        self.loadVar(newXMLQName.prefixOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESPECIAL, XML_QNAME, "<init>",
                io:sprintf("(L%s;L%s;L%s;)V", STRING_VALUE, STRING_VALUE, STRING_VALUE), false);
        self.storeToVar(newXMLQName.lhsOp.variableDcl);
    }

    function generateNewStringXMLQNameIns(bir:NewStringXMLQName newStringXMLQName) {
        self.mv.visitTypeInsn(NEW, XML_QNAME);
        self.mv.visitInsn(DUP);
        self.loadVar(newStringXMLQName.stringQNameOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESPECIAL, XML_QNAME, "<init>",
                io:sprintf("(L%s;)V", STRING_VALUE), false);
        self.storeToVar(newStringXMLQName.lhsOp.variableDcl);
    }

    function generateNewXMLTextIns(bir:NewXMLText newXMLText) {
        self.loadVar(newXMLText.textOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESTATIC, XML_FACTORY, "createXMLText",
                io:sprintf("(L%s;)L%s;", STRING_VALUE, XML_VALUE), false);
        self.storeToVar(newXMLText.lhsOp.variableDcl);
    }

    function generateNewXMLCommentIns(bir:NewXMLComment newXMLComment) {
        self.loadVar(newXMLComment.textOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESTATIC, XML_FACTORY, "createXMLComment",
                io:sprintf("(L%s;)L%s;", STRING_VALUE, XML_VALUE), false);
        self.storeToVar(newXMLComment.lhsOp.variableDcl);
    }

    function generateNewXMLProcIns(bir:NewXMLPI newXMLPI) {
        self.loadVar(newXMLPI.targetOp.variableDcl);
        self.loadVar(newXMLPI.dataOp.variableDcl);
        self.mv.visitMethodInsn(INVOKESTATIC, XML_FACTORY, "createXMLProcessingInstruction",
                io:sprintf("(L%s;L%s;)L%s;", STRING_VALUE, STRING_VALUE, XML_VALUE), false);
        self.storeToVar(newXMLPI.lhsOp.variableDcl);
    }

    function generateXMLStoreIns(bir:XMLAccess xmlStoreIns) {
        self.loadVar(xmlStoreIns.lhsOp.variableDcl);
        self.loadVar(xmlStoreIns.rhsOp.variableDcl);
        self.mv.visitMethodInsn(INVOKEVIRTUAL, XML_VALUE, "addChildren", io:sprintf("(L%s;)V", XML_VALUE),
                                        false);
    }

    function generateXMLLoadAllIns(bir:XMLAccess xmlLoadAllIns) {
        self.loadVar(xmlLoadAllIns.rhsOp.variableDcl);
        self.mv.visitMethodInsn(INVOKEVIRTUAL, XML_VALUE, "children", io:sprintf("()L%s;", XML_VALUE),
                                        false);
        self.storeToVar(xmlLoadAllIns.lhsOp.variableDcl);
    }

    function generateXMLAttrLoadIns(bir:FieldAccess xmlAttrStoreIns) {
        // visit xml_ref
        self.loadVar(xmlAttrStoreIns.rhsOp.variableDcl);

        // visit attribute name expr
        self.loadVar(xmlAttrStoreIns.keyOp.variableDcl);
        self.mv.visitTypeInsn(CHECKCAST, XML_QNAME);

        // invoke getAttribute() method
        self.mv.visitMethodInsn(INVOKEVIRTUAL, XML_VALUE, "getAttribute",
                io:sprintf("(L%s;)L%s;", XML_QNAME, STRING_VALUE), false);

        // store in the target reg
        bir:BType targetType = xmlAttrStoreIns.lhsOp.variableDcl.typeValue;
        self.storeToVar(xmlAttrStoreIns.lhsOp.variableDcl);
    }

    function generateXMLAttrStoreIns(bir:FieldAccess xmlAttrStoreIns) {
        // visit xml_ref
        self.loadVar(xmlAttrStoreIns.lhsOp.variableDcl);

        // visit attribute name expr
        self.loadVar(xmlAttrStoreIns.keyOp.variableDcl);
        self.mv.visitTypeInsn(CHECKCAST, XML_QNAME);

        // visit attribute value expr
        self.loadVar(xmlAttrStoreIns.rhsOp.variableDcl);

        // invoke setAttribute() method
        self.mv.visitMethodInsn(INVOKEVIRTUAL, XML_VALUE, "setAttribute",
                io:sprintf("(L%s;L%s;)V", XML_QNAME, STRING_VALUE), false);
    }

    function generateXMLLoadIns(bir:FieldAccess xmlLoadIns) {
        // visit xml_ref
        self.loadVar(xmlLoadIns.rhsOp.variableDcl);

        // visit element name/index expr
        self.loadVar(xmlLoadIns.keyOp.variableDcl);

        if (xmlLoadIns.keyOp.variableDcl.typeValue is bir:BTypeString) {
            // invoke `children(name)` method
            self.mv.visitMethodInsn(INVOKEVIRTUAL, XML_VALUE, "children",
                io:sprintf("(L%s;)L%s;", STRING_VALUE, XML_VALUE), false);
        } else {
            // invoke `getItem(index)` method
            self.mv.visitInsn(L2I);
            self.mv.visitMethodInsn(INVOKEVIRTUAL, XML_VALUE, "getItem",
                io:sprintf("(I)L%s;", XML_VALUE), false);
        }

        // store in the target reg
        bir:BType targetType = xmlLoadIns.lhsOp.variableDcl.typeValue;
        self.storeToVar(xmlLoadIns.lhsOp.variableDcl);
    }

    function generateTypeofIns(bir:UnaryOp unaryOp) {
        self.loadVar(unaryOp.rhsOp.variableDcl);
        addBoxInsn(self.mv, unaryOp.rhsOp.variableDcl.typeValue);
        self.mv.visitMethodInsn(INVOKESTATIC, TYPE_CHECKER, "getTypedesc",
                io:sprintf("(L%s;)L%s;", OBJECT, TYPEDESC_VALUE), false);
        self.storeToVar(unaryOp.lhsOp.variableDcl);
    }

    function generateNotIns(bir:UnaryOp unaryOp) {
        self.loadVar(unaryOp.rhsOp.variableDcl);

        jvm:Label label1 = new;
        jvm:Label label2 = new;

        self.mv.visitJumpInsn(IFNE, label1);
        self.mv.visitInsn(ICONST_1);
        self.mv.visitJumpInsn(GOTO, label2);
        self.mv.visitLabel(label1);
        self.mv.visitInsn(ICONST_0);
        self.mv.visitLabel(label2);

        self.storeToVar(unaryOp.lhsOp.variableDcl);
    }

    function generateNewTypedescIns(bir:NewTypeDesc newTypeDesc) {
        self.mv.visitTypeInsn(NEW, TYPEDESC_VALUE);
        self.mv.visitInsn(DUP);
        loadType(self.mv, newTypeDesc.typeValue);
        self.mv.visitMethodInsn(INVOKESPECIAL, TYPEDESC_VALUE, "<init>",
                io:sprintf("(L%s;)V", BTYPE), false);
        self.storeToVar(newTypeDesc.lhsOp.variableDcl);
    }

    function generateTernaryIns(bir:Ternary ternary) {
        jvm:Label label1 = new;
        jvm:Label label2 = new;

        self.loadVar(ternary.conditionOp.variableDcl);
        self.mv.visitJumpInsn(IFNE, label1);

        // if true
        self.loadVar(ternary.thenOp.variableDcl);
        self.mv.visitJumpInsn(GOTO, label2);

        // else
        self.mv.visitLabel(label1);
        self.loadVar(ternary.elseOp.variableDcl);

        self.mv.visitLabel(label2);
        self.storeToVar(ternary.lhsOp.variableDcl);
    }

    private function loadVar(bir:VariableDcl varDcl) {
        generateVarLoad(self.mv, varDcl, self.currentPackageName, self.getJVMIndexOfVarRef(varDcl));
    }

    private function storeToVar(bir:VariableDcl varDcl) {
        generateVarStore(self.mv, varDcl, self.currentPackageName, self.getJVMIndexOfVarRef(varDcl));
    }
};

function addBoxInsn(jvm:MethodVisitor mv, bir:BType? bType) {
    if (bType is bir:BType) {
        generateCast(mv, bType, "any");
    }
}

function addUnboxInsn(jvm:MethodVisitor mv, bir:BType bType) {
    generateCast(mv, "any", bType);
}

function generateVarLoad(jvm:MethodVisitor mv, bir:VariableDcl varDcl, string currentPackageName, int valueIndex) {
    bir:BType bType = varDcl.typeValue;

    if (varDcl.kind == bir:VAR_KIND_GLOBAL) {
        string varName = varDcl.name.value;
        string className = lookupGlobalVarClassName(currentPackageName + varName);
        string typeSig = getTypeDesc(bType);
        mv.visitFieldInsn(GETSTATIC, className, varName, typeSig);
        return;
    } else if (varDcl.kind == bir:VAR_KIND_SELF) {
        mv.visitVarInsn(ALOAD, 0);
        return;
    }

    if (bType is bir:BTypeInt || bType is bir:BTypeByte) {
        mv.visitVarInsn(LLOAD, valueIndex);
    } else if (bType is bir:BTypeFloat) {
        mv.visitVarInsn(DLOAD, valueIndex);
    } else if (bType is bir:BTypeBoolean) {
        mv.visitVarInsn(ILOAD, valueIndex);
    } else if (bType is bir:BArrayType ||
                bType is bir:BTypeString ||
                bType is bir:BMapType ||
                bType is bir:BTableType ||
                bType is bir:BStreamType ||
                bType is bir:BTypeAny ||
                bType is bir:BTypeAnyData ||
                bType is bir:BTypeNil ||
                bType is bir:BUnionType ||
                bType is bir:BTupleType ||
                bType is bir:BRecordType ||
                bType is bir:BErrorType ||
                bType is bir:BJSONType ||
                bType is bir:BFutureType ||
                bType is bir:BObjectType ||
                bType is bir:BXMLType ||
                bType is bir:BInvokableType ||
                bType is bir:BFiniteType ||
                bType is bir:BTypeDesc) {
        mv.visitVarInsn(ALOAD, valueIndex);
    } else {
        error err = error( "JVM generation is not supported for type " +io:sprintf("%s", bType));
        panic err;
    }
}

function generateVarStore(jvm:MethodVisitor mv, bir:VariableDcl varDcl, string currentPackageName, int valueIndex) {
    bir:BType bType = varDcl.typeValue;

    if (varDcl.kind == "GLOBAL") {
        string varName = varDcl.name.value;
        string className = lookupGlobalVarClassName(currentPackageName + varName);
        string typeSig = getTypeDesc(bType);
        mv.visitFieldInsn(PUTSTATIC, className, varName, typeSig);
        return;
    }

    if (bType is bir:BTypeInt || bType is bir:BTypeByte) {
        mv.visitVarInsn(LSTORE, valueIndex);
    } else if (bType is bir:BTypeFloat) {
        mv.visitVarInsn(DSTORE, valueIndex);
    } else if (bType is bir:BTypeBoolean) {
        mv.visitVarInsn(ISTORE, valueIndex);
    } else if (bType is bir:BArrayType ||
                    bType is bir:BTypeString ||
                    bType is bir:BMapType ||
                    bType is bir:BTableType ||
                    bType is bir:BStreamType ||
                    bType is bir:BTypeAny ||
                    bType is bir:BTypeAnyData ||
                    bType is bir:BTypeNil ||
                    bType is bir:BUnionType ||
                    bType is bir:BTupleType ||
                    bType is bir:BRecordType ||
                    bType is bir:BErrorType ||
                    bType is bir:BJSONType ||
                    bType is bir:BFutureType ||
                    bType is bir:BObjectType ||
                    bType is bir:BXMLType ||
                    bType is bir:BInvokableType ||
                    bType is bir:BFiniteType ||
                    bType is bir:BTypeDesc) {
        mv.visitVarInsn(ASTORE, valueIndex);
    } else {
        error err = error("JVM generation is not supported for type " +io:sprintf("%s", bType));
        panic err;
    }
}
