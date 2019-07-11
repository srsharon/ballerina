import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';

import { BallerinaExtension, ExtendedLangClient } from '../core/index';
import { ProjectTreeElement } from './project-tree';

/**
 * This class will provide Tree Data required to draw the Ballerina Project Overview 
 * on the explorer panel. 
 */
export class ProjectTreeProvider implements vscode.TreeDataProvider<ProjectTreeElement> {

    private _onDidChangeTreeData: vscode.EventEmitter<ProjectTreeElement | undefined> = new vscode.EventEmitter<ProjectTreeElement | undefined>();
    readonly onDidChangeTreeData: vscode.Event<ProjectTreeElement | undefined> = this._onDidChangeTreeData.event;
    private langClient?: ExtendedLangClient;
    private sourceRoot?: string;
    private balProjectTree: TreeStructure = {};

    constructor(context: BallerinaExtension) {
        if (vscode.window.activeTextEditor) {
            const currentUri = vscode.window.activeTextEditor.document.fileName;

            this.langClient = context.langClient;
            this.sourceRoot = this.getSourceRoot(currentUri, path.parse(currentUri).root);

            this._onDidChangeTreeData.fire();
        }
    }

    refresh(): void {
		this._onDidChangeTreeData.fire();
	}

    getTreeItem(element: ProjectTreeElement): vscode.TreeItem | Thenable<vscode.TreeItem> {
        return element;
    }

    getChildren(element?: ProjectTreeElement | undefined): vscode.ProviderResult<ProjectTreeElement[]> {
        if (!element) {
            return this.getProjectStructure();
        } else {
            return this.getTreeEl(element);
        }
    }

    private getProjectStructure(): Promise<any> {
        return new Promise<any>(resolve => {
            if (this.langClient && this.sourceRoot) {
                this.langClient.getProjectAST(vscode.Uri.file(this.sourceRoot).toString()).then((result: any) => {
                    if (result.modules) {
                        let treeNode: ProjectTreeElement[] = [];
                        this.balProjectTree = this.buildProjectTree(result.modules);
                        Object.keys(this.balProjectTree).map((node: any) => {
                            treeNode.push(new ProjectTreeElement(node,1));
                        });
                        treeNode.sort((node1, node2) => node1.label.localeCompare(node2.label));
                        resolve(treeNode);
                    }
                });
            }
        });
    }

    private buildProjectTree(treeItem: any): TreeStructure {
        let projectTree: TreeStructure = {};
        Object.keys(treeItem).map(item => {
            if (treeItem[item].hasOwnProperty("compilationUnits")) {
                projectTree[item] = this.buildProjectTree(treeItem[item].compilationUnits);
            } else if (treeItem[item].hasOwnProperty("ast")) {
                let nodes = treeItem[item].ast.topLevelNodes;
                nodes.map((node: any) => {
                    if (node.kind === "Service") {
                        let resources: TreeStructure = {};
                        if (node.resources && node.resources.length > 0) {
                            node.resources.map((res: any) => {
                                Object.defineProperty(resources, res.name.value, {
                                    writable: true,
                                    enumerable: true,
                                    configurable: true
                                });
                            });
                        }
                        projectTree[node.name.value] = resources;
                    }

                    if (node.kind === "Function") {
                        Object.defineProperty(projectTree, node.name.value, {
                            writable: true,
                            enumerable: true,
                            configurable: true
                        });
                    } 
                });
            }
        });
        return projectTree;
    }

    private getTreeEl(parentEl: ProjectTreeElement): ProjectTreeElement[] {
        let projectTree = this.balProjectTree;
        let elementTree: ProjectTreeElement[] = [];

        Object.keys(projectTree).map((key) => {
            let element = projectTree[key];
            if (key === parentEl.label) {
                Object.keys(element).map(child => {
                    elementTree.push(new ProjectTreeElement(child,1,{
                        command: "ballerina.executeTreeElement",
                        title: "Execute Tree Command",
                        arguments: [child]
                    }));
                });
            } else {
                let treeObj = this.getTreeForKey(element, parentEl.label);
                Object.keys(treeObj).map(child => {
                    elementTree.push(new ProjectTreeElement(child,1,{
                        command: "ballerina.executeTreeElement",
                        title: "Execute Tree Command",
                        arguments: [child]
                    }));
                });
            }
        });

        return elementTree;
    }

    private getTreeForKey(obj: any, searchKey: string): any {
        let matchedObjTree = {};
        Object.keys(obj).map(key => {
            if (key === searchKey && obj[searchKey] !== undefined) {
                matchedObjTree = obj[searchKey];
            }
        });
        return matchedObjTree;
    }

    /**
     * Util method to get Ballerina project root.
     * 
     * @param currentPath - current active path
     * @param root - root path
     */
    private getSourceRoot(currentPath: string, root: string): string|undefined {
        if (fs.existsSync(path.join(currentPath, '.ballerina'))) {
            if (currentPath !== os.homedir()) {
                return currentPath;
            }
        }
    
        if (currentPath === root) {
            return;
        }
    
        return this.getSourceRoot(path.dirname(currentPath), root);
    }
    
}

interface TreeStructure {
    [key: string]: any;
}