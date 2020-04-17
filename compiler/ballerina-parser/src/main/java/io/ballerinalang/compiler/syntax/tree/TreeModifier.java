/*
 *  Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package io.ballerinalang.compiler.syntax.tree;

import io.ballerinalang.compiler.internal.parser.tree.STNode;
import io.ballerinalang.compiler.internal.parser.tree.STNodeFactory;

/**
 * Produces a new tree by doing a depth-first traversal of the tree.
 *
 * This is a generated class.
 *
 * @since 1.3.0
 */
public abstract class TreeModifier extends NodeTransformer<Node> {

    @Override
    public Node transform(ModulePartNode modulePartNode) {
        NodeList<ImportDeclarationNode> imports = modifyNodeList(modulePartNode.imports());
        NodeList<ModuleMemberDeclarationNode> members = modifyNodeList(modulePartNode.members());
        Token eofToken = modifyToken(modulePartNode.eofToken());
        return modulePartNode.modify(
                imports,
                members,
                eofToken);
    }

    @Override
    public Node transform(FunctionDefinitionNode functionDefinitionNode) {
        MetadataNode metadata = modifyNode(functionDefinitionNode.metadata());
        Token visibilityQualifier = modifyToken(functionDefinitionNode.visibilityQualifier());
        Token functionKeyword = modifyToken(functionDefinitionNode.functionKeyword());
        IdentifierToken functionName = modifyNode(functionDefinitionNode.functionName());
        Token openParenToken = modifyToken(functionDefinitionNode.openParenToken());
        NodeList<ParameterNode> parameters = modifyNodeList(functionDefinitionNode.parameters());
        Token closeParenToken = modifyToken(functionDefinitionNode.closeParenToken());
        Node returnTypeDesc = modifyNode(functionDefinitionNode.returnTypeDesc());
        BlockStatementNode functionBody = modifyNode(functionDefinitionNode.functionBody());
        return functionDefinitionNode.modify(
                metadata,
                visibilityQualifier,
                functionKeyword,
                functionName,
                openParenToken,
                parameters,
                closeParenToken,
                returnTypeDesc,
                functionBody);
    }

    @Override
    public Node transform(ImportDeclarationNode importDeclarationNode) {
        Token importKeyword = modifyToken(importDeclarationNode.importKeyword());
        Token orgName = modifyToken(importDeclarationNode.orgName());
        Node moduleName = modifyNode(importDeclarationNode.moduleName());
        Node version = modifyNode(importDeclarationNode.version());
        Node prefix = modifyNode(importDeclarationNode.prefix());
        Token semicolon = modifyToken(importDeclarationNode.semicolon());
        return importDeclarationNode.modify(
                importKeyword,
                orgName,
                moduleName,
                version,
                prefix,
                semicolon);
    }

    @Override
    public Node transform(ListenerDeclarationNode listenerDeclarationNode) {
        MetadataNode metadata = modifyNode(listenerDeclarationNode.metadata());
        Token visibilityQualifier = modifyToken(listenerDeclarationNode.visibilityQualifier());
        Token listenerKeyword = modifyToken(listenerDeclarationNode.listenerKeyword());
        Node typeDescriptor = modifyNode(listenerDeclarationNode.typeDescriptor());
        Token variableName = modifyToken(listenerDeclarationNode.variableName());
        Token equalsToken = modifyToken(listenerDeclarationNode.equalsToken());
        Node initializer = modifyNode(listenerDeclarationNode.initializer());
        Token semicolonToken = modifyToken(listenerDeclarationNode.semicolonToken());
        return listenerDeclarationNode.modify(
                metadata,
                visibilityQualifier,
                listenerKeyword,
                typeDescriptor,
                variableName,
                equalsToken,
                initializer,
                semicolonToken);
    }

    @Override
    public Node transform(TypeDefinitionNode typeDefinitionNode) {
        MetadataNode metadata = modifyNode(typeDefinitionNode.metadata());
        Token visibilityQualifier = modifyToken(typeDefinitionNode.visibilityQualifier());
        Token typeKeyword = modifyToken(typeDefinitionNode.typeKeyword());
        Token typeName = modifyToken(typeDefinitionNode.typeName());
        Node typeDescriptor = modifyNode(typeDefinitionNode.typeDescriptor());
        Token semicolonToken = modifyToken(typeDefinitionNode.semicolonToken());
        return typeDefinitionNode.modify(
                metadata,
                visibilityQualifier,
                typeKeyword,
                typeName,
                typeDescriptor,
                semicolonToken);
    }

    @Override
    public Node transform(ServiceDeclarationNode serviceDeclarationNode) {
        MetadataNode metadata = modifyNode(serviceDeclarationNode.metadata());
        Token serviceKeyword = modifyToken(serviceDeclarationNode.serviceKeyword());
        IdentifierToken serviceName = modifyNode(serviceDeclarationNode.serviceName());
        Token onKeyword = modifyToken(serviceDeclarationNode.onKeyword());
        NodeList<ExpressionNode> expressions = modifyNodeList(serviceDeclarationNode.expressions());
        Node serviceBody = modifyNode(serviceDeclarationNode.serviceBody());
        return serviceDeclarationNode.modify(
                metadata,
                serviceKeyword,
                serviceName,
                onKeyword,
                expressions,
                serviceBody);
    }

    @Override
    public Node transform(AssignmentStatementNode assignmentStatementNode) {
        Node varRef = modifyNode(assignmentStatementNode.varRef());
        Token equalsToken = modifyToken(assignmentStatementNode.equalsToken());
        ExpressionNode expression = modifyNode(assignmentStatementNode.expression());
        Token semicolonToken = modifyToken(assignmentStatementNode.semicolonToken());
        return assignmentStatementNode.modify(
                varRef,
                equalsToken,
                expression,
                semicolonToken);
    }

    @Override
    public Node transform(CompoundAssignmentStatementNode compoundAssignmentStatementNode) {
        ExpressionNode lhsExpression = modifyNode(compoundAssignmentStatementNode.lhsExpression());
        Token binaryOperator = modifyToken(compoundAssignmentStatementNode.binaryOperator());
        Token equalsToken = modifyToken(compoundAssignmentStatementNode.equalsToken());
        ExpressionNode rhsExpression = modifyNode(compoundAssignmentStatementNode.rhsExpression());
        Token semicolonToken = modifyToken(compoundAssignmentStatementNode.semicolonToken());
        return compoundAssignmentStatementNode.modify(
                lhsExpression,
                binaryOperator,
                equalsToken,
                rhsExpression,
                semicolonToken);
    }

    @Override
    public Node transform(VariableDeclarationNode variableDeclarationNode) {
        NodeList<AnnotationNode> annotations = modifyNodeList(variableDeclarationNode.annotations());
        Token finalKeyword = modifyToken(variableDeclarationNode.finalKeyword());
        Node typeName = modifyNode(variableDeclarationNode.typeName());
        Token variableName = modifyToken(variableDeclarationNode.variableName());
        Token equalsToken = modifyToken(variableDeclarationNode.equalsToken());
        ExpressionNode initializer = modifyNode(variableDeclarationNode.initializer());
        Token semicolonToken = modifyToken(variableDeclarationNode.semicolonToken());
        return variableDeclarationNode.modify(
                annotations,
                finalKeyword,
                typeName,
                variableName,
                equalsToken,
                initializer,
                semicolonToken);
    }

    @Override
    public Node transform(BlockStatementNode blockStatementNode) {
        Token openBraceToken = modifyToken(blockStatementNode.openBraceToken());
        NodeList<StatementNode> statements = modifyNodeList(blockStatementNode.statements());
        Token closeBraceToken = modifyToken(blockStatementNode.closeBraceToken());
        return blockStatementNode.modify(
                openBraceToken,
                statements,
                closeBraceToken);
    }

    @Override
    public Node transform(BreakStatementNode breakStatementNode) {
        Token breakToken = modifyToken(breakStatementNode.breakToken());
        Token semicolonToken = modifyToken(breakStatementNode.semicolonToken());
        return breakStatementNode.modify(
                breakToken,
                semicolonToken);
    }

    @Override
    public Node transform(ExpressionStatementNode expressionStatementNode) {
        ExpressionNode expression = modifyNode(expressionStatementNode.expression());
        Token semicolonToken = modifyToken(expressionStatementNode.semicolonToken());
        return expressionStatementNode.modify(
                expressionStatementNode.kind(),
                expression,
                semicolonToken);
    }

    @Override
    public Node transform(ContinueStatementNode continueStatementNode) {
        Token continueToken = modifyToken(continueStatementNode.continueToken());
        Token semicolonToken = modifyToken(continueStatementNode.semicolonToken());
        return continueStatementNode.modify(
                continueToken,
                semicolonToken);
    }

    @Override
    public Node transform(ExternalFunctionBodyNode externalFunctionBodyNode) {
        Token equalsToken = modifyToken(externalFunctionBodyNode.equalsToken());
        NodeList<AnnotationNode> annotations = modifyNodeList(externalFunctionBodyNode.annotations());
        Token externalKeyword = modifyToken(externalFunctionBodyNode.externalKeyword());
        Token semicolonToken = modifyToken(externalFunctionBodyNode.semicolonToken());
        return externalFunctionBodyNode.modify(
                equalsToken,
                annotations,
                externalKeyword,
                semicolonToken);
    }

    @Override
    public Node transform(IfElseStatementNode ifElseStatementNode) {
        Token ifKeyword = modifyToken(ifElseStatementNode.ifKeyword());
        ExpressionNode condition = modifyNode(ifElseStatementNode.condition());
        Node ifBody = modifyNode(ifElseStatementNode.ifBody());
        Node elseBody = modifyNode(ifElseStatementNode.elseBody());
        return ifElseStatementNode.modify(
                ifKeyword,
                condition,
                ifBody,
                elseBody);
    }

    @Override
    public Node transform(ElseBlockNode elseBlockNode) {
        Token elseKeyword = modifyToken(elseBlockNode.elseKeyword());
        Node elseBody = modifyNode(elseBlockNode.elseBody());
        return elseBlockNode.modify(
                elseKeyword,
                elseBody);
    }

    @Override
    public Node transform(WhileStatementNode whileStatementNode) {
        Token whileKeyword = modifyToken(whileStatementNode.whileKeyword());
        ExpressionNode condition = modifyNode(whileStatementNode.condition());
        Node whileBody = modifyNode(whileStatementNode.whileBody());
        return whileStatementNode.modify(
                whileKeyword,
                condition,
                whileBody);
    }

    @Override
    public Node transform(PanicStatementNode panicStatementNode) {
        Token panicKeyword = modifyToken(panicStatementNode.panicKeyword());
        ExpressionNode expression = modifyNode(panicStatementNode.expression());
        Token semicolonToken = modifyToken(panicStatementNode.semicolonToken());
        return panicStatementNode.modify(
                panicKeyword,
                expression,
                semicolonToken);
    }

    @Override
    public Node transform(ReturnStatementNode returnStatementNode) {
        Token returnKeyword = modifyToken(returnStatementNode.returnKeyword());
        ExpressionNode expression = modifyNode(returnStatementNode.expression());
        Token semicolonToken = modifyToken(returnStatementNode.semicolonToken());
        return returnStatementNode.modify(
                returnKeyword,
                expression,
                semicolonToken);
    }

    @Override
    public Node transform(LocalTypeDefinitionStatementNode localTypeDefinitionStatementNode) {
        NodeList<AnnotationNode> annotations = modifyNodeList(localTypeDefinitionStatementNode.annotations());
        Token typeKeyword = modifyToken(localTypeDefinitionStatementNode.typeKeyword());
        Node typeName = modifyNode(localTypeDefinitionStatementNode.typeName());
        Node typeDescriptor = modifyNode(localTypeDefinitionStatementNode.typeDescriptor());
        Token semicolonToken = modifyToken(localTypeDefinitionStatementNode.semicolonToken());
        return localTypeDefinitionStatementNode.modify(
                annotations,
                typeKeyword,
                typeName,
                typeDescriptor,
                semicolonToken);
    }

    @Override
    public Node transform(BinaryExpressionNode binaryExpressionNode) {
        Node lhsExpr = modifyNode(binaryExpressionNode.lhsExpr());
        Token operator = modifyToken(binaryExpressionNode.operator());
        Node rhsExpr = modifyNode(binaryExpressionNode.rhsExpr());
        return binaryExpressionNode.modify(
                binaryExpressionNode.kind(),
                lhsExpr,
                operator,
                rhsExpr);
    }

    @Override
    public Node transform(BracedExpressionNode bracedExpressionNode) {
        Token openParen = modifyToken(bracedExpressionNode.openParen());
        ExpressionNode expression = modifyNode(bracedExpressionNode.expression());
        Token closeParen = modifyToken(bracedExpressionNode.closeParen());
        return bracedExpressionNode.modify(
                bracedExpressionNode.kind(),
                openParen,
                expression,
                closeParen);
    }

    @Override
    public Node transform(CheckExpressionNode checkExpressionNode) {
        Token checkKeyword = modifyToken(checkExpressionNode.checkKeyword());
        ExpressionNode expression = modifyNode(checkExpressionNode.expression());
        return checkExpressionNode.modify(
                checkKeyword,
                expression);
    }

    @Override
    public Node transform(FieldAccessExpressionNode fieldAccessExpressionNode) {
        ExpressionNode expression = modifyNode(fieldAccessExpressionNode.expression());
        Token dotToken = modifyToken(fieldAccessExpressionNode.dotToken());
        Token fieldName = modifyToken(fieldAccessExpressionNode.fieldName());
        return fieldAccessExpressionNode.modify(
                expression,
                dotToken,
                fieldName);
    }

    @Override
    public Node transform(FunctionCallExpressionNode functionCallExpressionNode) {
        Node functionName = modifyNode(functionCallExpressionNode.functionName());
        Token openParenToken = modifyToken(functionCallExpressionNode.openParenToken());
        NodeList<FunctionArgumentNode> arguments = modifyNodeList(functionCallExpressionNode.arguments());
        Token closeParenToken = modifyToken(functionCallExpressionNode.closeParenToken());
        return functionCallExpressionNode.modify(
                functionName,
                openParenToken,
                arguments,
                closeParenToken);
    }

    @Override
    public Node transform(MethodCallExpressionNode methodCallExpressionNode) {
        ExpressionNode expression = modifyNode(methodCallExpressionNode.expression());
        Token dotToken = modifyToken(methodCallExpressionNode.dotToken());
        Token methodName = modifyToken(methodCallExpressionNode.methodName());
        Token openParenToken = modifyToken(methodCallExpressionNode.openParenToken());
        NodeList<FunctionArgumentNode> arguments = modifyNodeList(methodCallExpressionNode.arguments());
        Token closeParenToken = modifyToken(methodCallExpressionNode.closeParenToken());
        return methodCallExpressionNode.modify(
                expression,
                dotToken,
                methodName,
                openParenToken,
                arguments,
                closeParenToken);
    }

    @Override
    public Node transform(MappingConstructorExpressionNode mappingConstructorExpressionNode) {
        Token openBrace = modifyToken(mappingConstructorExpressionNode.openBrace());
        NodeList<MappingFieldNode> fields = modifyNodeList(mappingConstructorExpressionNode.fields());
        Token closeBrace = modifyToken(mappingConstructorExpressionNode.closeBrace());
        return mappingConstructorExpressionNode.modify(
                openBrace,
                fields,
                closeBrace);
    }

    @Override
    public Node transform(MemberAccessExpressionNode memberAccessExpressionNode) {
        ExpressionNode containerExpression = modifyNode(memberAccessExpressionNode.containerExpression());
        Token openBracket = modifyToken(memberAccessExpressionNode.openBracket());
        ExpressionNode keyExpression = modifyNode(memberAccessExpressionNode.keyExpression());
        Token closeBracket = modifyToken(memberAccessExpressionNode.closeBracket());
        return memberAccessExpressionNode.modify(
                containerExpression,
                openBracket,
                keyExpression,
                closeBracket);
    }

    @Override
    public Node transform(TypeofExpressionNode typeofExpressionNode) {
        Token typeofKeyword = modifyToken(typeofExpressionNode.typeofKeyword());
        ExpressionNode expression = modifyNode(typeofExpressionNode.expression());
        return typeofExpressionNode.modify(
                typeofKeyword,
                expression);
    }

    @Override
    public Node transform(UnaryExpressionNode unaryExpressionNode) {
        Token unaryOperator = modifyToken(unaryExpressionNode.unaryOperator());
        ExpressionNode expression = modifyNode(unaryExpressionNode.expression());
        return unaryExpressionNode.modify(
                unaryOperator,
                expression);
    }

    @Override
    public Node transform(ComputedNameFieldNode computedNameFieldNode) {
        Token leadingComma = modifyToken(computedNameFieldNode.leadingComma());
        Token openBracket = modifyToken(computedNameFieldNode.openBracket());
        ExpressionNode fieldNameExpr = modifyNode(computedNameFieldNode.fieldNameExpr());
        Token closeBracket = modifyToken(computedNameFieldNode.closeBracket());
        Token colonToken = modifyToken(computedNameFieldNode.colonToken());
        ExpressionNode valueExpr = modifyNode(computedNameFieldNode.valueExpr());
        return computedNameFieldNode.modify(
                leadingComma,
                openBracket,
                fieldNameExpr,
                closeBracket,
                colonToken,
                valueExpr);
    }

    @Override
    public Node transform(ConstantDeclarationNode constantDeclarationNode) {
        MetadataNode metadata = modifyNode(constantDeclarationNode.metadata());
        Token visibilityQualifier = modifyToken(constantDeclarationNode.visibilityQualifier());
        Token constKeyword = modifyToken(constantDeclarationNode.constKeyword());
        Node typeDescriptor = modifyNode(constantDeclarationNode.typeDescriptor());
        Token variableName = modifyToken(constantDeclarationNode.variableName());
        Token equalsToken = modifyToken(constantDeclarationNode.equalsToken());
        Node initializer = modifyNode(constantDeclarationNode.initializer());
        Token semicolonToken = modifyToken(constantDeclarationNode.semicolonToken());
        return constantDeclarationNode.modify(
                metadata,
                visibilityQualifier,
                constKeyword,
                typeDescriptor,
                variableName,
                equalsToken,
                initializer,
                semicolonToken);
    }

    @Override
    public Node transform(DefaultableParameterNode defaultableParameterNode) {
        Token leadingComma = modifyToken(defaultableParameterNode.leadingComma());
        NodeList<AnnotationNode> annotations = modifyNodeList(defaultableParameterNode.annotations());
        Token visibilityQualifier = modifyToken(defaultableParameterNode.visibilityQualifier());
        Node type = modifyNode(defaultableParameterNode.type());
        Token paramName = modifyToken(defaultableParameterNode.paramName());
        Token equalsToken = modifyToken(defaultableParameterNode.equalsToken());
        Node expression = modifyNode(defaultableParameterNode.expression());
        return defaultableParameterNode.modify(
                leadingComma,
                annotations,
                visibilityQualifier,
                type,
                paramName,
                equalsToken,
                expression);
    }

    @Override
    public Node transform(RequiredParameterNode requiredParameterNode) {
        Token leadingComma = modifyToken(requiredParameterNode.leadingComma());
        NodeList<AnnotationNode> annotations = modifyNodeList(requiredParameterNode.annotations());
        Token visibilityQualifier = modifyToken(requiredParameterNode.visibilityQualifier());
        Node type = modifyNode(requiredParameterNode.type());
        Token paramName = modifyToken(requiredParameterNode.paramName());
        return requiredParameterNode.modify(
                leadingComma,
                annotations,
                visibilityQualifier,
                type,
                paramName);
    }

    @Override
    public Node transform(RestParameterNode restParameterNode) {
        Token leadingComma = modifyToken(restParameterNode.leadingComma());
        NodeList<AnnotationNode> annotations = modifyNodeList(restParameterNode.annotations());
        Node type = modifyNode(restParameterNode.type());
        Token ellipsisToken = modifyToken(restParameterNode.ellipsisToken());
        Token paramName = modifyToken(restParameterNode.paramName());
        return restParameterNode.modify(
                leadingComma,
                annotations,
                type,
                ellipsisToken,
                paramName);
    }

    @Override
    public Node transform(ExpressionListItemNode expressionListItemNode) {
        Token leadingComma = modifyToken(expressionListItemNode.leadingComma());
        ExpressionNode expression = modifyNode(expressionListItemNode.expression());
        return expressionListItemNode.modify(
                leadingComma,
                expression);
    }

    @Override
    public Node transform(ImportOrgNameNode importOrgNameNode) {
        Token orgName = modifyToken(importOrgNameNode.orgName());
        Token slashToken = modifyToken(importOrgNameNode.slashToken());
        return importOrgNameNode.modify(
                orgName,
                slashToken);
    }

    @Override
    public Node transform(ImportPrefixNode importPrefixNode) {
        Token asKeyword = modifyToken(importPrefixNode.asKeyword());
        Token prefix = modifyToken(importPrefixNode.prefix());
        return importPrefixNode.modify(
                asKeyword,
                prefix);
    }

    @Override
    public Node transform(ImportSubVersionNode importSubVersionNode) {
        Token leadingDot = modifyToken(importSubVersionNode.leadingDot());
        Token versionNumber = modifyToken(importSubVersionNode.versionNumber());
        return importSubVersionNode.modify(
                leadingDot,
                versionNumber);
    }

    @Override
    public Node transform(ImportVersionNode importVersionNode) {
        Token versionKeyword = modifyToken(importVersionNode.versionKeyword());
        Node versionNumber = modifyNode(importVersionNode.versionNumber());
        return importVersionNode.modify(
                versionKeyword,
                versionNumber);
    }

    @Override
    public Node transform(SubModuleNameNode subModuleNameNode) {
        Token leadingDot = modifyToken(subModuleNameNode.leadingDot());
        IdentifierToken moduleName = modifyNode(subModuleNameNode.moduleName());
        return subModuleNameNode.modify(
                leadingDot,
                moduleName);
    }

    @Override
    public Node transform(SpecificFieldNode specificFieldNode) {
        Token leadingComma = modifyToken(specificFieldNode.leadingComma());
        IdentifierToken fieldName = modifyNode(specificFieldNode.fieldName());
        Token colon = modifyToken(specificFieldNode.colon());
        ExpressionNode valueExpr = modifyNode(specificFieldNode.valueExpr());
        return specificFieldNode.modify(
                leadingComma,
                fieldName,
                colon,
                valueExpr);
    }

    @Override
    public Node transform(SpreadFieldNode spreadFieldNode) {
        Token leadingComma = modifyToken(spreadFieldNode.leadingComma());
        Token ellipsis = modifyToken(spreadFieldNode.ellipsis());
        ExpressionNode valueExpr = modifyNode(spreadFieldNode.valueExpr());
        return spreadFieldNode.modify(
                leadingComma,
                ellipsis,
                valueExpr);
    }

    @Override
    public Node transform(NamedArgumentNode namedArgumentNode) {
        Token leadingComma = modifyToken(namedArgumentNode.leadingComma());
        Token argumentName = modifyToken(namedArgumentNode.argumentName());
        Token equalsToken = modifyToken(namedArgumentNode.equalsToken());
        ExpressionNode expression = modifyNode(namedArgumentNode.expression());
        return namedArgumentNode.modify(
                leadingComma,
                argumentName,
                equalsToken,
                expression);
    }

    @Override
    public Node transform(PositionalArgumentNode positionalArgumentNode) {
        Token leadingComma = modifyToken(positionalArgumentNode.leadingComma());
        ExpressionNode expression = modifyNode(positionalArgumentNode.expression());
        return positionalArgumentNode.modify(
                leadingComma,
                expression);
    }

    @Override
    public Node transform(RestArgumentNode restArgumentNode) {
        Token leadingComma = modifyToken(restArgumentNode.leadingComma());
        Token ellipsis = modifyToken(restArgumentNode.ellipsis());
        ExpressionNode expression = modifyNode(restArgumentNode.expression());
        return restArgumentNode.modify(
                leadingComma,
                ellipsis,
                expression);
    }

    @Override
    public Node transform(ObjectTypeDescriptorNode objectTypeDescriptorNode) {
        NodeList<Token> objectTypeQualifiers = modifyNodeList(objectTypeDescriptorNode.objectTypeQualifiers());
        Token objectKeyword = modifyToken(objectTypeDescriptorNode.objectKeyword());
        Token openBrace = modifyToken(objectTypeDescriptorNode.openBrace());
        NodeList<Node> members = modifyNodeList(objectTypeDescriptorNode.members());
        Token closeBrace = modifyToken(objectTypeDescriptorNode.closeBrace());
        return objectTypeDescriptorNode.modify(
                objectTypeQualifiers,
                objectKeyword,
                openBrace,
                members,
                closeBrace);
    }

    @Override
    public Node transform(RecordTypeDescriptorNode recordTypeDescriptorNode) {
        Token objectKeyword = modifyToken(recordTypeDescriptorNode.objectKeyword());
        Token bodyStartDelimiter = modifyToken(recordTypeDescriptorNode.bodyStartDelimiter());
        NodeList<Node> fields = modifyNodeList(recordTypeDescriptorNode.fields());
        Token bodyEndDelimiter = modifyToken(recordTypeDescriptorNode.bodyEndDelimiter());
        return recordTypeDescriptorNode.modify(
                objectKeyword,
                bodyStartDelimiter,
                fields,
                bodyEndDelimiter);
    }

    @Override
    public Node transform(ReturnTypeDescriptorNode returnTypeDescriptorNode) {
        Token returnsKeyword = modifyToken(returnTypeDescriptorNode.returnsKeyword());
        NodeList<AnnotationNode> annotations = modifyNodeList(returnTypeDescriptorNode.annotations());
        Node type = modifyNode(returnTypeDescriptorNode.type());
        return returnTypeDescriptorNode.modify(
                returnsKeyword,
                annotations,
                type);
    }

    @Override
    public Node transform(NilTypeDescriptorNode nilTypeDescriptorNode) {
        Token openParenToken = modifyToken(nilTypeDescriptorNode.openParenToken());
        Token closeParenToken = modifyToken(nilTypeDescriptorNode.closeParenToken());
        return nilTypeDescriptorNode.modify(
                openParenToken,
                closeParenToken);
    }

    @Override
    public Node transform(OptionalTypeDescriptorNode optionalTypeDescriptorNode) {
        Node typeDescriptor = modifyNode(optionalTypeDescriptorNode.typeDescriptor());
        Token questionMarkToken = modifyToken(optionalTypeDescriptorNode.questionMarkToken());
        return optionalTypeDescriptorNode.modify(
                typeDescriptor,
                questionMarkToken);
    }

    @Override
    public Node transform(ObjectFieldNode objectFieldNode) {
        MetadataNode metadata = modifyNode(objectFieldNode.metadata());
        Token visibilityQualifier = modifyToken(objectFieldNode.visibilityQualifier());
        Node type = modifyNode(objectFieldNode.type());
        Token fieldName = modifyToken(objectFieldNode.fieldName());
        Token equalsToken = modifyToken(objectFieldNode.equalsToken());
        ExpressionNode expression = modifyNode(objectFieldNode.expression());
        Token semicolonToken = modifyToken(objectFieldNode.semicolonToken());
        return objectFieldNode.modify(
                metadata,
                visibilityQualifier,
                type,
                fieldName,
                equalsToken,
                expression,
                semicolonToken);
    }

    @Override
    public Node transform(RecordFieldNode recordFieldNode) {
        MetadataNode metadata = modifyNode(recordFieldNode.metadata());
        Node type = modifyNode(recordFieldNode.type());
        Token fieldName = modifyToken(recordFieldNode.fieldName());
        Token questionMarkToken = modifyToken(recordFieldNode.questionMarkToken());
        Token semicolonToken = modifyToken(recordFieldNode.semicolonToken());
        return recordFieldNode.modify(
                metadata,
                type,
                fieldName,
                questionMarkToken,
                semicolonToken);
    }

    @Override
    public Node transform(RecordFieldWithDefaultValueNode recordFieldWithDefaultValueNode) {
        MetadataNode metadata = modifyNode(recordFieldWithDefaultValueNode.metadata());
        Node type = modifyNode(recordFieldWithDefaultValueNode.type());
        Token fieldName = modifyToken(recordFieldWithDefaultValueNode.fieldName());
        Token equalsToken = modifyToken(recordFieldWithDefaultValueNode.equalsToken());
        ExpressionNode expression = modifyNode(recordFieldWithDefaultValueNode.expression());
        Token semicolonToken = modifyToken(recordFieldWithDefaultValueNode.semicolonToken());
        return recordFieldWithDefaultValueNode.modify(
                metadata,
                type,
                fieldName,
                equalsToken,
                expression,
                semicolonToken);
    }

    @Override
    public Node transform(RecordRestDescriptorNode recordRestDescriptorNode) {
        Node type = modifyNode(recordRestDescriptorNode.type());
        Token ellipsisToken = modifyToken(recordRestDescriptorNode.ellipsisToken());
        Token semicolonToken = modifyToken(recordRestDescriptorNode.semicolonToken());
        return recordRestDescriptorNode.modify(
                type,
                ellipsisToken,
                semicolonToken);
    }

    @Override
    public Node transform(TypeReferenceNode typeReferenceNode) {
        Token asteriskToken = modifyToken(typeReferenceNode.asteriskToken());
        Node type = modifyNode(typeReferenceNode.type());
        Token semicolonToken = modifyToken(typeReferenceNode.semicolonToken());
        return typeReferenceNode.modify(
                asteriskToken,
                type,
                semicolonToken);
    }

    @Override
    public Node transform(QualifiedIdentifierNode qualifiedIdentifierNode) {
        Token modulePrefix = modifyToken(qualifiedIdentifierNode.modulePrefix());
        Node colon = modifyNode(qualifiedIdentifierNode.colon());
        IdentifierToken identifier = modifyNode(qualifiedIdentifierNode.identifier());
        return qualifiedIdentifierNode.modify(
                modulePrefix,
                colon,
                identifier);
    }

    @Override
    public Node transform(ServiceBodyNode serviceBodyNode) {
        Token openBraceToken = modifyToken(serviceBodyNode.openBraceToken());
        NodeList<Node> resources = modifyNodeList(serviceBodyNode.resources());
        Token closeBraceToken = modifyToken(serviceBodyNode.closeBraceToken());
        return serviceBodyNode.modify(
                openBraceToken,
                resources,
                closeBraceToken);
    }

    @Override
    public Node transform(AnnotationNode annotationNode) {
        Token atToken = modifyToken(annotationNode.atToken());
        Node annotReference = modifyNode(annotationNode.annotReference());
        MappingConstructorExpressionNode annotValue = modifyNode(annotationNode.annotValue());
        return annotationNode.modify(
                atToken,
                annotReference,
                annotValue);
    }

    @Override
    public Node transform(MetadataNode metadataNode) {
        Node documentationString = modifyNode(metadataNode.documentationString());
        NodeList<AnnotationNode> annotations = modifyNodeList(metadataNode.annotations());
        return metadataNode.modify(
                documentationString,
                annotations);
    }

    @Override
    public Node transform(ModuleVariableDeclarationNode moduleVariableDeclarationNode) {
        MetadataNode metadata = modifyNode(moduleVariableDeclarationNode.metadata());
        Token finalKeyword = modifyToken(moduleVariableDeclarationNode.finalKeyword());
        Node typeName = modifyNode(moduleVariableDeclarationNode.typeName());
        Token variableName = modifyToken(moduleVariableDeclarationNode.variableName());
        Token equalsToken = modifyToken(moduleVariableDeclarationNode.equalsToken());
        ExpressionNode initializer = modifyNode(moduleVariableDeclarationNode.initializer());
        Token semicolonToken = modifyToken(moduleVariableDeclarationNode.semicolonToken());
        return moduleVariableDeclarationNode.modify(
                metadata,
                finalKeyword,
                typeName,
                variableName,
                equalsToken,
                initializer,
                semicolonToken);
    }

    @Override
    public Node transform(IsExpressionNode isExpressionNode) {
        ExpressionNode expression = modifyNode(isExpressionNode.expression());
        Token isKeyword = modifyToken(isExpressionNode.isKeyword());
        Node typeDescriptor = modifyNode(isExpressionNode.typeDescriptor());
        return isExpressionNode.modify(
                expression,
                isKeyword,
                typeDescriptor);
    }

    @Override
    public Node transform(ArrayTypeDescriptorNode arrayTypeDescriptorNode) {
        Node typeDescriptorNode = modifyNode(arrayTypeDescriptorNode.typeDescriptorNode());
        Token openBracketToken = modifyToken(arrayTypeDescriptorNode.openBracketToken());
        Node arrayLengthNode = modifyNode(arrayTypeDescriptorNode.arrayLengthNode());
        Token closeBracketToken = modifyToken(arrayTypeDescriptorNode.closeBracketToken());
        return arrayTypeDescriptorNode.modify(
                typeDescriptorNode,
                openBracketToken,
                arrayLengthNode,
                closeBracketToken);
    }

    @Override
    public Node transform(RemoteMethodCallActionNode remoteMethodCallActionNode) {
        ExpressionNode expression = modifyNode(remoteMethodCallActionNode.expression());
        Token rightArrowToken = modifyToken(remoteMethodCallActionNode.rightArrowToken());
        Token methodName = modifyToken(remoteMethodCallActionNode.methodName());
        Token openParenToken = modifyToken(remoteMethodCallActionNode.openParenToken());
        NodeList<FunctionArgumentNode> arguments = modifyNodeList(remoteMethodCallActionNode.arguments());
        Token closeParenToken = modifyToken(remoteMethodCallActionNode.closeParenToken());
        return remoteMethodCallActionNode.modify(
                expression,
                rightArrowToken,
                methodName,
                openParenToken,
                arguments,
                closeParenToken);
    }

    // Tokens

    @Override
    public Node transform(Token token) {
        return token;
    }

    @Override
    public Node transform(IdentifierToken identifier) {
        return identifier;
    }

    @Override
    public Node transform(EmptyToken emptyToken) {
        return emptyToken;
    }

    @Override
    protected Node transformSyntaxNode(Node node) {
        return node;
    }

    protected <T extends Node> NodeList<T> modifyNodeList(NodeList<T> nodeList) {
        if (nodeList.isEmpty()) {
            return nodeList;
        }

        boolean nodeModified = false;
        STNode[] newSTNodes = new STNode[nodeList.size()];
        for (int index = 0; index < nodeList.size(); index++) {
            T oldNode = nodeList.get(index);
            T newNode = modifyNode(oldNode);
            if (oldNode != newNode) {
                nodeModified = true;
            }
            newSTNodes[index] = newNode.internalNode();
        }

        if (!nodeModified) {
            return nodeList;
        }

        STNode stNodeList = STNodeFactory.createNodeList(java.util.Arrays.asList(newSTNodes));
        return new NodeList<>(stNodeList.createUnlinkedFacade());
    }

    protected <T extends Token> T modifyToken(T token) {
        // TODO
        return (T) token.apply(this);
    }

    protected <T extends Node> T modifyNode(T node) {
        // TODO
        return (T) node.apply(this);
    }
}

