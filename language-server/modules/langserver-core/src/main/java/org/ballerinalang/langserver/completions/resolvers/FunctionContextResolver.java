/*
*  Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package org.ballerinalang.langserver.completions.resolvers;

import org.antlr.v4.runtime.ParserRuleContext;
import org.ballerinalang.langserver.compiler.LSServiceOperationContext;
import org.ballerinalang.langserver.completions.CompletionKeys;
import org.ballerinalang.langserver.completions.util.CompletionItemResolver;
import org.ballerinalang.langserver.completions.util.ItemResolverConstants;
import org.ballerinalang.langserver.completions.util.Snippet;
import org.eclipse.lsp4j.CompletionItem;

import java.util.ArrayList;
import java.util.List;

/**
 * Completion Item resolver for the BLangFunction context.
 */
public class FunctionContextResolver extends AbstractItemResolver {
    @Override
    public List<CompletionItem> resolveItems(LSServiceOperationContext context) {
        ParserRuleContext parserRuleContext = context.get(CompletionKeys.PARSER_RULE_CONTEXT_KEY);
        boolean isSnippet = context.get(CompletionKeys.CLIENT_CAPABILITIES_KEY).getCompletionItem().getSnippetSupport();
        if (parserRuleContext == null) {
            List<CompletionItem> completionItems = new ArrayList<>();
            CompletionItem workerItem = new CompletionItem();
            workerItem.setLabel(ItemResolverConstants.WORKER);
            Snippet.DEF_WORKER.getBlock().populateCompletionItem(workerItem, isSnippet);
            workerItem.setDetail(ItemResolverConstants.SNIPPET_TYPE);

            CompletionItem endpointItem = new CompletionItem();
            endpointItem.setLabel(ItemResolverConstants.ENDPOINT);
            Snippet.DEF_ENDPOINT.getBlock().populateCompletionItem(endpointItem, isSnippet);
            endpointItem.setDetail(ItemResolverConstants.SNIPPET_TYPE);

            completionItems.add(workerItem);
            completionItems.add(endpointItem);

            return completionItems;
        }
        AbstractItemResolver contextResolver = CompletionItemResolver.getResolverByClass(parserRuleContext.getClass());

        if (contextResolver == null) {
            return new ArrayList<>();
        }
        
        return contextResolver.resolveItems(context);
    }
}
